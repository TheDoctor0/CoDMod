#include <amxmodx>
#include <codmod>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#pragma tabsize 0
        
new const nazwa[]   = "Rambo [SP]";
new const opis[]    = "Podczas przebywania w powietrzu masz 5 widocznosci, +8dmg z deagle, 1/5 na zabranie calej kasy ofierze";
new const bronie    = (1<<CSW_AK47)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE)|(1<<CSW_HEGRENADE);
new const zdrowie   = 35;
new const kondycja  = 20;
new const inteligencja = 15;
new const wytrzymalosc = 15;
    
new bool:ma_klase[33], bool:bInvis[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Super Premium");
	
      RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
      RegisterHam(Ham_Spawn, "player", "fwSpawn_Grawitacja", 1);
      
      register_forward(FM_CmdStart, "CmdStart");
}

public cod_class_enabled(id)
{
	if(!(cod_get_user_status(id) & STATUS_SPREMIUM))
	{
		client_print(id, print_chat, "[%s] Nie masz super premium, zeby grac ta klasa!", nazwa)
		return COD_STOP;
	}
	
      set_task(0.2, "fwSpawn_Grawitacja", id)

	ma_klase[id] = true;
   
	return COD_CONTINUE;
}

public fwSpawn_Grawitacja(id)
{
	if(ma_klase[id])
	{
		cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		cod_remove_user_rendering(id)
	}
}

public cod_class_disabled(id)
{
	cod_remove_user_rendering(id)
    	ma_klase[id] = false;
}

public CmdStart(id)
{
      if(!ma_klase[id]) return;
      
	static Float:fVelo[3];
	pev(id, pev_velocity, fVelo);

	if(fVelo[2])
	{
	      if(!bInvis[id])
		{
			bInvis[id] = true;
                  cod_set_user_rendering(id, 5)
		}
	}
	else
	{
		if(bInvis[id])
		{
			bInvis[id] = false;
			cod_remove_user_rendering(id)
		}
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
      if(!is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
            return HAM_IGNORED;

      if(!ma_klase[idattacker])
            return HAM_IGNORED;

      if(!random(5))
            cs_set_user_money(this, 0)

      if(get_user_weapon(idattacker) == CSW_DEAGLE && damagebits & DMG_BULLET)
      {
            SetHamParamFloat(4, damage+8)
            return HAM_HANDLED
      }

      return HAM_IGNORED;
}