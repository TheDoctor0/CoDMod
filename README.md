# General
New generation of Call of Duty Mod for Counter-Strike 1.6 (AMXX 1.8.3 / 1.9).

Feel free to suggest new functionality, changes and of course please report any found bugs.

### Compatibility
Mod was tested on AMXX builds:
- 1.8.3-dev+5142
- 1.9-dev+5235

In both cases with ReHLDS and ReGameDLL also installed.

### Known issues
**"Cache_TryAlloc: 2331984 is greater then free hunk"** crash can be caused on maps with big .bsp file by multiple sprites loaded by *cod_icons.amxx* plugin.
You can fix it by doing one of those things:
1. Add *-heapsize 65535* to server launch options.
2. Uncomment *#define LITE* in *cod_icons.sma* and compile it locally to use version with smaller sprites.
