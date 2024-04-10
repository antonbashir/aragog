local fio = require("fio")

return function(moduleName)
    if not fio.path.exists("modules/" .. moduleName) then
        return
    end

    local modulePath = "modules" .. "." .. moduleName
    package.loaded[modulePath] = nil
    local loadedModule = require(modulePath)
    modules[moduleName] = loadedModule
    loadedModule.load()

    local serviceFiles = fio.listdir("modules/" .. moduleName .. "/services")
    if not serviceFiles then
        return
    end

    for _, serviceFile in pairs(fio.listdir("modules/" .. moduleName .. "/services")) do
        local serviceName = string.gsub(serviceFile, ".lua", "")
        local path = modulePath .. "." .. "services" .. "." .. serviceName
        for name, _ in pairs(package.loaded) do
            if string.find(name, '^modules.' .. moduleName .. ".") ~= nil then
                package.loaded[name] = nil
            end
        end
        local service = require(path)
        services[serviceName] = service
        for functionName, _ in pairs(service) do
            box.schema.func.create("services." .. serviceName .. '.' .. functionName, { if_not_exists = true })
        end
    end
end
