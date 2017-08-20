#include <amxmodx>
#include <codmod>
#include hamsandwich

new const perk_name[] = "Chwilowka";
new const perk_desc[] = "Po uzyciu otrzymujesz na 25s auto-lame";

new bool:uzyl[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "MAGNET")
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_Spawn, "player", "spawn", 1);
}

public cod_perk_enabled(id)
	uzyl[id] = false
	
public cod_perk_disabled(id)
{
	remove_task(id)
	cod_take_weapon(id, CSW_SG550)
}

public cod_perk_used(id)
{
	if(uzyl[id])
	{
		client_print(id, print_center, "Wykorzystales juz perk w tej rundzie!");
		return;
	}
	
	uzyl[id] = true;
	
      cod_give_weapon(id, CSW_SG550)

	set_task(25.0, "Wylacz", id);
}

public Wylacz(id)
{
	if (!is_user_connected(id)) return;

	cod_take_weapon(id, CSW_SG550)
}

public spawn(id)
{
	if(is_user_alive(id))
	{
		remove_task(id)
		cod_take_weapon(id, CSW_SG550)
		uzyl[id] = false
	}
}
