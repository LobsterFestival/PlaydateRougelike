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
Tile.EMPTY      = {img = emptyImg, name = "empty"}

Tile.FLOOR      = {img = floorImg, name = "floor"}

Tile.WALL      = {img = wallImg, name = "wall"}

Tile.A_STAIRCASE = {img = aStairImg, name = "aStair"}

Tile.D_STAIRCASE = {img = dStairImg, name = "dStair"}

-- HACK: remove the actual soil and vein generation eventually
Tile.SOIL      = {img = wallImg, name = "soil"}

Tile.VEIN      = {img = wallImg, name = "vein"}

Tile.C_DOOR      = {img = cDoorImg, name = "cDoor"}

Tile.O_DOOR      = {img = oDoorImg, name = "oDoor"}

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

function Tile:isAccendStair()
  return self.class.name == "aStair"
end

function Tile:isDecendStair()
  return self.class.name == "dStair"
end