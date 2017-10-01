#include <amxmodx>
#include <fakemeta_util>
#include <cod>

#define PLUGIN "CoD Item Szybkostrzelnosc"
#define VERSION "1.0.9"
#define AUTHOR "O'Zone"

#define NAME        "Szybkostrzelnosc"
#define DESCRIPTION "Masz o %s procent wieksza szybkostrzelnosc"
#define RANDOM_MIN  25
#define RANDOM_MAX  40
#define UPGRADE_MIN -3
#define UPGRADE_MAX 5
#define VALUE_MAX   100

static const weaponNames[] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", 
	"weapon_c4", "weapon_mac10","weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", 
	"weapon_ump45", "weapon_sg550","weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", 
	"weapon_awp", "weapon_mp5navy", "weapon_m249","weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", 
	"weapon_flashbang", "weapon_deagle", "weapon_sg552","weapon_ak47", "weapon_knife", "weapon_p90" }

new itemValue[MAX_PLAYERS + 1], itemActive;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	cod_register_item(NAME, DESCRIPTION, RANDOM_MIN, RANDOM_MAX);
}

public cod_item_enabled(id, value)
{
	set_bit(id, itemActive);

	itemValue[id] = value;
}

public cod_item_disabled(id)
	rem_bit(id, itemActive);

public cod_item_value(id)
	return itemValue[id];

public cod_item_upgrade(id)
	cod_random_upgrade(itemValue[id], UPGRADE_MIN, UPGRADE_MAX, _, VALUE_MAX);

public cod_cur_weapon(id, weapon)
{
	if(!get_bit(id, itemActive)) return;
		
	static Float:speedMultiplier, ent;
	
	speedMultiplier = floatdiv(1.0, 1.0 + (float(itemValue[id]) / 100.0));
	
	for(new i = 1; i < sizeof weaponNames; i++) {
		ent = fm_find_ent_by_owner(-1, weaponNames[i], id);
			
		if(ent) {
			set_pdata_float(ent, 46, (get_pdata_float(ent, 46, 4) * speedMultiplier), 4);
			set_pdata_float(ent, 47, (get_pdata_float(ent, 47, 4) * speedMultiplier), 4);
		}
	}
}