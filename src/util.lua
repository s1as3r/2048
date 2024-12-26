local util = {}

function util.find(table, target)
    for i, val in ipairs(table) do
        if val == target then
            return i
        end
    end
    return -1
end

function util.getCenter()
    local w, h = love.graphics.getDimensions()
    return math.floor(w / 2), math.floor(h / 2)
end

function util.isInRect(x, y, rect)
    local xWithin = x > rect.x and x < (rect.x + rect.w)
    local yWithin = y > rect.y and y < (rect.y + rect.h)
    return xWithin and yWithin
end

function util.initialCells(rows, cols)
    local cells = {}
    for _ = 1, rows do
        local row = {}
        for _ = 1, cols do
            table.insert(row, 0)
        end
        table.insert(cells, row)
    end

    return cells
end

function util.countChars(str, char)
    local count = 0
    for _ in string.gmatch(str, char) do count = count + 1 end
    return count
end

return util
