-- The item class holds information about various items and equipment
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "EffectsDefinitions"
import "ItemDefinition"

local gfx <const> = playdate.graphics
class("Item").extends(playdate.graphics.sprite)

-- Takes in an ItemDefinition table and returns a new Item
function createItem(itemInfo)
end

function Item:addToInventory()
end

function Item:removeFromInventory()
end

-- TODO: Other Item class functions