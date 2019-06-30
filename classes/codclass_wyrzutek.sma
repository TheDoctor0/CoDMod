#include <amxmodx>
#include <cod>
#include <fakemeta>

#define PLUGIN "CoD Class Wyrzutek"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Wyrzutek"
#define DESCRIPTION  "Ma 1/6 szansy na wyrzucenie wroga w powietrze. Wrogom w powietrzu zadaje mu podwojne obrazenia"
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_M4A1)|(1<<CSW_USP)
#define HEALTH       20
#define INTELLIGENCE 0
#define STRENGTH     10
#define STAMINA      0
#define CONDITION    5

#define FL_ON_GROUND (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT | FL_FLY)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
{
	if (damageBits & DMG_BULLET && random_num(1, 6) == 1) {
		new Float:velocity[3];

		velocity[0] = 0.0;
		velocity[1] = 0.0;
		velocity[2] = 0.0;

		pev(victim, pev_velocity, velocity);

		velocity[2] = random_float(400.0, 600.0);

		set_pev(victim, pev_velocity, velocity);
	}

	if (!(pev(victim, pev_flags) & FL_ON_GROUND)) {
		cod_inflict_damage(attacker, victim, damage, 0.0, damageBits);
	}
}
