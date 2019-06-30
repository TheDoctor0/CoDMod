#if defined _cod_included
  #endinput
#endif
#define _cod_included

#if !defined client_print_color || !defined MAX_NAME_LENGTH
    #error THIS VERSION IS NOT SUPPORTED! PLEASE USE AMXX 1.8.3 OR 1.9!
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
enum _:types { RANDOM = -3, FULL, NONE, CLASS, ITEM, ADDITIONAL, ROUND, DAMAGE_GIVEN, DAMAGE_TAKEN, DEATH, USED, ALL };
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

/**
 * Checks if player is logged in his account.
 *
 * @note Account menu will be diplayed for player if not logged in.
 *
 * @param id        Player index
 *
 * @return          1 if player is logged in, 0 otherwise
 */
native cod_check_account(id);

/**
 * Checks if player is a VIP.
 *
 * @note Account menu will be diplayed for client if not logged in.
 *
 * @param id        Player index
 *
 * @return          1 if player is a VIP, 0 otherwise
 */
native cod_get_user_vip(id);

/**
 * Returns player honor amount.
 *
 * @param id        Player index
 *
 * @return          Honor amount
 */
native cod_get_user_honor(id);

/**
 * Checks how much honor player has.
 *
 * @param id        Player index
 * @param value     Honor amount
 * @param bonus     If true honor gain bonus will be applied
 *
 * @noreturn
 */
native cod_set_user_honor(id, value, bonus = false);

/**
 * Adds value to player honor amount.
 *
 * @param id        Player index
 * @param value     Honor amount
 * @param bonus     If true honor gain bonus will be applied
 *
 * @noreturn
 */
native cod_add_user_honor(id, value, bonus = false);

/**
 * Returns player clan index.
 *
 * @param id        Player index
 *
 * @return          Clan index
 */
native cod_get_user_clan(id);

/**
 * Returns player clan percentage exp bonus.
 *
 * @param id        Player index
 *
 * @return          Clan exp bonus
 */
native cod_get_user_clan_bonus(id);

/**
 * Retrieves the name of a clan with given index.
 *
 * @param clan      Clan index
 * @param data      Buffer to copy name to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_clan_name(clan, data[], length);

/**
 * Returns player current mission index.
 *
 * @note NONE (-1) will be returned if player have no mission in progress.
 *
 * @param id        Player index
 *
 * @return          Mission index
 */
native cod_get_user_mission(id);

/**
 * Returns player mission progress.
 *
 * @param id        Player index
 *
 * @return          Mission progress
 */
native cod_get_user_mission_progress(id);

/**
 * Returns player objectives count to mission end.
 *
 * @param id        Player index
 *
 * @return          Mission need
 */
native cod_get_user_mission_need(id);

/**
 * Spawns icon with specified type.
 *
 * @note Available icons: BOMBSITE_A, BOMBSITE_B, BOMB_DROP, BOMB_PLANT, BOMB_EXPLODE, BOX.
 * @note Icon entity will be saved in ent pev_user1.
 *
 * @param ent       Entity index
 *
 * @noreturn
 */
native cod_spawn_icon(ent, type = BOX);

/**
 * Returns player gametime in seconds.
 *
 * @param id        Player index
 *
 * @return          Player gametime
 */
native cod_get_user_time(id);

/**
 * Returns player gametime as text with hours, minutes, seconds.
 *
 * @note Text format: %i h %i min %i s.
 *
 * @param id        Player index
 * @param data      Buffer to copy formatted time string to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_user_time_text(id, data[], length);

/**
 * Returns player exp.
 *
 * @param id        Player index
 *
 * @return          Player exp
 */
native cod_get_user_exp(id);

/**
 * Sets player gained exp.
 *
 * @note To remove exp use negative value.
 *
 * @param id        Player index
 * @param value     Exp amount
 * @param bonus     If true exp gain bonus will be applied
 *
 * @return          Player exp
 */
native cod_set_user_exp(id, value, bonus = false);

/**
 * Returns exp multiplied by player exp gain bonus.
 *
 * @param id        Player index
 * @param value     Exp amount
 *
 * @return          Exp multiplied by bonus
 */
native cod_get_user_bonus_exp(id, value);

/**
 * Returns exp needed for specified level.
 *
 * @param level     Level
 *
 * @return          Exp needed
 */
native cod_get_level_exp(level);

/**
 * Returns player level.
 *
 * @param id        Player index
 *
 * @return          Player level
 */
native cod_get_user_level(id);

/**
 * Returns player highest level of all classes.
 *
 * @param id        Player index
 *
 * @return          Player highest level
 */
native cod_get_user_highest_level(id);

/**
 * Returns player class and its promotion.
 *
 * @param id        Player index
 * @param promotion Variable to store promotion
 *
 * @return          Player class
 */
native cod_get_user_class(id, &promotion = 0);

/**
 * Returns player current class name.
 *
 * @param id        Player index
 * @param data      Buffer to copy class name to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_user_class_name(id, data[], length);

/**
 * Returns player class promotion.
 *
 * @param id        Player index
 *
 * @return          Player class promotion
 */
native cod_get_user_promotion(id);

/**
 * Sets player class.
 *
 * @param id        Player index
 * @param class     Class index
 * @param force     If true class will be changed immediately.
 *
 * @noreturn
 */
native cod_set_user_class(id, class, force = false);

/**
 * Returns class index by correspoding class name.
 *
 * @param class     Class name
 *
 * @return          Class index
 */
native cod_get_class_id(class[]);

/**
 * Returns class name.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return name for class promotion
 * @param data      Buffer to copy class name to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_class_name(class, promotion = 0, data[], length);

/**
 * Returns class description.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return description for class promotion
 * @param data      Buffer to copy class description to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_class_desc(class, promotion = 0, data[], length);

/**
 * Returns player class health.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return health for class promotion
 *
 * @return          Class health
 */
native cod_get_class_health(class, promotion = 0);

/**
 * Returns player class intelligence.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return intelligence for class promotion
 *
 * @return          Class intelligence
 */
native cod_get_class_intelligence(class, promotion = 0);

