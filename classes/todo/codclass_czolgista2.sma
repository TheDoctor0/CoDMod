#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <codmod>

new const nazwa[] = "Czolgista";
new const opis[] = "Moze sie czolgac [e], ma ubranie wroga, 1/8 szansy na pojawienie sie na respie wroga.";
new const bronie = (1<<CSW_XM1014)|(1<<CSW_USP);
new const zdrowie = 10;
new const kondycja = 0;
new const inteligencja = 5;
new const wytrzymalosc = 15;

new bool:ma_klase[33], bool:moze[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"};
new Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

public plugin_init() 
{
	register_plugin("Czolgista", "1.0", "RiviT")

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);

	register_forward(FM_EmitSound, "EmitSound")
}

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
}

public cod_class_disabled(id)
{
	if(is_user_connected(id)) cs_reset_user_model(id);
	ma_klase[id] = false;
}

public client_PostThink(id)
{	
	if(ma_klase[id])
	{
		new button = pev(id,pev_button)
            new oldbuttons = pev(id,pev_oldbuttons)

		if(button & IN_USE && oldbuttons & IN_USE && pev(id,pev_watertype) == -1)
		{
			if(pev(id,pev_flags) & FL_ONGROUND)
			{		
				engfunc(EngFunc_DropToFloor,id)
				
				client_cmd(id,"+duck")
				set_pev(id,pev_waterlevel,5)
				moze[id] = true;		
			}
			
			if(button & IN_JUMP && moze[id])
			{				
				new Float:vVelocity[3] 				
				pev(id,pev_velocity,vVelocity)
				vVelocity[2] = float(-abs(floatround(vVelocity[2]))) 			
				set_pev(id,pev_velocity,vVelocity)						
				set_pev(id,pev_button,pev(id,pev_button) & ~IN_JUMP)
			}		
		}
		else
		{
			if(moze[id])
			{
				client_cmd(id,"-duck")
				set_pev(id,pev_waterlevel,0)
				moze[id] = false;
			}		
		}	
	}
}

public EmitSound(entity, channel, const sound[])
{
	if(equal(sound,"common/wpn_denyselect.wav")) return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

public Spawn(id)
{
	if(!is_user_alive(id))
		return;
		
	if(!ma_klase[id])
		return;
		
      moze[id] = false

      client_cmd(id,"-duck")
      
	if(!random(8))
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
	}
	cs_set_user_model(id, (cs_get_user_team(id) == CS_TEAM_T)? CT_Skins[random_num(0,3)]: Terro_Skins[random_num(0,3)]);
}