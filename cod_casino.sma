#include <amxmodx>
#include <codmod>
#include <engine>
#include <cstrike>
#include <fun>

native cod_set_user_coins(id, wartosc);
native cod_get_user_coins(id);

public plugin_init() 
{
	register_plugin("Kasyno", "1.0", "Kamilek");
	
	register_clcmd("say /kasyno", "Kasyno");
	register_clcmd("say /casino", "Kasyno");
}	

public Kasyno(id)
{
	new tytul[25];
	format(tytul, 24, "\rKASYNO");
	new menu = menu_create(tytul, "Kasyno_Handler");
	menu_additem(menu, "Obstaw 10 Monet \rWygraj 30 \rSzansa 20%");//2
	menu_additem(menu, "Obstaw 20 Monet \rWygraj 60 \rSzansa 20%");//3
	menu_additem(menu, "Obstaw 50 Monet \rWygraj 150 \rSzansa 20%");//4
	menu_additem(menu, "Obstaw 100 Monet \rWygraj 300 \rSzansa 20%");//5
	menu_additem(menu, "Obstaw 200 Monet \rWygraj 600 \rSzansa 20%");//6
	menu_display(id, menu);
	
}

public Kasyno_Handler(id, menu, item)
{
	
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	new kasa = cod_get_user_coins(id)
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	switch(item)
	{
		case 0:
		{

			if(kasa >= 10)
			{
				cod_set_user_coins(id, kasa-10);
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				new totek = random_num(0, 4);
				
				switch(totek)
				{
					case 0:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 1:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 2:
					{
						cod_set_user_coins(id,cod_get_user_coins(id)+30);
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 30 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 30 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 30 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 30 Monet---------============");
						client_print(0, print_chat, "[KASYNO] Ktos obstawiajac w kasynie wygral 30 Monet!");
					}
					case 3:
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					case 4:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
				}
			}		
			if(kasa < 10)
				client_print(id, print_chat, "============---------[KASYNO] Masz za malo Monet!---------============");
		}
		case 1:
		{

			if(kasa >= 20)
			{
				cod_set_user_coins(id, kasa-20);
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				new totek = random_num(0, 4);
				
				switch(totek)
				{
					case 0:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 1:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 2:
					{
						cod_set_user_coins(id,cod_get_user_coins(id)+60);
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 60 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 60 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 60 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 60 Monet---------============");
						client_print(0, print_chat, "[KASYNO] Ktos obstawiajac w kasynie wygral 60 Monet!");
					}
					case 3:
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					case 4:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
				}
			}		
			if(kasa < 20)
				client_print(id, print_chat, "============---------[KASYNO] Masz za malo Monet!---------============");
		}
		case 2:
		{

			if(kasa >= 50)
			{
				cod_set_user_coins(id, kasa-50);
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				new totek = random_num(0, 4);
				
				switch(totek)
				{
					case 0:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 1:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 2:
					{
						cod_set_user_coins(id,cod_get_user_coins(id)+150);
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 150 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 150 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 150 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 150 Monet---------============");
						client_print(0, print_chat, "[KASYNO] Ktos obstawiajac w kasynie wygral 150 Monet!");
					}
					case 3:
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					case 4:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
				}
			}		
			if(kasa < 50)
				client_print(id, print_chat, "============---------[KASYNO] Masz za malo Monet!---------============");
		}
		case 3:
		{

			if(kasa >= 100)
			{
				cod_set_user_coins(id, kasa-100);
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				new totek = random_num(0, 4);
				
				switch(totek)
				{
					case 0:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 1:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 2:
					{
						cod_set_user_coins(id,cod_get_user_coins(id)+300);
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 300 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 300 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 300 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 300 Monet---------============");
						client_print(0, print_chat, "[KASYNO] Ktos obstawiajac w kasynie wygral 300 Monet!");
					}
					case 3:
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					case 4:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
				}
			}		
			if(kasa < 100)
				client_print(id, print_chat, "============---------[KASYNO] Masz za malo Monet!---------============");
		}
		case 4:
		{

			if(kasa >= 200)
			{
				cod_set_user_coins(id, kasa-200);
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				client_print(id, print_chat, "============---------[Trwa losowanie!]---------============");
				new totek = random_num(0, 4);
				
				switch(totek)
				{
					case 0:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 1:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
					case 2:
					{
						cod_set_user_coins(id,cod_get_user_coins(id)+600);
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 600 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 600 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 600 Monet---------============");
						client_print(id, print_chat, "============---------[KASYNO] Wygrales 600 Monet---------============");
						client_print(0, print_chat, "[KASYNO] Ktos obstawiajac w kasynie wygral 600 Monet!");
					}
					case 3:
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					case 4:
					{
						client_print(id, print_chat, "============---------[KASYNO]Niestety nic nie wygrales!---------============");
					}
				}
			}		
			if(kasa < 200)
				client_print(id, print_chat, "============---------[KASYNO] Masz za malo Monet!---------============");
		}
  
  	}

  return PLUGIN_CONTINUE;
}