import "CoreLibs/object"
import "CoreLibs/graphics"

----- Image Loading -----
goblinImg = playdate.graphics.image.new("images/GOBLIN")
batImg = playdate.graphics.image.new("images/BAT")
frogImg = playdate.graphics.image.new("images/FROG")
warlockImg = playdate.graphics.image.new("images/WARLOCK")
-- This file defines all actor information tables, seperated to keep clean
-- TODO: add other values to actor defs
goblin = {
    name = "Goblin",
    desc = "A nasty little man",
    image = goblinImg,
    hp = {min = 1, max = 3},
    mp = {min = 0, max = 0},
    stats = { STR = 1, DEX = 3, CON = 1, INT = 1 },
}

bat = {
    name = "Bat",
    desc = "Leather wings, blood and things",
    image = batImg,
    hp = {min = 1, max = 2},
    mp = {min = 0, max = 0},
    stats = { STR = 1, DEX = 4, CON = 1, INT = 1 },
}

frog = {
    name = "Frog",
    desc = "Froggie :)",
    image = frogImg,
    hp = {min = 3, max = 6},
    mp = {min = 2, max = 4},
    stats = { STR = 2, DEX = 2, CON = 1, INT = 1 }
}

warlock = {
    name = "Warlock",
    desc = "Mad with power, mad with magicks...",
    image = warlockImg,
    hp = {min = 6, max = 10},
    mp = {min = 8, max = 12},
    stats = { STR = 1, DEX = 1, CON = 2, INT = 4 }
}

