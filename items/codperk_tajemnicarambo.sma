#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const perk_name[] = "Tajemnica Rambo";
new const perk_desc[] = "Za kazdego fraga dostajesz LW hp oraz pelen magazynek";

new admiral_id;

new const max_clip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

new wartosc_perku[33] = 0;
new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 20, 20);
	
	register_event("DeathMsg", "Death", "a");
	
	admiral_id = cod_get_classid("Admiral");
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == admiral_id)
		return COD_STOP;
			
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public Death()
{
	new attacker = read_data(1);
	if(!is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	
	if(ma_perk[attacker])
	{
		new cur_health = get_user_health(attacker);
		new Float:max_health = 100.0+cod_get_user_health(attacker);
		new Float:new_health = cur_health+float(wartosc_perku[attacker])<max_health? cur_health+float(wartosc_perku[attacker]): max_health;
		set_pev(attacker, pev_health, new_health);
		new weapon = get_user_weapon(attacker);
		if(max_clip[weapon] > 0)
			set_user_clip(attacker, max_clip[weapon]);
	}
	return PLUGIN_CONTINUE;
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = engfunc(EngFunc_FindEntityByString, weaponid, "classname", weaponname)) != 0)
		if (pev(weaponid, pev_owner) == id) {
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}
