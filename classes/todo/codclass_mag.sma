#include <amxmodx>
#include <fakemeta_util>
#include <codmod>

#define MAX 32

#define nazwa "Mag"
#define opis "Ma latarke dzieki, ktorej moze naswietlic niewidzialnych"

new const bronie = 1<<CSW_UMP45;
new const zdrowie = 0;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 0;

new ma_klase[MAX+1], flashlight[MAX+1],flashbattery[MAX+1]

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "cypis");
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_PlayerPreThink,"PreThink");

	register_event("Flashlight","Flashlight","b");
	
	register_cvar("cod_mag_render", "30");
}		

public cod_class_enabled(id)
{
	ma_klase[id] = true;
	flashbattery[id] = get_cvar_num("cod_mag_render");
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	flashbattery[id] = 0;
}

public PreThink(id)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	if(flashlight[id] && flashbattery[id] && ma_klase[id]) 
	{
		static flashlight_r, flashlight_g, flashlight_b;
		flashlight_r+= 1+random_num(0,2)
		
		if (flashlight_r>250) 
			flashlight_r-=245
		
		flashlight_g+= 1+random_num(-1,1)
		
		if (flashlight_g>250) 
			flashlight_g-=245
		
		flashlight_b+= -1+random_num(-1,1)
		
		if (flashlight_b<5) 
			flashlight_b+=240	
		
		new origin[3];
		get_user_origin(id, origin, 3);
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(27);
		write_coord(origin[0]);
		write_coord(origin[1]);
		write_coord(origin[2]);
		write_byte(8);
		write_byte(flashlight_r);
		write_byte(flashlight_g);
		write_byte(flashlight_b);
		write_byte(1);
		write_byte(90);
		message_end();
		
		new traget, bodypart;
		get_user_aiming(id, traget, bodypart) 
		if(get_user_team(id) != get_user_team(traget) && traget)
		{
			new data[2];
			data[0] = traget;
			data[1] = pev(traget, pev_renderamt);
			
			if(data[1] < 255.0)
			{
				fm_set_rendering(traget, kRenderFxGlowShell, flashlight_r, flashlight_g, flashlight_b, kRenderNormal, 4)	

				remove_task(8752+traget);
				set_task(7.5, "wylacz_rander", 8752+traget, data, 2)
			}
		}
	}
	return FMRES_HANDLED;
} 

public wylacz_rander(data[2])
{
	if(is_user_connected(data[0]) && is_user_alive(data[0]))
		fm_set_rendering(data[0], kRenderFxNone, 0, 0, 0, kRenderTransAlpha, data[1])	
}

public Flashlight(id)
{
	if(flashlight[id])
		flashlight[id] = 0;
	else if(flashbattery[id] > 0)
		flashlight[id] = 1;

	if(!task_exists(2071+id))
		set_task(flashlight[id]? 0.5: 1.0, "charge", 2071+id);

	message_begin(MSG_ONE,get_user_msgid("Flashlight"),{0,0,0},id);
	write_byte(flashlight[id]);
	write_byte(flashbattery[id]);
	message_end();

	set_pev(id, pev_effects, pev(id, pev_effects) & ~EF_DIMLIGHT);
}

public charge(id) 
{
	id -= 2071
	if(flashlight[id])
		flashbattery[id]--;
	else 
		flashbattery[id]++;

	message_begin(MSG_ONE,get_user_msgid("FlashBat"),{0,0,0},id);
	write_byte(flashbattery[id]);
	message_end();

	if(flashbattery[id] <= 0)
	{
		flashbattery[id] = 0;
		flashlight[id] = 0;

		message_begin(MSG_ONE,get_user_msgid("Flashlight"),{0,0,0},id);
		write_byte(flashlight[id]);
		write_byte(flashbattery[id]);
		message_end();
	}
	else if(flashbattery[id] >= get_cvar_num("cod_mag_render")) 
	{
		flashbattery[id] = get_cvar_num("cod_mag_render");
		return;
	}
	set_task(flashlight[id]? 0.5: 1.0,"charge", 2071+id)
}