/**
 * Returns player class intelligence.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return intelligence for class promotion
 *
 * @return          Class intelligence
 */
native cod_get_class_stamina(class, promotion = 0);

/**
 * Returns player class strength.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return strength for class promotion
 *
 * @return          Class strength
 */
native cod_get_class_strength(class, promotion = 0);

/**
 * Returns player class condition.
 *
 * @param class     Class index
 * @param promotion If greater than 0 will return condition for class promotion
 *
 * @return          Class condition
 */
native cod_get_class_condition(class, promotion = 0);

/**
 * Returns classes count.
 *
 * @return          Classes count
 */
native cod_get_classes_num();

/**
 * Returns player item and its value.
 *
 * @note NONE (-1) will be assigned to value if item has no available value.
 *
 * @param id        Player index
 * @param promotion Variable to item value
 *
 * @return          Player item
 */
native cod_get_user_item(id, &value = 0);

/**
 * Returns player item value.
 *
 * @note NONE (-1) will be returned if item has no available value.
 *
 * @param id        Player index
 *
 * @return          Player item value
 */
native cod_get_user_item_value(id);

/**
 * Returns player item name.
 *
 * @param id        Player index
 * @param data      Buffer to copy item name to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_user_item_name(id, dataReturn[], dataLength);

/**
 * Sets player item with value.
 *
 * @note Set item index to 0 to remove player item.
 * @note Set item index to RANDOM (-3) to give random item.
 * @note Set value to RANDOM (-3) to set random value.
 * @note COD_STOP (4) will be returned if item cannot be set.
 *
 * @param id        Player index
 * @param item      Item index
 *
 * @return          Player item value
 */
native cod_set_user_item(id, item = 0, value = RANDOM);

/**
 * Upgrades player item.
 *
 * @param id        Player index
 * @param check     If true will only check if item can be upgraded
 *
 * @return          Returns 1 if item was upgraded / is upgradable, 0 otherwise
 */
native cod_upgrade_user_item(id, check = false);

/**
 * Returns item index by correspoding item name.
 *
 * @param class     Item name
 *
 * @return          Item index
 */
native cod_get_item_id(itemName[]);

/**
 * Returns item name.
 *
 * @param item      Item index
 * @param data      Buffer to copy item name to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_item_name(item, data[], length);

/**
 * Returns item description.
 *
 * @param class     Item index
 * @param data      Buffer to copy item description to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_get_item_desc(item, data[], length);

/**
 * Returns items count.
 *
 * @return          Items count
 */
native cod_get_items_num();

/**
 * Returns player item durability.
 *
 * @param id        Player index
 *
 * @return          Item durability
 */
native cod_get_item_durability(id);

/**
 * Sets player item durability amount.
 *
 * @note Set durability to 0 to destroy item.
 *
 * @param id        Player index
 * @param amount    Item durability amount
 *
 * @noreturn
 */
native cod_set_item_durability(id, amount);

/**
 * Returns maximum item durability.
 *
 * @return          Max item durability
 */
native cod_max_item_durability();

/**
 * Returns player maximum health points.
 *
 * @return          Max health points
 */
native cod_get_user_max_health(id);

/**
 * Sets player health points.
 *
 * @param id        Player index
 * @param value     Health points
 * @param maximum   If true player max health limit will be applied
 *
 * @noreturn
 */
native cod_set_user_health(id, value, maximum = true);

/**
 * Adds value to player health points.
 *
 * @param id        Player index
 * @param value     Health points
 * @param maximum   If true player max health limit will be applied
 *
 * @noreturn
 */
native cod_add_user_health(id, value, maximum = true);

/**
 * Returns player health points.
 *
 * @param id        Player index
 * @param current   If true will return only current health points
 * @param class     If true will add class health points
 * @param stats     If true will add stats health points
 * @param bonus     If true will add bonus health points
 * @param base      If true will add base 100 HP
 *
 * @return          Health points
 */
native cod_get_user_health(id, current = false, class = true, stats = true, bonus = true, base = false);

/*------------------------------
Return intelligence statistic points.
If classIntelligence = 1 adds class intelligence points.
If statsIntelligence = 1 adds stats intelligence points.
If bonusIntelligence = 1 adds extra intelligence points.
------------------------------*/
/**
 * Returns player intelligence points.
 *
 * @param id        Player index
 * @param class     If true will add class intelligence points
 * @param stats     If true will add stats intelligence points
 * @param bonus     If true will add bonus intelligence points
 *
 * @return          Intelligence points
 */
native cod_get_user_intelligence(id, class = true, stats = true, bonus = true);

/**
 * Returns player stamina points.
 *
 * @param id        Player index
 * @param class     If true will add class stamina points
 * @param stats     If true will add stats stamina points
 * @param bonus     If true will add bonus stamina points
 *
 * @return          Stamina points
 */
native cod_get_user_stamina(id, class = true, stats = true, bonus = true);

/**
 * Returns player strength points.
 *
 * @param id        Player index
 * @param class     If true will add class strength points
 * @param stats     If true will add stats strength points
 * @param bonus     If true will add bonus strength points
 *
 * @return          Strength points
 */
native cod_get_user_strength(id, class = true, stats = true, bonus = true);

/**
 * Returns player condition points.
 *
 * @param id        Player index
 * @param class     If true will add class condition points
 * @param stats     If true will add stats condition points
 * @param bonus     If true will add bonus condition points
 *
 * @return          Condition points
 */
native cod_get_user_condition(id, class = true, stats = true, bonus = true);

/**
 * Returns player bonus health points.
 *
 * @param id        Player index
 *
 * @return          Bonus health points
 */
native cod_get_user_bonus_health(id);

/**
 * Returns player bonus intelligence points.
 *
 * @param id        Player index
 *
 * @return          Bonus intelligence points
 */
native cod_get_user_bonus_intelligence(id);

/**
 * Returns player bonus stamina points.
 *
 * @param id        Player index
 *
 * @return          Bonus stamina points
 */
native cod_get_user_bonus_stamina(id);

/**
 * Returns player bonus strength points.
 *
 * @param id        Player index
 *
 * @return          Bonus strength points
 */
native cod_get_user_bonus_strength(id);

