#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Przyklad Awanse"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Test"
#define DESCRIPTION  "Posiada 2 miny. Ma 10% szansy na natychmiastowe zabicie przeciwnika po trafieniu USP."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_USP)
#define HEALTH       10
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    5

#define NAME2        "Wyszkolony Test"
#define DESCRIPTION2 "Posiada 3 miny. Ma 10% szansy na natychmiastowe zabicie przeciwnika po trafieniu USP."
#define HEALTH2      15

#define NAME3        "Elitarny Test"
#define DESCRIPTION3 "Posiada 4 miny. Ma 20% szansy na natychmiastowe zabicie przeciwnika po trafieniu USP."
#define HEALTH3      15
#define CONDITION3   10

#define NAME4        "Mistrzowski Test"
#define DESCRIPTION4 "Posiada 5 min. Ma 20% szansy na natychmiastowe zabicie przeciwnika po trafieniu USP."
#define WEAPONS4     (1<<CSW_M4A1)|(1<<CSW_AK47)|(1<<CSW_USP)
#define HEALTH4      15
#define CONDITION4   20

new classPromotion[MAX_PLAYERS + 1];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);

    cod_register_promotion(NAME2, DESCRIPTION2, NAME, 25, PROMOTION_FIRST, .health = HEALTH2);
    cod_register_promotion(NAME3, DESCRIPTION2, NAME, 50, PROMOTION_SECOND, .health = HEALTH3, .condition = CONDITION3);
    cod_register_promotion(NAME4, DESCRIPTION2, NAME, 150, PROMOTION_THIRD, WEAPONS4, .health = HEALTH4, .condition = CONDITION4);
}

public cod_class_enabled(id, promotion)
{
    classPromotion[id] = promotion;

    switch (promotion) {
        case PROMOTION_NONE: cod_set_user_mines(id, 2, CLASS);
        case PROMOTION_FIRST: cod_set_user_mines(id, 3, CLASS);
        case PROMOTION_SECOND: cod_set_user_mines(id, 4, CLASS);
        case PROMOTION_THIRD: cod_set_user_mines(id, 5, CLASS);
    }
}

public cod_class_skill_used(id)
    cod_use_user_mine(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
    if (weapon == CSW_USP && damageBits & DMG_BULLET) {
        new bool:kill = false;

        switch (classPromotion[attacker]) {
            case PROMOTION_NONE, PROMOTION_FIRST: kill = cod_percent_chance(10);
            case PROMOTION_SECOND, PROMOTION_THIRD: kill = cod_percent_chance(20);
        }

        if (kill) damage = cod_kill_player(attacker, victim, damageBits);
    }
}
