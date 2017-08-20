#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>
#include <colorchat>

new bool:ma_klase[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

new const nazwa[] = "Bandyta";
new const opis[] = "TMP , Ubranie wroga , 1/7 na odrodzenie siê u wroga";
new const bronie = 1<<CSW_TMP;
new const zdrowie = 20;
new const kondycja = 25;
new const inteligencja = 10;
new const wytrzymalosc = 5;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ZmienUbranie(id, 1);
	ma_klase[id] = false;
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;
		
	if(!ma_klase[id])
		return;
		
	if(random_num(1,5) == 1)
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