/**
 * Returns player bonus condition points.
 *
 * @param id        Player index
 *
 * @return          Bonus condition points
 */
native cod_get_user_bonus_condition(id);

/**
 * Sets player bonus health points.
 *
 * @param id        Player index
 * @param value     Bonus health amount
 *
 * @noreturn
 */
native cod_set_user_bonus_health(id, value);

/**
 * Sets player bonus intelligence points.
 *
 * @param id        Player index
 * @param value     Bonus intelligence amount
 *
 * @noreturn
 */
native cod_set_user_bonus_intelligence(id, value);

/**
 * Sets player bonus stamina points.
 *
 * @param id        Player index
 * @param value     Bonus stamina amount
 *
 * @noreturn
 */
native cod_set_user_bonus_stamina(id, value);

/**
 * Sets player bonus strength points.
 *
 * @param id        Player index
 * @param value     Bonus strength amount
 *
 * @noreturn
 */
native cod_set_user_bonus_strength(id, value);

/**
 * Sets player bonus condition points.
 *
 * @param id        Player index
 * @param value     Bonus condition amount
 *
 * @noreturn
 */
native cod_set_user_bonus_condition(id, value);

/**
 * Adds value to player bonus health points.
 *
 * @param id        Player index
 * @param value     Bonus health amount
 *
 * @noreturn
 */
native cod_add_user_bonus_health(id, value);

/**
 * Adds value to player bonus intelligence points.
 *
 * @param id        Player index
 * @param value     Bonus intelligence amount
 *
 * @noreturn
 */
native cod_add_user_bonus_intelligence(id, value);

/**
 * Adds value to player bonus stamina points.
 *
 * @param id        Player index
 * @param value     Bonus stamina amount
 *
 * @noreturn
 */
native cod_add_user_bonus_stamina(id, value);

/**
 * Adds value to player bonus strength points.
 *
 * @param id        Player index
 * @param value     Bonus strength amount
 *
 * @noreturn
 */
native cod_add_user_bonus_strength(id, value);

/**
 * Adds value to player bonus condition points.
 *
 * @param id        Player index
 * @param value     Bonus condition amount
 *
 * @noreturn
 */
native cod_add_user_bonus_condition(id, value);

/**
 * Returns player available rockets.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available rockets
 */
native cod_get_user_rockets(id, type = ALL);

/**
 * Returns player available mines.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available mines
 */
native cod_get_user_mines(id, type = ALL);

/**
 * Returns player available medkits.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available medkits
 */
native cod_get_user_medkits(id, type = ALL);

/**
 * Returns player available poisons.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available poisons
 */
native cod_get_user_poisons(id, type = ALL);

/**
 * Returns player available dynamites.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available dynamites
 */
native cod_get_user_dynamites(id, type = ALL);

/**
 * Returns player available medkits.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available medkits
 */
native cod_get_user_thunders(id, type = ALL);

/**
 * Returns player available teleports.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  USED - left to use in this round
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available teleports
 */
native cod_get_user_teleports(id, type = ALL);

/**
 * Returns player available multijumps.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Available multijumps
 */
native cod_get_user_multijumps(id, type = ALL);

/**
 * Returns player gravity amount.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Gravity amount
 */
native Float:cod_get_user_gravity(id, type = ALL);

/**
 * Returns player speed amount.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Speed amount
 */
native Float:cod_get_user_speed(id, type = ALL);

/**
 * Returns player armor amount.
 *
 * @param id        Player index
 *
 * @return          Armor amount
 */
native cod_get_user_armor(id);

/**
 * Sets player rockets bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_rockets(id, value, type = ROUND);

/**
 * Sets player mines bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_mines(id, value, type = ROUND);

/**
 * Sets player medkits bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_medkits(id, value, type = ROUND);

/**
 * Sets player poisons bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_poisons(id, value, type = ROUND);

/**
 * Sets player dynamites bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_dynamites(id, value, type = ROUND);

/**
 * Sets player thunders bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_thunders(id, value, type = ROUND);

/**
 * Sets player teleports bonus.
 *
 * @note Set value to FULL (-2) for unlimited teleports.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_teleports(id, value, type = ROUND);

/**
 * Sets player multijumps bonus.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_multijumps(id, value, type = ROUND);

/**
 * Sets player gravity bonus.
 *
 * @note Lower gravity has priority, but still will be reduced by bonuses with value lower than 0.
 *
 * @param id        Player index
 * @param value     Bonus value, from -1.0 to 1.0
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_gravity(id, Float:value, type = ROUND);

/**
 * Sets player speed bonus.
 *
 * @note Player speed is calculated from base speed, condition bonus and speed bonus.
 * @note Higher speed bonus has priority, but still will be reduced by bonuses with value lower than 0.
 * @note Set value to COD_FREEZE (0.1) to prevent player from moving.
 *
 * @param id        Player index
 * @param value     Bonus value
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_speed(id, Float:value, type = ROUND);

/**
 * Sets player armor.
 *
 * @param id        Player index
 * @param value     Armor amount
 *
 * @noreturn
 */
native cod_set_user_armor(id, value);

/**
 * Add value to player rockets bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_rockets(id, value, type = ROUND);

/**
 * Add value to player mines bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_mines(id, value, type = ROUND);

/**
 * Add value to player medkits bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_medkits(id, value, type = ROUND);

/**
 * Add value to player poisons bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_poisons(id, value, type = ROUND);

/**
 * Add value to player dynamites bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_dynamites(id, value, type = ROUND);

/**
 * Add value to player thunders bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_thunders(id, value, type = ROUND);

/**
 * Add value to player teleports bonus.
 *
 * @note Set value to FULL (-2) for unlimited teleports.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_teleports(id, value, type = ROUND);

/**
 * Add value to player multijumps bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_multijumps(id, value, type = ROUND);

/**
 * Add value to player gravity bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_gravity(id, Float:value, type = ROUND);

/**
 * Add value to player speed bonus.
 *
 * @param id        Player index
 * @param value     Value amount
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_add_user_speed(id, Float:value, type = ROUND);

/**
 * Add value to player armor.
 *
 * @param id        Player index
 * @param value     Value amount
 *
 * @noreturn
 */
