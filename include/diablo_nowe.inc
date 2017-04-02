#if defined _diablomod_included
  #endinput
#endif
#define _diablomod_included

#define DIABLO_STOP 4
#define DIABLO_CONTINUE 3
#define DIABLO_RENDER_DESTROYED -1
#define FLAG_ALL -1

enum renderStruct{
	renderR,
	renderG,
	renderB,
	renderFx,
	renderNormal,
	renderAmount
}

enum DiabloDamageBits{
	diabloDamageKnife 	=	(1<<12) | (1<<1), 
	diabloDamageGrenade	 =	(1<<24),
	diabloDamageShot	=	(1<<1)
}

enum DiabloColor
{
	DIABLO_NORMAL = 1, // clients scr_concolor cvar color
	DIABLO_GREEN, // Green Color
	DIABLO_TEAM_COLOR, // Red, grey, blue
	DIABLO_GREY, // grey
	DIABLO_RED, // Red
	DIABLO_BLUE, // Blue
}

//rejestruje klase
native diablo_register_class(const szNazwa[],const iHealth,const szOpis[] = "" , iFlags = FLAG_ALL , const szFraction[] = ""); //grawitacja , predkosc , przezroczystosc

//zwraca klase gracza
native diablo_get_user_class(id);

//ustawia klase gracza
native diablo_set_user_class(id, classID);

//nazwe klasy pobiera
native diablo_get_class_name(classID , Return[] , len);

//zwraca item gracza
native diablo_get_user_item(id);

//nazwe itemu pobiera
native diablo_get_item_name(itemID , Return[] , len);

//zwraca level
native diablo_get_user_level(id);

//zwraca exp
native diablo_get_user_exp(id);

//zwraca exp aktualnego poziomu
native diablo_get_level_exp(id);

//zwraca points
native diablo_get_user_points(id);

//zwraca punkty agi
native diablo_get_user_agi(id);

//zwraca punkty str
native diablo_get_user_str(id);

//zwraca punkty dex
native diablo_get_user_dex(id);

//zwraca punkty int
native diablo_get_user_int(id);

//gdy klasa zostanie wybrana
forward diablo_class_enabled(id);

//gdy klasa zostanie zmieniona
forward diablo_class_disabled(id);

//przy zmianie broni
forward diablo_weapon_deploy(id,wpnID,weaponEnt);

//czy klasa gracza to klasa z tego pluginu
native diablo_is_class_from(id);

//ustawia rendering graczowi
native diablo_set_user_render(id, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16 , Float:fTime = 0.0 )

//czyszczenie wewnetrznych zmiennych klasy
forward diablo_clean_data(id);

//ustawianie wewnetrznych zmiennych klasy
forward diablo_set_data(id);

//prethink gracza
forward diablo_preThink( id );

forward diablo_preThinkClass(id);

forward diablo_preThinkItem(id);

//posthink gracza
forward diablo_postThinkClass(id);

//podczas zmiany renderu wysylany do wszystkich pluginow
forward diablo_render_change(id);

//czy ma taka klase
native diablo_is_this_class(id,szClass[]);

//czy ma taki item
native diablo_is_this_item(id,szItem[]);

//zwracasz czas call cast 0.0 powoduje zatrzymanie
forward Float:diablo_cast_time(id,Float:standardTime);

//call cast wykonany niech plugin dziala
forward diablo_call_cast(id);

//dodawanie speed graczowi
native diablo_set_speed(id,Float:fAmount);

//ustawianie speed
native diablo_add_speed(id,Float:fAmount);

//pobranie speed
native Float:diablo_get_speed(id)

//pobranie dodatkowe speed
native Float:diablo_get_speed_extra(id);

//forawrd ustawnia speed
forward diablo_speed_change(id);

native diablo_reset_speed( id );

//zadanie dmg
native diablo_damage(iVictim,iKiller,Float:fDamage,DiabloDamageBits:damageBits);

//zabij
native diablo_kill(iVictim,iKiller,DiabloDamageBits:damageBits);

//zadanie dmg w zasiegu
native diablo_create_explode(iKiller,Float:fOrigin[3],Float:fDamage,Float:fDist);

//przy spaawnie klasy
forward diablo_class_spawned(id);

//przy zabiciu klasy
forward diablo_class_killed(id);

//przy exp killu zwracaj 0 jak nic nie robisz
forward diablo_kill_xp(id,iIle);

