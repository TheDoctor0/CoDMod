#include <amxmodx>
#include <codmod>
#include <engine>
#include <colorchat>

new const perk_name[] = "Zlodziej";
new const perk_desc[] = "Masz 1/SW szans na zabranie itemu ofiarze";

new wartosc_perku[33] = 0;
new bool:ma_perk[33];
new ofiara[33], perk_ofiary[33], wartosc_perku_ofiary[33];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "O'Zone");
	
	cod_register_perk(perk_name, perk_desc, 3, 3);
}

public cod_perk_enabled(id, wartosc)
{
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
}
	
public cod_perk_disabled(id)
	ma_perk[id] = false;

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);

	if(!is_user_connected(killer))
		return;
	
	if(!ma_perk[killer])
		return;

	if(random_num(1, wartosc_perku[killer]) != 1)
		return;

	if(!(perk_ofiary[killer] = cod_get_user_perk(victim, wartosc_perku_ofiary[killer])))
		return;
		
	ofiara[killer] = victim;
	Zapytaj(killer);
}

public Zapytaj(id)
{
	new tytul[55];
	new nazwa_perku[33];
	cod_get_perk_name(perk_ofiary[id], nazwa_perku, 32);
	format(tytul, 54, "Czy chcesz ukrasc perk: %s ?", nazwa_perku);
	new menu = menu_create(tytul, "Zapytaj_Handle");
	
	menu_additem(menu, "Tak");
	menu_setprop(menu, MPROP_EXITNAME, "Nie");
	
	menu_display(id, menu);
}

public Zapytaj_Handle(id, menu, item)
{
	if(item)
		return;

	if(cod_get_user_perk(ofiara[id]) != perk_ofiary[id])
		return;

	new nick_zlodzieja[33];
	get_user_name(id, nick_zlodzieja, 32);
	ColorChat(ofiara[id], GREEN, "[COD:MW]^x01 Twoj perk zostal skradziony przez^x03 %s.", nick_zlodzieja);
	cod_set_user_perk(ofiara[id], 0);
	cod_set_user_perk(id, perk_ofiary[id], wartosc_perku_ofiary[id]);
}