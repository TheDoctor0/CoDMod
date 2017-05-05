#if defined _cod_included
  #endinput
#endif
#define _cod_included

#define get_bit(%2,%1) (%1 & (1<<(%2&31)))
#define set_bit(%2,%1) (%1 |= (1<<(%2&31)))
#define rem_bit(%2,%1) (%1 &= ~(1 <<(%2&31)))

#define is_user_valid(%1) (1 <= %1 <= MAX_PLAYERS)

#define COD_CONTINUE 0
#define COD_STOP 4
#define COD_BLOCK -1.0

#define DMG_CODSKILL (1<<31)
#define DMG_HEGRENADE (1<<24)
#define DMG_BULLET (1<<1)

#define	RENDER_ALWAYS (1<<1)
#define	RENDER_MOVE (1<<2)
#define	RENDER_STAND (1<<3)
#define	RENDER_DUCK (1<<4)
#define	RENDER_SHIFT (1<<5)

enum _:promotions { PROMOTION_NONE, PROMOTION_FIRST, PROMOTION_SECOND, PROMOTION_THIRD };

enum _:types { NONE = -1, CLASS, ITEM, ADDITIONAL, ALL };

enum _:hud { TYPE_HUD, TYPE_DHUD };

enum _:sounds { SOUND_SELECT, SOUND_EXIT, SOUND_START, SOUND_START2, SOUND_LVLUP, SOUND_LVLUP2, SOUND_LVLUP3, SOUND_DEPLOY, 
	SOUND_ONE, SOUND_LAST, SOUND_FORCE, SOUND_HUMILIATION, SOUND_BOMB, SOUND_BOX, SOUND_APPLAUSE, SOUND_LAUGH };

new const codSounds[sounds][] =
{
	"CoDMod/select.wav",
	"CoDMod/close.wav",
	"CoDMod/start.wav",
	"CoDMod/start2.wav",
	"CoDMod/levelup.wav",
	"CoDMod/levelup2.wav",
	"CoDMod/levelup3.wav",
	"CoDMod/deploy.wav",
	"CoDMod/one.wav",
	"CoDMod/last.wav",
	"CoDMod/force.wav",
	"CoDMod/humiliation.wav",
	"CoDMod/bomb.wav",
	"CoDMod/box.wav",
	"CoDMod/applause.wav",
	"CoDMod/laugh.wav"
};

/*------------------------------
Returns if player is logged in his account.
Account menu is diplayed if not logged in.
------------------------------*/
native cod_check_account(id);

/*------------------------------
Returns if player has a VIP.
------------------------------*/
native cod_get_user_vip(id);

/*------------------------------
Returns player's honor amount.
------------------------------*/
native cod_get_user_honor(id);

/*------------------------------
Sets player's honor amount.
------------------------------*/
native cod_set_user_honor(id, value);

/*------------------------------
Adds value to player's honor amount.
------------------------------*/
native cod_add_user_honor(id, value);

/*------------------------------
Returns clan.
------------------------------*/
native cod_get_user_clan(id);

/*------------------------------
Returns clan's name.
------------------------------*/
native cod_get_clan_name(clan, dataReturn[], dataLength);

/*------------------------------
Returns player's quest id (-1 if none).
------------------------------*/
native cod_get_user_quest(id);

/*------------------------------
Returns player's quest progress.
------------------------------*/
native cod_get_user_quest_progress(id);

/*------------------------------
Returns player's quest need.
------------------------------*/
native cod_get_user_quest_need(id);

/*------------------------------
Spawns an icon above box.
------------------------------*/
native cod_spawn_box_icon(ent);

/*------------------------------
Removes entity of box and icon.
------------------------------*/
native cod_remove_box_icon(ent);

/*------------------------------
Returns player's exp.
------------------------------*/
native cod_get_user_exp(id);

/*------------------------------
Sets player's gained exp.
To remove exp use negative value.
------------------------------*/
native cod_set_user_exp(id, value);

/*------------------------------
Returns exp multiplied by player's exp bonus.
------------------------------*/
native cod_get_user_bonus_exp(id, value);

