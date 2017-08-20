#include <amxmodx>
#include <codmod>
#include <fun>

new const perk_name[] = "Magiczny Noz"
new const perk_desc[] = "Podczas wyjetego noza jestes niesmiertelny i nie mozesz sie ruszac"

new bool:ma_perk[33]
new Float:oldspeed[33]

new bool:freezetime = true

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Dr@goN")
	cod_register_perk(perk_name, perk_desc)
	register_event("CurWeapon", "CurWeapon", "be")

	register_logevent("PoczatekRundy", 2, "1=Round_Start")
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0")
}

public cod_perk_enabled(id)
	ma_perk[id] = true

public cod_perk_disabled(id)
{
	ma_perk[id] = false
	set_user_godmode(id, 0)
	set_user_maxspeed(id, oldspeed[id])
}

public CurWeapon(id){
	if(freezetime == false && ma_perk[id] == true && get_user_weapon(id) == CSW_KNIFE)
	{
		oldspeed[id] = get_user_maxspeed(id)
		set_user_maxspeed(id, 0.1)
		set_user_godmode(id, 1)
	}
	else
	if(freezetime == false && ma_perk[id] == true && get_user_weapon(id) != CSW_KNIFE)
	{
		set_user_maxspeed(id, oldspeed[id])
		set_user_godmode(id, 0)
	}
	
}

public PoczatekRundy()
	freezetime = false

public NowaRunda()
	freezetime = true