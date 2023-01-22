import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Dungeon"

-- PLAYER --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

PLAYER_SPRITE_GROUP = 1
Player = {
    sprite = nil,
    hp = 10,
    mp = 10,
    stats = { STR = 1, DEX = 1, CON = 1, INT = 1 },
    inventory = {},
}

-- handles moving player between aStair and dStairs between dungeon.levels[] changes
-- params: stair: tile object of either aStair or dStair used to determine stair
-- to spawn on in level transported to
-- returns table of stair to spawn on, and whether we are goin up or down a level
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
function playerCurrentTile(x, y)
    local currentTile = coords2TilePos(x, y)
    local currentPlayerTile = dungeon.levels[currentLevel].matrix[currentTile.r][currentTile.c]
    return currentPlayerTile
end

-- Player Movement and intent
function checkMovementEffect(x, y)
    local nextTilePos = coords2TilePos(x, y)
    tileToMoveTo = dungeon.levels[1].matrix[nextTilePos.r][nextTilePos.c]
    if tileToMoveTo:isWall() then
        return 1
    end
    -- Bumping into Enemy Actor

    -- TODO: add checks for closed doors
end

function Player:moveIntent(dir)

    -- TODO: add calls to function for checking collisions with
    -- Actors, Items, etc.
    local currX = Player.sprite.x
    local currY = Player.sprite.y
    -- row and column of actors current position
    local currTileGridPos = coords2TilePos(currX, currY)
    -- Up: -8px Y
    local nonBlockingMovement = false
    local destination = { x = currX, y = currY }
    if dir == UP then
        if checkMovementEffect(currX, currY - 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = currX
            destination.y = currY - 8
        end
        -- Down: +8px Y
    elseif dir == DOWN then
        if checkMovementEffect(currX, currY + 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = currX
            destination.y = currY + 8
        end
        -- Left: -8px X
    elseif dir == LEFT then
        if checkMovementEffect(currX - 8, currY) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = currX - 8
            destination.y = currY
        end
        -- Right: +8px X
    elseif dir == RIGHT then
        if checkMovementEffect(currX + 8, currY) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            nonBlockingMovement = true
            destination.x = currX + 8
            destination.y = currY
        end
    end
    -- check for collisions with Enemy Actors
    if nonBlockingMovement then
        local actualPosX, actualPosY, collisionInfo, length = Player.sprite:moveWithCollisions(destination.x, destination.y)
        -- We have collided with an Enemy Actor
        if #collisionInfo >= 1 then
            -- 1 because there COULD be multiple collisions detected            
            enemyActor = collisionInfo[1].other
            print("Collided with Actor: "..enemyActor.name)
            Player:meleeAttack(enemyActor)
        end
    end
end

-- called when "bumping" into an Actor
-- param enemyActor: Actor class 
function Player:meleeAttack(enemyActor)
    print("I'm attacking something!")
    -- DEBUG: TODO: More complex Effects handling with effects tables later
    effectType = "melee"
    Player:hitCalculation(enemyActor, effectType)
end

-- TODO: ranged attacks are hard, do later
function Player:rangedAttack()
end

-- called to determine attack adjustments on Enemy Actor
-- param enemyActor: Actor class 
function Player:hitCalculation(enemyActor, effectTable)
    print("Rolling to effect: "..enemyActor.name.." with "..effectTable)
    enemyActor:hitEffect(effectTable)
end

-- Player will adjust hp,mp,stats, etc from enemy/item effect
function Player:hitEffect(effectTable)
    print("I was hit by "..effectTable..", adjusting effects")
end

-- END PLAYER --