/*------------------------------
Return exp needed for level.
------------------------------*/
native cod_get_level_exp(level);

/*------------------------------
Returns player's level.
------------------------------*/
native cod_get_user_level(id);

/*------------------------------
Returns player's highest level.
------------------------------*/
native cod_get_user_highest_level(id);

/*------------------------------
Return player's class.
------------------------------*/
native cod_get_user_class(id);

/*------------------------------
Set player's class.
When force = 1 the change is immediate.
------------------------------*/
native cod_set_user_class(id, class, force = 0);

/*------------------------------
Return class using class name.
------------------------------*/
native cod_get_classid(szClass[]);

/*------------------------------
Returns class name.
------------------------------*/
native cod_get_class_name(class, dataReturn[], dataLength);

/*------------------------------
Returns class description.
------------------------------*/
native cod_get_class_desc(class, dataReturn[], dataLength);

/*------------------------------
Returns class health bonus.
------------------------------*/
native cod_get_class_health(class);

/*------------------------------
Returns class intelligence bonus.
------------------------------*/
native cod_get_class_intelligence(class);

/*------------------------------
Returns class stamina bonus.
------------------------------*/
native cod_get_class_stamina(class);

/*------------------------------
Returns class strength bonus.
------------------------------*/
native cod_get_class_strength(class);

/*------------------------------
Returns class condition bonus.
------------------------------*/
native cod_get_class_condition(class);

/*------------------------------
Return classes number.
------------------------------*/
native cod_get_classes_num();

/*------------------------------
Returns item and assigns value of item to variable.
------------------------------*/
native cod_get_user_item(id, &value = 0);

/*------------------------------
Sets player's item. 
If item = -1 an item will be random.
If value = -1 item value will be random.
------------------------------*/
native cod_set_user_item(id, item = 0, value = 0);

/*------------------------------
Upgrades player's item
If check = 1 returns if item is upgradable.
------------------------------*/
native cod_upgrade_user_item(id, check = 0);

/*------------------------------
Returns item id using item name.
------------------------------*/
native cod_get_itemid(szItem[]);

/*------------------------------
Zwraca nazwe itemu.
------------------------------*/
native cod_get_item_name(item, dataReturn[], dataLength);

/*------------------------------
Returns item description.
------------------------------*/
native cod_get_item_desc(item, dataReturn[], dataLength);

/*------------------------------
Returns items number.
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
Sets player's health point.
If maximum = 1 player's max health limit is applied.
------------------------------*/
native cod_set_user_health(id, value, maximum = 1);

/*------------------------------
Adds value to player's health point.
If maximum = 1 player's max health limit is applied.
------------------------------*/
native cod_add_user_health(id, value, maximum = 1);

/*------------------------------
Returns health statistic points.
If current_health = 1 returns current health points.
If class_health = 1 adds class health points.
If stats_health = 1 adds stats health points.
If bonus_health = 1 adds extra health points.
If base_health = 1 adds base 100HP.
------------------------------*/
native cod_get_user_health(id, currect_health = 0, class_health = 1, stats_health = 1, bonus_health = 1, base_health = 0);

/*------------------------------
Returns intelligence statistic points.
If class_intelligence = 1 adds class intelligence points.
If stats_intelligence = 1 adds stats intelligence points.
If bonus_intelligence = 1 adds extra intelligence points.
------------------------------*/
native cod_get_user_intelligence(id, class_intelligence = 1, stats_intelligence = 1, bonus_intelligence = 1);

/*------------------------------
Returns stamina statistic points.
If class_stamina = 1 adds class stamina points.
If stats_stamina = 1 adds stats stamina points.
If bonus_stamina = 1 adds extra stamina points.
------------------------------*/
native cod_get_user_stamina(id, class_stamina = 1, stats_stamina = 1, bonus_stamina = 1);

/*------------------------------
Returns strength statistic points.
If class_strength = 1 adds class strength points.
If stats_strength = 1 adds stats strength points.
If bonus_strength = 1 adds extra strength points.
------------------------------*/
native cod_get_user_strength(id, class_strength = 1, stats_strength = 1, bonus_strength = 1);

