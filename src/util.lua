local util = {}

function util.find(table, target)
    for i, val in ipairs(table) do
        if val == target then
            return i
        end
    end
    return -1
end

return util
