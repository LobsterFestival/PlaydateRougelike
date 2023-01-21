import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "ActorDefinitions"

-- ACTOR --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

class('Actor').extends(playdate.graphics.sprite)

function createActor(actorInfo)
    local actor = Actor()
    -- TODO: set sprite groups, collisions, etc
    actor:setImage(actorInfo.image)
    -- origin top left like everything else
    actor:setCenter(0,0)
    -- actor:setCollideRect(0, 0, actor:getSize())
    actor.name = actorInfo.name
    actor.desc = actorInfo.desc
    actor.hp = actorInfo.hp
    actor.mp = actorInfo.mp
    actor.stats = actorInfo.stats
    -- TODO: assign other actor information
    return actor
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
