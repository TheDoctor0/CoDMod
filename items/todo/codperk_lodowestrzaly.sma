#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta_util>
#include fun

new const perk_name[] = "Lodowe strzaly";
new const perk_desc[] = "Masz 1/10 szansy na zamrozenie przeciwnika, zamrozenie trwa 3s";

new bool:ma_perk[33], bool:zamrozenie[33]

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1)
	RegisterHam(Ham_Killed, "player", "HamKilledPre", 0)
}

public cod_perk_enabled(id)
	ma_perk[id] = true

public cod_perk_disabled(id)
	ma_perk[id] = false

public TakeDamage(this, idinflictor, idattacker)
{
	if(!is_user_connected(idattacker) || get_user_team(idattacker) == get_user_team(this) || zamrozenie[this]) return HAM_IGNORED;

	if(ma_perk[idattacker] && !random(10))
	{
		zamrozenie[this] = true
		set_pev(this, pev_flags, pev(this, pev_flags) | FL_FROZEN)
		set_task(3.0, "Odmroz", this)
		client_print(this, print_center, "Zostales zamrozony na 3s!")
	}
	
	return HAM_IGNORED
}

public HamKilledPre(this, attacker)
{
	if(is_user_connected(this) && zamrozenie[this])
		set_pev(this, pev_flags, pev(this, pev_flags) &~ FL_FROZEN)
}

public Odmroz(id)
{
      if(!is_user_alive(id)) return
      
      new origin[3]
      get_user_origin(id, origin)
      
	set_pev(id, pev_flags, pev(id, pev_flags) &~ FL_FROZEN)
	zamrozenie[id] = false
	
	origin[2] += 35
	set_user_origin(id, origin)
}