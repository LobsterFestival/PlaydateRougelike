import "CoreLibs/object"
import "CoreLibs/graphics"
local gfx <const> = playdate.graphics
----- Image Loading -----
goblinImg = gfx.image.new("images/GOBLIN")
batImg = gfx.image.new("images/BAT")
frogImg = gfx.image.new("images/FROG")
warlockImg = gfx.image.new("images/WARLOCK")
-- This file defines all actor information tables, seperated to keep clean
-- TODO: add other values to actor defs
goblin = {
    name = "Goblin",
    desc = "A nasty little man",
    image = goblinImg,
    hpRange = {min = 1, max = 3},
    mpRange = {min = 0, max = 0},
    stats = { STR = 1, DEX = 3, CON = 1, INT = 1 },
}

bat = {
    name = "Bat",
    desc = "Leather wings, blood and things",
    image = batImg,
    hpRange = {min = 1, max = 2},
    mpRange = {min = 0, max = 0},
    stats = { STR = 1, DEX = 4, CON = 1, INT = 1 },
}

frog = {
    name = "Frog",
    desc = "Froggy :)",
    image = frogImg,
    hpRange = {min = 3, max = 6},
    mpRange = {min = 2, max = 4},
    stats = { STR = 2, DEX = 2, CON = 1, INT = 1 }
}

warlock = {
    name = "Warlock",
    desc = "Mad with power, mad with magicks...",
    image = warlockImg,
    hpRange = {min = 6, max = 10},
    mpRange = {min = 8, max = 12},
    stats = { STR = 1, DEX = 1, CON = 2, INT = 4 }
}

