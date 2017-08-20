#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <codmod>
new bool:ma_perk[33];
public plugin_init()
{
	register_plugin( "Perk Pan Swiata", "1.0", "Fili:P" );
	register_touch( "func_door", "player", "Touch" );
	cod_register_perk( "Pan Swiata", "Mozesz przechodzic przez drzwi" );
}
public cod_perk_enabled(id)
	ma_perk[id]=true;
public cod_perk_disabled(id)
	ma_perk[id]=false;
public Touch( drzwi, id )
{
	if(is_valid_ent(drzwi)&& is_user_alive(id)&&ma_perk[id])
		set_pev( drzwi, pev_owner, id );
	return PLUGIN_HANDLED;
}
