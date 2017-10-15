#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Elektryk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Elektryk"
#define DESCRIPTION  "Posiada 3 blyskawice. Ma 20% szansy ma podpalenie przeciwnika po trafieniu USP."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_USP)
#define HEALTH       15
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      10
#define CONDITION    5

// #define NAME2        "Wyszkolony Elektryk"
// #define DESCRIPTION2 "Posiada 4 blyskawice. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP."

// #define NAME3        "Elitarny Elektryk"
// #define DESCRIPTION3 "Posiada 5 blyskawic. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP."

// #define NAME4        "Mistrzowski Elektryk"
// #define DESCRIPTION4 "Posiada 6 blyskawic. Ma 10% szansy ma podpalenie przeciwnika po trafieniu USP."
// #define WEAPONS4     (1<<CSW_M4A1)|(1<<CSW_AK47)|(1<<CSW_USP)

new classPromotion[MAX_PLAYERS + 1];

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);

	// cod_register_promotion(NAME2, DESCRIPTION2, NAME, 25, PROMOTION_FIRST);
	// cod_register_promotion(NAME3, DESCRIPTION2, NAME, 50, PROMOTION_SECOND);
	// cod_register_promotion(NAME4, DESCRIPTION2, NAME, 150, PROMOTION_THIRD, WEAPONS4);
}

public cod_class_enabled(id, promotion)
{
	classPromotion[id] = promotion;

	switch (promotion) {
		case PROMOTION_NONE: cod_add_user_thunders(id, 3, CLASS);
		case PROMOTION_FIRST: cod_add_user_thunders(id, 4, CLASS);
		case PROMOTION_SECOND: cod_add_user_thunders(id, 5, CLASS);
		case PROMOTION_THIRD: cod_add_user_thunders(id, 6, CLASS);
	}
}
	
public cod_class_skill_used(id)
	cod_use_user_thunder(id);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if (weapon == CSW_USP && damageBits & DMG_BULLET && cod_percent_chance(20)) cod_repeat_damage(attacker, victim, 5.0, 0.2, 10, DMG_BURN, FIRE);
