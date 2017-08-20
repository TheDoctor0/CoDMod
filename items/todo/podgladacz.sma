#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <codmod>

new const perk_name[] = "Podgladacz";
new const perk_desc[] = "Mozesz zobaczyc co jest za drzwiami";

new bool:ma_perk[33];

public plugin_init()
{
	register_plugin(perk_name, "1.0", "MarWit & Dr@goN");
	
	cod_register_perk(perk_name, perk_desc);
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}


public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if( ! is_user_alive(host) || ! ma_perk[host] ||  ! isDoor(ent) )
		return FMRES_IGNORED;
		
	set_es(es_handle, ES_RenderMode, kRenderTransAdd );
	set_es(es_handle, ES_RenderAmt, 125 );
	
	return FMRES_HANDLED;
}

stock isDoor( iEntity )
{
	if( ! pev_valid( iEntity ) ) 
		return false;

	static szClassname[ 33 ];
	pev( iEntity, pev_classname, szClassname, 32 );
	
	return ( containi( szClassname, "door" ) != -1 );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
