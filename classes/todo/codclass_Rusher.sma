#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new bool:ma_klase[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"}

new const nazwa[]   = "Rusher [P]";
new const opis[]    = "1/4 szans na pojawienie sie na spawnie wroga, posiada ubranie wroga";
new const bronie    = (1<<CSW_M3)|(1<<CSW_DEAGLE);
new const zdrowie   = 20;
new const kondycja  = 10;
new const inteligencja = 10;
new const wytrzymalosc = 15;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}
	ma_klase[id] = true;

	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	if(is_user_connected(id)) cs_reset_user_model(id);
	ma_klase[id] = false;
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;
		
	if(!ma_klase[id])
		return;
		
	if(!random(4))
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
	}
	cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
}