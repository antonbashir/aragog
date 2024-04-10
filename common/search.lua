local search = function(request)
  local offset = request.offset
  local limit = request.limit
  local object = request.object
  local key = request.key
  local predicate = request.predicate
  local mapper = request.mapper
  local last = request.last
  local id = request.id

  local entities = {}

  local count = 0
  local index = 0

  if last ~= nil and id ~= nil then
    local found = {}
    for _, entity in object:pairs(key) do
      if index >= offset then
        if count >= limit then
          break
        end
        if not found[id(entity)] then
          entity = last(id(entity))
          if (predicate == nil or predicate(entity)) then
            if mapper ~= nil then
              entity = mapper(entity)
            end
            table.insert(entities, entity)
            found[id(entity)] = true
            count = count + 1
          end
        end
      end
      index = index + 1
    end
    return entities
  end

  for _, entity in object:pairs(key) do
    if index >= offset then
      if count >= limit then
        break
      end
      if predicate == nil or predicate(entity) then
        if mapper ~= nil then
          entity = mapper(entity)
        end
        table.insert(entities, entity)
        count = count + 1
      end
    end
    index = index + 1
  end

  return entities
end

return function(request)
  if request.atomic then return search(request) end
  return box.atomic(search)(request)
end
