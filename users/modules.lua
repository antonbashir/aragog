local configuration = require("configuration")

for name, module in pairs(configuration.modules) do
  box.once("initialize-user-" .. name, function()
    box.schema.user.create(module.user, { password = module.password })
    box.schema.user.grant(module.user, 'read,write,create,alter,drop,execute,session', 'universe', nil)
  end)
end
