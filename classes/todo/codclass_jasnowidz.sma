#include <amxmodx>
#include <codmod>
#include <colorchat>
#include <fakemeta_util>

#define KAC_TASK 1452614

new const nazwa[]   = "Jasnowidz"
new const opis[]    = "Moze przechodzic w obce cialo"
new const bronie    = (1<<CSW_HEGRENADE)|(1<<CSW_XM1014)|(1<<CSW_FLASHBANG)|(1<<CSW_DEAGLE)
new const zdrowie   = 20
new const kondycja  = 50
new const inteligencja = 0
new const wytrzymalosc = 0

new g_msgHostageAdd, g_msgHostageDel, msg_bartime, g_MaxPlayers
new gracz_id[33], name[33], wybrany[33]
new bool:skorzystal[33], bool:oznaczony[33]

public plugin_precache() {
	engfunc(EngFunc_PrecacheModel, "models/w_c4.mdl")
	engfunc(EngFunc_PrecacheSound, "cod_jasnowidz/wchodzi.wav")
}
public plugin_init()
{
	register_plugin("[COD] Jasnowidz", "1.5", "Dr@goN")
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc)
	
	g_MaxPlayers = get_maxplayers()
	register_cvar("cod_jasnowidz_moc", "20") // co ile sekund gracz moze uzyc mocy
	register_cvar("cod_jasnowidz_sledz", "3") // przez ile sekund ofiara ma byc obserwowana
	register_cvar("cod_jasnowidz_radar", "10") // przez ile sekund ma byc sledzona ofiara na radarze; 0-wylaczone; 1 - az do smierci badz nowej rundy
	register_cvar("cod_jasnowidz_odglos", "1") // 1 - gdy gracz przejdzie na ofiare, to wokol ofiary zostanie odegrany odglos; 0 - nie bedzie
	
	msg_bartime = get_user_msgid("BarTime")
	g_msgHostageAdd = get_user_msgid("HostagePos")
	g_msgHostageDel = get_user_msgid("HostageK")
	
	set_task(2.0,"radar_scan",.flags = "b")
	register_event("DeathMsg", "Death", "a")
	register_forward(FM_Think, "FM_KameraGracza")
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0")
}

public cod_class_enabled(id) skorzystal[id] = false
public cod_class_disabled(id)
{
	skorzystal[id] = false
	fm_set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255)
}

public cod_class_skill_used(id)
{
	if (!is_user_alive(id))
		return
	
	if (skorzystal[id])
	{
		ColorChat(id, RED, "Swojej umiejetnosci mozesz wykorzystywac co %d sekund!", get_cvar_num("cod_jasnowidz_moc"))
		return
	}
	
	Gracze(id)
}

public Gracze(id)
{
	new menu = menu_create("Kogo przesledzic?", "Gracze_handler")
	for(new i=0, n=0; i<=g_MaxPlayers; i++)
	{
		if (!is_user_alive(i) || get_user_team(i) == get_user_team(id) || i == id)
			continue
		
		gracz_id[n++] = i
		new nazwa_gracza[64]
		get_user_name(i, nazwa_gracza, 63)
		menu_additem(menu, nazwa_gracza, "0", 0)
	}
	menu_display(id, menu)
}

public Gracze_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	wybrany[id] = gracz_id[item]
	get_user_name(wybrany[id], name, 32)
	
	if (!is_user_alive(id)) {
		ColorChat(id, RED, "Za pozno.. juz nie zyjesz..")
		return PLUGIN_HANDLED
	}
	
	if (!is_user_alive(wybrany[id])) {
		ColorChat(id, TEAM_COLOR, "Niestety ^x04 %s ^x03 juz nie zyje.", name)
		return PLUGIN_HANDLED
	}
	
	skorzystal[id] = true
	set_task(float(get_cvar_num("cod_jasnowidz_moc")), "AktywacjaMocy",id+KAC_TASK)
	
	WejdzWCialo(id)
	
	return PLUGIN_HANDLED
}

public WejdzWCialo(id)
{
	Display_Fade(id,1,1,0x0000,254,254,254,25)
	ColorChat(id, GREEN, "Obserwujesz: ^x01%s!", name)
	fm_set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 30)
	
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEnt, pev_classname, "player_hat")
	engfunc(EngFunc_SetModel, iEnt, "models/w_c4.mdl")
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt, pev_movetype, MOVETYPE_FLYMISSILE)
	set_pev(iEnt, pev_owner, wybrany[id])
	set_pev(iEnt, pev_rendermode, kRenderTransTexture)
	set_pev(iEnt, pev_renderamt, 0.0)
	engfunc(EngFunc_SetView, id, iEnt)
	set_pev(iEnt, pev_nextthink, get_gametime())
	
	new sledz = get_cvar_num("cod_jasnowidz_sledz")
	message_begin(MSG_ONE, msg_bartime, _, id)
	write_short(sledz)
	message_end()
	
	new info[3]
	info[0] = id
	info[1] = wybrany[id]
	info[2] = iEnt
	
	if (get_cvar_num("cod_jasnowidz_odglos") == 1) {
		emit_sound(wybrany[id], CHAN_VOICE, "cod_jasnowidz/wchodzi.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)
		client_cmd(id, "spk cod_jasnowidz/wchodzi.wav")
	}
	set_task(float(sledz), "KoniecPodgladu",.parameter=info, .len=3)
}

