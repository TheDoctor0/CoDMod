#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Elitarny Snajper [P]";
new const opis[]    = "88 widocznosci na AWP, 600 grawitacji";
new const bronie    = (1<<CSW_AWP)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE);
new const zdrowie   = 10;
new const kondycja  = 5;
new const inteligencja = 10;
new const wytrzymalosc = 15;
    
new bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Premium");
	
	new const Nazwy_broni[][] = {
	"weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", 
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", 
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", 
	"weapon_ak47", "weapon_knife", "weapon_p90" }
	
      for(new i = 0; i < sizeof Nazwy_broni; i++)
            RegisterHam(Ham_Item_Deploy, Nazwy_broni[i], "fwHamItemDeploy", 1)

      RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_PREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}
	
	ma_klase[id] = true
	
      set_task(0.2, "fwSpawn_Grawitacja", id)
   
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
      cod_remove_user_rendering(id)
      entity_set_float(id, EV_FL_gravity, 1.0);
      ma_klase[id] = false
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
	{
		cod_remove_user_rendering(id)
		entity_set_float(id, EV_FL_gravity, 0.75);
		cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
      }
}

#define m_pPlayer 41
public fwHamItemDeploy(ent)
{
	static id;
	id = get_pdata_cbase(ent, m_pPlayer, 4)
	
	if(!is_user_alive(id) || !ma_klase[id]) return;
	
	if(cs_get_weapon_id(ent) == CSW_AWP)
		cod_set_user_rendering(id, 88)
	else
		cod_remove_user_rendering(id)
}