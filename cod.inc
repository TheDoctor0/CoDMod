#if defined _cod_included
  #endinput
#endif
#define _cod_included

#if !defined client_print_color || !defined MAX_NAME_LENGTH
    #error NOTSUPPORT AMXX < 1.8.3!
#endif

#pragma unused codSounds

#define is_user_valid(%1) (1 <= %1 <= MAX_PLAYERS)

#define get_bit(%2,%1) (%1 & (1<<(%2&31)))
#define set_bit(%2,%1) (%1 |= (1<<(%2&31)))
#define rem_bit(%2,%1) (%1 &= ~(1 <<(%2&31)))

#define MAX_NAME      MAX_NAME_LENGTH
#define MAX_SAFE_NAME MAX_NAME * 2
#define MAX_DESC      256

#define COD_STOP      4
#define COD_CONTINUE  0
#define COD_BLOCK     -1.0
#define COD_FREEZE    0.1

#define FL_WATERJUMP  (1<<11)
#define FL_ONGROUND   (1<<9)

#define DMG_BULLET    (1<<1)
#define DMG_BURN      (1<<3)
#define DMG_FREEZE    (1<<4)
#define DMG_FALL      (1<<5)
#define DMG_NERVEGAS  (1<<16)
#define DMG_HEGRENADE (1<<24)
#define DMG_DYNAMITE  (1<<25)
#define DMG_MINE      (1<<26)
#define DMG_ROCKET    (1<<27)
#define DMG_THUNDER   (1<<28)
#define DMG_KILL      (1<<29)
#define DMG_REPEAT    (1<<30)
#define DMG_CODSKILL  (1<<31)

#define RENDER_ALWAYS (1<<1)
#define RENDER_MOVE   (1<<2)
#define RENDER_STAND  (1<<3)
#define RENDER_DUCK   (1<<4)
#define RENDER_SHIFT  (1<<5)

enum _:sounds { SOUND_SELECT, SOUND_EXIT, SOUND_START, SOUND_START2, SOUND_LVLUP, SOUND_LVLUP2, SOUND_LVLUP3, SOUND_DEPLOY, SOUND_ACTIVATE,
	SOUND_CHARGE, SOUND_PICKUP, SOUND_THUNDER, SOUND_ONE, SOUND_LAST, SOUND_FORCE, SOUND_HUMILIATION, SOUND_BOMB, SOUND_APPLAUSE, SOUND_LAUGH };
enum _:icons { BOMBSITE_A, BOMBSITE_B, BOMB_DROP, BOMB_PLANT, BOMB_EXPLODE, BOX };
enum _:promotions { PROMOTION_NONE, PROMOTION_FIRST, PROMOTION_SECOND, PROMOTION_THIRD };
enum _:types { RANDOM = -3, FULL, NONE, CLASS, ITEM, ADDITIONAL, ROUND, USED, ALL };
enum _:repeating { FIRE, POISON, HEAL };
enum _:hud { TYPE_HUD, TYPE_DHUD };

new const codSounds[sounds][] = {
	"CoDMod/select.wav",
	"CoDMod/close.wav",
	"CoDMod/start.wav",
	"CoDMod/start2.wav",
	"CoDMod/levelup.wav",
	"CoDMod/levelup2.wav",
	"CoDMod/levelup3.wav",
	"CoDMod/deploy.wav",
	"CoDMod/activate.wav",
	"CoDMod/charge.wav",
	"CoDMod/pickup.wav",
	"CoDMod/thunder.wav",
	"CoDMod/one.wav",
	"CoDMod/last.wav",
	"CoDMod/force.wav",
	"CoDMod/humiliation.wav",
	"CoDMod/bomb.wav",
	"CoDMod/applause.wav",
	"CoDMod/laugh.wav"
};

/*------------------------------
Return if player is logged in his account.
Account menu is diplayed if not logged in.
------------------------------*/
native cod_check_account(id);

/*------------------------------
Return if player has a VIP.
------------------------------*/
native bool:cod_get_user_vip(id);

/*------------------------------
Return player's honor amount.
------------------------------*/
native cod_get_user_honor(id);

/*------------------------------
Set player's honor amount.
If bonus is true honor bonus will be calculated.
------------------------------*/
native cod_set_user_honor(id, value, bonus = false);

/*------------------------------
Add value to player's honor amount.
If bonus is true honor bonus will be calculated.
------------------------------*/
native cod_add_user_honor(id, value, bonus = false);

/*------------------------------
Return clan id.
------------------------------*/
native cod_get_user_clan(id);

/*------------------------------
Return clan's name by clan id.
------------------------------*/
native cod_get_clan_name(clan, dataReturn[], dataLength);

