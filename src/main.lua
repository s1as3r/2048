local cmove = require("cell_moves")
local util = require("util")


local function getCellsCopy()
    local cells = util.initialCells(ROWS, COLS)
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
    local offset_y = math.floor(y_4 / 2) - F_HEIGHT / 2

    local offset_x
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
    elseif key == "." then
        GAME_STATE.show_settings = not GAME_STATE.show_settings
    elseif key == "/" then
        GAME_STATE.show_help = not GAME_STATE.show_help
    end

    if GAME_STATE.over or GAME_STATE.show_help or GAME_STATE.show_settings then return end
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
    COLOR_SHADER:send("scale", { 0, 1, 1, 1 })

    love.window.setTitle("2048")
    START_SCORE_CHOICES = { 2, 2, 2, 4 }
    ROWS = 4
    COLS = 4
    SETTINGS = {
        use_shader = false,
    }
    BUTTON_COORDS = {
        use_shader = { x = 0, y = 0, w = 0, h = 0 }
    }
    GAME_STATE = {
        show_settings = false,
        show_help = false,
        score = 0,
        over = false,
        cells = util.initialCells(ROWS, COLS)
    }
    spawnCell()
end

local function drawHelp()
    COLOR_SHADER:send("scale", { 0, 1, 1, 1 })
    local w_2, h_2 = util.getCenter()
    local help_string = "Arrow Keys: Move Cells\n"
        .. "f: Toggle Full-Screen\n"
        .. "/: Toggle Help Screen\n"
        .. ".: Settings\n"
        .. "q: Quit"

    local offset_y = util.countChars(help_string, "\n") + 2
    love.graphics.printf(help_string, 0, h_2 - (offset_y / 2) * F_HEIGHT, w_2, "center", 0, 2)
end

local function drawSettings()
    COLOR_SHADER:send("scale", { 0, 1, 1, 1 })
    local w_2, h_2 = util.getCenter()
    local w_pad, h_pad = 4, 2
    local buttonText;
    if SETTINGS.use_shader then
        buttonText = "Disable Shader"
    else
        buttonText = "Enable Shader"
    end

    local rectWidth = love.graphics.getFont():getWidth(buttonText) + w_pad * 2
    local rectHeight = F_HEIGHT + h_pad * 2;
    local rect_x, rect_y = w_2 - (rectWidth / 2), h_2 - (rectHeight / 2)
    love.graphics.rectangle("line", rect_x, rect_y, rectWidth, rectHeight)
    love.graphics.print(buttonText, w_2 - (rectWidth / 2) + w_pad, h_2 - (rectHeight / 2) + h_pad)

    BUTTON_COORDS.use_shader = { x = rect_x, y = rect_y, w = rectWidth, h = rectHeight }
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    if GAME_STATE.show_settings and util.isInRect(x, y, BUTTON_COORDS.use_shader) then
        SETTINGS.use_shader = not SETTINGS.use_shader
    end
end

function love.draw()
    if GAME_STATE.show_help then
        drawHelp()
        return
    end

    if GAME_STATE.show_settings then
        drawSettings()
        return
    end

    if SETTINGS.use_shader then
        COLOR_SHADER:send("scale", { 0, 1, 0, math.cos(love.timer.getTime()) * 0.5 + 0.5 })
    end

    if GAME_STATE.over then
        local w_2, h_2 = util.getCenter()
        love.graphics.clear()
        love.graphics.printf(string.format("Game Over! Score: %d", GAME_STATE.score), 0, h_2, w_2, "center", 0, 2)
        return
    end


    drawBoard()
    drawCells()
end