native cod_add_user_armor(id, value);

/**
 * Forces player rocket use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_rocket(id);

/**
 * Forces player mine use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_mine(id);

/**
 * Forces player dynamite use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_dynamite(id);

/**
 * Forces player thunder use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_thunder(id);

/**
 * Forces player medkit use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_medkit(id);

/**
 * Forces player poison use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_poison(id);

/**
 * Forces player teleport use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_use_user_teleport(id);

/**
 * Returns if player has resistance for skills.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has resistance, 0 otherwise
 */
native cod_get_user_resistance(id, type = ALL);

/**
 * Returns if player has god mode.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has god mode, 0 otherwise
 */
native cod_get_user_godmode(id, type = ALL);

/**
 * Returns if player has noclip.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has noclip, 0 otherwise
 */
native cod_get_user_noclip(id, type = ALL);

/**
 * Returns if player has bunnyhop.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has bunnyhop, 0 otherwise
 */
native cod_get_user_bunnyhop(id, type = ALL);

/**
 * Returns if player has silent walk.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has silent walk, 0 otherwise
 */
native cod_get_user_footsteps(id, type = ALL);

/**
 * Returns if player has model of opponent team.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          1 if player has model of opponent team, 0 otherwise
 */
native cod_get_user_model(id, type = ALL);

/**
 * Returns if player has unlimited ammo.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapon    Weapon in CSW_* format to check for
 *
 * @return          1 if player has unlimited ammo, 0 otherwise
 */
native cod_get_user_unlimited_ammo(id, type = ALL, weapon = 0);

/**
 * Returns if player has recoil eliminator.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapon    Weapon in CSW_* format to check for
 *
 * @return          1 if player has recoil eliminator, 0 otherwise
 */
native cod_get_user_recoil_eliminator(id, type = ALL, weapon = 0);

/**
 * Returns if player has recoil reducer.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapon    Weapon in CSW_* format to check for
 *
 * @return          1 if player has recoil reducer, 0 otherwise
 */
native cod_get_user_recoil_reducer(id, type = ALL, weapon = 0);

/**
 * Sets player bunny hop bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_bunnyhop(id, value, type = ROUND);

/**
 * Sets player silent walk bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_footsteps(id, value, type = ROUND);

/**
 * Sets player model of opponent bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_model(id, value, type = ROUND);

/**
 * Sets player resistance for skills bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_resistance(id, value, type = ROUND);

/**
 * Sets player god mode bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_godmode(id, value, type = ROUND);

/**
 * Sets player noclip bonus value.
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @noreturn
 */
native cod_set_user_noclip(id, value, type = ROUND);

/**
 * Sets player unlimited ammo bonus value.
 *
 * @note Weapons can be bitsum, for example bonus for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapons   Weapons in 1<<CSW_* format or FULL for all weapons.
 *
 * @noreturn
 */
native cod_set_user_unlimited_ammo(id, value, type = ROUND, weapons = FULL);

/**
 * Sets player recoil eliminator bonus value.
 *
 * @note Weapons can be bitsum, for example bonus for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapons   Weapons in 1<<CSW_* format or FULL for all weapons.
 *
 * @noreturn
 */
native cod_set_user_recoil_eliminator(id, value, type = ROUND, weapons = FULL);

/**
 * Sets player recoil reducer bonus value.
 *
 * @note Weapons can be bitsum, for example bonus for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 *
 * @param id        Player index
 * @param value     True to enable bonus, false to disable
 * @param type      Bonus type, valid types are:
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param weapons   Weapons in 1<<CSW_* format or FULL for all weapons.
 *
 * @noreturn
 */
native cod_set_user_recoil_reducer(id, value, type = ROUND, weapons = FULL);

/**
 * Gives player a weapon and allows player to own and pick it.
 *
 * @note Amount is only for adding multiple nades at once and is not used for other weapons.
 *
 * @param id        Player index
 * @param weapon    Weapon in CSW_* format.
 * @param amount    Amount value
 *
 * @noreturn
 */
native cod_give_weapon(id, weapon, amount = 0);

/**
 * Removes a weapon from player inventory and disallows to own or pick it.
 *
 * @param id        Player index
 * @param weapon    Weapon in CSW_* format.
 *
 * @noreturn
 */
native cod_take_weapon(id, weapon);

/**
 * Returns player current weapon.
 *
 * @param id        Player index
 *
 * @noreturn
 */
native cod_get_user_weapon(id);

/**
 * Returns players render amount.
 *
 * @param id        Player index
 * @param type      Bonus type, valid types are:
 *                  NONE - at this moment (with status and weapon rules applied)
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 *
 * @return          Render amount
 */
native cod_get_user_render(id, type = NONE);

/**
 * Sets players render amount bonus.
 *
 * @note There can be only one render for CLASS, ITEM, ADDITIONAL,
 *       but multiple all other types - every set adds new render record.
 * @note Lower render has priority, but still will be reduced by bonuses with value lower than 0.
 * @note Value for class type must be at least 0.
 * @note Status can be bitsum, for example only while crouching while not moving: RENDER_STAND|RENDER_DUCK.
 * @note Weapons can be bitsum, for example bonus for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 *
 * @param id        Player index
 * @param value     Render amount, value from -255 to 255 (256 to disable)
 * @param type      Bonus type, valid types are:
 *                  ALL - overall
 *                  CLASS - for class
 *                  ITEM - for item
 *                  ADDITIONAL - static bonus
 *                  ROUND - until round end
 *                  DEATH - until death
 *                  DAMAGE_GIVEN - until player damage enemy
 *                  DAMAGE_TAKEN - until player is hurt
 * @param status    Player state for render, valid values:
 *                  RENDER_ALWAYS - always
 *                  RENDER_STAND - only if player is standing still
 *                  RENDER_MOVE - only if player is moving
 *                  RENDER_DUCK - only if player is ducking
 *                  RENDER_SHIFT - only if player is walking
 * @param weapons   Weapons in 1<<CSW_* format or FULL for all weapons.
 * @param timer     Timer sets static render value for certain amount of time.
 *                  While active it blocks any other render bonuses.
 *
 * @noreturn
 */
