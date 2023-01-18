--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Dungeon Generation --
import "Dungeon"
import "Player"
local gfx <const> = playdate.graphics
local insert = table.insert

-- Settings for level sizes and number of levels in dungeon.
height = 30
width = 50
nrOfLevels = 1

-- global table containing row and column values of tiles that need to be redrawn
dirtyTiles = {}

function addDirtyTile(row, column)
    insert(dirtyTiles, { row, column })
end

-- generate with default settings

-- generate with advanced settings,
-- params: (advanced, maxRooms, maxRoomSize, scatteringFactor)
-- dungeon:generateDungeon(true, 30, 10, 30)

-- Helper function to convert the 30 x 50 split grid into x,y pixel values
-- TODO: can get tile x,y from image at that grid location, refactor
function tilePos2Coords(row, column)
    -- level matrix is 1 bigger x,y add offset, should fix this
    local gridOffset = -1
    row = row + gridOffset
    column = column + gridOffset
    local y = row * 8
    local x = column * 8
    return { x, y }
end

function coords2TilePos(x, y)
    -- level matrix is 1 bigger x,y add offset, should fix this
    local gridOffset = 1
    local R = y / 8
    local C = x / 8
    return { R + gridOffset, C + gridOffset }
end


dungeon = Dungeon:new(nrOfLevels, height, width)
dungeon:generateDungeon()

local function initBackground()
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            -- this is supposed to be faster?
            local next = next
            if next(dirtyTiles) ~= nil then
                dungeon:updateDirtyTiles(dirtyTiles):draw(0, 0)
                --  clear dirty tiles
                dirtyTiles = {}
            else
                dungeon:printDungeon():draw(0, 0)
            end

        end
    )
end

local function initPlayer()
    local playerImage = gfx.image.new("images/PLAYER")
    if (not Player.sprite) then
        Player.sprite = gfx.sprite.new(playerImage)
    end
    local validSpawns = dungeon.levels[1].floorTilesArray
    -- this will return the Row and Column (level.matrix) of a valid floor tile
    -- this needs to be converted to the correct x and y values for player sprite placement
    -- TODO: can get tile x,y from image at that grid location, refactor
    local rc = validSpawns[math.random(#validSpawns)]
    local xy = tilePos2Coords(rc[1], rc[2])
    Player.sprite:moveTo(xy[1], xy[2])
    -- set center to top left so everything aligns to our 30 x 50 grid representation
    Player.sprite:setCenter(0, 0)
    Player.sprite:add()
end

start = true
-- Main Game Loop --
function playdate.update()
    if playdate.buttonJustPressed(playdate.kButtonA) then
        gfx.clear()
        dungeon:generateDungeon()
        initBackground()
        -- TODO: not sure if needed?
        gfx.sprite.update()
        playdate.timer.updateTimers()
        initPlayer()
    end
    -- TODO: Button Callbacks
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
