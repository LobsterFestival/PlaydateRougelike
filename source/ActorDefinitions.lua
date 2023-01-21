import "CoreLibs/object"
import "CoreLibs/graphics"

----- Image Loading -----
goblinImg = playdate.graphics.image.new("images/GOBLIN")
batImg = playdate.graphics.image.new("images/BAT")
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