#include <amxmodx>
#include <engine>
#include <fakemeta> 
#include <fun>
#include <cstrike>
#include <amxmisc>
#include <codmod>

#define CS_PLAYER_HEIGHT 72.0

#define AUTHOR "J River"

#define x 0
#define y 1
#define z 2

new const nazwa[]   = "Knife Ruggber (Premium)";
new const opis[]    = "Moze robic migniecia nozem na odleglsoc 800(+inteligencja), 1\5 szans na oslepeinie wroga";
new const bronie    = (1<<CSW_M4A1)|(1<<CSW_KNIFE);
new const zdrowie   = 0;
new const kondycja  = 50;
new const inteligencja = 0;
new const wytrzymalosc = 100;

new gmsgFade
new bool:ma_klase[33];
new player_b_blink[33] = 0	//Ability to get a railgun
new player_b_blind[33] = 0	//Chance 1/Value to blind the enemy

public plugin_init()
{
	register_plugin(nazwa, "1.0", AUTHOR);
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_event("ResetHUD", "ResetHUD", "abe")
	
	register_event("Damage", "Damage", "b", "2!0")
	
	gmsgFade = get_user_msgid("ScreenFade")
}
public cod_class_enabled(id)
{
	if(!(get_user_flags(id) & ADMIN_LEVEL_H))
	{
		client_print(id, print_chat, "[Server] (Only Premium !!) Nie masz uprawnien, aby uzywac klasy Knife Ruggber")
		return COD_STOP;
	}
	client_print(id, print_chat, "Klasa Knife Ruggber stworzona przez J River")
	player_b_blink[id] = floatround(halflife_time())
	player_b_blind[id] = 5
	ma_klase[id] = true;
	return COD_CONTINUE;
}
public cod_class_disabled(id)
{
	player_b_blink[id] = 0
	ma_klase[id] = false;
}
public client_PreThink ( id ) 
{
	if (player_b_blink[id] > 0) Prethink_Blink(id)
	
	return PLUGIN_CONTINUE	
	
}
public Prethink_Blink(id)
{
	if( get_user_button(id) & IN_ATTACK2 && !(get_user_oldbutton(id) & IN_ATTACK2) && is_user_alive(id)) 
	{			
		new clip, ammo
		new weapon = get_user_weapon(id,clip,ammo)
		
		if (weapon == CSW_KNIFE)
		{
			if (halflife_time()-player_b_blink[id] <= 0.5) return PLUGIN_HANDLED		
			player_b_blink[id] = floatround(halflife_time())	
			UTIL_Teleport(id,800+15*cod_get_user_intelligence( id, 1, 1, 1 ))		
		}
	}
	return PLUGIN_CONTINUE
}	
public ResetHUD(id)
{
	if (is_user_connected(id))
	{	
		if(ma_klase[id])
			player_b_blink[id] = 1
			
		if (player_b_blink[id] > 0)
			player_b_blink[id] = 1
		client_cmd(id,"hud_centerid 0")  
	}
}
public UTIL_Teleport(id,distance)
{	
	Set_Origin_Forward(id,distance)
	
	new origin[3]
	get_user_origin(id,origin)
	
	//Particle burst ie. teleport effect	
	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY) //message begin
	write_byte(TE_PARTICLEBURST )
	write_coord(origin[0]) // origin
	write_coord(origin[1]) // origin
	write_coord(origin[2]) // origin
	write_short(20) // radius
	write_byte(1) // particle color
	write_byte(4) // duration * 10 will be randomized a bit
	message_end()
	
	
}

