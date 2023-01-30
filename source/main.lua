--[[ These are Libs that are used in every project --]]
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Dungeon Generation --
import "Dungeon"
import "Player"
import "Common"
import "Item"
local gfx <const> = playdate.graphics
local insert = table.insert

-- Settings for level sizes and number of levels in dungeon.
height = 30
width = 50
nrOfLevels = 2

-- ##### GLOBALS ##### --
-- table containing row and column values of tiles that need to be redrawn
dirtyTiles = {}
start = true
currentLevel = 1
Player = nil

-- ##### END GLOBALS ##### --
local gameScreenInputHandlers = {
    upButtonDown = function()
        Player:moveIntent(UP)
        playerPhaseComplete = true
    end,
    downButtonDown = function()
        Player:moveIntent(DOWN)
        playerPhaseComplete = true
    end,
    leftButtonDown = function()
        Player:moveIntent(LEFT)
        playerPhaseComplete = true
    end,
    rightButtonDown = function()
        Player:moveIntent(RIGHT)
        playerPhaseComplete = true
    end,
    AButtonDown = function()
        local currentTile = Player:currentTile(Player.x, Player.y)
        spawnInfo = nil
        if currentTile.class.name == "aStair" or currentTile.class.name == "dStair" then
            spawnInfo = playerGetNextLevelSpawnStair(currentTile, currentLevel)
        end
        if spawnInfo ~= nil then
            nextLevel = currentLevel + spawnInfo.offset
            currentLevel = nextLevel
            levelTransition(nextLevel, spawnInfo.x, spawnInfo.y)
        end
        -- TODO: eventually menuing and picking up items on the ground will also end Player Phase
    end,
    BButtonDown = function()
        print("Im gonna be the menu button!~")
    end
}
function addDirtyTile(row, column)
    insert(dirtyTiles, { row, column })
end

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
    if (not Player) then
        print("creating player")
        -- DEBUG: will be created during Player creation screen
        local playerSword = createItem(i_sword)
        local potionOfStrength = createItem(i_potionOfStrength)
        playerInfo.eqiuppedWeapon = playerSword
        insert(playerInfo.inventory, potionOfStrength)
        Player = createPlayer(playerInfo)
    end
    local validSpawns = dungeon.levels[1].floorTilesArray
    -- this will return the Row and Column (level.matrix) of a valid floor tile
    -- this needs to be converted to the correct x and y values for player sprite placement
    -- TODO: can get tile x,y from image at that grid location, refactor
    spawnRC = validSpawns[math.random(#validSpawns)]
    spawnPos = tilePos2Coords(spawnRC.r, spawnRC.c)
    Player:moveTo(spawnPos.x, spawnPos.y)
    Player:add()
end

-- handles cleaning up current level being displayed, prints the next dungeon,
-- and places player at x, y
function levelTransition(nextLevel, x, y)
    gfx.clear()
    -- TODO: smelly call
    local newLevel = dungeon.levels[nextLevel]
    newLevel:printDungeon(nextLevel)
    Player:moveTo(x, y)
    Player:add()
    -- Generate actors for newLevel
    newLevel:generateActors()
    newLevel:drawActors()
end

-- DEBUG: testing Turn Counter
turnCount = 0
-- Set input handler to gameScreenMovement
playdate.inputHandlers.push(gameScreenInputHandlers)

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
    if playerPhaseComplete then
        print("Enemy Phase: Enemies are doing things...")
        dungeon.levels[currentLevel]:enemyPhase()
        turnCount += 1
        print("Turn " .. turnCount .. " is complete!\n")
    end
    playerPhaseComplete = false
end
