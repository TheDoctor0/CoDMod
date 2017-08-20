#include <amxmodx>
#include <fakemeta>
#include <codmod>

new bool:ma_perk[33];

public plugin_init() 
{
      new perk_name[] = "Twarda Bania";
      new perk_desc[] = "Odpornosc na strzaly w glowe";

      register_plugin(perk_name, "1.0", "RiviT");

      cod_register_perk(perk_name, perk_desc);

      register_forward(FM_TraceLine, "TraceLine", 1);
}

public cod_perk_enabled(id)
      ma_perk[id] = true;

public cod_perk_disabled(id)
      ma_perk[id] = false;

public TraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{
      new iHit = get_tr2(trace, TR_pHit);
      
      if(!is_user_alive(iHit) || !ma_perk[iHit] || !is_user_alive(id) || get_tr2(trace, TR_iHitgroup) != HIT_HEAD) return FMRES_IGNORED;

      set_tr2(trace, TR_iHitgroup, 8);

      return FMRES_IGNORED;
}