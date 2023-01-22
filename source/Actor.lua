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

class('Actor').extends(gfx.sprite)
ACTOR_SPRITE_GROUP = 2
function createActor(actorInfo)
    local actor = Actor()
    -- TODO: set sprite groups, collisions, etc
    actor:setImage(actorInfo.image)
    -- origin top left like everything else
    actor:setCenter(0,0)
    actor:setCollideRect(0, 0, actor:getSize())
    actor:setGroups(ACTOR_SPRITE_GROUP)
    actor:setCollidesWithGroups(PLAYER_SPRITE_GROUP)
    actor.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    actor.name = actorInfo.name
    actor.desc = actorInfo.desc
    actor.hp = actorInfo.hp
    actor.mp = actorInfo.mp
    actor.stats = actorInfo.stats
    -- TODO: assign other actor information
    return actor
end

function Actor:getName()
    return self.name
end

-- Add actor to screen at x, y position
function Actor:addToScreen(x, y)
    self:moveTo(x,y)
    -- don't add them yet, we do this in main as theres a specific draw order
end

-- Remove Actor from screen and cleanup tasks
function Actor:removeFromScreen()
    self:remove()
    -- TODO: handle spawning dropped items
end

function Actor:moveIntent()
    print(self.name.." wants to move somewhere!")
end

function Actor:meleeAttack()
    print(self.name.." is attacking something!")
end

-- TODO: ranged attacks are hard, do later if time
function Actor:rangedAttack()
end

-- When Player attacks Actor
function Actor:hitCalculation(effectTable)
    print(self.name.." is attacking Player with"..effectTable)
    Player:hitEffect(effectTable)
end

-- Actor will adjust hp,mp,stats, etc from Player/item effect
-- currently only Player will be able to damage enemy actors
-- param adjustments: effect table of what to adjust
-- DEBUG: TODO: effect table is just a string right now
function Actor:hitEffect(effectTable)
    print(self.name.." was hit by player with "..effectTable)
end
