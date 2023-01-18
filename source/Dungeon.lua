import "Level"
---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - Dungeon object - - - - - - - - - - - - - - -
---------------------------------------------------------------------------
-- Dungeon objects have several levels (consisting of Level objects) which
-- together represent a whole dungeon.

Dungeon = {}
Dungeon.__index = Dungeon

function Dungeon:new(nrOfLevels, height, width)
  local dungeon = {}
  dungeon.nrOfLevels = nrOfLevels
  dungeon.height = height
  dungeon.width = width
  dungeon.levels = {}

  setmetatable(dungeon, Dungeon)
  return dungeon
end

function Dungeon:generateDungeon(advanced, maxRooms, maxRoomSize, scatteringFactor)
  for i = 1, self.nrOfLevels do
    local newLevel = Level:new(self.height, self.width)
    if advanced then
      newLevel:setMaxRooms(maxRooms)
      newLevel:setMaxRoomSize(maxRoomSize)
      newLevel:setScatteringFactor(scatteringFactor)
    end
    newLevel:generateLevel()

    self.levels[i] = newLevel
  end
end

function Dungeon:printDungeon()
  return dungeon.levels[1]:printLevel()
end

function Dungeon:updateDirtyTiles(dirtyTiles)
  return dungeon.levels[1]:updateLevelTiles(dirtyTiles)
end

function Dungeon:cleanUp()
  self.levels[1] = nil
end