native cod_set_user_render(id, value, type = ROUND, status = RENDER_ALWAYS, weapons = FULL, Float:timer = 0.0);

/*------------------------------
Set player render glow.
Usage is the same as in set_user_rendering native.
Timer sets glow for certain amount of time.
------------------------------*/
/**
 * Sets players render glow amount.
 *
 * @note Usage is the same as in set_user_rendering native.
 *       https://www.amxmodx.org/api/fun/set_user_rendering
 *
 * @param id        Player index
 * @param effect    Rendering effects, one of kRenderFx* constants
 * @param red       The amount of red color, value 0 to 255
 * @param green     The amount of green color, value 0 to 255
 * @param blue      The amount of blue color, value 0 to 255
 * @param render    Render mode, one of kRender* constants
 * @param amount    Render amount, value 0 to 255
 *                  While active it blocks any other render bonuses.
 * @param timer     Timer sets render glow for certain amount of time.
 *                  While active it blocks any other render bonuses.
 *
 * @noreturn
 */
native cod_set_user_glow(id, effect, red, green, blue, model, amount, Float:timer = 0.0);

/**
 * Sends colored chat message with [CoD] prefix to players.
 *
 * @note The colors can be modified inside of the format string using special characters.
 *       These characters can be included using the escape character:
 *       green           x04 ; use location color from this point forward
 *       red/blue/grey   x03 ; use team color from this point forward
 *       red/blue/grey   x02 ; use team color to the end of the client name
 *                           ; This only works at the start of the string,
 *                           ; and precludes using other control characters
 *       default         x01 ; use default color from this point forward
 *
 * @param index     Player index, use 0 to display to all players
 * @param text      String to display
 * @param ...       Variables to replace formatting parameters in text string
 *
 * @noreturn
 */
native cod_print_chat(id, const text[], any:...);

/**
 * Logs error to cod_mod.log file.
 *
 * @note For plugin param __BINARY__ or PLUGIN constant should be used.
 *
 * @param plugin    Plugin name
 * @param text      String to display
 * @param ...       Variables to replace formatting parameters in text string
 *
 * @noreturn
 */
native cod_log_error(const plugin[] = "CoD Mod", const text[], any:...);

/**
 * Executes command on player with bypassing protectors (at least some of them).
 *
 * @param id        Player index
 * @param text      Command string
 * @param ...       Variables to replace formatting parameters in command string
 *
 * @noreturn
 */
native cod_cmd_execute(id, const command[], any:...);

/**
 * Prepare safe SQL string for query.
 *
 * @param source    Raw SQL string to prepare
 * @param dest      Buffer to copy safe SQL string to
 * @param lenth     Maximum buffer size
 *
 * @noreturn
 */
native cod_sql_string(const source[], dest[], length);


/**
 * Diplays text in HUD / DHUD to players.
 *
 * @note Usage is the same as in set_hudmessage / set_dhudmessage.
 *       https://www.amxmodx.org/api/amxmodx/set_hudmessage
 *
 * @param id            Player index, use 0 to display to all players
 * @param type          Display method type, TYPE_HUD or TYPE_DHUD
 * @param red           Red component of hudmessage color, value 0 to 255
 * @param green         Green component of hudmessage color, value 0 to 255
 * @param blue          Blue component of hudmessage color, value 0 to 255
 * @param x             Location of the message on the x axis in percent
 * @param y             Location of the message on the y axis in percent
 * @param effects       Display effect
 * @param fxTime        Duration of the effect in seconds
 * @param holdTime      Time the message stays on screen in seconds
 * @param fadeInTime    Time it takes the message to fully appear (fade-in) in seconds
 * @param fadeOutTime   Time it takes the message to fully disappear (fade-out) in seconds
 * @param channel       Channel to use on the client
 * @param text          Command string
 * @param ...           Variables to replace formatting parameters in command string
 *
 * @noreturn
 */
native cod_show_hud(id, type = TYPE_HUD, red = 255, green = 255, blue = 255, Float:x = -1.0, Float:y = 0.35, effects = 0, Float:fxTime = 6.0, Float:holdTime = 12.0, Float:fadeInTime = 0.1, Float:fadeOutTime = 0.2, const text[], any:...);

/**
 * Displays screen fade.
 *
 * @param id        Player index, use 0 to display to all players
 * @param fxTime    Duration of the effect in seconds
 * @param holdTime  Time the message stays on screen in seconds
 * @param fadeType  Display type, available values:
 *                  FFADE_IN 0x0000
 *                  FFADE_OUT 0x0001
 *                  FFADE_MODULATE 0x0002
 *                  FFADE_STAYOUT 0x0004
 * @param red       Red component of fade color, value 0 to 255
 * @param green     Green component of fade color, value 0 to 255
 * @param blue      Blue component of fade color, value 0 to 255
 * @param alpha     Alpha is fade transparency, value from 0 to 255
 *
 * @noreturn
 */
native cod_display_fade(id, duration, holdTime, fadeType, red, green, blue, alpha);

/**
 * Displays status icon.
 *
 * @note All icons can be found here: https://forums.alliedmods.net/showthread.php?t=52529.
 *
 * @param id        Player index, use 0 to display to all players
 * @param icon      Status icon name
 * @param enable    If true will show icon, otherwise hide it
 * @param red       Red component of icon color, value 0 to 255
 * @param green     Green component of icon color, value 0 to 255
 * @param blue      Blue component of icon color, value 0 to 255
 *
 * @noreturn
 */
native cod_display_icon(id, const icon[], enable = false, red = 0, green = 0, blue = 0);

/**
 * Displays bar timer.
 *
 * @param id        Player index, use 0 to display to all players
 * @param duration  Duration of the bar time hold time in seconds
 * @param start     Percentage of bar to start from, value 0 to 100
 *
 * @noreturn
 */
native cod_make_bartimer(id, duration = 0, start = 0);

/**
 * Shakes player screen.
 *
 * @param id        Player index
 * @param amplitude Power of shakes
 * @param duration  Effect time in seconds
 * @param frequency Noise frequency
 *
 * @noreturn
 */
