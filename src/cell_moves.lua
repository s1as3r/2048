local util = require("util")

local cell_moves = {}

function cell_moves.moveRight(cells)
    local score = 0;

    for _, row in ipairs(cells) do
        local toMerge = {}
        for j = 1, #row - 1 do
            if row[j] ~= 0 and row[j + 1] == 0 then
                row[j + 1] = row[j]
                row[j] = 0
            end
        end

        for j = 1, #row - 1 do
            if row[j] ~= 0 and row[j] == row[j + 1] then
                table.insert(toMerge, j)
            end
        end

        for _, j in ipairs(toMerge) do
            if util.find(toMerge, j + 1) == -1 then
                score = score + row[j]
                row[j + 1] = 2 * row[j + 1]
                row[j] = 0
            end
        end

        for j = 1, #row - 1 do
            if row[j] ~= 0 and row[j + 1] == 0 then
                row[j + 1] = row[j]
                row[j] = 0
            end
        end
    end

    return score
end

function cell_moves.moveLeft(cells)
    local score = 0;

    for _, row in ipairs(cells) do
        local toMerge = {}
        for j = #row, 2, -1 do
            if row[j] ~= 0 and row[j - 1] == 0 then
                row[j - 1] = row[j]
                row[j] = 0
            end
        end

        for j = #row, 2, -1 do
            if row[j] ~= 0 and row[j] == row[j - 1] then
                table.insert(toMerge, j)
            end
        end

        for _, j in ipairs(toMerge) do
            if util.find(toMerge, j - 1) == -1 then
                score = score + row[j]
                row[j - 1] = 2 * row[j - 1]
                row[j] = 0
            end
        end

        for j = #row, 2, -1 do
            if row[j] ~= 0 and row[j - 1] == 0 then
                row[j - 1] = row[j]
                row[j] = 0
            end
        end
    end

    return score
end

function cell_moves.moveUp(cells)
    local score = 0;

    for i = 1, #cells[1] do
        local toMerge = {}

        for j = #cells, 2, -1 do
            if cells[j][i] ~= 0 and cells[j - 1][i] == 0 then
                cells[j - 1][i] = cells[j][i]
                cells[j][i] = 0
            end
        end

        for j = #cells, 2, -1 do
            if cells[j][i] ~= 0 and cells[j][i] == cells[j - 1][i] then
                table.insert(toMerge, j)
            end
        end

        for _, j in ipairs(toMerge) do
            if util.find(toMerge, j - 1) == -1 then
                score = score + cells[j][i]
                cells[j - 1][i] = 2 * cells[j - 1][i]
                cells[j][i] = 0
            end
        end

        for j = #cells, 2, -1 do
            if cells[j][i] ~= 0 and cells[j - 1][i] == 0 then
                cells[j - 1][i] = cells[j][i]
                cells[j][i] = 0
            end
        end
    end

    return score
end

function cell_moves.moveDown(cells)
    local score = 0;

    for i = 1, #cells[1] do
        local toMerge = {}

        for j = 1, #cells - 1 do
            if cells[j][i] ~= 0 and cells[j + 1][i] == 0 then
                cells[j + 1][i] = cells[j][i]
                cells[j][i] = 0
            end
        end

        for j = 1, #cells - 1 do
            if cells[j][i] ~= 0 and cells[j][i] == cells[j + 1][i] then
                table.insert(toMerge, j)
            end
        end

        for _, j in ipairs(toMerge) do
            if util.find(toMerge, j + 1) == -1 then
                score = score + cells[j][j]
                cells[j + 1][i] = 2 * cells[j + 1][i]
                cells[j][i] = 0
            end
        end

        for j = 1, #cells - 1 do
            if cells[j][i] ~= 0 and cells[j + 1][i] == 0 then
                cells[j + 1][i] = cells[j][i]
                cells[j][i] = 0
            end
        end
    end

    return score
end

return cell_moves
