#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <engine>
#include <cstrike>

#define TASKID_CIEMNOSC 76225

new CzasTrwania;

public plugin_init() 
{
      new perk_name[] = "Ciemnosc";
      new perk_desc[] = "Tylko Ty masz noktowizor. Mozesz zrobic ciemno na 40s [C]. Perk niszczy sie po uzyciu";

	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
	
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1)
}

public cod_perk_used(id)
{
      CzasTrwania = 40

	set_task(1.0, "Ciemno", TASKID_CIEMNOSC+id, _, _, "a", CzasTrwania);
	
	set_lights("a")
	cs_set_user_nvg(id, 1)
	client_cmd(id, "nightvision")
      cod_set_user_perk(id, 0)
	
	return PLUGIN_CONTINUE
}

public Ciemno(id)
{
      --CzasTrwania

	if(!CzasTrwania)
      {
            id -= TASKID_CIEMNOSC
            set_lights("#OFF")
            client_cmd(id, "nightvision")
      }
}

public Odrodzenie(id)
{
      if(!is_user_alive(id)) return PLUGIN_CONTINUE
      
      if(CzasTrwania)
      {
            if(!cs_get_user_nvg(id))
                  cs_set_user_nvg(id, 1)

            client_cmd(id, "nightvision")
      }

      return PLUGIN_CONTINUE
}