native cod_screen_shake(id, amplitude = (7<<14), duration = (1<<13), frequency = (1<<14));

/**
 * Refills player clip ammo.
 *
 * @param id            Player index
 *
 * @noreturn
 */
native cod_refill_ammo(id);

/**
 * Makes an explosion effect around entity.
 *
 * @param ent           Entity index, can be player
 * @param distance      Specifies beam distance
 * @param explosion     If true shows explosion effect
 * @param dmgDistance   Distance from entity where players will be hurt
 * @param damage        Damage dealt to players in dmgDistance
 * @param factor        Intelligence bonus for damage
 * @param suicide       If true player will die after explosion
 *
 * @noreturn
 */
native cod_make_explosion(ent, distance = 0, explosion = true, Float:dmgDistance = 0.0, Float:damage = 0.0, Float:factor = 0.5, suicide = false);

/**
 * Makes repeating damage to player.
 *
 * @note Uses cod_inflict_damage with DMG_REPEAT flag.
 * @note If damage or time is set 0.0 previous task will be removed and no new task created.
 * @note If counter is set 0 effect will last till player death or round end - usefull for constant healing.
 *
 * @param attacker  Player that makes damage
 * @param victim    Player that is receiving damage
 * @param damage    Damage amount to make
 * @param time      Interval between damage events
 * @param counter   Damage dealt to players in dmgDistance
 * @param flags     Damage flag in DMG_* format, alternatively FIRE, POISON, or HEAL
 *                  (healing player instead of hurting) to use custom effects out of the box.
 * @param instant   If true makes first damage immediately
 *
 * @noreturn
 */
native cod_repeat_damage(attacker, victim, Float:damage = 0.0, Float:time = 0.0, counter = 1, flags = DMG_CODSKILL, instant = true);

/**
 * Makes damage as player to other player.
 *
 * @note Damage will be blocked if victim has god mode or resistance.
 *
 * @param attacker  Attacker index
 * @param victim    Victim index
 * @param damage    Damage amount to make
 * @param factor    Intelligence bonus for damage
 * @param flags     Damage flags in DMG_* format (DMG_CODSKILL flag will be added)
 *
 * @noreturn
 */
native cod_inflict_damage(attacker, victim, Float:damage, Float:factor = 0.5, flags = 0);

/**
 * Kills a player imitating kill by another player.
 *
 * @note Uses cod_inflict_damage with DMG_KILL flag.
 *
 * @param attacker      Killer index
 * @param victim        Victim index
 * @param damageBits    Damage flags in DMG_* format
 *
 * @returns             COD_BLOCK (-1.0)
 */
native Float:cod_kill_player(killer, victim, damageBits);

/**
 * Respawns player after defined time.
 *
 * @param id        Player that makes kill
 * @param enemy     If true will respawn player on enemy spawn
 * @param time      Respawn delay in seconds, use 0.1 for immediate respawn
 *
 * @noreturn
 */
native cod_respawn_player(id, enemy = false, Float:time = 0.1);

/**
 * Teleports player to spawn.
 *
 * @param id        Player that makes kill
 * @param enemy     If true will teleport player to enemy spawn
 *
 * @noreturn
 */
native cod_teleport_to_spawn(id, enemy = false);

/**
 * Makes random item upgrade.
 *
 * @note After upgrade item value will always be at least 0.
 * @note COD_STOP will be returned if item is not upgradable
 *       or valueMin / valueMax is already reached.
 *
 * @param value         Item value pointer to malipulate
 * @param upgradeMin    Minimum upgrade value, can be smaller than 0
 * @param upgradeMax    Maximum upgrade value
 * @param valueMin      Minimum item value
 * @param valueMax      Maximum item value
 *
 * @returns             COD_CONTINUE (0) if upgraded, otherwise COD_STOP (4)
 */
native cod_random_upgrade(&value, upgradeMin = -1, upgradeMax = 1, valueMin = NONE, valueMax = NONE);

/**
 * Returns random bool with specified percentage chance for success (true).
 *
 * @param percent   Percentage change for success
 *
 * @returns         1 if success, 0 otherwise
 */
native cod_percent_chance(percent);

/**
 * Returns if there is enough space for entity in current origin.
 *
 * @param ent       Entity index
 * @param distance  Distance limit around entity, value in units
 *
 * @returns         1 if enough place, 0 otherwise
 */
native cod_is_enough_space(ent, Float:distance = 120.0);

/**
 * Removes all entities with specified class name.
 *
 * @param id        Player index, will remove only entities owned by that player
 * @param className Entities class name
 *
 * @noreturn
 */
native cod_remove_ents(id = 0, className[]);

/**
 * Returns player access flags.
 *
 * @param id        Player index
 *
 * @return          Access flags
 */
native cod_get_user_flags(id);

/**
 * Sets player access flags.
 *
 * @param id        Player index
 * @param flags     Access flags
 *
 * @noreturn
 */
native cod_set_user_flags(id, flags);

/**
 * Registers new item.
 *
 * @param name      Item name
 * @param desc      Item description
 * @param valueMin  Mininum value for item (used for random value)
 * @param valueMax  Maximum value for item (used for random value)
 *
 * @return          Item index
 */
native cod_register_item(const name[], const desc[], valueMin = 0, valueMax = 0);

/**
 * Registers new class.
 *
 * @note Weapons can be bitsum, for example for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 *
 * @param name          Class name
 * @param desc          Class description
 * @param faction       Class faction, can be empty
 * @param weapons       Class weapons
 * @param health        Class health bonus
 * @param intelligence  Class intelligence bonus
 * @param strength      Class strength bonus
 * @param stamina       Class stamina bonus
 * @param condition     Class condition bonus
 * @param flag          Class access flag
 *
 * @return          Class index
 */
native cod_register_class(const name[], const desc[], const faction[], weapons, health, intelligence, strength, stamina, condition, flag = NONE);

