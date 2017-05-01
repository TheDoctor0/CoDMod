#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define DMG_BULLET (1<<1)

new const nazwa[] = "Rambo";
new const opis[] = "Posiada podwojny skok, 1/4 na natychmiastowe zabicie z AWP, dostaje pelny magazynek i 15hp po zabiciu wroga";
new const bronie = (1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_DEAGLE);
new const zdrowie = 20;
new const kondycja = 30;
new const inteligencja = 0;
new const wytrzymalosc = 20;
new const niewidzialnosc = 0;
new const bonus_niewidzialnosci = 0;

new bool:ma_klase[33];
new skoki[33];

new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init() {
	register_plugin(nazwa, "1.0", "O'Zone");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, niewidzialnosc, bonus_niewidzialnosci);
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_forward(FM_CmdStart, "MultiJump");
	
	register_event("DeathMsg", "DeathMsg", "ade");
}

public plugin_precache(){
	precache_model("models/cod_slowexp/vip/v_goldawp.mdl");
	precache_model("models/cod_slowexp/vip/p_goldawp.mdl");
}

public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_A))
	{
		client_print(id, print_chat, "[%s] Nie masz uprawnien, aby uzywac tej klasy.",nazwa)
		return COD_STOP;
	}
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public MultiJump(id, uc_handle)
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

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(!is_user_connected(killer) || !is_user_connected(victim))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[killer])
	{
		new cur_health = pev(killer, pev_health);
		new Float:max_health = 100.0+cod_get_user_health(killer);
		new Float:new_health = cur_health+15.0<max_health? cur_health+15.0: max_health;
		set_pev(killer, pev_health, new_health);
		
		new weapon = get_user_weapon(killer);
		if(maxClip[weapon] != -1)
			set_user_clip(killer, maxClip[weapon]);
	}
	
	
	return PLUGIN_CONTINUE;
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_AWP && damagebits & DMG_BULLET && random_num(1,4) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}
	
public CurWeapon(id)
{
	if(!ma_klase[id])
		return PLUGIN_CONTINUE;
	
	new bron = read_data(2)  

	if(bron == CSW_AWP){
		set_pev(id,pev_viewmodel2,"models/cod_slowexp/vip/v_goldawp.mdl")
		set_pev(id,pev_weaponmodel2,"models/cod_slowexp/vip/p_goldawp.mdl")
	}
	return PLUGIN_CONTINUE;
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = engfunc(EngFunc_FindEntityByString, weaponid, "classname", weaponname)) != 0)
		if (pev(weaponid, pev_owner) == id) {
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}
