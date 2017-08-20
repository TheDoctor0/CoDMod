#include <amxmodx>
#include <codmod>
#include <fakemeta_util>

#define PLUGIN	"Regenerator"
#define AUTHOR	"Mentos"
#define VERSION	"1.0"

new const nazwa[] = "Regenerator";
new const opis[] = "Co 5 sekund regeneruje sie 5hp";
new const bronie = 1<<CSW_MP5NAVY;
new const zdrowie = 40;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

        cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
{
        set_task(5.0, "DodajHP", id, _, _, "b");
}

public cod_class_disabled(id)
{
        remove_task(id);
}

public DodajHP(id)
{
        if(get_user_health(id) < 100+cod_get_user_health(id))
                fm_set_user_health(id, get_user_health(id)+5);
}