/**
 * Registers new class promotion.
 *
 * @note Weapons can be bitsum, for example for both M4A1 and AK47: (1<<CSW_M4A1)|(1<<CSW_AK47).
 * @note Values from weapons to flag will be copied from base class if not specified.
 *
 * @param name          Class name
 * @param desc          Class description
 * @param baseClass     Base class for promotion
 * @param level         Level to advance to this promotion
 * @param promotion     Promotion step, available: PROMOTION_FIRST, PROMOTION_SECOND, PROMOTION_THIRD.
 * @param weapons       Class weapons
 * @param health        Class health bonus
 * @param intelligence  Class intelligence bonus
 * @param strength      Class strength bonus
 * @param stamina       Class stamina bonus
 * @param condition     Class condition bonus
 * @param flag          Class access flag
 *
 * @return              Class promotion index
 */
native cod_register_promotion(const name[], const desc[], const baseClass[], level, promotion, weapons = NONE, health = NONE, intelligence = NONE, strength = NONE, stamina = NONE, condition = NONE, flag = NONE);

/**
 * Multiforward called on players access flags change.
 *
 * @param id        Player index
 * @param flags     Access flags
 *
 * @noreturn
 */
forward cod_flags_changed(id, flags);

/**
 * Multiforward called when player class has changed.
 *
 * @param id        Player index
 * @param class     Class index
 *
 * @noreturn
 */
forward cod_class_changed(id, class);

/**
 * Multiforward called when player item has changed.
 *
 * @param id        Player index
 * @param item      Item index
 *
 * @noreturn
 */
forward cod_item_changed(id, item);

/**
 * Multiforward called when player item has changed.
 *
 * @param id        Player index
 * @param render    Render amount, value 0 to 255
 *
 * @noreturn
 */
forward cod_render_changed(id, render);

/**
 * Multiforward called when player gravity has changed.
 *
 * @param id        Player index
 * @param gravity   Gravity amount, value 0.0 to 1.0
 *
 * @noreturn
 */
forward cod_gravity_changed(id, Float:gravity);

/**
 * Multiforward called when player speed has changed.
 *
 * @note Speed COD_FREEZE (0.1) means that player cannot move.
 *
 * @param id        Player index
 * @param speed     Speed amount
 *
 * @noreturn
 */
forward cod_speed_changed(id, Float:speed);

/**
 * Multiforward called before player receives damage.
 *
 * @note It is called before armor damage reduction.
 * @note Damage forwards are called in this order:
 *       cod_class_damage_victim
 *       cod_item_damage_victim
 *       cod_class_damage_attacker
 *       cod_item_damage_attacker
 *       cod_damage_pre
 *       cod_damage_post
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @return              Set to COD_BLOCK (-1.0) to block damage
 */
forward cod_damage_pre(attacker, victim, weapon, Float:damage, damageBits, hitPlace);

/**
 * Multiforward called after player receives damage.
 *
 * @note It is called after armor damage reduction.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_damage_post(attacker, victim, weapon, Float:damage, damageBits, hitPlace);

/**
 * Multiforward called before cod_inflict_damage (custom HamTakeDamage) is executed.
 *
 * @note Flags bitsum can contain custom DMG_ flags, so damage type can be easily identified:
 *       DMG_CODSKILL (always), DMG_DYNAMITE, DMG_MINE, DMG_ROCKET, DMG_THUNDER, DMG_KILL, DMG_REPEAT.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param damage        Amount of damage to deal
 * @param factor        Intelligence bonus for damage
 * @param flags         Damage flags in DMG_* format
 *
 * @return              Set to COD_BLOCK (-1.0) to block damage
 */
forward cod_damage_inflict(attacker, victim, Float:damage, Float:factor, flags);

/**
 * Multiforward called when player weapon has been deployed.
 *
 * @param id        Player index
 * @param weapon    Weapon index in CSW_* format
 * @param ent       Weapon entity index
 *
 * @noreturn
 */
forward cod_weapon_deploy(id, weapon, ent);

/**
 * Multiforward called when cur weapon event has been executed.
 *
 * @param id        Player index
 * @param weapon    Weapon index in CSW_* format
 *
 * @noreturn
 */
forward cod_cur_weapon(id, weapon);

/**
 * Multiforward called on player team assignment.
 *
 * @param id        Player index
 * @param team      Player team index, availables:
 *                  0 - unassigned
 *                  1 - terrorist
 *                  2 - counter-terrorist
 *                  3 - spectator
 *
 * @noreturn
 */
forward cod_team_assign(id, team);

/**
 * Multiforward called on player death.
 *
 * @param killer    Killer index
 * @param victim    Victim index
 * @param weapon    Weapon that was used to kill player
 * @param hitPlace  Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_killed(killer, victim, weapon, hitPlace);

/**
 * Multiforward called on player spawn.
 *
 * @param id        Player index
 * @param respawn   If true then its not first spawn for this player in this round
 *
 * @noreturn
 */
forward cod_spawned(id, respawn);

/**
 * Multiforward called on player spawn.
 *
 * @param id            Player index
 * @param button        Button that is being pressed right now in IN_* format
 * @param oldButton     Last pressed button in IN_* format
 * @param flags         Player flags in FL_* format
 * @param playerState   Player state used also for render, valid values:
 *                      RENDER_ALWAYS - always
 *                      RENDER_STAND - only if player is standing still
 *                      RENDER_MOVE - only if player is moving
 *                      RENDER_DUCK - only if player is ducking
 *                      RENDER_SHIFT - only if player is walking
 *
 * @noreturn
 */
forward cod_cmd_start(id, button, oldButton, flags, playerState);

/**
 * Multiforward called on bomb planting event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_planting(id);

/**
 * Multiforward called on bomb planted event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_planted(id);

/**
 * Multiforward called on bomb defusing event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_defusing(id);

/**
 * Multiforward called on bomb defused event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_defused(id);

/**
 * Multiforward called on bomb explode event.
 *
 * @param planter   Planter index
 * @param defuser   Defuser index, empty if no player was defusing bomb
 *
 * @noreturn
 */
forward cod_bomb_explode(planter, defuser);

/**
 * Multiforward called on bomb drop event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_dropped(id);

/**
 * Multiforward called on bomb pick event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_bomb_picked(id);

/**
 * Multiforward called on hostage kill event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_hostage_killed(id);

/**
 * Multiforward called on hostage rescue event.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_hostage_rescued(id);

/**
 * Multiforward called when all hostages have been rescued.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_hostages_rescued(id);

/**
 * Multiforward called on new round event.
 *
 * @noreturn
 */
