return function(newVersion, migrations)
  if box.info.ro then
    return
  end

  require("log").info("Migration started to version " .. newVersion)

  local current = getVersion()

  if current == newVersion then
    require("log").info("Migration finished without changes")
    return
  end

  if newVersion > current then
    for id, script in ipairs(migrations) do
      if id > current and id <= newVersion then
        require(script).upgrade(id)
        setVersion(id)
      end
    end
    require("log").info("Migration done with upgrade from " .. tostring(current) .. " to " .. tostring(newVersion))
    return
  end

  if newVersion < current then
    local id = current - 1
    while id >= newVersion do
      require(migrations[id]).rollback(id)
      setVersion(id)
      id = id - 1
    end
    require("log").info("Migration done with downgrade from " .. tostring(current) .. " to " .. tostring(newVersion))
  end
end
