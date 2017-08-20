#include <amxmodx>
#include <codmod>
#include <hamsandwich>

new bool:ma_perk[33];

public plugin_init()
{
	register_plugin( "Perk Buty Hefajstosa", "1.0", "Fili:P" );
	cod_register_perk( "Buty Hefajstosa", "Otrzymujesz mniejsze obrazenia od upadku" );
	RegisterHam( Ham_TakeDamage, "player", "TakeDmg" );
}
public cod_perk_enabled(id)
	ma_perk[id]=true;
public cod_perk_disabled(id)
	ma_perk[id]=false;
public TakeDmg(this,idi,id,Float:dmg,damagebits)
{
	if( !is_user_alive( this ) )
		return HAM_IGNORED;
	if( is_user_alive( id ) )
		return HAM_IGNORED;
	if( !ma_perk[this] )
		return HAM_IGNORED;
	if( !(damagebits & (1<<5)) )
		return HAM_IGNORED;
	SetHamParamFloat( 4, dmg*0.2 );
	return HAM_IGNORED;
}