forward cod_new_round();

/**
 * Multiforward called on round start event.
 *
 * @noreturn
 */
forward cod_start_round();

/**
 * Multiforward called on round restart event.
 *
 * @noreturn
 */
forward cod_restart_round();

/**
 * Multiforward called on round end event.
 *
 * @noreturn
 */
forward cod_end_round();

/**
 * Multiforward called on round win event.
 *
 * @param team      Team index that won round:
 *                  1 - terrorist
 *                  2 - counter-terrorist
 *
 * @noreturn
 */
forward cod_win_round(team);

/**
 * Multiforward called on map end (message intermission) event.
 *
 * @noreturn
 */
forward cod_end_map();

/**
 * Multiforward called on data reset.
 *
 * @noreturn
 */
forward cod_reset_data();

/**
 * Multiforward called on stats data reset.
 *
 * @noreturn
 */
forward cod_reset_stats_data();

/**
 * Multiforward called on full data reset.
 *
 * @noreturn
 */
forward cod_reset_all_data();

/**
 * Multiforward called on medkit heal.
 *
 * @param id        Medkit owner index
 * @param player    Healed player index
 * @param healed    HP amount that will be healed
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  healing will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_medkit_heal(id, player, Float:healed);

/**
 * Multiforward called on poison damage.
 *
 * @param id        Poison owner index
 * @param player    Hurt player index
 * @param damage    Damage amount that will be taken
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  damage will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_poison_infect(id, player, Float:damage);

/**
 * Multiforward called on rocket damage.
 *
 * @param id        Rocket owner index
 * @param player    Hurt player index
 * @param damage    Damage amount that will be taken
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  damage will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_rocket_explode(id, player, Float:damage);

/**
 * Multiforward called on mine damage.
 *
 * @param id        Mine owner index
 * @param player    Hurt player index
 * @param damage    Damage amount that will be taken
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  damage will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_mine_explode(id, player, Float:damage);

/**
 * Multiforward called on dynamite damage.
 *
 * @param id        Dynamite owner index
 * @param player    Hurt player index
 * @param damage    Damage amount that will be taken
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  damage will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_dynamite_explode(id, player, Float:damage);

/**
 * Multiforward called on thunder damage.
 *
 * @param id        Thunder owner index
 * @param player    Hurt player index
 * @param damage    Damage amount that will be taken
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer,
 *                  damage will be blocked if COD_BLOCK (-1.0) is returned
 */
forward cod_thunder_reach(id, player, Float:damage);

/**
 * Multiforward called on teleport use.
 *
 * @param id        Player index
 *
 * @return          Value greater than 0 will reduce time to next use,
 *                  lower than 0 will make this period longer
 */
forward cod_teleport_used(id);

/**
 * Player item forward called on item give.
 *
 * @param id        Player index
 * @param value     Item value
 *
 * @return          COD_STOP (4) to block item give
 */
forward cod_item_enabled(id, value);

/**
 * Player item forward called on item drop.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_item_disabled(id);

/**
 * Player item forward called on spawn event.
 *
 * @param id        Player index
 * @param respawn   True if it's not first spawn of this player in this round
 *
 * @noreturn
 */
forward cod_item_spawned(id, respawn);

/**
 * Player item forward called on kill event.
 *
 * @param killer    Killer index
 * @param victim    Victim index
 * @param hitPlace  Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_item_kill(killer, victim, hitPlace);

/**
 * Player item forward called on death event.
 *
 * @param killer    Killer index
 * @param victim    Victim index
 * @param hitPlace  Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_item_killed(killer, victim, hitPlace);

/**
 * Player item forward called on item skill use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_item_skill_used(id);

/**
 * Player item forward called on item upgrade.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_item_upgrade(id);

/**
 * Player item forward used for getting value of item.
 *
 * @param id        Player index
 *
 * @return          Item value if available
 */
forward cod_item_value(id);

/**
 * Player item called before player deals damage.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal, can be manipulated,
 *                      set to COD_BLOCK (-1.0) to block damage
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_item_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/**
 * Player item called before player receives damage.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal, can be manipulated,
 *                      set to COD_BLOCK (-1.0) to block damage
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_item_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/**
 * Player class forward called on class enable.
 *
 * @param id        Player index
 * @param promotion Class promotion step
 *
 * @return          COD_STOP (4) to block class change
 */
forward cod_class_enabled(id, promotion);

/**
 * Player class forward called on class disable.
 *
 * @param id        Player index
 * @param promotion Class promotion step
 *
 * @noreturn
 */
forward cod_class_disabled(id, promotion);

/**
 * Player class forward called on spawn event.
 *
 * @param id        Player index
 * @param respawn   True if it's not first spawn of this player in this round
 *
 * @noreturn
 */
forward cod_class_spawned(id, respawn);

/**
 * Player class forward called on kill event.
 *
 * @param killer    Killer index
 * @param victim    Victim index
 * @param hitPlace  Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_class_kill(killer, victim, hitPlace);

/**
 * Player class forward called on death event.
 *
 * @param killer    Killer index
 * @param victim    Victim index
 * @param hitPlace  Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_class_killed(killer, victim, hitPlace);

/**
 * Player class forward called on class skill use.
 *
 * @param id        Player index
 *
 * @noreturn
 */
forward cod_class_skill_used(id);

/**
 * Player class called before player take damage.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal, can be manipulated,
 *                      set to COD_BLOCK (-1.0) to block damage
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);

/**
 * Player class called before player receives damage.
 *
 * @param attacker      Attacker index
 * @param victim        Victim index
 * @param weapon        Weapon used to make this damage
 * @param damage        Amount of damage to deal, can be manipulated,
 *                      set to COD_BLOCK (-1.0) to block damage
 * @param damageBits    Damage flags in DMG_* format
 * @param hitPlace      Body hit place in HIT_* format
 *
 * @noreturn
 */
forward cod_class_damage_victim(attacker, victim, weapon, &Float:damage, damageBits, hitPlace);