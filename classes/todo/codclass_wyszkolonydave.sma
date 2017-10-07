#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <cstrike>
	
#define DMG_HEGRENADE (1<<24)
	
new const nazwa[]   = "Wyszkolony Dave";
new const opis[]    = "Posiada ubranie wroga, zmniejszona widocznoœæ na no¿u do 200, 1/1 he";
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_MP5NAVY)|(1<<CSW_DEAGLE);
new const zdrowie   = 60;
new const kondycja  = 20;
new const inteligencja = 35;
new const wytrzymalosc = 40;
    
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);

	register_event("CurWeapon", "eventKnife_Niewidzialnosc", "be", "1=1");

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

public cod_class_enabled(id)
{
	give_item(id, "weapon_hegrenade");
	ma_klase[id] = true;

}

public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
    	ma_klase[id] = false;

}
public Spawn(id)
{
	cod_class_used(id);
}
public cod_class_used(id)
{
	if (!is_user_alive(id))
		return;
	
	if (!ma_klase[id])
		return;
	
	if (random_num(1,1) == 1)
	{
		new CsTeams:team = cs_get_user_team(id);
		
		cs_set_user_team(id, (team == CS_TEAM_CT)? CS_TEAM_T: CS_TEAM_CT);
		ExecuteHam(Ham_CS_RoundRespawn, id);
		
		cs_set_user_team(id, team);
	}
}

public eventKnife_Niewidzialnosc(id)
{
	if (!ma_klase[id])
		return;

	if ( read_data(2) == CSW_KNIFE )
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 200);
	}
	else
	{
		set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
	}
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
        if (!is_user_connected(idattacker))
                return HAM_IGNORED;

        if (!ma_klase[idattacker])
                return HAM_IGNORED;

        if (get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_HEGRENADE && damagebits & DMG_HEGRENADE)
                cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
        
        return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
