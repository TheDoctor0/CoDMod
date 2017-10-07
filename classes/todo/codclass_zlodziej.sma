#include <amxmodx>
#include <codmod>
#include <engine>
#include <colorchat>
new const nazwa[] = "Zlodziej";
new const opis[] = "Ma zmniejszona widocznosc oraz 1/2 szansy na zabranie perku swojej ofierze";
new const bronie = 1<<CSW_GALIL;
new const zdrowie = 0;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;
new bool:ma_klase[33];
new ofiara[33], perk_ofiary[33], wartosc_perku_ofiary[33];
public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("DeathMsg", "DeathMsg", "ade");
}
public cod_class_enabled(id)
{
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 150);
	ma_klase[id] = true;
}
public cod_class_disabled(id)
{
	set_rendering(id,kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255);
	ma_klase[id] = false;
}
public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if (!is_user_connected(killer))
		return;
	
	if (!ma_klase[killer])
		return;
	
	if (random(3))
		return;
	
	if (!(perk_ofiary[killer] = cod_get_user_perk(victim, wartosc_perku_ofiary[killer])))
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
	if (item)
		return;
	
	if (cod_get_user_perk(ofiara[id]) != perk_ofiary[id])
		return;
	
	new nick_zlodzieja[33];
	get_user_name(id, nick_zlodzieja, 32);
	ColorChat(ofiara[id], RED, "Twoj perk zostal skradziony przez %s.", nick_zlodzieja);
	cod_set_user_perk(ofiara[id], 0);
	cod_set_user_perk(id, perk_ofiary[id], wartosc_perku_ofiary[id]);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
