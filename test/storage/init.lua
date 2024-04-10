local function load()
  require("log").info("Module 'test' loading started")
  require("modules.test.initialization.schema")
  require("modules.test.initialization.defaults")
  require("modules.test.migrations")
  require("log").info("Module 'test' loading finished")
end

local function clear()
  box.space["test"]:truncate()
end

return {
  load = load,
  clear = clear
}
