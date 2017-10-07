#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <codmod>
#include <engine>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new sprite;
new const gszSound[] = "ambience/thunder_clap.wav";

new const nazwa[] = "MAGNETyczny Elektryk";
new const opis[] = "Jego naboje przyciagaja prad do wroga, zadajac mu +10DMG";
new const bronie = 1<<CSW_M4A1;
new const zdrowie = 10;
new const kondycja = 10;
new const inteligencja = 10;
new const wytrzymalosc = 10;

new ma_klase[33]

public plugin_init() {
	register_plugin(nazwa, "1.0", "MAGNET");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
}

public plugin_precache()
{
	sprite = precache_model("sprites/lgtning.spr");
	precache_sound(gszSound);
}

public cod_class_enabled(id, wartosc)
{
	ma_klase[id] = 1;
}

public cod_class_disabled(id)
{
	ma_klase[id] = 0;
}

stock Create_TE_BEAMENTS(startEntity, endEntity, iSprite, startFrame, frameRate, life, width, noise, red, green, blue, alpha, speed) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMENTS )
	write_short( startEntity )        // start entity
	write_short( endEntity )        // end entity
	write_short( iSprite )            // model
	write_byte( startFrame )        // starting frame
	write_byte( frameRate )            // frame rate
	write_byte( life )                // life
	write_byte( width )                // line width
	write_byte( noise )                // noise amplitude
	write_byte( red )                // red
	write_byte( green )                // green
	write_byte( blue )                // blue
	write_byte( alpha )                // brightness
	write_byte( speed )                // scroll speed
	message_end()
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	new ent = create_entity("info_target");
	if (!is_user_connected(idattacker))
	return HAM_IGNORED; 
	
	if (!ma_klase[idattacker] && get_user_team(idattacker) == get_user_team(this))
	return HAM_IGNORED;
	
	if (damagebits & DMG_BULLET)
	{
		
		
		entity_set_string(ent, EV_SZ_classname, "blyskawica");
		cod_inflict_damage(idattacker, this, 10.0, 1.0, ent, DMG_SHOCK);
		
		remove_entity(ent);
		
		//Piorun
		Create_TE_BEAMENTS(idattacker, this, sprite, 0, 10, floatround(1.0*10), 150, 5, 200, 200, 200, 200, 10);
		
		//Dzwiek
		emit_sound(idattacker, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		emit_sound(this, CHAN_WEAPON, gszSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);		

		
	}
	
	return HAM_IGNORED;
}