public KoniecPodgladu(info[3])
{
	new id = info[0]
	new sledzony = info[1]
	new iEnt = info[2]
	
	engfunc(EngFunc_SetView, id, id)
	engfunc(EngFunc_RemoveEntity, iEnt)
	fm_set_rendering(id,kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255)
	
	if (get_cvar_num("cod_jasnowidz_radar") == 0) return
	if (!is_user_alive(sledzony)) return
	if (!is_user_alive(id) && is_user_connected(id))
	{
		ColorChat(id, RED, "Niestety nie dozyles. Nie udostepnisz namiarow na wroga swojej ^x03 druzynie.")
		return
	}
	new radar = get_cvar_num("cod_jasnowidz_radar")
	if (radar == 1) {
		oznaczony[sledzony] = true
		ColorChat(id, RED, "Ofiara jest oznaczona na radarze!")
	} else {
		oznaczony[sledzony] = true
		ColorChat(id, RED, "Ofiara jest oznaczona przez %d sekund na radarze!", radar)
		set_task(float(radar), "SledzOfiare", sledzony+541230)
	}
}

public FM_KameraGracza(iEnt)
{
	static szClassname[32]
	pev(iEnt, pev_classname, szClassname, sizeof szClassname - 1)
	
	if (!equal(szClassname, "player_hat"))
		return FMRES_IGNORED
	
	static g_Owner
	g_Owner = pev(iEnt, pev_owner)
	
	if (!is_user_alive(g_Owner))
		return FMRES_IGNORED
	
	static Float:g_Origin[3], Float:g_Angle[3]
	pev(g_Owner, pev_origin, g_Origin)
	pev(g_Owner, pev_v_angle, g_Angle)
	static Float:v_Back[3]
	angle_vector(g_Angle, ANGLEVECTOR_FORWARD, v_Back)
	g_Origin[2] += 40.0
	g_Origin[0] += (-v_Back[0] * 150.0)
	g_Origin[1] += (-v_Back[1] * 150.0)
	g_Origin[2] += (-v_Back[2] * 150.0)
	
	engfunc(EngFunc_SetOrigin, iEnt, g_Origin)
	set_pev(iEnt, pev_angles, g_Angle)
	set_pev(iEnt, pev_nextthink, get_gametime())
	
	return FMRES_HANDLED
}

public radar_scan()
{
	if (get_cvar_num("cod_jasnowidz_radar") == 0) return
	
	new PlayerCoords[3]
	
	for(new i=1; i<=g_MaxPlayers; i++)
	{
		if (oznaczony[i])
		{
			get_user_origin(i, PlayerCoords)
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageAdd, {0,0,0}, oznaczony[i])
			write_byte(oznaczony[i])
			write_byte(i)           
			write_coord(PlayerCoords[0])
			write_coord(PlayerCoords[1])
			write_coord(PlayerCoords[2])
			message_end()
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgHostageDel, {0,0,0}, oznaczony[i])
			write_byte(i)
			message_end()
		}
	}
}

public AktywacjaMocy(id)
{
	id-=KAC_TASK
	skorzystal[id] = false
	if (is_user_alive(id))
		ColorChat(id, RED, "Mozesz wkoncu wykorzystac swoja umiejetnosc!")
}

public SledzOfiare(sledzony)
{			
	sledzony-=541230
	oznaczony[sledzony] = false
}

public Death() {
	new id = read_data(2)
	
	if (skorzystal[id])
	{
		skorzystal[id] = false
		remove_task(KAC_TASK+id, 0)
	}
	
	if (oznaczony[id])
	{
		oznaczony[id] = false
		remove_task(541230+id, 0)
	}
}

public NowaRunda() {
	for (new id=1;id<=g_MaxPlayers;id++)
	{
		skorzystal[id] = false
		remove_task(KAC_TASK+id, 0)
		
		oznaczony[id] = false
		remove_task(541230+id, 0)
	}
}

public client_disconnect(id) { 
	skorzystal[id] = false
	oznaczony[id] = false
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha) {
	static msgScreenFade

	if (!msgScreenFade) msgScreenFade = get_user_msgid("ScreenFade")

	message_begin(!id ? MSG_ALL : MSG_ONE, msgScreenFade,{0,0,0},id)
	write_short((1<<12) * duration)  // Duration of fadeout
	write_short((1<<12) * holdtime)  // Hold time of color
	write_short(fadetype)    // Fade type
	write_byte(red)         // Red
	write_byte(green)       // Green
	write_byte(blue)        // Blue
	write_byte(alpha)       // Alpha
	message_end();
} // DarkGL
