-- a json parser from a filename
local json = require("vendor/json")

local function loadCreature(filename)
    local file, err = io.open(filename, "r")
    if not file then
        return nil, err
    end

    local content = file:read("*a")
    file:close()

    local data, err = json.decode(content)
    if err then
        return nil, err
    end

    return data
end

local function saveCreature(filename, data)
    local file, err = io.open(filename, "w")
    if not file then
        return nil, err
    end

    local content = json.encode(data)
    file:write(content)
    file:close()

    return true
end

return {
    loadCreature = loadCreature,
    saveCreature = saveCreature
}
