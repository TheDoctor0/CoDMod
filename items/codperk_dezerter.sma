#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Dezerter";
new const perk_desc[] = "Masz 1/SW szansy na odrodzenie na respie wroga. Masz ubranie wroga i M4A1, z ktorego zadajesz +10 obrazen";

new bool:ma_perk[33];
new wartosc_perku[33] = 0;

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

public plugin_init() {
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 6, 6);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc){
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	cod_give_weapon(id, CSW_M4A1);
	ZmienUbranie(id, 0);
}

public cod_perk_disabled(id){
	ma_perk[id] = false;
	cod_take_weapon(id, CSW_M4A1);
	ZmienUbranie(id, 1);
}

public Spawn(id){
	if(!is_user_alive(id) || !ma_perk[id])
		return;
	
	ZmienUbranie(id, 0);
  
	if(random_num(1, wartosc_perku[id]) == 1)
	{
		new CsTeams:team = cs_get_user_team(id);
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		cs_set_user_team(id, team);
	}
}

public ZmienUbranie(id, reset){
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(reset)
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[num]: Terro_Skins[num]);
	}
	return PLUGIN_CONTINUE;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits){
	if(!is_user_connected(idattacker) || !ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_M4A1 && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, 10.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}
