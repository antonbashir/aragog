return function(request)
    if box.info.ro then
        return { status = 500 }
    end
    return { status = 200 }
end
