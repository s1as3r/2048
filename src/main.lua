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
    local x4 = math.floor(width / COLS)
    local y4 = math.floor(height / ROWS)

    love.graphics.rectangle("line", 0, 0, width, height)

    for i = 1, ROWS do
        love.graphics.line(0, i * y4, width, i * y4);
    end

    for i = 1, COLS do
        love.graphics.line(i * x4, 0, i * x4, height);
    end
end

local function drawCells()
    local width, height = love.graphics.getDimensions()
    local x4 = math.floor(width / COLS)
    local y4 = math.floor(height / ROWS)


    local offsetXBase = math.floor(x4 / 2)
    local offsetY = math.floor(y4 / 2) - F_HEIGHT / 2

    local offsetX
    for i, row in ipairs(GAME_STATE.cells) do
        for j, value in ipairs(row) do
            if value ~= 0 then
                offsetX = offsetXBase - (string.len(tostring(value)) * F_WIDTH / 2)
                love.graphics.printf(value, (j - 1) * x4, offsetY + (i - 1) * y4, offsetX, "center", 0, 2)
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

local function restartGame()
    GAME_STATE.score = 0
    GAME_STATE.cells = util.initialCells(ROWS, COLS)
    GAME_STATE.over = false
    GAME_STATE.showSettings = false
    GAME_STATE.showHelp = false

    spawnCell()
end

function love.keypressed(key)
    -- general keymaps
    if key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "q" then
        love.event.quit()
    elseif key == "." then
        GAME_STATE.showSettings = not GAME_STATE.showSettings
    elseif key == "/" then
        GAME_STATE.showHelp = not GAME_STATE.showHelp
    elseif key == "r" then
        restartGame()
    end

    -- game control keymaps
    if GAME_STATE.over or GAME_STATE.showHelp or GAME_STATE.showSettings then return end
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
        useShader = false,
    }
    BUTTON_COORDS = {
        useShader = { x = 0, y = 0, w = 0, h = 0 }
    }
    GAME_STATE = {
        showSettings = false,
        showHelp = false,
        score = 0,
        over = false,
        cells = util.initialCells(ROWS, COLS)
    }
    spawnCell()
end

local function drawHelp()
    COLOR_SHADER:send("scale", { 0, 1, 1, 1 })
    local w2, h2 = util.getCenter()
    local helpString = "Arrow Keys: Move Cells\n"
        .. "f: Toggle Full-Screen\n"
        .. "/: Toggle Help Screen\n"
        .. ".: Settings\n"
        .. "r: Restart\n"
        .. "q: Quit"

    local offsetY = util.countChars(helpString, "\n") + 2
    love.graphics.printf(helpString, 0, h2 - (offsetY / 2) * F_HEIGHT, w2, "center", 0, 2)
end

local function drawSettings()
    COLOR_SHADER:send("scale", { 0, 1, 1, 1 })
    local w2, h2 = util.getCenter()
    local wPad, hPad = 4, 2
    local buttonText;
    if SETTINGS.useShader then
        buttonText = "Disable Shader"
    else
        buttonText = "Enable Shader"
    end

    local rectWidth = love.graphics.getFont():getWidth(buttonText) + wPad * 2
    local rectHeight = F_HEIGHT + hPad * 2;
    local rectX, rectY = w2 - (rectWidth / 2), h2 - (rectHeight / 2)
    love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight)
    love.graphics.print(buttonText, w2 - (rectWidth / 2) + wPad, h2 - (rectHeight / 2) + hPad)

    BUTTON_COORDS.useShader = { x = rectX, y = rectY, w = rectWidth, h = rectHeight }
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    if GAME_STATE.showSettings and util.isInRect(x, y, BUTTON_COORDS.useShader) then
        SETTINGS.useShader = not SETTINGS.useShader
    end
end

function love.update()
    if SETTINGS.useShader then
        COLOR_SHADER:send("scale", { 0, 1, 0, math.cos(love.timer.getTime()) * 0.5 + 0.5 })
    end
end

function love.draw()
    if GAME_STATE.showHelp then
        drawHelp()
        return
    end

    if GAME_STATE.showSettings then
        drawSettings()
        return
    end

    if GAME_STATE.over then
        local w2, h2 = util.getCenter()
        love.graphics.clear()
        love.graphics.printf(string.format("Game Over! Score: %d", GAME_STATE.score), 0, h2, w2, "center", 0, 2)
        return
    end


    drawBoard()
    drawCells()
end
