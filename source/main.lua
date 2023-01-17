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

function coords2TilePos(x, y)
    -- level matrix is 1 bigger x,y add offset, should fix this
    local gridOffset = 1
    R = y / 8
    C = x / 8
    return { R + gridOffset, C + gridOffset }
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



-- END PLAYER --

start = true
dungeon = Dungeon:new(nrOfLevels, height, width)
dungeon:generateDungeon()

local function initBackground()
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            dungeon:printDungeon():draw(0, 0)
        end
    )
end

-- Player Movement and intent
function checkMovementEffect(x, y)
    print(x .. y)
    rc = coords2TilePos(x, y)
    print("r,c " .. rc[1] .. rc[2])
    tileToMoveTo = dungeon.levels[1].matrix[rc[1]][rc[2]]
    print(tileToMoveTo.class.name)
    if tileToMoveTo:isWall() then
        print("Wall detected!")
        return 1
    end
    -- TODO: add checks for closed doors, up stairs and down stairs
end

function Player:moveIntent(dir)

    -- TODO: add calls to function for checking collisions with
    -- Walls, Actors, Items, etc.
    currX = Player.sprite.x
    currY = Player.sprite.y
    -- Up: -8px Y
    if dir == UP then
        if checkMovementEffect(currX, currY - 8) ~= 1 then
            Player.sprite:moveTo(currX, currY - 8)
        end
        -- Down: +8px Y
    elseif dir == DOWN then
        if checkMovementEffect(currX, currY + 8) ~= 1 then
            Player.sprite:moveTo(currX, currY + 8)
        end
        -- Left: -8px X
    elseif dir == LEFT then
        if checkMovementEffect(currX - 8, currY) ~= 1 then
            Player.sprite:moveTo(currX - 8, currY)
        end
        -- Right: +8px X
    elseif dir == RIGHT then
        if checkMovementEffect(currX + 8, currY) ~= 1 then
            Player.sprite:moveTo(currX + 8, currY)
        end
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

-- initPlayer()
-- initBackground(dungeon.levels[1].levelImage)
-- Helper function that draws dungeon to single image for display?

-- Main Game Loop --
function playdate.update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        gfx.clear()
        dungeon:generateDungeon()
        initBackground()
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
    if start then
        initBackground()
    end
    gfx.sprite.update()
    playdate.timer.updateTimers()
    if start then
        initPlayer()
        start = false
    end

end