/*------------------------------
Return player's mission id.
NONE (-1) if player have no mission in progress.
------------------------------*/
native cod_get_user_mission(id);

/*------------------------------
Return player's mission progress.
------------------------------*/
native cod_get_user_mission_progress(id);

/*------------------------------
Return player's mission need.
------------------------------*/
native cod_get_user_mission_need(id);

/*------------------------------
Spawns an icon with defined type.
Icon entity will be saved in ent pev_user1.
------------------------------*/
native cod_spawn_icon(ent, type = BOX);

/*------------------------------
Return player's gametime in seconds.
------------------------------*/
native cod_get_user_time(id);

/*------------------------------
Return player's gametime as text with hours, minutes, seconds.
------------------------------*/
native cod_get_user_time_text(id, dataReturn[], dataLength);

/*------------------------------
Return player's exp.
------------------------------*/
native cod_get_user_exp(id);

/*------------------------------
Set player's gained exp.
If bonus = 1 exp bonus will be applied.
To remove exp use negative value.
------------------------------*/
native cod_set_user_exp(id, value, bonus = 0);

/*------------------------------
Return exp multiplied by player's exp bonus.
------------------------------*/
native cod_get_user_bonus_exp(id, value);

/*------------------------------
Return exp needed for level.
------------------------------*/
native cod_get_level_exp(level);

/*------------------------------
Return player's level.
------------------------------*/
native cod_get_user_level(id);

/*------------------------------
Return player's highest level.
------------------------------*/
native cod_get_user_highest_level(id);

/*------------------------------
Return player's class and promotion if necessary.
------------------------------*/
native cod_get_user_class(id, &promotion = 0);

/*------------------------------
Return player's class name.
------------------------------*/
native cod_get_user_class_name(id, dataReturn[], dataLength);

/*------------------------------
Return player's promotion.
------------------------------*/
native cod_get_user_promotion(id);

/*------------------------------
Set player's class.
When force = 1 the change is immediate.
------------------------------*/
native cod_set_user_class(id, class, force = 0);

/*------------------------------
Return class using class name.
------------------------------*/
native cod_get_class_id(szClass[]);

/*------------------------------
Return class name.
------------------------------*/
native cod_get_class_name(class, promotion = 0, dataReturn[], dataLength);

/*------------------------------
Return class description.
------------------------------*/
native cod_get_class_desc(class, promotion = 0, dataReturn[], dataLength);

/*------------------------------
Return class health bonus.
------------------------------*/
native cod_get_class_health(class, promotion = 0);

/*------------------------------
Return class intelligence bonus.
------------------------------*/
native cod_get_class_intelligence(class, promotion = 0);

/*------------------------------
Return class stamina bonus.
------------------------------*/
native cod_get_class_stamina(class, promotion = 0);

/*------------------------------
Return class strength bonus.
------------------------------*/
native cod_get_class_strength(class, promotion = 0);

/*------------------------------
Return class condition bonus.
------------------------------*/
native cod_get_class_condition(class, promotion = 0);

/*------------------------------
Return classes number.
------------------------------*/
native cod_get_classes_num();

/*------------------------------
Return item and assigns value of item to variable.
------------------------------*/
native cod_get_user_item(id, &value = 0);

/*------------------------------
Return value of user item.
------------------------------*/
native cod_get_user_item_value(id);

/*------------------------------
Return user item name.
------------------------------*/
native cod_get_user_item_name(id, dataReturn[], dataLength);

/*------------------------------
Set player's item.
If item = RANDOM (-3) an item will be random.
If value = RANDOM (-3) item value will be random.
------------------------------*/
native cod_set_user_item(id, item = 0, value = RANDOM);

/*------------------------------
Upgrades player's item.
If check = 1 Return if item is upgradable.
------------------------------*/
native cod_upgrade_user_item(id, check = 0);

/*------------------------------
Return item id using item name.
------------------------------*/
native cod_get_item_id(szItem[]);

/*------------------------------
Return item name.
------------------------------*/
native cod_get_item_name(item, dataReturn[], dataLength);

/*------------------------------
Return item description.
------------------------------*/
native cod_get_item_desc(item, dataReturn[], dataLength);

/*------------------------------
Return items number.
------------------------------*/
native cod_get_items_num();

/*------------------------------
Retuns player's item durability.
------------------------------*/
native cod_get_item_durability(id);

/*------------------------------
Set's player's item durability.
------------------------------*/
native cod_set_item_durability(id, durability);

/*------------------------------
Return max item durability.
------------------------------*/
native cod_max_item_durability();

