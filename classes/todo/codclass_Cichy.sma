#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

new bool:ma_klase[33]

#define m_fWeaponState_Usp 74 //(int) Bit flag status of weapon silencer/shield.
#define CBASE_WEAPONSTATE_USP_SILENCED ( 1 << 0 )
#define CBASE_WEAPONSTATE_M4A1_SILENCED ( 1 << 2 )
        
new const nazwa[]   = "Cichy";
new const opis[]    = "Na poczatku rundy ma odrazu zalozony tlumik na usp i m4a1";
new const bronie    = (1<<CSW_USP)|(1<<CSW_M4A1);
new const zdrowie   = 0;
new const kondycja  = 0;
new const inteligencja = 5;
new const wytrzymalosc = 10;

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn", 1);
}

public cod_class_enabled(id)
      ma_klase[id] = true

public cod_class_disabled(id)
      ma_klase[id] = false
      
public fwSpawn(id)
{
      if(is_user_alive(id) && ma_klase[id])
      {
            new ent = find_ent_by_owner(-1, "weapon_usp", id)
            if(ent)
                  set_pdata_int(ent, m_fWeaponState_Usp, get_pdata_int(ent, m_fWeaponState_Usp, 4) | CBASE_WEAPONSTATE_USP_SILENCED, 4)
                  
            ent = find_ent_by_owner(-1, "weapon_m4a1", id)
            if(ent)
                  set_pdata_int(ent, m_fWeaponState_Usp, get_pdata_int(ent, m_fWeaponState_Usp, 4) | CBASE_WEAPONSTATE_M4A1_SILENCED, 4)
      }
}