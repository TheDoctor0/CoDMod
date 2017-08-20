#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new const perk_name[] = "Sekret terrorysty";
new const perk_desc[] = "1/2 na pojawienie sie na spawnie wroga w jego ubraniu";

new bool:ma_perk[33];
new Ubrania_CT[4][]={"sas","gsg9","urban","gign"};
new Ubrania_Terro[4][]={"arctic","leet","guerilla","terror"};

public plugin_init()
{
      register_plugin(perk_name, "1.0", "RiviT")
      
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_perk_enabled(id)
	ma_perk[id] = true;

public cod_perk_disabled(id)
{
	ma_perk[id] = false;

	if(is_user_connected(id))
		cs_reset_user_model(id);
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;
	
	if(!ma_perk[id])
		return;
		
	cs_reset_user_model(id);

	if(!random(2))
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
		
		cs_set_user_model(id, (team == CS_TEAM_CT) ? Ubrania_Terro[random(4)]: Ubrania_CT[random(4)]);
	}
}