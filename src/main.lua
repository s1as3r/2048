local cmove = require("cell_moves")

local function initialCells(rows, cols)
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

local function getCellsCopy()
    local cells = initialCells(ROWS, COLS)
    for i = 1, ROWS do
        for j = 1, COLS do
            cells[i][j] = GAME_STATE.cells[i][j]
        end
    end

    return cells
end

local function drawBoard()
    local width, height = love.graphics.getDimensions()
    local x_4 = math.floor(width / COLS)
    local y_4 = math.floor(height / ROWS)

    love.graphics.rectangle("line", 0, 0, width, height)

    for i = 1, ROWS do
        love.graphics.line(0, i * y_4, width, i * y_4);
    end

    for i = 1, COLS do
        love.graphics.line(i * x_4, 0, i * x_4, height);
    end
end

local function drawCells()
    local width, height = love.graphics.getDimensions()
    local x_4 = math.floor(width / COLS)
    local y_4 = math.floor(height / ROWS)


    local offset_x_base = math.floor(x_4 / 2)
    local offset_x
    local offset_y = math.floor(y_4 / 2) - F_HEIGHT / 2

    for i, row in ipairs(GAME_STATE.cells) do
        for j, value in ipairs(row) do
            if value ~= 0 then
                offset_x = offset_x_base - (string.len(tostring(value)) * F_WIDTH / 2)
                love.graphics.printf(value, (j - 1) * x_4, offset_y + (i - 1) * y_4, offset_x, "center", 0, 2)
            end
        end
    end
end

local function movePossible()
    local fns = { cmove.moveLeft, cmove.moveRight, cmove.moveUp, cmove.moveDown }
    for _, fn in ipairs(fns) do
        if fn(getCellsCopy()) ~= 0 then
            return true
        end
    end
    return false
end

local function spawnCell()
    local emptyCells = {}
    for i, row in ipairs(GAME_STATE.cells) do
        for j, value in ipairs(row) do
            if value == 0 then
                table.insert(emptyCells, { i, j })
            end
        end
    end

    local n = #emptyCells

    if n == 0 then
        GAME_STATE.over = not movePossible();
        return
    end

    local pick = math.random(n)

    local i, j = emptyCells[pick][1], emptyCells[pick][2]
    GAME_STATE.cells[i][j] = START_SCORE_CHOICES[math.random(#START_SCORE_CHOICES)]
end

function love.keypressed(key)
    if key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "q" then
        love.event.quit()
    elseif key == "/" then
        GAME_STATE.show_help = not GAME_STATE.show_help
    end

    if GAME_STATE.over or GAME_STATE.show_help then return end
    if key == "right" then
        GAME_STATE.score = GAME_STATE.score + cmove.moveRight(GAME_STATE.cells)
    elseif key == "left" then
        GAME_STATE.score = GAME_STATE.score + cmove.moveLeft(GAME_STATE.cells)
    elseif key == "down" then
        GAME_STATE.score = GAME_STATE.score + cmove.moveDown(GAME_STATE.cells)
    elseif key == "up" then
        GAME_STATE.score = GAME_STATE.score + cmove.moveUp(GAME_STATE.cells)
    else
        return
    end

    spawnCell()
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setNewFont("data/font/Fruktur-Regular.ttf")
    F_HEIGHT     = love.graphics.getFont():getHeight()
    F_WIDTH      = love.graphics.getFont():getWidth("4")

    COLOR_SHADER = love.graphics.newShader("data/shaders/color.shader")
    love.graphics.setShader(COLOR_SHADER)

    love.window.setTitle("2048")
    START_SCORE_CHOICES = { 2, 4 }
    ROWS = 4
    COLS = 4
    GAME_STATE = {
        show_help = false,
        score = 0,
        over = false,
        cells = initialCells(ROWS, COLS)
    }
    spawnCell()
end

local function drawHelp()
    local width, height = love.graphics.getDimensions()
    local w_2, h_2 = math.floor(width / 2), math.floor(height / 2)
    local help_string = "Arrow Keys: Move Cells\n"
        .. "f: Toggle Full-Screen\n"
        .. "/: Toggle Help Screen\n"
        .. "q: Quit"

    love.graphics.printf(help_string, 0, h_2 - 3 * F_HEIGHT, w_2, "center", 0, 2)
end

function love.draw()
    if GAME_STATE.show_help then
        COLOR_SHADER:send("scale", { 0, 0, 1, 1 })
        drawHelp()
        return
    end

    COLOR_SHADER:send("scale", { 0, 1, 0, math.cos(love.timer.getTime()) * 0.5 + 0.5 })

    if GAME_STATE.over then
        local width, height = love.graphics.getDimensions()
        local w_2, h_2 = math.floor(width / 2), math.floor(height / 2)
        love.graphics.clear()
        love.graphics.printf(string.format("Game Over! Score: %d", GAME_STATE.score), 0, h_2, w_2, "center", 0, 2)
        return
    end


    drawBoard()
    drawCells()
end
