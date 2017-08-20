#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <hamsandwich>
 
new const perk_name[] = "Lowca Headow";
new const perk_desc[] = "Za strzal w glowe dostajesz LW EXP'a";

new bool:ma_perk[33],
wartosc_perku[33]
 
public plugin_init()
{
      register_plugin(perk_name, "1.0", "RiviT");
        
      cod_register_perk(perk_name, perk_desc, 300, 600);
	  
      RegisterHam(Ham_TraceAttack, "player", "TraceAttack");
}
        
public cod_perk_enabled(id, wartosc)
{
        ma_perk[id] = true;
        wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
        ma_perk[id] = false;
        
public TraceAttack(id, attacker, Float:damage, Float:direction[3], tracehandle)
{
        if(!is_user_connected(attacker) || get_user_team(id) == get_user_team(attacker) || id == attacker)
                return HAM_IGNORED;
                
        if(get_tr2(tracehandle, TR_iHitgroup) == HIT_HEAD)
                cod_add_user_xp(attacker, wartosc_perku[attacker]);
        
        return HAM_HANDLED;
}