--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Dungeon Generation --
import "Dungeon"
import "Player"
import "Common"
local gfx <const> = playdate.graphics
local insert = table.insert

-- Settings for level sizes and number of levels in dungeon.
height = 30
width = 50
nrOfLevels = 2

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

function tilePos2Coords(row, column)
    -- level matrix is 1 bigger x,y add offset, should fix this
    local gridOffset = -1
    row = row + gridOffset
    column = column + gridOffset
    local y = row * 8
    local x = column * 8
    return { x = x, y = y }
end

function coords2TilePos(x, y)
    -- level matrix is 1 bigger x,y add offset, should fix this
    local gridOffset = 1
    local R = y / 8
    local C = x / 8
    return { r = R + gridOffset, c = C + gridOffset }
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
                dungeon:printDungeon(currentLevel):draw(0, 0)
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
    spawnRC = validSpawns[math.random(#validSpawns)]
    spawnPos = tilePos2Coords(spawnRC.r, spawnRC.c)
    Player.sprite:moveTo(spawnPos.x, spawnPos.y)
    -- set center to top left so everything aligns to our 30 x 50 grid representation
    Player.sprite:setCenter(0, 0)
    Player.sprite:setCollideRect(0,0, Player.sprite:getSize())
    Player.sprite:setGroups(PLAYER_SPRITE_GROUP)
    Player.sprite:setCollidesWithGroups(ACTOR_SPRITE_GROUP)
    Player.sprite.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    Player.sprite:add()
end

-- handles cleaning up current level being displayed, prints the next dungeon,
-- and places player at x, y
function levelTransition(nextLevel, x, y)
    gfx.clear()
    -- TODO: smelly call
    local newLevel = dungeon.levels[nextLevel]
    newLevel:printDungeon(nextLevel)
    Player.sprite:moveTo(x, y)
    Player.sprite.add()
    -- Generate actors for newLevel
    newLevel:generateActors()
    newLevel:drawActors()
end

start = true
-- Currently displayed dungeon.levels[i]
currentLevel = 1

-- Main Game Loop --
function playdate.update()

    if start then
        initBackground()
    end
    gfx.sprite.update()
    playdate.timer.updateTimers()
    if start then
        initPlayer()
        dungeon.levels[currentLevel]:generateActors()
        dungeon.levels[currentLevel]:drawActors()
        start = false
    end

    -- TODO: Button Callbacks
    if playdate.buttonJustPressed(playdate.kButtonA) then
        local currentTile = playerCurrentTile(Player.sprite.x, Player.sprite.y)
        spawnInfo = nil
        if currentTile.class.name == "aStair" or currentTile.class.name == "dStair" then
            spawnInfo = playerGetNextLevelSpawnStair(currentTile, currentLevel)
        end
        if spawnInfo ~= nil then
            nextLevel = currentLevel + spawnInfo.offset
            currentLevel = nextLevel
            levelTransition(nextLevel, spawnInfo.x, spawnInfo.y)
        end
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


end