/*------------------------------
Return player's maximum health points
------------------------------*/
native cod_get_user_max_health(id);

/*------------------------------
Set player's health point.
If maximum = 1 player's max health limit is applied.
------------------------------*/
native cod_set_user_health(id, value, maximum = 1);

/*------------------------------
Add value to player's health point.
If maximum = 1 player's max health limit is applied.
------------------------------*/
native cod_add_user_health(id, value, maximum = 1);

/*------------------------------
Return health statistic points.
If currentHealth = 1 Return current health points.
If classHealth = 1 adds class health points.
If statsHealth = 1 adds stats health points.
If bonusHealth = 1 adds extra health points.
If baseHealth = 1 adds base 100HP.
------------------------------*/
native cod_get_user_health(id, currentHealth = 0, classHealth = 1, statsHealth = 1, bonusHealth = 1, baseHealth = 0);

/*------------------------------
Return intelligence statistic points.
If classIntelligence = 1 adds class intelligence points.
If statsIntelligence = 1 adds stats intelligence points.
If bonusIntelligence = 1 adds extra intelligence points.
------------------------------*/
native cod_get_user_intelligence(id, classIntelligence = 1, statsIntelligence = 1, bonusIntelligence = 1);

/*------------------------------
Return stamina statistic points.
If classStamina = 1 adds class stamina points.
If statsStamina = 1 adds stats stamina points.
If bonusStamina = 1 adds extra stamina points.
------------------------------*/
native cod_get_user_stamina(id, classStamina = 1, statsStamina = 1, bonusStamina = 1);

/*------------------------------
Return strength statistic points.
If classStrength = 1 adds class strength points.
If statsStrength = 1 adds stats strength points.
If bonusStrength = 1 adds extra strength points.
------------------------------*/
native cod_get_user_strength(id, classStrength = 1, statsStrength = 1, bonusStrength = 1);

/*------------------------------
Return condition statistic points.
If classCondition = 1 adds class condition points.
If statsCondition = 1 adds stats condition points.
If bonusCondition = 1 adds extra condition points.
------------------------------*/
native cod_get_user_condition(id, classCondition = 1, statsCondition = 1, bonusCondition = 1);

/*------------------------------
Return player's extra health points.
------------------------------*/
native cod_get_user_bonus_health(id);

/*------------------------------
Return player's extra intelligence points.
------------------------------*/
native cod_get_user_bonus_intelligence(id);

/*------------------------------
Return player's extra stamina points.
------------------------------*/
native cod_get_user_bonus_stamina(id);

/*------------------------------
Return player's extra strength points.
------------------------------*/
native cod_get_user_bonus_strength(id);

/*------------------------------
Return player's extra condition points.
------------------------------*/
native cod_get_user_bonus_condition(id);

/*------------------------------
Set player's extra health points.
------------------------------*/
native cod_set_user_bonus_health(id, value);

/*------------------------------
Set player's extra intelligence points.
------------------------------*/
native cod_set_user_bonus_intelligence(id, value);

/*------------------------------
Set player's extra stamina points.
------------------------------*/
native cod_set_user_bonus_stamina(id, value);

/*------------------------------
Set player's extra strength points.
------------------------------*/
native cod_set_user_bonus_strength(id, value);

/*------------------------------
Add value to player's extra condition points.
------------------------------*/
native cod_set_user_bonus_condition(id, value);

/*------------------------------
Add value to player's extra health points.
------------------------------*/
native cod_add_user_bonus_health(id, value);

/*------------------------------
Add value to player's extra intelligence points.
------------------------------*/
native cod_add_user_bonus_intelligence(id, value);

/*------------------------------
Add value to player's extra stamina points.
------------------------------*/
native cod_add_user_bonus_stamina(id, value);

/*------------------------------
Add value to player's extra strength points.
------------------------------*/
native cod_add_user_bonus_strength(id, value);

/*------------------------------
Add value to player's extra condition points.
------------------------------*/
native cod_add_user_bonus_condition(id, value);

/*------------------------------
Return player's rockets amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_rockets(id, type = ALL);

/*------------------------------
Return player's mines amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_mines(id, type = ALL);

/*------------------------------
Return player's medkits amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_medkits(id, type = ALL);

/*------------------------------
Return player's dynamites amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_dynamites(id, type = ALL);

/*------------------------------
Return player's thunders amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_thunders(id, type = ALL);

/*------------------------------
Return player's teleports amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_teleports(id, type = ALL);

/*------------------------------
Return player's multijumps amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_multijumps(id, type = ALL);

/*------------------------------
Return player's gravity amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native Float:cod_get_user_gravity(id, type = ALL);

/*------------------------------
Return player's speed bonus amount.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native Float:cod_get_user_speed(id, type = ALL);

/*------------------------------
Return player's armor amount.
------------------------------*/
native cod_get_user_armor(id);

