#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

#define DMG_BULLET (1<<1)

new const nazwa[]   = "Wyszkolony Snajper";
new const opis[]    = "1/4 z AWP, 1/10 z Deagle, mo¿e wykonaæ skok w powietrzu.";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_DEAGLE)|(1<<CSW_SCOUT)|(1<<CSW_MAC10)|(1<<CSW_FLASHBANG)|(1<<CSW_FLASHBANG);
new const zdrowie   = 50;
new const kondycja  = 30;
new const inteligencja = 45;
new const wytrzymalosc = 20;

new skoki[33];
new ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "amxx.pl");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_forward(FM_CmdStart, "fwCmdStart_MultiJump");
}

public cod_class_enabled(id)
{
	ma_klase[id]= true;
}
public cod_class_disabled(id)
{
	ma_klase[id]=false;
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(!(damagebits & DMG_BULLET))
		return HAM_IGNORED;
	
	if(get_user_weapon(idattacker) == CSW_AWP && random_num(1,4) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	if(get_user_weapon(idattacker) == CSW_DEAGLE && random_num(1,10) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
public fwCmdStart_MultiJump(id, uc_handle)
{
	if(!is_user_alive(id) || !ma_klase[id])
		return FMRES_IGNORED;

	new flags = pev(id, pev_flags);

	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id])
	{
		skoki[id]--;
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity,velocity);
	}
	else if(flags & FL_ONGROUND)
		skoki[id] = 1;

	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
