# General
New generation of Call of Duty Mod for Counter-Strike 1.6 (AMXX 1.8.3 / 1.9).

Feel free to suggest new functionality, changes and of course please report any found bugs.

### Compatibility
Mod was tested on AMXX builds:
- 1.8.3-dev+5142
- 1.9-dev+5235

In both cases with ReHLDS and ReGameDLL also installed.

### Known issues
**"Cache_TryAlloc: 2331984 is greater then free hunk"** can be caused on maps with big .bsp file by sprites loaded by *cod_icons.amxx* plugin.
You can disable this plugin or add *-heapsize 65535* to server launch options to fix it.
