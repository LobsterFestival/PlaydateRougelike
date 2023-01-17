--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
-- Dungeon Generation --
import "Dungeon"
local gfx <const> = playdate.graphics
-- Settings for level sizes and number of levels in dungeon.
height = 30
width = 50
nrOfLevels = 1

-- generate with default settings

-- generate with advanced settings,
-- params: (advanced, maxRooms, maxRoomSize, scatteringFactor)
-- dungeon:generateDungeon(true, 30, 10, 30)

-- Helper function to convert the 30 x 50 split grid into x,y pixel values
function tilePos2Coords(row, column)
    -- We know all tiles have their origin in the upper left
    -- We know all tiles are offset by 8 px on the X and Y axes
    X = row * 8
    Y = col * 8
    return { X, Y }
end

-- PLAYER --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

Player = {
    sprite = nil,
    hp = 10,
    mp = 10,
    stats = { STR = 1, DEX = 1, CON = 1, INT = 1 },
    inventory = {},
}

-- Player Movement and intent
function Player:moveIntent(dir)
    -- TODO: add calls to function for checking collisions with
    -- Walls, Actors, Items, etc.
    currX = Player.sprite.x
    currY = Player.sprite.y
    print("Current X: " .. currX .. " Current Y: " .. currY)
    -- Up: -8px Y
    if dir == UP then
        Player.sprite:moveTo(currX, currY - 8)
        -- Down: +8px Y
    elseif dir == DOWN then
        Player.sprite:moveTo(currX, currY + 8)
        -- Left: -8px X
    elseif dir == LEFT then
        Player.sprite:moveTo(currX - 8, currY)
        -- Right: +8px X
    elseif dir == RIGHT then
        Player.sprite:moveTo(currX + 8, currY)
    end
end

local function initPlayer()
    local playerImage = gfx.image.new("images/PLAYER")
    Player.sprite = gfx.sprite.new(playerImage)
    -- TODO: function call to set player on a valid tile
    Player.sprite:moveTo(0, 0)
    Player.sprite:setCenter(0, 0)
    Player.sprite:add()
end

local function initBackground()
    backgroundImage = gfx.image.new("images/BG_FRAME")
    assert(backgroundImage)
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0, 0)
            gfx.clearClipRect()
        end
    )
end

-- END PLAYER --

start = true
dungeon = Dungeon:new(nrOfLevels, height, width)
initBackground()
initPlayer()

-- Main Game Loop --
function playdate.update()
    if start then
        dungeon:generateDungeon()
        dungeon:printDungeon()        
        start = false
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        gfx.clear()
        dungeon:generateDungeon()
        dungeon:printDungeon()
    end
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        Player:moveIntent(UP)

    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        Player:moveIntent(DOWN)

    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        Player:moveIntent(LEFT)

    end
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        Player:moveIntent(RIGHT)

    end
    gfx.sprite.update()
end
