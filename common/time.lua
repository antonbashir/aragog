local clock = require("clock")
return function()
    return clock.time() * 1000
end
