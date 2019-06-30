# CoD Mod
New generation of Call of Duty Mod for Counter-Strike 1.6 (AMXX 1.8.3 / 1.9).

Feel free to suggest new functionality, changes and of course please report any found bugs.

## Compatibility
Mod was tested on AMXX builds:
- 1.8.3-dev+5142
- 1.9-dev+5235

In both cases with ReHLDS and ReGameDLL also installed.

## Documentation
Docs for all natives and forwards are available in [cod.inc](https://github.com/TheDoctor0/CoDMod/blob/master/cod.inc).

It is recommended to read it, as there are many build-in features that make writing classes, items and others plugins much easier.

## Configuration
The configuration can be changed by cvars loaded from [cod_mod.cfg](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_mod.cfg).

All of available cvars have short descriptions.

Plugins can be enabled / disabled in [plugins-cod.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/plugins-cod.ini).

### Optional
Options for main menu are stored in [cod_menu.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_menu.ini).

Missions configuration is stored in [cod_missions.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_missions.ini).

Available skins are stored in [cod_skins.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_skins.ini).

## Additional
Do you want to add promiotions (advances) to classes?

Check [this example](https://github.com/TheDoctor0/CoDMod/blob/master/classes/codclass_promotions_example.sma) to learn how to do it.

## Known issues
**"Cache_TryAlloc: 2331984 is greater then free hunk"** crash can be caused on maps with big .bsp file by multiple sprites loaded by *cod_icons.amxx* plugin.
You can fix it by doing one of those things:
1. Add *-heapsize 65535* to server launch options.
2. Uncomment *#define LITE* in *cod_icons.sma* and compile it locally to use version with smaller sprites.

## Servers
List of servers that are using this mod is available [HERE](https://www.gametracker.com/search/?search_by=server_variable&search_by2=cod_version&query=&loc=_all&sort=&order=).