/*------------------------------
Set player's rockets amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_rockets(id, value, type = ROUND);

/*------------------------------
Set player's mines amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_mines(id, value, type = ROUND);

/*------------------------------
Set player's medkits amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_medkits(id, value, type = ROUND);

/*------------------------------
Set player's dynamites amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_dynamites(id, value, type = ROUND);

/*------------------------------
Set player's thunders amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_thunders(id, value, type = ROUND);

/*------------------------------
Set player's teleports amount. Value = FULL (-2) for unlimited teleports.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_teleports(id, value, type = ROUND);

/*------------------------------
Set player's multijumps amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_multijumps(id, value, type = ROUND);

/*------------------------------
Set player's gravity amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
Lower gravity (but higher than 0) has priority and will be reduced by gravity lower than 0.
------------------------------*/
native cod_set_user_gravity(id, Float:value, type = ROUND);

/*------------------------------
Set player's speed bonus - can be lower than 0. Alternative to Condition bonus.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
Player speed is calculated from base speed, condition bonus and speed bonus.
Higher speed bonus has priority, but still will be reduced by bonuses lower than 0.
Set value to COD_FREEZE (0.1) to prevent player from moving.
------------------------------*/
native cod_set_user_speed(id, Float:value, type = ROUND);

/*------------------------------
Set player's armor amount.
------------------------------*/
native cod_set_user_armor(id, value);

/*------------------------------
Add value to player's rockets amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_rockets(id, value, type = ROUND);

/*------------------------------
Add value to player's mines amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_mines(id, value, type = ROUND);

/*------------------------------
Add value to player's medkits amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_medkits(id, value, type = ROUND);

/*------------------------------
Add value to player's dynamites amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_dynamites(id, value, type = ROUND);

/*------------------------------
Add value to player's thunders amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_thunders(id, value, type = ROUND);

/*------------------------------
Add value to player's teleports amount. Value = FULL (-2) for unlimited teleports.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_teleports(id, value, type = ROUND);

/*------------------------------
Add value to player's multijumps amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_multijumps(id, value, type = ROUND);

/*------------------------------
Add value to player's gravity amount.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - others, ROUND - until round end.
------------------------------*/
native cod_add_user_gravity(id, Float:value, type = ROUND);

/*------------------------------
Add value to player's speed amount. Alternative to Condition bonus.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_add_user_speed(id, Float:value, type = ROUND);

/*------------------------------
Add value to player's armor amount.
------------------------------*/
native cod_add_user_armor(id, value);

/*------------------------------
Use player's rocket.
------------------------------*/
native cod_use_user_rocket(id);

/*------------------------------
Use player's rocket.
------------------------------*/
native cod_use_user_mine(id);

/*------------------------------
Use player's dynamite.
------------------------------*/
native cod_use_user_dynamite(id);

/*------------------------------
Use player's thunder.
------------------------------*/
native cod_use_user_thunder(id);

/*------------------------------
Use player's medkit.
------------------------------*/
native cod_use_user_medkit(id);

/*------------------------------
Use player's teleport.
------------------------------*/
native cod_use_user_teleport(id);

/*------------------------------
Return if player has resistance for cod skills.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - others, ROUND - until round end.
------------------------------*/
native cod_get_user_resistance(id, type = ALL);

/*------------------------------
Return if player has god mode.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - others, ROUND - until round end.
------------------------------*/
native cod_get_user_godmode(id, type = ALL);

/*------------------------------
Return if player has noclip.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - others, ROUND - until round end.
------------------------------*/
native cod_get_user_noclip(id, type = ALL);

/*------------------------------
Return if player has bunnyhop.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - others, ROUND - until round end.
------------------------------*/
native cod_get_user_bunnyhop(id, type = ALL);

/*------------------------------
Return if player has silent walk.
Type can be ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_get_user_footsteps(id, type = ALL);

/*------------------------------
Return if player has model of the opponent.
Type can be ALL - overal, CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_get_user_model(id, type = ALL);

/*------------------------------
Return if player has clip unlimited ammo.
Type can be ALL - overal, CLASS - for class, ITEM - for item, ADDITIONAL - others.
Weapon defines if defined weapons condition has to be checked.
------------------------------*/
native cod_get_user_unlimited_ammo(id, type = ALL, weapon = 0);

