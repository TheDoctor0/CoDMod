# CoD Mod
Call of Duty Mod for Counter-Strike 1.6 (AMXX 1.8.3 / 1.9 / 1.10).

[Release pack](https://github.com/TheDoctor0/CoDMod/releases/latest) contains configuration and plugins with all needed resources: models, sounds, sprites etc.

Feel free to suggest new functionality, changes and of course please report any found bugs.

## Compatibility
Mod was tested on AMXX builds:
- 1.8.3-dev+5142
- 1.9-dev+5235
- 1.10-dev+5392

In both cases with ReHLDS and ReGameDLL also installed.

## Documentation
Online documentation with all natives, forwards and constants is available on [codmod.5v.pl](http://codmod.5v.pl/). You can also find it in [cod.inc](https://github.com/TheDoctor0/CoDMod/blob/master/cod.inc).

It is recommended to read docs, as there are many build-in features that make writing classes, items and others plugins much easier.

## Configuration
The configuration can be changed by cvars loaded from [cod_mod.cfg](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_mod.cfg).

All of available cvars have short descriptions.

Plugins can be enabled / disabled in [plugins-cod.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/plugins-cod.ini).

### Optional
Options for main menu are stored in [cod_menu.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_menu.ini).

Missions configuration is stored in [cod_missions.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_missions.ini).

Available skins are stored in [cod_skins.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/cod_skins.ini).

## Database
`cod_database.amxx` owns the whole schema. It has to be loaded first in [plugins-cod.ini](https://github.com/TheDoctor0/CoDMod/blob/master/resources/addons/amxmodx/configs/plugins-cod.ini) - the other plugins wait for its `cod_database_ready()` forward before they touch a table.

Tables: `cod_players`, `cod_classes`, `cod_stats`, `cod_missions`, `cod_clans`, `cod_clans_members`, `cod_clans_applications`, `cod_clans_wars`. Everything is keyed by `cod_players`.`player_id`.

### Migrations
Schema changes are applied as migrations, the same way Laravel does it. Applied migrations are recorded in `cod_migrations` (`id`, `migration`, `batch`, `ran_at`) and are never run twice, so a server can be updated by dropping in new plugins and restarting.

To add one, append a name to the `migrations` list in [cod_database.sma](https://github.com/TheDoctor0/CoDMod/blob/master/cod_database.sma) and a matching `case` to `run_migration()`. Never edit a migration that has already shipped - servers that ran it will not run it again.

### Upgrading an existing server
The first start moves the old tables aside (`cod_accounts` becomes `cod_legacy_accounts` and so on) and imports accounts, honor, classes, HUD settings, stats and clans into the new schema. The legacy tables are kept, so nothing is lost if the import needs to be repeated - drop the reworked tables together with the `cod_migrations` rows and restart.

Knife choices, free honor flags and mission progress lived in nvaults. They are imported the first time each player connects, so keep the `.vault` files in place for a while after the update.

## Additional

### Class promotion
Do you want to add promotions (advances) to classes?

Check [this example](https://github.com/TheDoctor0/CoDMod/blob/master/classes/codclass_promotions_example.sma) to learn how to do it.

### Item access
There are two supported options for defining access to item:
1. **Flag** (easy) - use *flag* parameter in *cod_register_item* native.
2. **Forward** (harder) - implement *cod_item_check* function in item plugin - [example in item Cien](https://github.com/TheDoctor0/CoDMod/blob/master/items/coditem_cien.sma#L22).

## Known issues
**"Cache_TryAlloc: 2331984 is greater then free hunk"** crash can be caused on maps with big .bsp file by multiple sprites loaded by *cod_icons.amxx* plugin.
You can fix it by doing one of those things:
1. Add *-heapsize 65535* to server launch options.
2. Uncomment *#define LITE* in *cod_icons.sma* and compile it locally to use version with smaller sprites.

## Servers
List of servers that are using this mod is available [HERE](https://www.gametracker.com/search/?search_by=server_variable&search_by2=cod_version&query=&loc=_all&sort=&order=).
