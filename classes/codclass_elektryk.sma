#include <amxmodx>
#include <engine>
#include <cod>

#define PLUGIN "CoD Class Elektryk"
#define VERSION "1.0"
#define AUTHOR "O'Zone"

new const name[] = "Elektryk";
new const description[] = "Posiada 3 blyskawice, ktore moze uzyc po wycelowaniu w przeciwnika.";
new const fraction[] = "";
new const weapons = (1<<CSW_M4A1)|(1<<CSW_USP);
new const health = 30;
new const intelligence = 0;
new const strength = 0;
new const stamina = 10;
new const condition = 0;

new const sound[] = "ambience/thunder_clap.wav";

new thunders[MAX_PLAYERS + 1], lastThunder[MAX_PLAYERS + 1];

new sprite;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	cod_register_class(name, description, fraction, weapons, health, intelligence, strength, stamina, condition);
}

public plugin_precache()
{
	sprite = precache_model("sprites/lgtning.spr");

	precache_sound(sound);
}

public cod_class_enabled(id, promotion)
	thunders[id] = 3;

public cod_class_disabled(id, promotion)
	thunders[id] = 0;

public cod_class_spawned(id)
	thunders[id] = 3;
	
public cod_class_skill_used(id) 
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED;

	if(!thunders[id])
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Wykorzystales juz wszystkie blyskawice!");
		
		return PLUGIN_CONTINUE;
	}

	new victim, body;

	get_user_aiming(id, victim, body);
	
	if(!is_user_alive(victim) || get_user_team(victim) == get_user_team(id)) return PLUGIN_HANDLED;
		
	if(lastThunder[id] + 3.0 > get_gametime())
	{
		set_dhudmessage(218, 40, 67, 0.50, 0.35, 0, 0.0, 1.0, 0.0, 0.0);
		show_dhudmessage(id, "Blyskawic mozesz uzywac co 3 sekundy!");
		
		return PLUGIN_CONTINUE;
	}

	lastThunder[id] = floatround(get_gametime());
	thunders[id]--;

	make_thunder(id, victim, 65.0, 0.5);

	return PLUGIN_HANDLED;
}

public make_thunder(id, victim, Float:damage, Float:time)
{
	new ent = create_entity("info_target");

	entity_set_string(ent, EV_SZ_classname, "thunder");

	cod_inflict_damage(id, victim, damage, 0.5, DMG_CODSKILL);
	
	remove_entity(ent);
	
	Create_TE_BEAMENTS(id, victim, sprite, 0, 10, floatround(time*10), 150, 5, 200, 200, 200, 200, 10);
	
	emit_sound(id, CHAN_WEAPON, sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	emit_sound(victim, CHAN_WEAPON, sound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
}

stock Create_TE_BEAMENTS(startEntity, endEntity, sprite, startFrame, frameRate, life, width, noise, red, green, blue, alpha, speed) 
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);

	write_byte(TE_BEAMENTS);

	write_short(startEntity);
	write_short(endEntity);
	write_short(sprite);
	write_byte(startFrame);
	write_byte(frameRate);
	write_byte(life);
	write_byte(width);
	write_byte(noise);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	write_byte(speed);
	message_end();
}