/*------------------------------
Return if player has recoil eliminator.
Type can be ALL - overal, CLASS - for class, ITEM - for item, ADDITIONAL - others.
Weapon defines if defined weapons condition has to be checked.
------------------------------*/
native cod_get_user_recoil_eliminator(id, type = ALL, weapon = 0);

/*------------------------------
Return if player has recoil reducer.
Type can be ALL - overal, CLASS - for class, ITEM - for item, ADDITIONAL - others.
Weapon defines if defined weapons condition has to be checked.
------------------------------*/
native cod_get_user_recoil_reducer(id, type = ALL, weapon = 0);

/*------------------------------
Set player's bunnyhop.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_bunnyhop(id, value, type = ROUND);

/*------------------------------
Set player's silent walk.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_footsteps(id, value, type = ROUND);

/*------------------------------
Set player's model of the opponent.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_model(id, value, type = ROUND);

/*------------------------------
Set player's resistance for powers.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_resistance(id, value, type = ROUND);

/*------------------------------
Set player's god mode.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_godmode(id, value, type = ROUND);

/*------------------------------
Set player's noclip.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_set_user_noclip(id, value, type = ROUND);

/*------------------------------
Set player's unlimited clip ammo.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
Weapon is weapon id (1<<CSW_ format) or FULL for all weapons.
------------------------------*/
native cod_set_user_unlimited_ammo(id, value, type = ROUND, weapon = FULL);

/*------------------------------
Set player's recoil eliminator.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
Weapon is weapon id (1<<CSW_ format) or FULL for all weapons.
------------------------------*/
native cod_set_user_recoil_eliminator(id, value, type = ROUND, weapon = FULL);

/*------------------------------
Set player's recoil reducer.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
Weapon is weapon id (1<<CSW_ format) or FULL for all weapons.
------------------------------*/
native cod_set_user_recoil_reducer(id, value, type = ROUND, weapon = FULL);

/*------------------------------
Give player a weapon and allows player to own it.
Amount is only for adding multiple nades at once and is not used for normal weapons.
------------------------------*/
native cod_give_weapon(id, weapon, amount = 0);

/*------------------------------
Remove a weapon from player's inventory and disallows to own it.
------------------------------*/
native cod_take_weapon(id, weapon);

/*------------------------------
Return player's current weapon.
------------------------------*/
native cod_get_user_weapon(id);

/*------------------------------
Return player's render amount.
Type can be NONE - at this moment (with status and weapon rules applied), ALL - overall, CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
------------------------------*/
native cod_get_user_render(id, type = NONE);

/*------------------------------
Set player's render.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - bonus, ROUND - until round end.
There can be only one render for CLASS, ITEM, ADDITIONAL, but multiple for ROUND - every set adds new render record.
Value is number from -255 to 255 (256 to disable), but for CLASS type must be 0 or more
(negative numbers substract it from player's current render value, positive and 0 sets it to this value).
Status is player state for render. It can be a bitsum of RENDER_ALWAYS, RENDER_STAND, RENDER_MOVE, RENDER_DUCK, RENDER_SHIFT.
Weapon is weapon id (1<<CSW_ format) or FULL for all weapons.
Timer sets render value for certain amount of time - it ignores type, status and weapon.
------------------------------*/
native cod_set_user_render(id, value, type = ROUND, status = RENDER_ALWAYS, weapon = FULL, Float:timer = 0.0);

/*------------------------------
Set player's render glow.
Usage is the same as in set_user_rendering native.
Timer sets glow for certain amount of time.
------------------------------*/
native cod_set_user_glow(id, effect, red, green, blue, model, amount, Float:timer = 0.0);

/*------------------------------
Print chat message with [CoD] prefix.
Color formaters are allowed as in client_print_color.
------------------------------*/
native cod_print_chat(id, const text[], any:...);

/*------------------------------
Log error to cod_mod.log file.
For plugin param __BINARY__ or PLUGIN constants should be used.
------------------------------*/
native cod_log_error(const plugin[] = "CoD Mod", const text[], any:...);

/*------------------------------
Execute command on player with bypassing protectors (most of them).
------------------------------*/
native cod_cmd_execute(id, const text[], any:...);

/*------------------------------
Prepare safe sql string for query.
------------------------------*/
native cod_sql_string(const source[], dest[], length);

/*------------------------------
Diplay text in HUD/DHUD.
Type can be TYPE_HUD or TYPE_DHUD.
HUD/DHUD params usage is the same as in set_hudmessage/set_dhudmessage.
------------------------------*/
native cod_show_hud(id, type = 0, red = 255, green = 255, blue = 255, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxtime = 6.0, Float:holdTime = 12.0, Float:fadeInTime = 0.1, Float:fadeOutTime = 0.2, const text[], any:...);

