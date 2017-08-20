#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include <fakemeta>
#include <engine>
#include <cstrike>
#include <ColorChat>

// Nazwa klasy codmod
#define CLASS_NAME "Snajper"
// Opis klasy codmod
#define CLASS_DESC "Posiada nowe silniejsze AWP, jest niewidzialny z AWP kucajac"
// Punkty Zdrowia klasy
#define CLASS_HEALTH_POINTS 20
// Punkty Kondycji klasy
#define CLASS_TRIM_POINTS 25
// Punkty Inteligencji klasy
#define CLASS_INTELIGENCE_POINTS 0
// Punkty Wytrzymalosci klasy
#define CLASS_STAMINA_POINTS 20

// Sciezka do nowego modelu v (string)
#define WEAPON_1_V_MODEL "models/v_awp2.mdl"
// Sciezka do nowego modelu p (string)
#define WEAPON_1_P_MODEL "models/p_awp2.mdl"
// Sciezka do nowego modelu w (string)
#define WEAPON_1_W_MODEL "models/w_awp2.mdl"
// Sciezka do starego modelu w (string)
#define WEAPON_1_OLD_W_MODEL "models/w_awp.mdl"
// Klasa bytu broni (string)
#define WEAPON_1_CLASSNAME "weapon_awp"
// Id bytu broni (CSW_)
#define WEAPON_1_ID CSW_AWP
// Nowa klasa bytu broni (string) (jakby wirtualna )
#define WEAPON_1_NEWCLASSNAME "weapon_newawp"
// Primary Ammo ( jezeli bron nie primary to ustaw -1 )
#define WEAPON_1_PRIMARY_AMMO_ID 1
// ID Primary Max Ammo ( Maksymalna ilosc amunicji ) ( jezeli bron nie primary to ustaw -1 )
#define WEAPON_1_PRIMARY_MAX_AMMO 30
// ID Secondary Ammo  ( jezeli bron secondary to ustaw -1 )
#define WEAPON_1_SECONDARY_AMMO_ID -1
// Secondary Max Ammo ( Maksymalna ilosc amunicji ) ( jezeli bron nie secondary to ustaw -1 )
#define WEAPON_1_SECONDARY_MAX_AMMO -1
// Numer slotu od 1 do 5
#define WEAPON_1_SLOT 1
// ID sekwencji wyjecia broni
#define WEAPON_1_DRAW_ID 5

// Sciezka do nowego modelu v (string)
#define WEAPON_2_V_MODEL "models/v_dg2.mdl"
// Sciezka do nowego modelu p (string)
#define WEAPON_2_P_MODEL "models/p_dg2.mdl"
// Sciezka do nowego modelu w (string)
#define WEAPON_2_W_MODEL "models/w_dg2.mdl"
// Sciezka do starego modelu w (string)
#define WEAPON_2_OLD_W_MODEL "models/w_deagle.mdl"
// Klasa bytu broni (string)
#define WEAPON_2_CLASSNAME "weapon_deagle"
// Id bytu broni (CSW_)
#define WEAPON_2_ID CSW_DEAGLE
// Nowa klasa bytu broni (string) (jakby wirtualna )
#define WEAPON_2_NEWCLASSNAME "weapon_newdeagle"
// ID Primary Ammo ( jezeli bron nie primary to ustaw -1 )
#define WEAPON_2_PRIMARY_AMMO_ID -1
// Primary Max Ammo ( Maksymalna ilosc amunicji ) ( jezeli bron nie primary to ustaw -1 )
#define WEAPON_2_PRIMARY_MAX_AMMO -1
// ID Secondary Ammo  ( jezeli bron secondary to ustaw -1 )
#define WEAPON_2_SECONDARY_AMMO_ID 8
// Secondary Max Ammo ( Maksymalna ilosc amunicji ) ( jezeli bron nie secondary to ustaw -1 )
#define WEAPON_2_SECONDARY_MAX_AMMO 35
// Numer slotu od 1 do 5
#define WEAPON_2_SLOT 2
// ID sekwencji wyjecia broni
#define WEAPON_2_DRAW_ID 5

new bool:ma_klase[33];
new old_weapon[33];
new MsgIndexWeaponList;
new bool:ma_nie[33];

