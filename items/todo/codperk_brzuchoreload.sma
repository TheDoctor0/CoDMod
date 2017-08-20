#include <amxmodx>
#include <codmod>
#include <fakemeta>


new const perk_name[] = "Brzucho Reload";
new const perk_desc[] = "Mozna cie zabic tylko strzalami w glowe";

new bool:ma_perk[33];

public plugin_init()
{
        register_plugin(perk_name, "1.0", "O'Zone");
        
        cod_register_perk(perk_name, perk_desc);
		
        register_forward(FM_TraceLine, "TraceLine");
        
}

public cod_perk_enabled(id)
        ma_perk[id] = true;

public cod_perk_disabled(id)
        ma_perk[id] = false;

public TraceLine(Float:v1[3], Float:v2[3], noMonsters, pentToSkip)
{
        if(!is_user_alive(pentToSkip) || !ma_perk[pentToSkip])
                return FMRES_IGNORED
        
        static entity2 ; entity2 = get_tr(TR_pHit)
        if(!is_user_alive(entity2))
                return FMRES_IGNORED
        
        if(pentToSkip == entity2)
                return FMRES_IGNORED
        
        if(get_tr(TR_iHitgroup) != 1) {
                set_tr(TR_flFraction,1.0)
                return FMRES_SUPERCEDE
        }
        return FMRES_IGNORED
}
