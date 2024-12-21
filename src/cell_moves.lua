local util = require("util")

local cell_moves = {}

local function moveOverEmptyCellsInRow(cells, row, from, to, direction)
    for j = from, to, direction do
        if cells[row][j] ~= 0 then
            local i = j - direction;
            while i > 0 and i <= #cells[row] and cells[row][i] == 0 do
                cells[row][i] = cells[row][i + direction]
                cells[row][i + direction] = 0
                i = i - direction
            end
        end
    end
end

local function moveOverEmptyCellsInCol(cells, col, from, to, direction)
    for j = from, to, direction do
        if cells[j][col] ~= 0 then
            local i = j - direction
            while i > 0 and i <= #cells and cells[i][col] == 0 do
                cells[i][col] = cells[i + direction][col]
                cells[i + direction][col] = 0
                i = i - direction
            end
        end
    end
end

function cell_moves.moveRight(cells)
    local score = 0;

    for i, row in ipairs(cells) do
        local toMerge = {}
        moveOverEmptyCellsInRow(cells, i, #row - 1, 1, -1)

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

        moveOverEmptyCellsInRow(cells, i, #row - 1, 1, -1)
    end

    return score
end

function cell_moves.moveLeft(cells)
    local score = 0;

    for i, row in ipairs(cells) do
        local toMerge = {}
        moveOverEmptyCellsInRow(cells, i, 2, #row, 1)

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

        moveOverEmptyCellsInRow(cells, i, 2, #row, 1)
    end

    return score
end

function cell_moves.moveUp(cells)
    local score = 0;

    for i = 1, #cells[1] do
        local toMerge = {}
        moveOverEmptyCellsInCol(cells, i, 2, #cells, 1)

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

        moveOverEmptyCellsInCol(cells, i, 2, #cells, 1)
    end

    return score
end

function cell_moves.moveDown(cells)
    local score = 0;

    for i = 1, #cells[1] do
        local toMerge = {}
        moveOverEmptyCellsInCol(cells, i, #cells - 1, 1, -1)

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

        moveOverEmptyCellsInCol(cells, i, #cells - 1, 1, -1)
    end

    return score
end

return cell_moves
