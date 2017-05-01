#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <codmod>


new const perk_name[] = "Noz Komandosa";
new const perk_desc[] = "Natychmiastowe zabicie z noza";

new komandos_id;

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	komandos_id = cod_get_classid("Komandos");
}

public cod_perk_enabled(id)
{
	if(cod_get_user_class(id) == komandos_id)
		return COD_STOP;
	ma_perk[id] = true;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
	ma_perk[id] = false;

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED;
	
	if(get_user_team(this) != get_user_team(idattacker) && get_user_weapon(idattacker) == CSW_KNIFE && damagebits & DMG_BULLET && damage > 20)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+1.0, 0.0, idinflictor, damagebits);
	
	return HAM_IGNORED;
}
