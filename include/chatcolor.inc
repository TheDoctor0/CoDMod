#if defined _chatcolor_included
  #endinput
#endif
#define _chatcolor_included

#pragma reqlib chatcolor

enum _:Colors {
	DontChange,
	Red,
	Blue,
	Grey
}

native client_print_color(id, iColor=DontChange, const szMsg[], any:...);
native register_dictionary_colored(const filename[]);