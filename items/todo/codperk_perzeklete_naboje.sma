#include <amxmodx>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Przeklete naboje";
new const perk_desc[] = "Masz 1/4 szans na wyrzucenie broni przeciwnika";

new bool:ma_perk[33];

public plugin_init()
{
            register_plugin(perk_name, "1.0", "Pas");
            
            cod_register_perk(perk_name, perk_desc);
            
            RegisterHam(Ham_TakeDamage, "player", "TakeDamage");          
}

public cod_perk_enabled(id, wartosc)
{
            client_print(id, print_chat, "Perk %s zostal stworzony przez Pas", perk_name);
            ma_perk[id] = true;
}

public cod_perk_disabled(id)
            ma_perk[id] = false;
            
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
                            if(!is_user_connected(idattacker))
                                                            return HAM_IGNORED;
                            
                            if(!ma_perk[idattacker])
                                                            return HAM_IGNORED;
                            
                            if(get_user_team(this) != get_user_team(idattacker) && random_num(1, 4) == 1 && damagebits & DMG_BULLET)
                                                            client_cmd(this, "drop");
                                                            
                            return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
