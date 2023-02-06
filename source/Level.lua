import "helpFunctions"
import "Tile"
import "Room"
import "Actor"

local random = math.random
local floor = math.floor
local ceil = math.ceil
local min = math.min
local max = math.max
local insert = table.insert


seed = playdate.getSecondsSinceEpoch()
-- DEBUG: static seed with convinent enemy placement
DEBUGSEED = 728428767
math.randomseed(seed)
print("Level seed: "..seed)  -- for debugging
SCREENHEIGHT = 240
SCREENWIDTH = 400
---------------------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - - - - Level object - - - - - - - - - - - - - - -- - --
---------------------------------------------------------------------------------------

-- A Level object consist of several Tile objects which together make up
-- one dungeon level.

-- Will have "flat" image of all tiles for easy display

Level = { height, width, matrix, rooms, entrances, staircases, levelImage }
Level.__index = Level

Level.MIN_ROOM_SIZE = 3

Level.veinSpawnRate = 0.00
Level.soilSpawnRate = 0.00

function Level:new(height, width)
  if height < 10 or width < 10 then error("Level must have height>=10, width>=10") end

  local level = {
    height = height,
    width = width,
    matrix = {},
    rooms = {},
    entrances = {},
    staircases = {},
    rootRoom = nil,
    endRoom = nil,
    levelImage = nil,
    floorTilesArray = {},
    doorTilesArray = {},
    aStairLocation = {},
    dStairLocation = {},
    actors = {}
  }
  level.maxRoomSize = ceil(min(height, width) / 10) + 5
  level.maxRooms = ceil(max(height, width) / Level.MIN_ROOM_SIZE)
  -- Determines amount of random tiles built when generating corridors:
  level.scatteringFactor = ceil(max(height, width) / level.maxRoomSize)
  level.levelImage = playdate.graphics.image.new(248, 408)
  setmetatable(level, Level)
  return level
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:generateLevel()
  -- A default generation of a level including rooms, corridors to each room forming
  -- an MSF, staircases and doors. addCycles can be uncommented to dig more corridors.
  print("Generating Level")
  self:initMap()
  self:generateRooms()
  root = self:getRoomTree()
  self:buildCorridors(root)
  -- self:addCycles(5)
  self:addStaircases()
  self:addDoors()
  -- Level Generation Complete

  self:trackImportantTiles()
  -- only currently displayed levels should generate and display their Actors
  -- self:generateActors()

end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:initMap()

  -- Create void
  for i = -1, self.height + 1 do
    self.matrix[i] = {}
    for j = 0, self.width + 1 do
      self.matrix[i][j] = Tile:new(Tile.EMPTY)
    end
  end

  self:addWalls(0, 0, self.height + 1, self.width + 1)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --
-- Helper functions for storing important sections of generated Levels

function Level:trackImportantTiles()
  -- loop through level matrix and add important tiles to their respective tables
  -- TODO: more effiecent way of doing this would be inline with the level generation itself
  for i = -1, self.height + 1 do
    for j = 0, self.width + 1 do
      local tile2check = self.matrix[i][j]
      -- Skip Empty Tiles
      if tile2check.class.name ~= "empty" then
        self:addImportantTile(i, j, tile2check)
      end
    end
  end
end

function Level:addImportantTile(R, C, importantTile)
  if importantTile.class.name == "floor" then
    insert(self.floorTilesArray, { r = R, c = C })
  elseif importantTile.class.name == "aStair" then
    insert(self.aStairLocation, { r = R, c = C })
  elseif importantTile.class.name == "dStair" then
    insert(self.dStairLocation, { r = R, c = C })
  elseif importantTile:isClosedDoor() or importantTile:isOpenDoor() then
    insert(self.doorTilesArray, { r = R, c = C })
  end
end

