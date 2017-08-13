#include <amxmodx>
#include <cod>

#define PLUGIN "CoD Class Pulkownik"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Pulkownik";
new const description[] = "Zadaje coraz wieksze obrazenia wraz ze spadkiem ilosci amunicji w magazynku M249. Mniejsza widocznosc z nozem.";
new const fraction[] = "";
new const weapons = (1<<CSW_M249)|(1<<CSW_GLOCK18);
new const health = 20;
new const intelligence = 0;
new const strength = 0;
new const stamina = 0;
new const condition = 20;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public cod_class_enabled(id, promotion)
	cod_set_user_render(id, CLASS, 60, RENDER_WEAPON, CSW_KNIFE);

public cod_class_damage_attacker(attacker, victim, weapon, &Float:damage, damageBits)
{
	if(weapon == CSW_M249)
	{
		new ammo, weapon = get_user_weapon(id, ammo, _);

		cod_inflict_damage(attacker, victim, (100 - ammo) * 0.2, 0.0, damageBits)
	}
}