/*------------------------------
Returns condition statistic points.
If class_condition = 1 adds class condition points.
If stats_condition = 1 adds stats condition points.
If bonus_condition = 1 adds extra condition points.
------------------------------*/
native cod_get_user_condition(id, class_condition = 1, stats_condition = 1, bonus_condition = 1);

/*------------------------------
Returns player's extra health points.
------------------------------*/
native cod_get_user_bonus_health(id);

/*------------------------------
Returns player's extra intelligence points.
------------------------------*/
native cod_get_user_bonus_intelligence(id);

/*------------------------------
Returns player's extra stamina points.
------------------------------*/
native cod_get_user_bonus_stamina(id);

/*------------------------------
Returns player's extra strength points.
------------------------------*/
native cod_get_user_bonus_strength(id);

/*------------------------------
Returns player's extra condition points.
------------------------------*/
native cod_get_user_bonus_condition(id);

/*------------------------------
Sets player's extra health points.
------------------------------*/
native cod_set_user_bonus_health(id, value);

/*------------------------------
Sets player's extra intelligence points.
------------------------------*/
native cod_set_user_bonus_intelligence(id, value);

/*------------------------------
Sets player's extra stamina points.
------------------------------*/
native cod_set_user_bonus_stamina(id, value);

/*------------------------------
Sets player's extra strength points.
------------------------------*/
native cod_set_user_bonus_strength(id, value);

/*------------------------------
Sets player's extra condition points.
------------------------------*/
native cod_set_user_bonus_condition(id, value);

/*------------------------------
Returns player's rockets amount.
------------------------------*/
native cod_get_user_rockets(id);

/*------------------------------
Returns player's mines amount.
------------------------------*/
native cod_get_user_mines(id);

/*------------------------------
Returns player's medkits amount.
------------------------------*/
native cod_get_user_medkits(id);

/*------------------------------
Returns player's dynamites amount.
------------------------------*/
native cod_get_user_dynamites(id);

/*------------------------------
Returns player's teleports amount.
------------------------------*/
native cod_get_user_teleports(id);

/*------------------------------
Returns player's multijumps amount.
------------------------------*/
native cod_get_user_multijumps(id);

/*------------------------------
Returns player's gravity amount.
------------------------------*/
native cod_get_user_gravity(id);

/*------------------------------
Returns player's armor amount.
------------------------------*/
native cod_get_user_armor(id);

/*------------------------------
Sets player's rockets amount.
------------------------------*/
native cod_set_user_rockets(id, value);

/*------------------------------
Sets player's mines amount.
------------------------------*/
native cod_set_user_mines(id, value);

/*------------------------------
Sets player's medkits amount.
------------------------------*/
native cod_set_user_medkits(id, value);

/*------------------------------
Sets player's dynamites amount.
------------------------------*/
native cod_set_user_dynamites(id, value);

/*------------------------------
Sets player's teleports amount.
------------------------------*/
native cod_set_user_teleports(id, value);

/*------------------------------
Sets player's multijumps amount.
------------------------------*/
native cod_set_user_multijumps(id, value);

/*------------------------------
Sets player's gravity amount.
------------------------------*/
native cod_set_user_gravity(id, value);

/*------------------------------
Sets player's armor amount.
------------------------------*/
native cod_set_user_armor(id, value);

/*------------------------------
Adds value to player's rockets amount.
------------------------------*/
native cod_add_user_rockets(id, value);

/*------------------------------
Adds value to player's mines amount.
------------------------------*/
native cod_add_user_mines(id, value);

/*------------------------------
Adds value to player's medkits amount.
------------------------------*/
native cod_add_user_medkits(id, value);

/*------------------------------
Adds value to player's dynamites amount.
------------------------------*/
native cod_add_user_dynamites(id, value);

/*------------------------------
Adds value to player's teleports amount.
------------------------------*/
native cod_add_user_teleports(id, value);

