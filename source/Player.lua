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

-- Player Movement and intent
function checkMovementEffect(x, y)
    rc = coords2TilePos(x, y)
    tileToMoveTo = dungeon.levels[1].matrix[rc[1]][rc[2]]
    if tileToMoveTo:isWall() then
        return 1
    end
    -- TODO: add checks for closed doors, up stairs and down stairs
end

function Player:moveIntent(dir)

    -- TODO: add calls to function for checking collisions with
    -- Walls, Actors, Items, etc.
    currX = Player.sprite.x
    currY = Player.sprite.y
    -- Up: -8px Y
    if dir == UP then
        if checkMovementEffect(currX, currY - 8) ~= 1 then
            Player.sprite:moveTo(currX, currY - 8)
        end
        -- Down: +8px Y
    elseif dir == DOWN then
        if checkMovementEffect(currX, currY + 8) ~= 1 then
            Player.sprite:moveTo(currX, currY + 8)
        end
        -- Left: -8px X
    elseif dir == LEFT then
        if checkMovementEffect(currX - 8, currY) ~= 1 then
            Player.sprite:moveTo(currX - 8, currY)
        end
        -- Right: +8px X
    elseif dir == RIGHT then
        if checkMovementEffect(currX + 8, currY) ~= 1 then
            Player.sprite:moveTo(currX + 8, currY)
        end
    end
end

-- END PLAYER --