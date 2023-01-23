-- This file contains definitions for all Items and Equipment,
-- Each item will have an effect table that determines what it affects
import "CoreLibs/object"
import "CoreLibs/graphics"
import "EffectsDefinitions"

-- TODO: add and organize item images, May need multiple images, 8x8 for on the ground, larger for display in inventory screen
defaultItemImg = playdate.graphics.image.new("images/SOIL")
i_sword = {
    name = "Sword",
    desc = "A Sword, sharp!",
    image = defaultItemImg,
    effect = basicMeleeAttackET
}