/*------------------------------
Adds value to player's multijumps amount.
------------------------------*/
native cod_add_user_multijumps(id, value);

/*------------------------------
Adds value to player's gravity amount.
------------------------------*/
native cod_add_user_gravity(id, value);

/*------------------------------
Adds value to player's armor amount.
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
Use player's medkit.
------------------------------*/
native cod_use_user_medkit(id);

/*------------------------------
Use player's teleport.
------------------------------*/
native cod_use_user_teleport(id);

/*------------------------------
Returns if player have resistance for powers.
------------------------------*/
native cod_get_user_resistance(id);

/*------------------------------
Returns if player have bunnyhop.
Type can be NONE - all, CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_get_user_bunnyhop(id, type = NONE);

/*------------------------------
Returns if player have silent walk.
Type can be NONE - all, CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_get_user_footsteps(id, type = NONE);

/*------------------------------
Returns if player have model of the opponent.
Type can be NONE - all, CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_get_user_model(id, type = NONE);

/*------------------------------
Set's player's resistance for powers.
------------------------------*/
native cod_set_user_resistance(id, value);

/*------------------------------
Set's player's bunnyhop.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_set_user_bunnyhop(id, type, value);

/*------------------------------
Set's player's silent walk.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_set_user_footsteps(id, type, value);

/*------------------------------
Set's player's model of the opponent.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - others.
------------------------------*/
native cod_set_user_model(id, type, value);

/*------------------------------
Gives player a weapon and allows player to own it
------------------------------*/
native cod_give_weapon(id, weapon);

/*------------------------------
Removes player a weapon and disallows player to own it
------------------------------*/
native cod_take_weapon(id, weapon);

/*------------------------------
Returns player's render amount.
------------------------------*/
native cod_get_user_render(id);

/*------------------------------
Sets player's render.
Type can be CLASS - for class, ITEM - for item, ADDITIONAL - others.
Value is number from -255 to 255 (negative numbers substract it from player's current render value, positive and 0 sets it to this value).
Status is player state for render. It can be a bitsum of RENDER_ALWAYS, RENDER_STAND, RENDER_MOVE, RENDER_DUCK, RENDER_SHIFT.
Weapon is weapon id (CSW_), 0 for all weapons.
Timer sets render value for certain amount of time - it ignores type, status and weapon.
------------------------------*/
native cod_set_user_render(id, type, value, status = RENDER_ALWAYS, weapon = 0, Float:timer = 0.0);

/*------------------------------
Set's player's render glow.
Usage is the same as in set_user_rendering native.
Timer sets glow for certain amount of time.
------------------------------*/
native cod_set_user_glow(id, effect, red, green, blue, model, amount, Float:timer = 0.0);

/*------------------------------
Diplays text in HUD/DHUD.
Type can be TYPE_HUD or TYPE_DHUD.
HUD/DHUD params usage is the same as in set_hudmessage/set_dhudmessage.
------------------------------*/
native cod_show_hud(id, type=0, red=255, green=255, blue=255, Float:x=-1.0, Float:y=0.35, effects=0, Float:fxtime=6.0, Float:holdtime=12.0, Float:fadeintime=0.1, Float:fadeouttime=0.2, const text[], any:...);

/*------------------------------
Displays screen fade.
Duration and holdtime are time seconds.
------------------------------*/
native cod_display_fade(id, duration, holdtime, fadetype, red, green, blue, alpha);

/*------------------------------
Displays bartimer.
Duration is time in seconds.
Start is value from 0-100 and specifies from what percent of bar it starts.
------------------------------*/
native cod_make_bartimer(id, duration, start = 0);

/*------------------------------
Shakes player's screen.
Amplitude is power of shakes.
Duration is time in seconds.
Frequency is noise frequency.
------------------------------*/
native cod_screen_shake(id, amplitude, duration, frequency);

/*------------------------------
Makes an explosion around ent.
Distance specifies beam distance.
Explosion is explosion effect.
Damage_distance is distance from ent where players will be hurt.
Damage specifies damage dealt to players in damage_distance.
Factor is intelligence multiplier for damage.
------------------------------*/
native cod_make_explosion(ent, distance = 0, explosion = 1, Float:damage_distance = 0.0, Float:damage = 0.0, Float:factor = 0.5)

