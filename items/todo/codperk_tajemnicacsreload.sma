#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <fun>
#include <fakemeta>

new const perk_name[] = "Tajemnica Cs-Reload.pl";
new const perk_desc[] = "Zadajesz SW obrazen wiecej, masz eliminator rozrzutu i bezlik ammo - znika po 1 rundzie!";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];
new bool:used[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 20, 20);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
	
	register_forward(FM_PlayerPreThink, "PreThink");
	register_forward(FM_UpdateClientData, "UpdateClientData", 1);
	
	RegisterHam(Ham_Spawn,"player","Spawn");
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(ma_perk[idattacker])
		cod_inflict_damage(idattacker, this, float(wartosc_perku[idattacker]), 0.0, idinflictor, damagebits);

	return HAM_IGNORED;
}

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

public PreThink(id)
{
	if(ma_perk[id])
		set_pev(id, pev_punchangle, {0.0,0.0,0.0})
}
		
public UpdateClientData(id, sw, cd_handle)
{
	if(ma_perk[id])
		set_cd(cd_handle, CD_PunchAngle, {0.0,0.0,0.0})   
}

public Spawn(id){
	if(ma_perk[id]){
		if(used[id])
			cod_set_user_perk(id, 0)
		else
			used[id] = true;
	}
	return PLUGIN_CONTINUE;
}
