#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

new bool:ma_klase[33];
	
new const nazwa[]   = "Hardmen";
new const opis[]    = "ak47, Odrdza sie 1/2 na czyjms Respie";
new const bronie    = (1<<CSW_AK47);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
    
public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}
public cod_class_enabled(id)
{
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public Spawn(id)
{
	if (!is_user_alive(id))
		return;
		
	if (!ma_klase[id])
		return;
		
	if (random_num(1,2) == 1)
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
	}
}
