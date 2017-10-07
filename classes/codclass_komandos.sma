#include <amxmodx>
#include <fakemeta>
#include <cod>

#define PLUGIN "CoD Class Komandos"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

#define NAME         "Komandos"
#define DESCRIPTION  "Natychmiastowe zabicie z noza (PPM), 1/10 na zabicie z Deagle, mniejsza widocznosc na nozu."
#define FRACTION     "Podstawowe"
#define WEAPONS      (1<<CSW_DEAGLE)
#define HEALTH       30
#define INTELLIGENCE 0
#define STRENGTH     0
#define STAMINA      0
#define CONDITION    30

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(NAME, DESCRIPTION, FRACTION, WEAPONS, HEALTH, INTELLIGENCE, STRENGTH, STAMINA, CONDITION);
}

public cod_class_enabled(id, promotion)
	cod_set_user_render(id, 100, CLASS, RENDER_ALWAYS, 1<<CSW_KNIFE);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits, hitPlace)
	if ((weapon == CSW_KNIFE && !(pev(attacker, pev_button) & IN_ATTACK)) || (weapon == CSW_DEAGLE && damageBits & DMG_BULLET && cod_percent_chance(10))) damage = cod_kill_player(attacker, victim, damageBits);