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

start = true
dungeon = Dungeon:new(nrOfLevels, height, width)

for i = -1, height + 1 do
    playerPos.matrix[i] = {}
    for j = 0, width + 1 do
      playerPos.matrix[i][j] = 0
    end
  end
-- Main Game Loop --
function playdate.update()
    newR, newC = 0, 0
    if start then
        dungeon:generateDungeon()
        dungeon:printDungeon()
        newR, newC = initPlayer(dungeon.levels[1])
        start = false
        gameStart = true
    end
    if playdate.buttonJustPressed(playdate.kButtonA) then
        gfx.clear()
        dungeon:generateDungeon()
        dungeon:printDungeon()
    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        newR, newC = movePlayerLeft(newR,newC,gameStart)
    end
end

function initPlayer(level)
    c = level:getRoot().center
    adj = getAdjacentPos(c[1], c[2])
    i = 1
    repeat
        endr, endc = adj[i][1], adj[i][2]
        i = i + 1
    until level:getTile(endr, endc).class == Tile.FLOOR

    level:getTile(endr, endc).class = Tile.PLAYER
    level:getTile(endr, endc).class:add()
    return r, c
end

-- r,c is row,col in levels[1].matrix
function movePlayerLeft(r, c, gameStart, level, lastTile)
    -- left movement only
    if r-1 < 0 then
        return r, c
    end

    return newR, newC
end
