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
Tile = { class, roomId }
Tile.__index = Tile

emptyImg         = gfx.image.new("images/EMPTY")
floorImg         = gfx.image.new("images/FLOOR_FULL")
wallImg          = gfx.image.new("images/WALL")
aStairImg        = gfx.image.new("images/UP_STAIR")
dStairImg        = gfx.image.new("images/DOWN_STAIR")
soilImg          = gfx.image.new("images/SOIL")
cDoorImg         = gfx.image.new("images/C_DOOR")
oDoorImg         = gfx.image.new("images/O_DOOR")
playerImg        = gfx.image.new("images/PLAYER")
playerSprite     = gfx.sprite.new(playerImg)
TILE.PLAYER      = playerSprite
Tile.EMPTY       = emptyImg
Tile.FLOOR       = floorImg
Tile.WALL        = wallImg
Tile.A_STAIRCASE = aStairImg
Tile.D_STAIRCASE = dStairImg
Tile.SOIL        = soilImg
Tile.VEIN        = soilImg
Tile.C_DOOR      = cDoorImg
Tile.O_DOOR      = oDoorImg

function Tile:new(t)
  local tile = {}
  tile.class = t
  tile.roomId = 0

  setmetatable(tile, Tile)

  return tile

end

-- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### -- ##### --

function Tile:isWall()
  return (
      self.class == Tile.WALL or
          self.class == Tile.SOIL or
          self.class == Tile.VEIN
      )
end

function Tile:isEmpty()
  return self.class == Tile.EMPTY
end
