#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <engine>

new bool:ma_perk[33];
public plugin_init()
{
	register_plugin( "Perk Braterstwo", "1.0", "Fili:P" );
	cod_register_perk( "Braterstwo", "Bedac niedaleko drugiej osoby z druzyny, zadajesz nieco wieksze obrazenia + inteligencja" );
	RegisterHam( Ham_TakeDamage, "player", "fw_Tdmg" );
}
public cod_perk_enabled( id )
	ma_perk[ id ] = true;
public cod_perk_disabled( id )
	ma_perk[ id ] = false;
public fw_Tdmg( this, ini, id, Float:damage, damagebits )
{
	if( !is_user_connected( id ) )
		return HAM_IGNORED;
	if( !ma_perk[ id ] )
		return HAM_IGNORED;
	new ents[1];
	find_sphere_class( id, "player", 50.0, ents, 1 );
	if( !is_user_alive( ents[0] ) )
		return HAM_IGNORED;
	SetHamParamFloat( 4, 0.0 );
	cod_inflict_damage( id, this, damage*1.15, 1.1, ini );
	return HAM_HANDLED;
}