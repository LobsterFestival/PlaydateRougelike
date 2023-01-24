-- The item class holds information about various items and equipment
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "EffectsDefinitions"
import "ItemDefinitions"

local gfx <const> = playdate.graphics
local insert = table.insert
class("Item").extends(playdate.graphics.sprite)
ITEM_SPRITE_GROUP = 3

-- Takes in an ItemDefinition table and returns a new Item
function createItem(itemInfo)
    local item = Item()
    item:setImage(itemInfo.image)
    item:setCenter(0,0)
    item:setGroups(ITEM_SPRITE_GROUP)
    -- Collisions?
    item.name = itemInfo.name
    item.desc = itemInfo.desc
    item.effect = itemInfo.effect
    return item
end

function Item:addToInventory()
    insert(Player.inventory, self)
end

function Item:removeFromInventory()
end

-- TODO: Other Item class functions