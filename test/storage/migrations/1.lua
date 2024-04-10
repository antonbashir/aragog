local log = require("log")

local upgrade = function(newVersion)
  log.info("Version migrated from [" .. getVersion() .. "] to [" .. newVersion .. "]")
end

local rollback = function(newVersion)
  log.info("Version migrated from [" .. getVersion() .. "] to [" .. newVersion .. "]")
end

return { upgrade = upgrade, rollback = rollback }
