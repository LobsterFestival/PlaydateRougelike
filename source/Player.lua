import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Dungeon"
import "Item"
local gfx <const> = playdate.graphics
-- PLAYER --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

class('PlayerClass').extends(gfx.sprite)
PLAYER_SPRITE_GROUP = 1
local playerImage = gfx.image.new("images/PLAYER")

-- TODO: DEBUG: this information will be populated from character creation menus eventually
playerInfo = {
    name = "lobster",
    vocation = "warrior",
    image = playerImage,
    hp = 10,
    mp = 10,
    stats = { STR = 1, DEX = 3, CON = 1, INT = 1 },
    inventory = {},
    eqiuppedWeapon = nil,
    activeEffects = {}
}

function createPlayer(playerInfo)
    local player = PlayerClass()
    player:setImage(playerInfo.image)
    -- set center to top left so everything aligns to 30 x 50 grid
    player:setCenter(0, 0)
    player:setCollideRect(0, 0, player:getSize())
    player:setGroups(PLAYER_SPRITE_GROUP)
    player:setCollidesWithGroups(ACTOR_SPRITE_GROUP)
    player.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    player.name = playerInfo.name
    player.vocation = playerInfo.vocation
    player.hp = playerInfo.hp
    player.mp = playerInfo.mp
    player.stats = playerInfo.stats
    player.inventory = playerInfo.inventory
    player.eqiuppedWeapon = playerInfo.eqiuppedWeapon
    player.activeEffects = playerInfo.activeEffects
    return player
end

function PlayerClass:__tostring()
    return self.name
end

-- handles moving player between aStair and dStairs between dungeon.levels[] changes
-- params: stair: tile object of either aStair or dStair used to determine stair
-- to spawn on in level transported to
-- returns table of stair to spawn on, and whether we are goin up or down a level
-- TODO: Level generation needs to spawn valid stairs on all levels for this to work
-- TODO: move out of PlayerClass into Level(?)
function playerGetNextLevelSpawnStair(stair, currentLevel)
    spawnStair = {}
    if stair.class.name == "aStair" then
        local transitionOffset = 1
        spawnStair = dungeon.levels[currentLevel + transitionOffset].dStairLocation
    elseif stair.class.name == "dStair" then
        local transitionOffset = -1
        spawnStair = dungeon.levels[currentLevel + transitionOffset].aStairLocation
    else
        return nil
    end
    -- Will have to ensure every level has 1 up and 1 down stair on each level
    assert(spawnStair ~= nil)
    local xy = tilePos2Coords(spawnStair[1].r, spawnStair[1].c)
    return { x = xy.x, y = xy.y, offset = transitionOffset }
end

-- returns current Tile object player is standing on
function PlayerClass:currentTile()
    local currentTile = coords2TilePos(self.x, self.y)
    local currentPlayerTile = dungeon.levels[currentLevel].matrix[currentTile.r][currentTile.c]
    return currentPlayerTile
end

-- Check that we can move to that tile
function PlayerClass:checkMovementEffect(x, y)
    local nextTilePos = coords2TilePos(x, y)
    tileToMoveTo = dungeon.levels[1].matrix[nextTilePos.r][nextTilePos.c]
    if tileToMoveTo:isWall() then
        return 1
    end
end

-- Part of PlayerPhase
function PlayerClass:moveIntent(dir)
    local currX = self.x
    local currY = self.y
    -- row and column of actors current position
    local currTileGridPos = coords2TilePos(self.x, self.y)
    -- Up: -8px Y
    local nonBlockingMovement = false
    local destination = { x = self.x, y = self.y }
    if dir == UP then
        if self:checkMovementEffect(self.x, self.y - 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = self.x
            destination.y = self.y - 8
        end
        -- Down: +8px Y
    elseif dir == DOWN then
        if self:checkMovementEffect(self.x, self.y + 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = self.x
            destination.y = self.y + 8
        end
        -- Left: -8px X
    elseif dir == LEFT then
        if self:checkMovementEffect(self.x - 8, self.y) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = self.x - 8
            destination.y = self.y
        end
        -- Right: +8px X
    elseif dir == RIGHT then
        if self:checkMovementEffect(self.x + 8, self.y) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = self.x + 8
            destination.y = self.y
        end
    end
    -- Regardless of valid movement, check effects
    self:activeEffectsProc()
    -- check for collisions with Enemy Actors
    if nonBlockingMovement then
        local actualPosX, actualPosY, collisionInfo, length = Player:moveWithCollisions(destination.x, destination.y)
        -- We have collided with an Enemy Actor
        if #collisionInfo >= 1 then
            -- 1 because there COULD be multiple collisions detected
            enemyActor = collisionInfo[1].other
            print("Collided with Actor: " .. enemyActor.name)
            self:meleeAttack(enemyActor)
        end
    end
    -- End of Player Phase, remove effects that have expired
    -- TODO: do we do this here?
    self:activeEffectsRemoval()
end

-- called when "bumping" into an Actor
-- param enemyActor: Actor class
function PlayerClass:meleeAttack(enemyActor)
    print("I'm attacking " .. enemyActor.name .. " with melee!")
    self.eqiuppedWeapon:useItem(enemyActor)
end

-- called to determine attack adjustments on Enemy Actor
-- param enemyActor: Actor class
-- param item: Item class of Item being used to deal some effect
function PlayerClass:hitCalculation(enemyActor, item)
    print("Rolling to effect: " .. enemyActor.name .. " with " .. item.name)
    -- DEBUG: will have actual hit chances here, for now just pass to hitEffect
    return 1
end

-- Called when entering player phase
-- Checks if any effects need to be removed from Player.activeEffects
-- Checks if any effects need to be applyed again this turn (someEffectTable.overTime == true)
function PlayerClass:activeEffectsProc()
    -- apply effects
    if #self.activeEffects ~= 0 then
        for k, v in pairs(self.activeEffects) do
            if v.overTime then
                print(v.name .. " is procing!")
                k:applyEffect(self)
            end
            -- decrement turn counter
            v.turns = v.turns - 1
        end
    end
end

-- Called at very end of player phase
-- Checks if any effects have a turn counter of zero and removes them from active effects.
function PlayerClass:activeEffectsRemoval()
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


-- END PLAYER --
