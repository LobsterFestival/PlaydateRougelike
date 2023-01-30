-- This file holds all the effects tables for various items, attacks, spells and abilities
-- TODO: finilize actual structure of what these tables should hold
import "CoreLibs/object"
local insert = table.insert

defaultEffectTable = {
    name = "defaultEffect",
    hp = 0,
    mp = 0,
    stats = { STR = 0, DEX = 0, CON = 0, INT = 0 },
    overTime = false, -- does this effect "pop" every turn
    turns = 0
}

basicMeleeAttack = {
    name = "Basic Melee Attack",
    hp = -1,
    mp = 0,
    stats = { STR = 0, DEX = 0, CON = 0, INT = 0 },
    overTime = false,
    turns = 0
}

-- STATS
str1turn10 = {
    name = "Buff STR +1 10 Turns",
    hp = 0,
    mp = 0,
    stats = { STR = 1, DEX = 0, CON = 0, INT = 0 },
    overTime = false,
    turns = 10
}

dex1turn10 = {
    name = "Buff DEX +1 10 Turns",
    hp = 0,
    mp = 0,
    stats = { STR = 0, DEX = 1, CON = 0, INT = 0 },
    overTime = false,
    turns = 10
}

con1turn10 = {
    name = "Buff CON +1 10 Turns",
    hp = 0,
    mp = 0,
    stats = { STR = 0, DEX = 0, CON = 1, INT = 0 },
    overTime = false,
    turns = 10
}

int1turn10 = {
    name = "Buff INT +1 10 Turns",
    hp = 0,
    mp = 0,
    stats = { STR = 0, DEX = 0, CON = 0, INT = 1 },
    overTime = false,
    turns = 10
}

-- DoTs and HoTs
hp1turn5 = {
    name = "Heal HP +1 5 turns",
    hp = 0,
    mp = 0,
    stats = { STR = 1, DEX = 0, CON = 0, INT = 0 },
    overTime = true,
    turns = 10
}