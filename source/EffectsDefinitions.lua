-- This file holds all the effects tables for various items, attacks, spells and abilities
-- TODO: finilize actual structure of what these tables should hold
import "CoreLibs/object"

basicMeleeAttackET = {
    hp = -1,
    mp = nil,
    stats = nil,
    turns = 0
}

buffStrength10 = {
    hp = 0,
    mp = 0,
    stats = {STR = 1, DEX = 0, CON = 0, INT = 0},
    turns = 10
}