---------------------------------------------------------------------------
-- - - - - - - - - - - - - - - - Tile object - - - - - - - - - - - - - - --
---------------------------------------------------------------------------

-- Tile objects:
-- The tile objects are pulled from their respective sprites, bounding boxes included
-- these objects are then placed on screen?
--  * Keeps track of room association, if not in room (default): roomId = 0
--  * Has graphic symbol to represent what kind of tile this is in a level
import "CoreLibs/sprites"
local gfx <const> = playdate.graphics
local TILE_SPRITE_GROUP = 1

function loadImageToSpriteHelper(path)
  image = gfx.image.new(path)
  if image == nil then
    print("#### Failed to load image at " .. path .. " ####")
    return nil
  end
  return image
end

-- loadin tileset
Tile = { class, roomId, img, name }
Tile.__index = Tile

emptyImg  = gfx.image.new("images/TILES/EMPTY")
floorImg  = gfx.image.new("images/TILES/FLOOR_FULL")
wallImg   = gfx.image.new("images/TILES/WALL")
aStairImg = gfx.image.new("images/TILES/UP_STAIR")
dStairImg = gfx.image.new("images/TILES/DOWN_STAIR")
soilImg   = gfx.image.new("images/TILES/SOIL")
cDoorImg  = gfx.image.new("images/TILES/C_DOOR")
oDoorImg  = gfx.image.new("images/TILES/O_DOOR")

-- Can't compare gfx.image objects, use this as a hacky work arround and compare strings instead!
Tile.EMPTY      = {img = emptyImg, name = "empty", walkable = false}

Tile.FLOOR      = {img = floorImg, name = "floor", walkable = true}

Tile.WALL      = {img = wallImg, name = "wall", walkable = false}

Tile.A_STAIRCASE = {img = aStairImg, name = "aStair", walkable = true}

Tile.D_STAIRCASE = {img = dStairImg, name = "dStair", walkable = true}

-- HACK: remove the actual soil and vein generation eventually
Tile.SOIL      = {img = wallImg, name = "soil", walkable = false}

Tile.VEIN      = {img = wallImg, name = "vein", walkable = false}

Tile.C_DOOR      = {img = cDoorImg, name = "cDoor", walkable = true} -- DEBUG: TODO: will edit when keys are a thing

Tile.O_DOOR      = {img = oDoorImg, name = "oDoor", walkable = true}

function Tile:new(t)
  local tile = {}
  tile.class = t
  tile.roomId = 0
  tile.class.name = t.name
  setmetatable(tile, Tile)

  return tile

end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tile:isWall()
  return (
      self.class.name == "wall" or
          self.class.name == "soil" or
          self.class.name == "vein"
      )
end

function Tile:isEmpty()
  return self.class.name == "empty"
end

function Tile:isFloor()
  return self.class.name == "floor"
end

function Tile:isClosedDoor()
  return self.class.name == "cDoor"
end

function Tile:isOpenDoor()
  return self.class.name == "oDoor"
end

function Tile:isAccendStair()
  return self.class.name == "aStair"
end

function Tile:isDecendStair()
  return self.class.name == "dStair"
end