stock Set_Origin_Forward(id, distance) 
{
	new Float:origin[3]
	new Float:angles[3]
	new Float:teleport[3]
	new Float:heightplus = 10.0
	new Float:playerheight = 64.0
	new bool:recalculate = false
	new bool:foundheight = false
	pev(id,pev_origin,origin)
	pev(id,pev_angles,angles)
	
	teleport[0] = origin[0] + distance * floatcos(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
	teleport[1] = origin[1] + distance * floatsin(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
	teleport[2] = origin[2]+heightplus
	
	while (!Can_Trace_Line_Origin(origin,teleport) || Is_Point_Stuck(teleport,48.0))
	{	
		if (distance < 10)
			break;
		
		//First see if we can raise the height to MAX playerheight, if we can, it's a hill and we can teleport there	
		for (new i=1; i < playerheight+20.0; i++)
		{
			teleport[2]+=i
			if (Can_Trace_Line_Origin(origin,teleport) && !Is_Point_Stuck(teleport,48.0))
			{
				foundheight = true
				heightplus += i
				break
			}
			
			teleport[2]-=i
		}
		
		if (foundheight)
			break
		
		recalculate = true
		distance-=10
		teleport[0] = origin[0] + (distance+32) * floatcos(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
		teleport[1] = origin[1] + (distance+32) * floatsin(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
		teleport[2] = origin[2]+heightplus
	}
	
	if (!recalculate)
	{
		set_pev(id,pev_origin,teleport)
		return PLUGIN_CONTINUE
	}
	
	teleport[0] = origin[0] + distance * floatcos(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
	teleport[1] = origin[1] + distance * floatsin(angles[1],degrees) * floatabs(floatcos(angles[0],degrees));
	teleport[2] = origin[2]+heightplus
	set_pev(id,pev_origin,teleport)
	
	return PLUGIN_CONTINUE
}

stock bool:Can_Trace_Line_Origin(Float:origin1[3], Float:origin2[3])
{	
	new Float:Origin_Return[3]	
	new Float:temp1[3]
	new Float:temp2[3]
	
	temp1[x] = origin1[x]
	temp1[y] = origin1[y]
	temp1[z] = origin1[z]-30
	
	temp2[x] = origin2[x]
	temp2[y] = origin2[y]
	temp2[z] = origin2[z]-30
	
	trace_line(-1, temp1, temp2, Origin_Return) 
	
	if (get_distance_f(Origin_Return,temp2) < 1.0)
		return true
	
	return false
}

stock bool:Is_Point_Stuck(Float:Origin[3], Float:hullsize)
{
	new Float:temp[3]
	new Float:iterator = hullsize/3
	
	temp[2] = Origin[2]
	
	for (new Float:i=Origin[0]-hullsize; i < Origin[0]+hullsize; i+=iterator)
	{
		for (new Float:j=Origin[1]-hullsize; j < Origin[1]+hullsize; j+=iterator)
		{
			//72 mod 6 = 0
			for (new Float:k=Origin[2]-CS_PLAYER_HEIGHT; k < Origin[2]+CS_PLAYER_HEIGHT; k+=6) 
			{
				temp[0] = i
				temp[1] = j
				temp[2] = k
				
				if (point_contents(temp) != -1)
					return true
			}
		}
	}
	
	return false
}

stock Effect_Bleed(id,color)
{
	new origin[3]
	get_user_origin(id,origin)
	
	new dx, dy, dz
	
	for(new i = 0; i < 3; i++) 
	{
		dx = random_num(-15,15)
		dy = random_num(-15,15)
		dz = random_num(-20,25)
		
		for(new j = 0; j < 2; j++) 
		{
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(dx*j))
			write_coord(origin[1]+(dy*j))
			write_coord(origin[2]+(dz*j))
			write_short(sprite_blood_spray)
			write_short(sprite_blood_drop)
			write_byte(color) // color index
			write_byte(8) // size
			message_end()
		}
	}
}
public Damage(id)
{
	if (is_user_connected(id))
	{
		new damage = read_data(2)
		new weapon
		new bodypart
		new attacker_id = get_user_attacker(id,weapon,bodypart) 
		if (is_user_connected(attacker_id) && attacker_id != id)
			add_bonus_blind(id,attacker_id,weapon,damage)		
	}
}

/* ==================================================================================================== */

public add_bonus_blind(id,attacker_id,weapon,damage)
{
	if (player_b_blind[attacker_id] > 0 && weapon != 4)
	{
		new roll = random_num(1,player_b_blind[attacker_id])
		if (roll == 1)
		{
			message_begin(MSG_ONE,gmsgFade,{0,0,0},id)
			write_short( 1<<14 ) 
			write_short( 1<<14 ) 
			write_short( 1<<16 ) 
			write_byte( 255 ) 
			write_byte( 155 ) 
			write_byte( 50 ) 
			write_byte( 230 ) 
			message_end()
		}
		
	}
}
