-- This file contains definitions for all Items and Equipment,
-- Each item def will have an an effect table that determines what it affects
-- Effect Table instance is created on Item Instance creation
import "CoreLibs/object"
import "CoreLibs/graphics"
import "EffectsDefinitions"

-- TODO: add and organize item images, May need multiple images, 8x8 for on the ground, larger for display in inventory screen
defaultItemImg = playdate.graphics.image.new("images/TILES/SOIL")
i_sword = {
    name = "Sword",
    desc = "A Sword, sharp!",
    image = defaultItemImg,
    effect = basicMeleeAttack
}

i_potionOfStrength = {
    name = "Potion of Strength",
    desc = "Increases STR by 1 for 10 Turns.",
    image = defaultItemImg,
    effect = str1turn10
}