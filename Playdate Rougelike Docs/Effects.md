Effects are tables that hold information regarding how different in game values should be altered. To keep things simple all effects are some numerical change in some [[Player]] or [[Actor]] value, e.g HP, MP, one of the stats like STR. reducing or buffing those values by some number.
### Example Simple Effect Table
`swordDamageET = {HP = -1, MP = 0, stats = {STR = 0, DEX = 0, CON = 0, INT = 0}, turns = 0}`
This table would be applyed to a [[Player]] or [[Actor]] to reduce their HP by 1.
The turns - 0 means this effect does not have a turn counter that would revert the effect after x turns (say a potion that buffs strength for 10 moves.)
Effects are a member of the [[Item]] class