/*------------------------------
Display screen fade.
Duration and holdtime are time seconds.
Fadetype is fade display type:
- FFADE_IN 0x0000
- FFADE_OUT 0x0001
- FFADE_MODULATE 0x0002
- FFADE_STAYOUT 0x0004
Red, green, blue is fade color in RGB
Alpha is fade power from 0 to 255
------------------------------*/
native cod_display_fade(id, duration, holdTime, fadeType, red, green, blue, alpha);

/*------------------------------
Display status icon.
Red, green, blue is status color in RGB - not required if hiding icon.
Icon is status icon name - all icons can be found here: https://forums.alliedmods.net/showthread.php?t=52529.
Enable defines if show or hide icon.
------------------------------*/
native cod_display_icon(id, const icon[], enable = 0, red = 0, green = 0, blue = 0);

/*------------------------------
Display bartimer.
Duration is time in seconds.
Start is value from 0-100 and specifies from what percent of bar it starts.
------------------------------*/
native cod_make_bartimer(id, duration = 0, start = 0);

/*------------------------------
Shake player's screen.
Amplitude is power of shakes.
Duration is time in seconds.
Frequency is noise frequency.
------------------------------*/
native cod_screen_shake(id, amplitude = (7<<14), duration = (1<<13), frequency = (1<<14));

/*------------------------------
Refill player's clip ammo.
------------------------------*/
native cod_refill_ammo(id);

/*------------------------------
Make an explosion around ent.
Distance specifies beam distance.
Explosion is explosion effect.
Damage_distance is distance from ent where players will be hurt.
Damage specifies damage dealt to players in damage_distance.
Factor is intelligence bonus for damage.
Suicide is decision if player will die after explosion
------------------------------*/
native cod_make_explosion(ent, distance = 0, explosion = 1, Float:damageDistance = 0.0, Float:damage = 0.0, Float:factor = 0.5, suicide = 0);

/*------------------------------
Make repeating damage to player.
Attacker is player that makes damage.
Victim is player that is receiving damage.
Damage is damage amount. If damage = 0.0 previous task will be removed and no task created.
Time is interval between damage. If time = 0.0 previous task will be removed and no task created.
Counter is how many times make damage. If counter = 0 effect will last till player death or round end - usefull for constant healing.
Flags is damage flag (DMG_ format).
Flags can also be FIRE, POISON or HEAL (healing player instead of huring) if want to use custom effects out of the box.
Instant makes first damage immediately.
------------------------------*/
native cod_repeat_damage(attacker, victim, Float:damage = 0.0, Float:time = 0.0, counter = 1, flags = DMG_CODSKILL, instant = 1);

/*------------------------------
Make damage with intelligence factor.
Factor is intelligence bonus for damage.
Flags are damage flags (DMG_CODSKILL flag will be added).
------------------------------*/
native cod_inflict_damage(attacker, victim, Float:damage, Float:factor = 0.5, flags = 0);

/*------------------------------
Kill a player imitating kill by another player.
Return COD_BLOCK.
------------------------------*/
native Float:cod_kill_player(attacker, victim, damageBits);

/*------------------------------
Respawn player after defined time (0.1 for immediate respawn).
If enemy is true will respawn player on enemy spawn.
------------------------------*/
native cod_respawn_player(id, enemy = 0, Float:time = 0.1);

/*------------------------------
Teleport player to spawn.
If enemy is true will teleport player to enemy spawn.
------------------------------*/
native cod_teleport_to_spawn(id, enemy = 0);

/*------------------------------
Random item upgrade.
Value is current item value.
UpgradeMin is minimum upgrade value (can be lower than 0).
UpgradeMax is maximum upgrade value.
ValueMin is minimum item value. If reached function will return COD_STOP.
ValueMax is maximum item value. If reached function will return COD_STOP.
Returned item value will always be at least 0.
------------------------------*/
native cod_random_upgrade(&value, upgradeMin = -1, upgradeMax = 1, valueMin = NONE, valueMax = NONE);

/*------------------------------
Return true/false result for given percent chance.
------------------------------*/
native bool:cod_percent_chance(percent);

/*------------------------------
Return if there is enough space for ent (or origin) with defined minimum distance in units.
------------------------------*/
native bool:cod_is_enough_space(ent, Float:distance = 120.0);

/*------------------------------
Remove all ents with specified className.
If id > 0 will remove only ents owned by that player.
------------------------------*/
native cod_remove_ents(id = 0, className[]);

