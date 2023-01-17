The level class holds the `matrix` that contains the 2D array with the map arraned in a 30 x 50 array. The matrix is initilized with empty [[Tile]] tables. The tiles are placed into the `matrix` in a series of generation steps. Assume these steps produce decent levels as this is the bluk of the class. 
After the Tiles are placed in the matrix, they are printed to the screen in the `printLevel()` function by calling the `playdate.graphics:draw()` function on the `Tile.class` 
Levels are stored in the [[Dungeon]] class in a table `levels` 

On game start the [[Player]] will be randomly placed on a valid Floor [[Tile]] square. 
When moving up and down stairs, the [[Player]] will be placed on the next (or previous) levels down/up stair. 