public plugin_precache()
{
	precache_generic("sprites/weapon_newawp.txt");
	precache_generic("sprites/sniperW1s.spr");
	precache_generic("sprites/sniperW1.spr");
	precache_model(WEAPON_1_V_MODEL);
	precache_model(WEAPON_1_P_MODEL);
	precache_model(WEAPON_1_W_MODEL);
	precache_model(WEAPON_2_V_MODEL);
	precache_model(WEAPON_2_P_MODEL);
	precache_model(WEAPON_2_W_MODEL);
	precache_sound("weapons/de_deploy.wav");
}
public plugin_init()
{
	register_plugin("Klasa:Snajper", "1.0", "Fili:P");
	
	cod_register_class(CLASS_NAME, CLASS_DESC, 1 << WEAPON_1_ID | 1 << WEAPON_2_ID | 1<< CSW_KNIFE, CLASS_HEALTH_POINTS, CLASS_TRIM_POINTS, CLASS_INTELIGENCE_POINTS, CLASS_STAMINA_POINTS);
	
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	
	RegisterHam(Ham_Item_AddToPlayer, WEAPON_1_CLASSNAME, "OnAddToPlayerAwp", 1)
	RegisterHam(Ham_Item_ItemSlot, WEAPON_1_CLASSNAME, "OnItemSlotAwp" );  
	RegisterHam(Ham_TakeDamage, "player", "OnTakeDamage");
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_PlayerPreThink, "fw_PreThink");
	register_clcmd( WEAPON_1_NEWCLASSNAME, "ClientCommand_SelectAwp" );
	MsgIndexWeaponList = get_user_msgid( "WeaponList" );
}
public fw_PreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	SUsunNie(id);
	if(!ma_klase[id])	
		return FMRES_IGNORED;
	if(get_user_weapon(id) != CSW_AWP)
		return FMRES_IGNORED;
	if( !(pev(id, pev_button) & IN_DUCK) )
		return FMRES_IGNORED;
	if(pev(id, pev_speed) > 0.0)
		return FMRES_IGNORED;
	if(ma_nie[id])
		return FMRES_IGNORED;
	set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, random_num(50,100));
	ColorChat(id, GREEN, "Snajper: ^x01Udalo ci sie zamaskowac! Jestes slabo widoczny!");
	ma_nie[id]=true;
	return FMRES_IGNORED;
}
public SUsunNie(id)
{
	if(ma_nie[id])
	{
		if(get_user_weapon(id) != CSW_AWP || !(pev(id, pev_button) & IN_DUCK)  || pev(id, pev_speed) > 0.0)
		{
			set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 255);
			ma_nie[id]=false;
			ColorChat(id, GREEN, "Snajper: ^x01Wyszedles z ukrycia! Jestes widoczny!");
		}
	}
}
public OnTakeDamage(this, idinf, idattacker, Float:damage, damagebits)
{
	if(this == idattacker)
		return 0;
	if(get_user_team(this) == get_user_team(idattacker))
		return 0;
	if(!is_user_connected(idattacker))
		return 0;
	if(!is_user_connected(this))
		return 0;
	if(get_user_weapon(idattacker) != CSW_AWP)
		return 0;
		
	set_pev(this, pev_punchangle, {3.0,3.0,3.0});
	new Float:fVelo[3];
	pev(this, pev_velocity, fVelo);
	for(new i; i<3; i++)
		fVelo[i]*=0.25;
	set_pev(this, pev_velocity, fVelo);
	
	if(random_num(1,10))
	{
		SetHamParamFloat(4, damage+=10.0);
		set_pev(this, pev_health, pev(this, pev_health) + 10.0);
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}
public OnAddToPlayerAwp( const item, const player )
{
    if( pev_valid( item ) && is_user_alive( player ) && ma_klase[player]) // just for safety.
    {
        message_begin( MSG_ONE, MsgIndexWeaponList, .player = player );
        {
            write_string( WEAPON_1_NEWCLASSNAME );    // WeaponName
            write_byte( WEAPON_1_PRIMARY_AMMO_ID );  // PrimaryAmmoID
            write_byte( WEAPON_1_PRIMARY_MAX_AMMO );                   // PrimaryAmmoMaxAmount
            write_byte( -1 );                   // SecondaryAmmoID
            write_byte( -1 );                   // SecondaryAmmoMaxAmount
            write_byte( WEAPON_1_SLOT-1 );                    // SlotID (0...N)    <== Changed here (was 2)
            write_byte( WEAPON_1_SLOT );                    // NumberInSlot (1...N)
            write_byte( WEAPON_1_ID );            // WeaponID
            write_byte( 0 );                    // Flags
        }
        message_end();
    }
}

public OnItemSlotAwp( const item )
{
	SetHamReturnInteger( WEAPON_1_SLOT );
	return HAM_SUPERCEDE;
}
public client_disconnect(id)
{
	old_weapon[id]=false;
	ma_nie[id]=false;
}
public cod_class_enabled(id)
{
	ma_klase[id]=true;
	client_cmd(id, "bind ^"mouse3^" ^"doubleshot^"");
}
public cod_class_disabled(id)
{
	ma_klase[id]=false;
	old_weapon[id]=false;
}
public ClientCommand_SelectAwp( const client )
{
    engclient_cmd( client, WEAPON_1_CLASSNAME );
}
public CurrentWeapon(id)
{
	if(ma_klase[id] && is_user_alive(id))
	{
		if(read_data(2) == WEAPON_1_ID)
		{
			set_pev(id, pev_viewmodel2, WEAPON_1_V_MODEL);
			set_pev(id, pev_weaponmodel2, WEAPON_1_P_MODEL);
			if(old_weapon[id]!=WEAPON_1_ID)
			{
				UTIL_PlayWeaponAnimation(id, WEAPON_1_DRAW_ID);
				cs_set_user_zoom(id, 0, 1);
				//client_cmd(id, "bind ^"mouse2^" ^"+attack2^"");
				//emit_sound(id, CHAN_AUTO,"weapons/de_deploy.wav",VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		if(read_data(2) == WEAPON_2_ID)
		{
			set_pev(id, pev_viewmodel2, WEAPON_2_V_MODEL);
			set_pev(id, pev_weaponmodel2, WEAPON_2_P_MODEL);
			if(old_weapon[id]!=WEAPON_2_ID)
			{
				UTIL_PlayWeaponAnimation(id, WEAPON_2_DRAW_ID);
				//client_cmd(id, "bind ^"mouse2^" ^"deagle_zoom^"");
				emit_sound(id, CHAN_AUTO,"weapons/de_deploy.wav",VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		old_weapon[id]=read_data(2);
	}
}
public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
	
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, WEAPON_1_OLD_W_MODEL))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(-1, WEAPON_1_CLASSNAME, entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED;
	
		if(ma_klase[iOwner])
		{
			entity_set_model(entity, WEAPON_1_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	if(equal(model, WEAPON_2_OLD_W_MODEL))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(-1, WEAPON_2_CLASSNAME, entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED;
	
		if(ma_klase[iOwner])
		{
			entity_set_model(entity, WEAPON_2_W_MODEL)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED;
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}
