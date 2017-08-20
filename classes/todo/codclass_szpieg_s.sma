#include <amxmodx>
#include <codmod>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <colorchat>

new const model[] = "models/QTM_CodMod/mine.mdl"

new const nazwa[] = "Szpieg";
new const opis[] = "Losowa bron i ubranie wroga: Special: Pułapka, ktora zakopuje wrogow";
new const bronie = 0;
new const zdrowie = 10;
new const kondycja = 20;
new const inteligencja = 0;
new const wytrzymalosc = 5;

new  cvar_ilosc_special;

new bool:ma_klase[33];
new ma_special[33];
new bool:special_uzyty[33];
new bool:bron_gracza[33];

new CT_Skins[4][] = {"sas","gsg9","urban","gign"},
	Terro_Skins[4][] = {"arctic","leet","guerilla","terror"};

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote edit by Eustachy8");
	
	RegisterHam(Ham_Spawn, "player", "Resp", 1);	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_event("ResetHUD", "ResetHUD", "abe");
	cvar_ilosc_special = register_cvar("special_ilosc", "2"); 
    register_clcmd("special", "class_special_used");
	register_touch("trap", "player",  "DotykPulapki");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}
public plugin_precache()
	precache_model(model);

public cod_class_enabled(id)
{
	ZmienUbranie(id, 0);
	new ilosc_special = get_pcvar_num(cvar_ilosc_special);
	ma_klase[id] = true;
	ma_special[id] = ilosc_special;
	special_uzyty[id] = false;
	Resp(id);
	ResetHUD(id);
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	ma_special[id] = 0;
	special_uzyty[id] = false;
	ZmienUbranie(id, 1);
	cod_take_weapon(id, bron_gracza[id]);
	bron_gracza[id] = 0;
}

public Resp(id)
{
	if(ma_klase[id])
	{
		if(bron_gracza[id])
			cod_take_weapon(id, bron_gracza[id]);
		
		cod_give_weapon(id, bron_gracza[id] = random_num(2, 29));
	}
}

public ZmienUbranie(id,reset)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if (reset)
		cs_reset_user_model(id);
	else
	{
		new num = random_num(0,3);
		cs_set_user_model(id, (get_user_team(id) == 1)? CT_Skins[num]: Terro_Skins[num]);
	}
	
	return PLUGIN_CONTINUE;
}
public Pulapeczka(id)
{		

	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
		
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, "trap");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, model);
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	
	
	return PLUGIN_CONTINUE;
}

public DotykPulapki(ent, id)
{
	if(!is_valid_ent(ent))
		return;
		
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector(id, EV_VEC_origin, fOrigin);
		fOrigin[2] -= 30.0;
		entity_set_vector(id, EV_VEC_origin, fOrigin);
		set_task(30.0, "Odkop", id);

		remove_entity(ent);
	}
}

public ResetHUD(id)
{
	new ilosc_special = get_pcvar_num(cvar_ilosc_special);
	ma_special[id] = ilosc_special;
	special_uzyty[id] = false;
	ShowAmmo(id);
}

public NowaRunda()
{
	new ent = find_ent_by_class(-1, "trap");
	while(ent > 0) 
	{
		remove_entity(ent);
		ent = find_ent_by_class(ent, "trap");	
	}
}

public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "trap");
	while(ent > 0)
	{
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "trap");
	}
}

public Odkop(id)
{
	new Float:fOrigin[3];
	entity_get_vector(id, EV_VEC_origin, fOrigin);
	fOrigin[2] += 30.0;
	entity_set_vector(id, EV_VEC_origin, fOrigin);
}
// SPECIAL	
public class_special_used(id)
{
	if(!is_user_connected(id))
		return;
	
	if(!ma_klase[id])
		return;

		if(!ma_special[id]>0)
	{
		ColorChat(id, GREEN, "Wykorzystales juz speciale.");
		return;
	}

	ma_special[id] -= 1;
	ColorChat(id, GREEN, "Special on.");
	Pulapeczka(id);
	ShowAmmo(id);
}

ShowAmmo(id)
{ 
	new ilosc_special = get_pcvar_num(cvar_ilosc_special);
    new ammo[51] 
    formatex(ammo, 50, "Liczba speciali: %i/%i",ma_special[id], ilosc_special)

    message_begin(MSG_ONE, get_user_msgid("StatusText"), {0,0,0}, id) 
    write_byte(0) 
    write_string(ammo) 
    message_end() 
}

// +special by Eustachy8