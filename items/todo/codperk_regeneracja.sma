/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */

#include <amxmodx>
#include <codmod>
#include <fakemeta_util>

new const perk_name[] = "Regeneracja";
new const perk_desc[] = "Co 5 sekund regeneruje sie LW hp";

new bool:wartosc_perku[33]

public plugin_init()
{
	register_plugin(perk_name, "1.0", "bulka_z_maslem")

        cod_register_perk(perk_name, perk_desc, 5, 10);
}

public cod_perk_enabled(id, wartosc)
{
        set_task(5.0, "DodajHP", id, _, _, "b");
	wartosc_perku[id] = wartosc;
}

public cod_perk_disabled(id)
{
        remove_task(id);
}

public DodajHP(id, idattacker)
{
        if(get_user_health(id) < 100+cod_get_user_health(id))
                fm_set_user_health(id, get_user_health(id)+wartosc_perku[idattacker]);
}

/* ---------------Perk stworzony dla amxx.pl---------------
------------------przez bulka_z_maslem--------------------- */
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