-- Generates and places, but does not display actors in a level
-- TODO: add params
function Level:generateActors()
  -- DEBUG: spawn just 1 goblin
  local newActor = createActor(goblin)
  -- pick valid spawn for actor
  local validSpawns = self.floorTilesArray
  local spawnRC = validSpawns[math.random(#validSpawns)]
  local spawnPos = tilePos2Coords(spawnRC.r, spawnRC.c)
  newActor:moveTo(spawnPos.x, spawnPos.y)
  insert(self.actors, newActor)
end

-- add all actors to screen
function Level:drawActors()
  for k, v in pairs(self.actors) do
    v:add()
  end
end

function Level:undrawActors()
  for k, v in pairs(self.actors) do
    v:remove()
  end
end



-- Called after Player Phase 
-- runs intents and checks on all actors in level
function Level:enemyPhase()
  for k, actor in pairs(self.actors) do
    print("DEBUG: checking state of "..actor.name)
    if actor.hp <= 0 then
        print(actor.name.." is dead!")
        actor:dead()
        table.remove(self.actors, k)
    end
    actor:moveIntent()
  end
end

-- TODO: add draw function for drawing actors only when we enter a room.

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --
function Level:printLevel()
  local heightOffset = 0
  local rowOffset = 0

  -- all draw calls write to Level.levelImage
  playdate.graphics.pushContext(Level.levelImage)
  playdate.graphics.lockFocus(Level.levelImage)
  for i = 1, self.height + 1 do
    for j = 1, self.width + 1 do
      -- print each sprite one at a time
      if self:getTile(i, j):isEmpty() then
        goto SkipEmpty
      end

      self.matrix[i][j].class.img:draw(rowOffset, heightOffset)

      ::SkipEmpty::
      rowOffset = rowOffset + 8
      if rowOffset == 0 then
        rowOffset = 8
      end
      if rowOffset >= 408 then
        rowOffset = 0
        break
      end
      -- row=row..self.matrix[i][j].class..Tile.EMPTY
      -- row=row..self.matrix[i][j].roomId..Tile.EMPTY    -- for exposing room-ids
    end
    heightOffset = heightOffset + 8
    if heightOffset == 0 then
      heightOffset = 8
    end
    if heightOffset >= 248 then
      heightOffset = 0
    end
  end
  playdate.graphics.unlockFocus()
  playdate.graphics.popContext()

  return self.levelImage
end

-- Function used by background image callback
-- @param tiles: array of tables containing row and column of tiles to be updated
function Level:updateLevelTiles(tiles)
  -- draw to background image
  playdate.graphics.pushContext(Level.levelImage)
  playdate.graphics.lockFocus(Level.levelImage)
  for k, v in pairs(tiles) do
    -- DEBUG: make local after peeking
    -- v[1] and v[2] are the row and column of the tile to draw
    local xy = tilePos2Coords(v[1], v[2])
    self.matrix[v[1]][v[2]].class.img:draw(xy.x, xy.y)
  end
  playdate.graphics.unlockFocus()
  playdate.graphics.popContext()

  return self.levelImage
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getRandRoom()
  -- return: Random room in level
  local i = random(1, #self.rooms)
  return self.rooms[i]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getRoot()
  -- return: Room that is root of room tree if such has been generated.
  return self.rootRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getEnd()
  -- return: Leaf room added last to tree if such has been generated.
  return self.endRoom
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getStaircases()
  -- Index [1] for row, [2] for col on individual entry for individual staircase.
  return self.staircases
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getTile(r, c)
  return self.matrix[r][c]
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:isRoom(row, col)
  return (self:getTile(row, col).roomId ~= 0)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:setMaxRooms(m)
  self.maxRooms = m
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:setScatteringFactor(f)
  self.scatteringFactor = f
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:setMaxRoomSize(m)
  if m > min(self.height, self.width) or m < 3 then
    error("MaxRoomSize can't be bigger than height-3/width-3 or smaller than 3")
  end
  self.maxRoomSize = m
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:generateRooms()
  for i = 1, self.maxRooms do
    self:generateRoom()
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:generateRoom()
  -- Will randomly place rooms across tiles (no overlapping).

  local startRow = random(1, self.height - self.maxRoomSize)
  local startCol = random(1, self.width - self.maxRoomSize)

  local height = random(Level.MIN_ROOM_SIZE, self.maxRoomSize)
  local width = random(Level.MIN_ROOM_SIZE, self.maxRoomSize)

  for i = startRow - 1, startRow + height + 1 do
    for j = startCol - 1, startCol + width + 1 do

      if (self:isRoom(i, j)) then
        return -- Room is overlapping other room->room is discarded
      end
    end
  end
  self:buildRoom(startRow, startCol, startRow + height, startCol + width)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getRoomTree()
  if #self.rooms < 1 then error("Can't generate room tree, no rooms exists") end

  local root, lastLeaf = prims(table.clone(self.rooms))
  self.rootRoom = root
  self.endRoom = lastLeaf

  return root
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildRoom(startR, startC, endR, endC)
  -- init room object and paint room onto tiles.

  local id = #self.rooms + 1
  local room = Room:new(id)
  local r, c = endR - floor((endR - startR) / 2), endC - floor((endC - startC) / 2)
  room:setCenter(r, c)
  insert(self.rooms, room)

  for i = startR, endR do
    for j = startC, endC do
      local tile = self:getTile(i, j)
      tile.roomId, tile.class = id, Tile.FLOOR
    end
  end
  self:addWalls(startR - 1, startC - 1, endR + 1, endC + 1)
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildCorridors(root)
  -- Recursive DFS function for building corridors to every neighbour of a room (root)

  for i = 1, #root.neighbours do
    local neigh = root.neighbours[i]
    self:buildCorridor(root, neigh)
    self:buildCorridors(neigh)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildCorridor(from, to)
  -- Parameters from and to are both Room-objects.

  local start, goal = from.center, to.center
  local nextTile = findNext(start, goal)
  repeat
    local row, col = nextTile[1], nextTile[2]
    self:buildTile(row, col)

    if random() < self.scatteringFactor * 0.05 then
      self:buildRandomTiles(row, col) -- Makes the corridors a little more interesting
    end
    nextTile = findNext(nextTile, goal)
  until (self:getTile(nextTile[1], nextTile[2]).roomId == to.id)

  insert(self.entrances, { row, col })
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildTile(r, c)
  -- Builds floor tile surrounded by walls.
  -- Only floor and empty tiles around floor tiles turns to walls.

  local adj = getAdjacentPos(r, c)
  self:getTile(r, c).class = Tile.FLOOR
  for i = 1, #adj do
    r, c = adj[i][1], adj[i][2]
    if not (self:getTile(r, c).class == Tile.FLOOR) then
      self:placeWall(r, c)
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addDoors(maxDoors)
  -- Adds open or closed door randomly to entrance tiles.
  if #self.entrances == 0 or #self.rooms < 2 then return end
  if not maxDoors then maxDoors = #self.entrances end

  for i = 1, maxDoors do
    e = self.entrances[i]
    if self:isValidEntrance(e[1], e[2]) then
      tile = self:getTile(e[1], e[2])
      if random() > 0.5 then
        tile.class = Tile.C_DOOR
      else
        tile.class = Tile.O_DOOR
      end
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addStaircases(maxStaircases)
  -- Adds both descending and ascending staircases to random rooms.
  -- Number of staircases depend on number of rooms.
  -- TODO: this code needs to ensure there is always one up and one down staircase in a level!
  -- if (not maxStaircases) or (maxStaircases > #self.rooms) then
  --   -- maxStaircases = ceil(#self.rooms - (#self.rooms / 2)) + 1
  --   maxStaircases = 2
  -- end
  local staircases = 2

  repeat
    local room = self:getRandRoom()
    if not room.hasStaircase then
      print("DEBUG: placing staircase in "..room.id)
      self:placeStaircase(room, staircases)
      staircases = staircases - 1
    end
  until staircases == 0
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addWalls(startR, startC, endR, endC)
  -- Places walls on circumference of given rectangle.

  -- Upper and lower sides
  for j = startC, endC do
    self:placeWall(startR, j)
    self:placeWall(endR, j)
  end

  -- Left and right sides
  for i = startR, endR do
    self:placeWall(i, startC)
    self:placeWall(i, endC)
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:placeWall(r, c)
  -- Places wall at given coordinate. Could either place
  -- regular wall, soil or mineral vein

  local tile = self:getTile(r, c)

  if random() <= Level.veinSpawnRate then
    tile.class = Tile.VEIN
  elseif random() <= Level.soilSpawnRate then
    tile.class = Tile.SOIL
    Level.soilSpawnRate = 0.6 -- for clustering
  else
    tile.class = Tile.WALL
    Level.soilSpawnRate = 0.05
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:placeStaircase(room, staircases)
  -- Places staircase in given room.
  -- DEBUG: Position is 2 steps away from center.
  local steps = 2

  -- get center of room
  local roomCenterRow, roomCenterCol = room.center[1], room.center[2]
  local row, col = roomCenterRow, roomCenterCol
  -- Get random neighbors until we have left the room or our steps are complete
  repeat
    -- Get random neighbor of center tile until we have a floor tile
    repeat
      nrow, ncol = getRandNeighbour(row, col)
    until self:getTile(nrow, ncol):isFloor()
    row, col = nrow, ncol
    steps = steps - 1
  until (self:getTile(nrow, ncol).roomId ~= room.id or steps <= 0)

  if staircases % 2 == 0 then
    print("DEBUG: placing down stairs at: "..row.." "..col)
    self:getTile(row, col).class = Tile.D_STAIRCASE
  else
    print("DEBUG: placing up stairs at: "..row.." "..col)
    self:getTile(row, col).class = Tile.A_STAIRCASE
  end
  room.hasStaircase = true
  insert(self.staircases, { row, col })
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:isValidEntrance(row, col)
  -- Tile is a valid entrance position if there is a wall above and below it or
  -- to the left and to the right of it.
  return (
      (self:getTile(row + 1, col):isWall() and self:getTile(row - 1, col):isWall()) or
          (self:getTile(row, col + 1):isWall() and self:getTile(row, col - 1):isWall())
      )
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:getAdjacentTiles(row, col)
  -- returns table containing all adjacent tiles to given position.
  -- Including self!

  local result = {}
  local adj = getAdjacentPos(row, col)
  for i = 1, #adj do
    local row, col = adj[i][1], adj[i][2]
    insert(result, self:getTile(row, col))
  end
  return result
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:buildRandomTiles(r, c)
  -- Creates random floor tiles starting from given tile.

  local rand = random(1, self.scatteringFactor)
  for i = 1, rand do
    local nr, nc = getRandNeighbour(r, c, true)

    if (self:getTile(nr, nc).roomId == 0 and
        withinBounds(nr, nc, self.height, self.width)) then
      self:buildTile(nr, nc)
      r, c = nr, nc
    end
  end
end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Level:addCycles(maxCycles)
  -- Adds corridors between random rooms.

  for _ = 1, maxCycles do
    from = self:getRandRoom()
    to = self:getRandRoom()
    self:buildCorridor(from, to)
  end
end