/*------------------------------
Register new item and return its id.
ValueMin is normal item value or random min value.
ValueMax is random max value.
Those values are used for item description and generating random value passed to item plugin.
------------------------------*/
native cod_register_item(const name[], const description[], valueMin = 0, valueMax = 0);

/*------------------------------
Register new class and return its id.
------------------------------*/
native cod_register_class(const name[], const description[], const fraction[], weapons, health, intelligence, strength, stamina, condition, flag = NONE);

/*------------------------------
Register new class promotion and return its id.
Values weapons to flag will be copied from class if not specified.
------------------------------*/
native cod_register_promotion(const name[], const description[], const className[], level, promotion, weapons = NONE, health = NONE, intelligence = NONE, strength = NONE, stamina = NONE, condition = NONE, flag = NONE);

/*------------------------------
Multiforward executed when player's class is changed.
------------------------------*/
forward cod_class_changed(id, class);

/*------------------------------
Multiforward executed when player's item is changed.
------------------------------*/
forward cod_item_changed(id, item);

/*------------------------------
Multiforward executed when player's render is changed.
------------------------------*/
forward cod_render_changed(id, render);

/*------------------------------
Multiforward executed when player's gravity is changed.
------------------------------*/
forward cod_gravity_changed(id, Float:gravity);

/*------------------------------
Multiforward executed when player's gravity is changed.
------------------------------*/
forward cod_speed_changed(id, Float:speed);

/*------------------------------
Multiforward executed on damage event before armor reduce.
Damage will be blocked if COD_BLOCK is returned.
------------------------------*/
forward cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits, hitPlace);

/*------------------------------
Multiforward executed on damage event after armor reduce.
Damage will be blocked if COD_BLOCK is returned.
------------------------------*/
forward cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace);

/*------------------------------
Multiforward executed on cod_inflict_damage use which is not registered by HamTakeDamage.
Flags param will contain sum with custom DMG_ flags: DMG_DYNAMITE, DMG_MINE, DMG_ROCKET, DMG_THUNDER, DMG_KIll
so damage type can be easily identified.
Damage will be blocked if COD_BLOCK is returned.
------------------------------*/
forward cod_damage_inflict(attacker, victim, Float:damage, Float:factor, flags);

/*------------------------------
Multiforward executed on weapon deploy event.
Id is player id.
Weapon is CSW_ format.
Ent is weapon entity.
------------------------------*/
forward cod_weapon_deploy(id, weapon, ent);

/*------------------------------
Multiforward executed on cur weapon event.
Id is player id.
Weapon is CSW_ format.
------------------------------*/
forward cod_cur_weapon(id, weapon);

/*------------------------------
Multiforward executed on team assign event.
Id is player id.
Team is player team.
0 - unassigned
1 - terrorist
2 - counter-terrorist
3 - spectator
------------------------------*/
forward cod_team_assign(id, team);

/*------------------------------
Multiforward executed on death event.
------------------------------*/
forward cod_killed(killer, victim, weapon, hitPlace);

/*------------------------------
Multiforward executed on player spawn event.
Respawn is true if it's not first spawn of this player in this round.
------------------------------*/
forward cod_spawned(id, respawn);

/*------------------------------
Multiforward executed on cmd start event.
Id is player id.
Button is button pressed right now.
Oldbutton is last pressed button.
Player state have types RENDER_ALWAYS, RENDER_STAND, RENDER_MOVE, RENDER_DUCK, RENDER_SHIFT.
------------------------------*/
forward cod_cmd_start(id, button, oldButton, playerState);

/*------------------------------
Multiforward executed on player prethink.
------------------------------*/
forward cod_player_prethink(id);

/*------------------------------
Multiforward executed on bomb planting event.
Id is player id.
------------------------------*/
forward cod_bomb_planting(id);

/*------------------------------
Multiforward executed on bomb planted event.
Id is player id.
------------------------------*/
forward cod_bomb_planted(id);

/*------------------------------
Multiforward executed on bomb defusing event.
Id is player id.
------------------------------*/
forward cod_bomb_defusing(id);

/*------------------------------
Multiforward executed on bomb defused event.
Id is player id.
------------------------------*/
forward cod_bomb_defused(id);

/*------------------------------
Multiforward executed on bomb explode event.
Planter is id for player that planted the bomb.
Defuser is id for player that was defusing the bomb (can be empty).
------------------------------*/
forward cod_bomb_explode(planter, defuser);

/*------------------------------
Multiforward executed on bomb dropped event.
Id is player id.
------------------------------*/
forward cod_bomb_dropped(id);

/*------------------------------
Multiforward executed on bomb picked event.
Id is player id.
------------------------------*/
forward cod_bomb_picked(id);

