#include <amxmodx>
#include <hamsandwich>
#include <codmod>
#include fakemeta

#define XO_PLAYER      5
#define m_iFOV      363

new bool:ma_perk[33];
new msgScreenFade;

public plugin_init()
{
      new  nazwa[] = "Nacpane naboje"
      new  opis[] = "1/5 na nacpanie przeciwnika po trafieniu"

   register_plugin(nazwa, "1.0", "RiviT")
   
   cod_register_perk(nazwa, opis);
   
   RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 1)
   
      msgScreenFade = get_user_msgid("ScreenFade")

}

public cod_perk_enabled(id)
   ma_perk[id] = true;

public cod_perk_disabled(id)
   ma_perk[id] = false;

public TakeDamage(this, inflictor, attacker)
{
   if(!is_user_connected(attacker) || get_user_team(this) == get_user_team(attacker)) return HAM_IGNORED
   
   if(ma_perk[attacker] && !random(5))
   {
      set_pdata_int(this, m_iFOV, 180, XO_PLAYER)
      set_pev(this,pev_fov, 180.0)
      Display_Fade(this, 0, 255, 0);
      
      remove_task(this);
      set_task(10.0, "odwyk", this)
   }

   return HAM_IGNORED   
}

public odwyk(id)
{
      set_pdata_int(id, m_iFOV, 90, XO_PLAYER)
      set_pev(id, pev_fov, 90.0)
}

Display_Fade(id, r, g, b)
{
    message_begin(MSG_ONE_UNRELIABLE, msgScreenFade, {0, 0, 0}, id);
    write_short((1<<12) * 8);  // Duration of fadeout
    write_short((1<<12) * 8);  // Hold time of color
    write_short(0);    // Fade type
    write_byte (r);         // Red
    write_byte (g);       // Green
    write_byte (b);        // Blue
    write_byte (90);       // Alpha
    message_end();
}