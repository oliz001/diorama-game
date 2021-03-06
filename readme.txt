Compatibility test v0.1.10.0
============================

* variable gravity directions (NORTH, SOUTH, EAST, WEST, UP, DOWN)
* infinite Height levels


compatibility demo v0.1.1
-------------------------

* Multiplayer added
  * max 32 players per server
  * server can be started with command line arguments
  * chat window added (press T)
  * players and player name visible in the game
  * server saves level on exit
  * server accepts command line args (-i input -s random_seed)
* different blocks available (press 1-9)
* menus reorganisation
* lua api extended:
  * mods split into client and server mods
  * render to texture available (dio.drawing.createRenderToTexture / setRenderToTexture)
  * render passes can be added (dio.drawing.addRenderPassBefore / addRenderPassAfter)
  * new events for dio.events.addListener:
	  CLIENT_CHAT_MESSAGE_RECEIVED
	  CLIENT_KEY_CLICKED
	  CLIENT_WINDOW_FOCUS_LOST
	  CLIENT_WINDOW_FOCUS_LOST
* BUGFIX: ESCAPE correctly opens / closes pause menu
* BUGFIX: multiple key presses per tick were raised in reverse order
* paint application added


compatibility demo v0.1.0
-------------------------

* Saves / Loads player position per level.
* Level height is user selectable.
* Block falling game temporarily added.
* Compressed level saves. Filesize approx 5% of v0.0.2.
* BUGFIX: Keypad ENTER acts like ENTER in menus.
* BUGFIX: players can't drop blocks over themselves.
* BUGFIX: players can't get stuck in unloaded chunk.
* BUGFIX: players can't get stuck when dropped into new levels.
* BUGFIX: Crosshair now behind the pause menu.
* BUGFIX: Better thread closure on exit.


Known Bugs
==========

* Meshes update slower than collision. You can walk in blocks you just destroyed.
* Delete World option doesn't always delete it fully! Delete it again!


Controls
========

WASD = movement
SPACE = jump
SHIFT + WASD = move (very) quickly)
LEFT MOUSE = destroy blocks
RIGHT MOUSE = place BRICK
