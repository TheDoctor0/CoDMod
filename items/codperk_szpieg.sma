#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new const perk_name[] = "Szpieg";
new const perk_desc[] = "Masz 1/LW szansy na odrodzenie sie u wroga oraz wygladasz jak wrog";

new bool:ma_perk[33];
new wartosc_perku[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

public plugin_init()
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 3, 5);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id, wartosc)
{
	wartosc_perku[id] = wartosc;
	ma_perk[id] = true;
	ZmienUbranie(id, 0);
}

public cod_perk_disabled(id)
{
	ZmienUbranie(id, 1);
	ma_perk[id] = false;
}

public Spawn(id)
{
	if(!is_user_alive(id))
	return;

	if(!ma_perk[id])
	return;

	if(random_num(1, wartosc_perku[id]) == 1)
	{
		new CsTeams:team = cs_get_user_team(id);
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		cs_set_user_team(id, team);
	}
	ZmienUbranie(id, 0);
}

public ZmienUbranie(id, reset)
{
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
