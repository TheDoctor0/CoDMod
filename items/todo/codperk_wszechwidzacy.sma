/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fakemeta>

new bool:ma_perk[33];

new const perk_name[] = "Wszechwidzacy";
new const perk_desc[] = "Widzisz miny i niewidzialnych";

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")
	
	cod_register_perk(perk_name, perk_desc);
	
	register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
	
	register_forward(FM_AddToFullPack, "Miny", 1)
}

public cod_class_enabled(id)
{
	ma_perk[id] = true;
}
public cod_class_disabled(id)
{
	ma_perk[id] = false;
}

public FwdAddToFullPack(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!is_user_connected(host) || !is_user_connected(ent))
		return;
	
	if(!ma_perk[host])
		return;
	
	set_es(es_handle, ES_RenderAmt, 255.0);
}

public Miny(es_handle, e, ent, host, hostflags, player, pSet)
{
	if(!pev_valid(ent))
		return;
	
	new classname[5];
	pev(ent, pev_classname, classname, 4);
	if(equal(classname, "mine"))
	{
		set_es(es_handle, ES_RenderMode, kRenderTransAdd);
		set_es(es_handle, ES_RenderAmt, 90.0);
	}
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
