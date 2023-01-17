The Tile class derives from the Playdate "class" table. This allows for quickly creating Tiles with subclasses of our different dungeon tiles e.g wall, stairs, floor, etc. 
Each Tile table has 3 parts; the base tile table and its class, a roomId used ion the generation, and the playdate image object drawn to the screen as part of [[Level]] `printLevel()` 
Tile table has helper functions to determine what class the tile is, and if the tile is empty.

