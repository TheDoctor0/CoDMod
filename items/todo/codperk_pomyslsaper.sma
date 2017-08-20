#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <fakemeta>

new bool:ma_perk[33];

new const perk_name[] = "Pomysl sapera";
new const perk_desc[] = "P90 +10 dmg, +40 wytrzymalosci, widzisz miny";

public plugin_init()
{
	register_plugin(perk_name, "1.0", "RiviT")
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_TakeDamage, "player", "Obrazenia", 0);
	
      register_forward(FM_AddToFullPack, "FwdAddToFullPack", 1)
}

public cod_perk_enabled(id)
{
	cod_add_user_bonus_stamina(id, 40);
	cod_give_weapon(id, CSW_P90);
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	cod_add_user_bonus_stamina(id, -40);
	cod_take_weapon(id, CSW_P90);
	ma_perk[id] = false;
}

public Obrazenia(this, idattacker, idinflictor, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED
	
	if(!ma_perk[idattacker])
		return HAM_IGNORED
	
	if(damagebits & (1<<1))
	{
		if(get_user_weapon(idattacker) == CSW_P90)
		{
			SetHamParamFloat(4, damage+10)
			return HAM_HANDLED
            }
	}
	return HAM_IGNORED
}

public FwdAddToFullPack(es_handle, e, ent, host)
{
   if(!is_user_connected(host))
      return;
   
   if(!ma_perk[host])
      return;
   
   if(!pev_valid(ent))
      return;
   
   new classname[5];
   pev(ent, pev_classname, classname, 4);
   if(equal(classname, "mine"))
   {
      set_es(es_handle, ES_RenderMode, kRenderTransAdd);
      set_es(es_handle, ES_RenderAmt, 255.0);
   }
   
}