#include <amxmodx>
#include <codmod>
#include <fun>
#include csx

#define TASK_PALACE_REKAWICZKI 73685

new bool:ma_perk[33];

public plugin_init() 
{
      new const perk_name[] = "Palace rekawiczki";
      new const perk_desc[] = "Co 15 sekund dostajesz HE";

	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	cod_give_weapon(id, CSW_HEGRENADE);
}

public cod_perk_disabled(id)
{
	cod_take_weapon(id, CSW_HEGRENADE);
	ma_perk[id] = false;
	remove_task(id+TASK_PALACE_REKAWICZKI)
}

public grenade_throw(id, greindex, wid)
{
      if(!ma_perk[id]) return;
      
      if(wid == CSW_HEGRENADE) set_task(15.0, "PalaceRekawiczki", id+TASK_PALACE_REKAWICZKI);
}

public PalaceRekawiczki(id)
{
	id -= TASK_PALACE_REKAWICZKI;
		
	if(is_user_alive(id))
		give_item(id, "weapon_hegrenade");
}