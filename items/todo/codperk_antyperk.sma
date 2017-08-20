#include <amxmodx>
#include <codmod>


public plugin_init() 
{
      new const perk_name[] = "Antyperk";
      new const perk_desc[] = "Mozesz komus zniszczyc perk [C]. Perk niszczy sie po uzyciu.";

	register_plugin(perk_name, "1.0", "RiviT");
	
	cod_register_perk(perk_name, perk_desc);
}

public cod_perk_used(id)
{
      new menu = menu_create("Wybierz gracza:", "Gracz_handler")
      new Przeciwnyteam, nick[33], strid[3]

      Przeciwnyteam = get_user_team(id) == 1 ? 2 : 1
      new bool:jestJeden = false

      for(new i = 1; i <= get_maxplayers(); i++)
      {
            if(!is_user_connected(i) || !cod_get_user_perk(i))     continue

            if(get_user_team(i) != Przeciwnyteam) continue;

            get_user_name(i, nick, 33)
            num_to_str(i, strid, 2)
            menu_additem(menu, nick, strid)
            jestJeden = true
      }
      
      if(jestJeden)
            menu_display(id, menu)
      else
            client_print(id, print_center, "Przykro, ale nikt z przeciwnikow nie ma perku!")
      
      return PLUGIN_CONTINUE
}

public Gracz_handler(id, menu, item)
{
    	if(item == MENU_EXIT)
    	{
            menu_destroy(menu);
            return PLUGIN_CONTINUE;
   	}
	
	new id2, strid[3], name[33];
	menu_item_getinfo(menu, item, id2, strid, 2, name, 32, id2);
   	id2 = str_to_num(strid);
	
	new wyrzucajacy_name_perk[33]
	get_user_name(id, wyrzucajacy_name_perk, 32);
	
	client_print(id2, print_center, "%s zniszczyl ci perk!", wyrzucajacy_name_perk);

	cod_get_perk_name(cod_get_user_perk(id2), wyrzucajacy_name_perk, 32);

	client_print(id, print_center, "Zniszczyles perk: %s graczowi %s", wyrzucajacy_name_perk, name);
	
	cod_set_user_perk(id2, 0);
	cod_set_user_perk(id, 0);

      menu_destroy(menu);
      
	return PLUGIN_CONTINUE;
}