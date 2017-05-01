#include <amxmodx>
#include <codmod>
#include <fakemeta>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Bezlik Ammo";
new const perk_desc[] = "Masz nieskonczona ilosc amunicji";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc);
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
	ma_perk[id] = false;
	
public CurWeapon(id)
{
	if(!is_user_connected(id) || !ma_perk[id])
		return;
	
	set_user_clip(id, 2);
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
