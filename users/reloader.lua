local configuration = require("configuration")

box.once("initialize-reloader-user", function()
  box.schema.user.create(configuration.reloader.user, { password = configuration.reloader.password })
  box.schema.user.grant(configuration.reloader.user, 'execute', 'function', 'reload')
  box.schema.user.grant(configuration.reloader.user, 'create,drop,read,write', 'universe', nil)
end)
