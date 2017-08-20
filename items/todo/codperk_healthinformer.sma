#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>

#define DMG_BULLET (1<<1)

new const perk_name[] = "Health Informer";
new const perk_desc[] = "Po strzale widzisz zycie przeciwnika.";

new bool:ma_perk[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "amxx.pl");
	cod_register_perk(perk_name, perk_desc);
	RegisterHam(Ham_TakeDamage, "player", "fwd_Ham_TakeDamagePost", 1);
}

public cod_perk_enabled(id)
{
	ma_perk[id] = true;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public fwd_Ham_TakeDamagePost(victim, inflictor, attacker, Float:fDamage, damagebits) {

	if(!is_user_connected(attacker))
		return HAM_IGNORED;
	if (!is_user_alive(victim))
		return HAM_IGNORED;
	if (victim == attacker)
		return HAM_IGNORED;
	if (get_user_team(victim) == get_user_team(attacker))
		return HAM_IGNORED;
	if (!ma_perk[attacker])
		return HAM_IGNORED;
	if (damagebits && DMG_BULLET)
		pokazHP(attacker, victim);
	return HAM_IGNORED;
}

public pokazHP(attacker, victim) {
	new hp = get_user_health(victim);
	client_print(attacker, print_center, "Enemy's Health : %d", hp);

}
