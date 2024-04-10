local isMaster = require("common.is-master-handler");
local fio = require("fio")
local configuration = require("configuration")
local httpd = require("http.server");
local reloader = require("common.reloader")
local string = require("string")

metrics = require('metrics')

prometheus = require('metrics.plugins.prometheus')

modules = {}

services = {}

getVersion = function()
  return box.space.version:get("current").value
end

setVersion = function(version)
  return box.space.version:put({ "current", version })
end

migrate = function(newVersion, migrations)
  require("migrate")(newVersion, migrations)
end

isAlive = function()
  return box.info.status == "running"
end

reload = function(request)
  local module = request["module"]
  local files = request["files"]
  for file, content in pairs(files) do
    local parts = string.split(file, "/", 64)
    if #parts > 1 then
      parts[#parts] = nil
      fio.mktree('modules/' .. table.concat(parts, "/"))
    end
    local handle = fio.open('modules/' .. file, { 'O_RDWR', 'O_CREAT', 'O_TRUNC' })
    if handle ~= nil then
      handle:write(content)
      fio.sync()
      handle:close()
    end
  end
  reloader(module)
end

if configuration.environment == "test" or configuration.environment == "local" then
  truncate = function()
    for _, loadedModule in pairs(modules) do
      loadedModule.clear()
    end
  end
end


return function(module)
  if configuration.modules[module].directory ~= nil then
    fio.mktree(configuration.modules[module].directory)
    configuration.modules[module].box.memtx_dir = configuration.modules[module].directory
    configuration.modules[module].box.wal_dir = configuration.modules[module].directory
  end

  box.cfg(configuration.modules[module].box)
  require("users.modules")
  box.ctl.promote()
  require("initialization.version")
  metrics.enable_default_metrics()

  box.schema.func.create("isAlive", { if_not_exists = true })

  box.schema.func.create("reload", { if_not_exists = true })
  require("users.reloader")

  local httpServer = httpd.new("0.0.0.0", configuration.modules[module].http.port, {
    app_dir = configuration.modules[module].box.memtx_dir
  })
  httpServer:route({ path = "/isMaster", method = "GET" }, isMaster)
  httpServer:route({ path = '/metrics' }, prometheus.collect_http)
  httpServer:start()

  if configuration.mode == "test" or configuration.environment == "local" then
    box.schema.func.create("truncate", { if_not_exists = true })
  end

  if configuration.environment == "local" and configuration.console ~= false then
    require('console').start()
  end
end
