local search = require("common.search")

local service = {}

local space = box.space["test"]

service.put = function(entity)
    return space:put(box.tuple.new(entity))
end

service.count = function()
    return space:count()
end

service.test = function()
    return require("modules.test.constants").value
end

service.findAll = function(offset, limit)
    local searchRequest = {
        offset = offset,
        limit = limit,
        object = space
    }
    return search(searchRequest)
end

return service