//przy exp damage 0 jak nic nie robisz
forward diablo_exp_damage(id,iIle);

//dodaje hp
native diablo_add_hp(id,iHp);

//dodaje hp pomijajac limit hp
native diablo_add_force_hp(id,iHp);

//przy uzyciu skillu klasy
forward diablo_class_skill_used(id);

//when cast stop can return diablo_stop
forward diablo_cast_stop(id);

//can move when cast 
forward diablo_cast_move(id);

//forward write hud
forward diablo_hud_write(id,szMessage[],iLen);

//czy jest freezetime
native diablo_is_freezetime();

//uruchom write hud
native diablo_write_hud_native(id);

//damage forward
forward diablo_damage_taken_post(iKiller,iVictim,iDamage);

forward diablo_damage_taken_pre(iKiller , iVictim , &Float:fDamage );

native diablo_get_xpbonus();

native diablo_get_xpbonus2();

//daje xp
native diablo_add_xp(id,ile);

//zabiera xp
native diablo_take_xp(id,ile);

//daje xp i zapisuje pomijajac wszystkie inne czynniki
native diablo_save_xp(id,ile);

//zmiana damage klasy dostaje
forward diablo_damage_class_taken(iVictim,iAttacker,&Float:fDamage,damageBits);

//zmiana damage klasy zadaje
forward diablo_damage_class_do(iVictim,iAttacker,&Float:fDamage,damageBits);

//gracz zespawnowany
forward diablo_player_spawned(id);

//dodaje noze
native diablo_add_knife(id,iIle);

//ustawia liczbe nozy
native diablo_set_knife(id,iIle);

//gravity zmieniona
forward diablo_grav_change(id);

native diablo_set_user_grav(id,Float:fGrav);
native diablo_add_user_grav(id,Float:fGrav);
native Float:diablo_get_user_grav(id)

native diablo_reset_grav( id );

native diablo_give_user_trap(id,bool:give = true);
native diablo_give_user_bow(id,bool:give = true);

native diablo_show_hudmsg( id , Float:fTime , const szMessage[] ,  any:... );

native diablo_render_cancel( id );

native diablo_display_icon( id , enable , szNameIcon[] , red , green , blue );
native diablo_display_fade( id,duration,holdtime,fadetype,red,green,blue,alpha );

forward diablo_user_change_class( id , class )

forward diablo_death(iKiller , killerClass , iVictim , victimClass );

native diablo_add_max_hp( id , ile );

native diablo_register_item( Name[] , durability = 250 );

native diablo_items_amount();

forward diablo_item_give( id , szRet[] , iLen );
forward diablo_item_reset( id );
forward diablo_item_drop( id );
forward diablo_item_info( id , szMessage[] , iLen , bool:bList );
forward diablo_upgrade_item( id );
forward diablo_item_set_data( id );

forward diablo_damage_item_taken(iVictim,iAttacker,&Float:fDamage,damageBits);

forward diablo_damage_item_do(iVictim,iAttacker,&Float:fDamage,damageBits);

forward diablo_item_skill_used( id );

forward diablo_item_player_spawned( id );

native diablo_screen_shake( id , amplitude , duration , frequency );

native diablo_set_max_hp( id , ile );
native diablo_get_max_hp( id );

forward diablo_new_round();

//wymiana itemami
forward diablo_copy_item( iFrom , iTo );

native diablo_add_extra_str( id , iIle );
native diablo_add_extra_int( id , iIle );
native diablo_add_extra_agi( id , iIle );
native diablo_add_extra_dex( id , iIle );

native diablo_set_extra_str( id , iIle );
native diablo_set_extra_int( id , iIle );
native diablo_set_extra_agi( id , iIle );
native diablo_set_extra_dex( id , iIle );

native diablo_player_hud(id);

forward diablo_is_additional_damage();

forward diablo_clean_user_inf( id );

forward diablo_is_set_render();

forward diablo_cur_weapon( id );

forward diablo_give_item( id , item );

native diablo_print_chat( id , {DiabloColor,Color}:color , const msg[] , {Float,Sql,Result,_}:... );

native bool: diablo_is_player_class_none( id );

native diablo_blood_effect( id , color );

native diablo_bar_timer( id , iTime );

forward diablo_can_use_skill( id );

native diablo_get_item_from( idItem );
native diablo_get_item_to( idItem );