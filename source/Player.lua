import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "Dungeon"

-- PLAYER --
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4

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
    -- TODO: add checks for closed doors
end

function Player:moveIntent(dir)

    -- TODO: add calls to function for checking collisions with
    -- Actors, Items, etc.
    currX = Player.sprite.x
    currY = Player.sprite.y
    -- row and column of actors current position
    currTileGridPos = coords2TilePos(currX, currY)
    -- Up: -8px Y
    if dir == UP then
        if checkMovementEffect(currX, currY - 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            Player.sprite:moveTo(currX, currY - 8)
        end
        -- Down: +8px Y
    elseif dir == DOWN then
        if checkMovementEffect(currX, currY + 8) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            Player.sprite:moveTo(currX, currY + 8)
        end
        -- Left: -8px X
    elseif dir == LEFT then
        if checkMovementEffect(currX - 8, currY) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            Player.sprite:moveTo(currX - 8, currY)
        end
        -- Right: +8px X
    elseif dir == RIGHT then
        if checkMovementEffect(currX + 8, currY) ~= 1 then
            addDirtyTile(currTileGridPos.r, currTileGridPos.c)
            Player.sprite:moveTo(currX + 8, currY)
        end
    end
end

-- END PLAYER --
