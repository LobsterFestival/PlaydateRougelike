import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "ActorDefinitions"
local gfx <const> = playdate.graphics
-- ACTOR --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

DEBUGSEED = 728423326
math.randomseed(DEBUGSEED)

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
    -- TODO: assign other actor information, equipped item, items to drop
    return actor
end

function Actor:__tostring()
    return self.name
end

-- Add actor to screen at x, y position
function Actor:addToScreen(x, y)
    self:moveTo(x, y)
    -- don't add them yet, we do this in main as theres a specific draw order
end

-- Remove Actor from screen and cleanup tasks
function Actor:dead()
    self:remove()
    -- TODO: handle spawning dropped items
    print(self.name.." drops some items")
end

function Actor:moveIntent()
    print(self.name .. " wants to move somewhere!")
end

function Actor:meleeAttack()
    print(self.name .. " is attacking something!")
end

-- TODO: ranged attacks are hard, do later if time
function Actor:rangedAttack()
end

-- When Player attacks Actor
function Actor:hitCalculation(item)
    print(self.name .. " is attacking Player with" .. item.name)
    item:useItem(Player)
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
                -- TODO: check this is right removal code
                k = nil
            end
        end
    end
end

