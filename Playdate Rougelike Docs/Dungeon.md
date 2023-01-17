The `Dungeon` table holds the meta information about the dungeon being generated such as: number of levels to generate and store in `levels[]` . It can produce much larger dungeons but we are only using it to draw 30 x 50 to fit the playdates screen comfortably. It calls print dungeon to loop through the `levels[]` and call printLevel on each one. 
This needs to be modified to print only one level then when there is a level change (stairs?) the screen would be cleared and the next level will be drawn to screen and player placed on the opposing stair tile (down->up, up->down)
Not sure if we want to generate levels in batches? 
- [ ] #TODO Check memory usage of storing multiple levels in `dungeon.levels`