/*------------------------------
Multiforward executed on hostage killed event.
Id is player id.
------------------------------*/
forward cod_hostage_killed(id);

/*------------------------------
Multiforward executed on hostage rescued event.
Id is player id.
------------------------------*/
forward cod_hostage_rescued(id);

/*------------------------------
Multiforward executed on hostages rescued event.
Id is player id.
------------------------------*/
forward cod_hostages_rescued(id);

/*------------------------------
Multiforward executed on new round event.
------------------------------*/
forward cod_new_round();

/*------------------------------
Multiforward executed on round start event.
------------------------------*/
forward cod_start_round();

/*------------------------------
Multiforward executed on round restart event.
------------------------------*/
forward cod_restart_round();

/*------------------------------
Multiforward executed on round end event.
------------------------------*/
forward cod_end_round();

/*------------------------------
Multiforward executed on round win event.
Team is team that won this round.
1 - terrorist
2 - counter-terrorist
------------------------------*/
forward cod_win_round(team);

/*------------------------------
Multiforward executed on map end (message intermission) event.
------------------------------*/
forward cod_end_map();

/*------------------------------
Multiforward executed on medkit player heal.
Id is medkit owner.
Player is healed player.
Healed is healed hp.
Healing will be blocked if COD_BLOCK is returned.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_medkit_heal(id, player, Float:healed);

/*------------------------------
Multiforward executed on rocket explosion (when there is damage).
Id is rocket owner.
Player is hurt player.
Damage is damage that rocket made to player.
Damage will be blocked if COD_BLOCK is returned.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_rocket_explode(id, player, Float:damage);

/*------------------------------
Multiforward executed on mine explosion (when there is damage).
Id is mine owner.
Player is hurt player.
Damage is damage that mine made to player.
Damage will be blocked if COD_BLOCK is returned.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_mine_explode(id, player, Float:damage);

/*------------------------------
Multiforward executed on dynamite explosion (when there is damage).
Id is dynamite owner.
Player is hurt player.
Damage is damage that dynamite made to player.
Damage will be blocked if COD_BLOCK is returned.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_dynamite_explode(id, player, Float:damage);

/*------------------------------
Multiforward executed on thunder player reach.
Id is thunder owner.
Player is hurt player.
Damage is damage that thunder made to player.
Damage will be blocked if COD_BLOCK is returned.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_thunder_reach(id, player, Float:damage);

/*------------------------------
Multiforward executed on teleport use.
Id is player that used teleport.
Returned greater than 0 will reduce time to next use, lower than 0 will make this period longer.
------------------------------*/
forward cod_thunder_reach(id);

/*------------------------------
Item forward executed on item give.
------------------------------*/
forward cod_item_enabled(id, value);

/*------------------------------
Item forward executed on item remove.
------------------------------*/
forward cod_item_disabled(id);

/*------------------------------
Item forward executed on spawn event.
Respawn is true if it's not first spawn of this player in this round.
------------------------------*/
forward cod_item_spawned(id, respawn);

/*------------------------------
Item forward executed on kill event.
------------------------------*/
forward cod_item_kill(killer, victim, hitPlace);

/*------------------------------
Item forward executed on death event.
------------------------------*/
forward cod_item_killed(killer, victim, hitPlace);

/*------------------------------
Item forward executed on skill use.
------------------------------*/
forward cod_item_skill_used(id);

/*------------------------------
Item forward executed on item upgrade.
------------------------------*/
forward cod_item_upgrade(id);

/*------------------------------
Item function for getting value of item.
------------------------------*/
forward cod_item_value(id);

/*------------------------------
Item function for attacker damage change.
------------------------------*/
forward cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/*------------------------------
Item function for victim damage change.
------------------------------*/
forward cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/*------------------------------
Class forward executed on class set.
------------------------------*/
forward cod_class_enabled(id, promotion);

/*------------------------------
Class forward executed on class remove.
------------------------------*/
forward cod_class_disabled(id, promotion);

/*------------------------------
Class forward executed on spawn event.
Respawn is true if it's not first spawn of this player in this round.
------------------------------*/
forward cod_class_spawned(id, respawn);

/*------------------------------
Class forward executed on kill event.
------------------------------*/
forward cod_class_kill(killer, victim, hitPlace);

/*------------------------------
Class forward executed on death event.
------------------------------*/
forward cod_class_killed(killer, victim, hitPlace);

/*------------------------------
Class forward executed on skill use.
------------------------------*/
forward cod_class_skill_used(id);

/*------------------------------
Class function for attacker damage change.
------------------------------*/
forward cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/*------------------------------
Class function for victim damage change.
------------------------------*/
forward cod_class_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);