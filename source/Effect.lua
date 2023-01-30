import "CoreLibs/object"
import "EffectsDefinitions"
local insert = table.insert

EffectTable = {
    name = "defaultEffect",
    hp = 0,
    mp = 0,
    stats = { STR = 0, DEX = 0, CON = 0, INT = 0 },
    overTime = false, -- does this effect "pop" every turn
    turns = 0
}

EffectTable.__index = EffectTable

function EffectTable:create(effectTableDef)
    local o = effectTableDef
    setmetatable(o, EffectTable)
    o.name = effectTableDef.name
    o.hp = effectTableDef.hp
    o.mp = effectTableDef.mp
    o.stats = effectTableDef.stats
    o.overTime = effectTableDef.overTime
    o.turns = effectTableDef.turns
    return o
end

function EffectTable:applyEffect(actor)
    print("Applying " .. self.name .. " to " .. actor.name)
    -- Adjust actor values by effects values and add effect to actor currentEffects table
    print(actor.name.." current HP: "..actor.hp)
    actor.hp = actor.hp + self.hp
    actor.mp = actor.mp + self.mp
    actor.stats.STR = actor.stats.STR + self.stats.STR
    actor.stats.DEX = actor.stats.DEX + self.stats.DEX
    actor.stats.CON = actor.stats.CON + self.stats.CON
    actor.stats.INT = actor.stats.INT + self.stats.INT
    -- Put into actor activeEffects if its something that will revert in X turns
    if self.turns ~= 0 then
        -- TODO: multiple effects of same type might mess things up
        print("Adding")
        actor.activeEffects[self.name] = self
    end
end

function EffectTable:removeEffect(actor)
    print("Removing " .. self.name .. "from " .. actor.name)
    -- Adjust actor values by effects values and remove effect to actor currentEffects table
    actor.hp = actor.hp - self.hp
    actor.mp = actor.mp - self.mp
    actor.stats.STR = actor.stats.STR - self.stats.STR
    actor.stats.DEX = actor.stats.DEX - self.stats.DEX
    actor.stats.CON = actor.stats.CON - self.stats.CON
    actor.stats.INT = actor.stats.INT - self.stats.INT
    -- TODO: check this is actually correct way of removing
    actor.activeEffects[self.name] = nil
end
