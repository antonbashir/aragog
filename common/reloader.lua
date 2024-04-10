local configuration = require("configuration")

local loadModule = require("common.load-module")

return function(module)
  --  box.atomic(function()
  require("log").info("Reloading started")
  package.loaded["modules"] = nil
  loadModule(module)
  if configuration.environment == "test" or configuration.environment == "local" then
    local dependencies = configuration.modules[module].dependencies
    if dependencies ~= nil then
      for _, dependency in pairs(dependencies) do
        loadModule(dependency)
      end
    end
  end
  require("log").info("Reloading finished")
  --  end)
end