/*------------------------------
Inflicts damage with intelligence factor.
Factor is intelligence multiplier for damage.
------------------------------*/
native cod_inflict_damage(attacker, victim, Float:damage, Float:factor = 0.5, flags = 0);

/*------------------------------
Kills a player imitating kill by another player.
------------------------------*/
native cod_kill_player(attacker, victim, damageBits);

/*------------------------------
Register a new item and return its id.
------------------------------*/
native cod_register_item(const itemName[], const itemDesc[]);

/*------------------------------
Register a new class and return its id.
------------------------------*/
native cod_register_class(const className[], const classDesc[], const classFraction[], weapons, health, intelligence, strength, stamina, condition);

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
forward cod_render_changed(id);

/*------------------------------
Multiforward executed when player's gravity is changed.
------------------------------*/
forward cod_gravity_changed(id);

/*------------------------------
Multiforward executed on damage event before armor reduce.
------------------------------*/
forward cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits);

/*------------------------------
Multiforward executed on damage event after armor reduce.
------------------------------*/
forward cod_damage_post(attacker, victim, weapon, Float:damage, damageBits);

/*------------------------------
Multiforward executed on weapon deploy event.
------------------------------*/
forward cod_weapon_deploy(id, weapon, ent);

/*------------------------------
Multiforward executed on death event.
------------------------------*/
forward cod_killed(killer, victim, weapon, hitPlace);

/*------------------------------
Multiforward executed on spawn event.
------------------------------*/
forward cod_spawned(id);

/*------------------------------
Multiforward executed on cmd start event.
------------------------------*/
forward cod_cmd_start(id, button, oldButton);

/*------------------------------
Multiforward executed on new round event.
------------------------------*/
forward cod_new_round();

/*------------------------------
Multiforward executed on round start event.
------------------------------*/
forward cod_start_round();

/*------------------------------
Multiforward executed on round end event.
------------------------------*/
forward cod_end_round();

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
------------------------------*/
forward cod_item_spawned(id);

/*------------------------------
Item forward executed on death event.
------------------------------*/
forward cod_item_killed(id);

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
forward cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits);

/*------------------------------
Item function for victim damage change.
------------------------------*/
forward cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits);

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
------------------------------*/
forward cod_class_spawned(id);

/*------------------------------
Class forward executed on death event.
------------------------------*/
forward cod_class_killed(id);

/*------------------------------
Class forward executed on skill use.
------------------------------*/
forward cod_class_skill_used(id);

/*------------------------------
Class function for attacker damage change.
------------------------------*/
forward cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits);

/*------------------------------
Class function for victim damage change.
------------------------------*/
forward cod_class_damage_victim(attacker, victim, weapon, &Float:damage, damageBits);

stock cmd_execute(id, const text[], any:...) 
{
	#pragma unused text

	new message[256];

	format_args(message, charsmax(message), 1);

	message_begin(id == 0 ? MSG_ALL : MSG_ONE, SVC_DIRECTOR, _, id);
	write_byte(strlen(message) + 2);
	write_byte(10);
	write_string(message);
	message_end();
}

stock cod_print_chat(id, const text[] = "", any:...)
{
	new message[192];

	if(numargs() == 2) copy(message, charsmax(message), text);
	else vformat(message, charsmax(message), text, 3);

	client_print_color(id, id, "^x04[CoD]^x01 %s", message);
}

stock mysql_escape_string(const source[], dest[], length)
{
	copy(dest, length, source);
	
	replace_all(dest, length, "\\", "\\\\");
	replace_all(dest, length, "\0", "\\0");
	replace_all(dest, length, "\n", "\\n");
	replace_all(dest, length, "\r", "\\r");
	replace_all(dest, length, "\x1a", "\Z");
	replace_all(dest, length, "'", "\'");
	replace_all(dest, length, "`", "\`");
	replace_all(dest, length, "^"", "\^"");
}