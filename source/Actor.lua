import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "ActorDefinitions"
import "Item"
-- pure lua A* pathfinding library, Credits: https://github.com/wesleywerner/lua-star
luastar = import "lua-star"
local gfx <const> = playdate.graphics
-- ACTOR --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

DEBUGSEED = 728423326
math.randomseed(DEBUGSEED)
USECACHEDPATHING = true

class('Actor').extends(gfx.sprite)
ACTOR_SPRITE_GROUP = 2
function createActor(actorInfo)
    local actor = Actor()
    actor:setImage(actorInfo.image)
    -- origin top left like everything else
    actor:setCenter(0, 0)
    actor:setCollideRect(0, 0, actor:getSize())
    actor:setGroups(ACTOR_SPRITE_GROUP)
    actor:setCollidesWithGroups(PLAYER_SPRITE_GROUP)
    actor.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    actor.name = actorInfo.name
    actor.desc = actorInfo.desc
    actor.hp = math.random(actorInfo.hpRange.min, actorInfo.hpRange.max)
    actor.mp = math.random(actorInfo.mpRange.min, actorInfo.mpRange.max)
    actor.stats = actorInfo.stats
    actor.activeEffects = {}
    actor.eqiuppedWeapon = createItem(i_sword)
    -- TODO: assign other actor information, items to drop
    return actor
end

function Actor:__tostring()
    return self.name
end

function Actor:currentTileRC()
    local currentTileRC = coords2TilePos(self.x, self.y)
    return currentTileRC
end

-- Add actor to screen at x, y position
function Actor:addToScreen(x, y)
    self:moveTo(x, y)
    -- don't add them yet, we do this in main as theres a specific draw order
end

-- Remove Actor from screen and cleanup tasks
function Actor:dead()
    -- Mark tile Actor is on as dirty
    currentTile = self:currentTileRC()
    addDirtyTile(currentTile.r, currentTile.c)
    self:remove()
    -- TODO: handle spawning dropped items
    print(self.name .. " drops some items")
end

-- Used in pathfinding, takes x, y
-- converts to matrix row and col space
-- returns tile.class.walkable
function positionIsOpenFunc(x, y)
    tileGridPos = coords2TilePos(x, y)
    return dungeon.levels[currentFloor].matrix[tileGridPos.r][tileGridPos.c].class.walkable
end

function Actor:moveIntent()
    print(self.name .. " wants to move somewhere!")
    -- DEBUG: testing pathfinding, calculate path every turn
    local startNode = { x = self.x, y = self.y }
    local goalNode = { x = Player.x, y = Player.y }
    local pathFound = luastar:find(SCREENWIDTH, SCREENHEIGHT, startNode, goalNode, positionIsOpenFunc, USECACHEDPATHING, false)
    local step = pathFound[2]
    if #pathFound > 2 then
        self:moveTo(step.x, step.y)
    elseif step ~= nil and #pathFound == 2 then
        print("Attempting to bump")
        local actualPosX, actualPosY, collisionInfo, length = self:moveWithCollisions(step.x, step.y)
        if #collisionInfo >= 1 then
            target = collisionInfo[1].other
            self.eqiuppedWeapon:useItem(target)
        end
    end
end

-- called when "bumping" into target , currently player only
function Actor:meleeAttack(target)
    print(self.name .. " is attacking "..target.name)
    self.eqiuppedWeapon:useItem(target)
end

-- When Player attacks Actor
function Actor:hitCalculation(item)
    print(self.name .. " is attacking Player with" .. item.name)
    return 1
end

-- Called when entering Enemy Phase
-- Checks if any effects need to be removed from Player.activeEffects
-- Checks if any effects need to be applyed again this turn (someEffectTable.overTime == true)
function Actor:activeEffectsProc()
    -- apply effects
    if #self.activeEffects ~= 0 then
        for k, v in pairs(self.activeEffects) do
            if v.overTime then
                print(v.name .. " is procing!")
                k:applyEffect(self)
            end
            -- decrement turn counter on all effects
            v.turns = v.turns - 1
        end
    end
end

-- Called at very end of Enemy Phase
-- Checks if any effects have a turn counter of zero and removes them from active effects.
function Actor:activeEffectsRemoval()
    if #self.activeEffects ~= 0 then
        for k, v in pairs(self.activeEffects) do
            if v.turns <= 0 then
                print(v.name .. " has expired! removing")
                table.remove(self.activeEffects, k)
            end
        end
    end
    if self.hp <= 0 then
        print(self.name .. " is dead!")
        self:dead()
    end
end
