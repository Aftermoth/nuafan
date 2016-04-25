Minetest mod: nuafan

==== NUA For Agnostic Nodes ==== 

Nuafan adds nua functionality to nodes from nua-ignorant mods.

Specifically, on_construct and after_destruct node update alerts,
 and user-defined callbacks allowing them to receive and respond
 to alerts as well.

A demo is enabled by default so you can play around with it in-game before deciding whether to use it seriously.
It reports nearby updates via chat.

requires: nua
https://github.com/Aftermoth/nua


Limitations:

1) Some node types already use on_construct or after_destruct to provide special functionality.
Nuafan cannot yet cooperate with existing definitions without breaking them, and so avoids altering them by default.

2) Some node types repeatedly and ceaselessly destruct/construct without changing type.
Nuafan cannot yet distinguish between real and fake changes, so its best option is not to signal events from those nodes at all, although they may still receive them.
Additionally, large numbers of those nodes spam the event queue quite heavily however they are handled, and could impact performance, especially if extra tests are required.

3) Map-generated nodes and trees do not receive extra functionality upon creation, although nodes in (2) and some plants aquire it without player intervention. This is generally desirable, although it can be difficult to remember which nodes of the same type are aware and which are not, e.g. between generated and user-placed stone.


----

Copyright (C) 2016 Aftermoth, Zolan Davis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License,
or (at your option) version 3 of the License.

http://www.gnu.org/licenses/lgpl-2.1.html

