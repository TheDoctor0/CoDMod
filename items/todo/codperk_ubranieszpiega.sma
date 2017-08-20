/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <codmod>

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

new const perk_name[] = "Ubranie szpiega";
new const perk_desc[] = "Posiadasz ubranie wroga";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem");
	
	cod_register_perk(perk_name, perk_desc);

	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}
public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	ZmienUbranie(id, 0);
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false;
	ZmienUbranie(id, 1);
}

public ZmienUbranie(id,reset)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if (reset)
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[num]: Terro_Skins[num]);
	}
	
	return PLUGIN_CONTINUE;
}
public Spawn(id)
{
	if(ma_perk[id])
		ZmienUbranie(id, 0);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
