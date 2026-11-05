# FAQ

### Jinsi ya kubadilisha kati ya miundo ya kibodi?

Hariri faili yako ya `~/.config/hypr/input.lua` na uongeze hii kubadilisha kati ya miundo kwa `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Upau utaonyesha kiotomatiki umbo lako la sasa la kibodi mara utakapokuwa na miundo mingi imesanidiwa (na unaweza kuibofya kubadilisha pia).

### Jinsi ya kubadilisha umbizo la saa kuwa saa 12?

Bofya kulia saa katika upau kuzunguka kupitia umbizo la kawaida, ikiwa ni pamoja na zile za saa 12. Unaweza pia kuweka umbizo moja kwa moja:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Hii itaonyesha Sunday 10:55 AM.

### Jinsi ya kubadilisha eneo langu la saa?

Endesha _Sasisha > Eneo la saa_ katika menyu ya Omarchy na uchague kutoka orodha. Kama eneo la saa ni sahihi lakini saa yenyewe imepotea, _Sasisha > Muda_ huwasha upya usawazishaji wa muda kwa ajili yako.

### Jinsi ya kubadilisha DNS yangu, kushiriki Wi-Fi yangu, au kuangalia kasi ya muunganisho wangu?

Hayo yote huishi katika [mtandao](35-networking.md).

### Jinsi ya kuangalia kasi ya diski yangu?

_Anzisha > Jaribio la kasi > Jaribio la kasi ya diski_ hupima kasi ya moja kwa moja ya kusoma na kuandika kwenye kiendeshaji chako, au `omarchy disk speedtest` kutoka terminali.

### Kwa nini siwezi kuingia kwenye akaunti yangu ya Google katika Chromium?

Jengo la Chromium la chanzo huria la kawaida haliji na vitambulisho vya OAuth ambavyo Google inahitaji kwa kuingia kwenye akaunti. Endesha _Sakinisha > Huduma > Akaunti ya Chromium_ katika menyu ya Omarchy kuviongeza, washa upya kivinjari, na uingizaji utapita.

### Jinsi ya kuongeza kichapishaji?

Uchapishaji umesanidiwa na unaendeshwa mara moja, na unaongeza kila kichapishaji mwenyewe kutoka _Print Settings_ katika kizinduzi cha programu (`Super + Space`).

Chagua _Add_, na uipe muda kutazama: kichapishaji kilichochomekwa kupitia USB, na vichapishaji vingi vya mtandao, hupatikana kwa ajili yako. Kama chako hakipo katika orodha, chagua _Network Printer > Internet Printing Protocol (ipp)_ na uweke anwani yake — skrini ya kichapishaji yenyewe au ukurasa wake wa wavuti itakuambia hilo ni nini, kawaida kitu kama `192.168.1.50` na foleni ya `ipp/print`. _Forward_ kisha hutoa kiendeshaji, ambapo kichapishaji cha kisasa hufanya kazi vizuri zaidi kwenye profaili isiyo na kiendeshaji ya _IPP Everywhere_ na cha zamani kinataka kiendeshaji cha modeli yenyewe.

Bofya kulia kichapishaji na uchague _Set as Default_ kuchagua ni kipi programu zako huanza kufikia, na _Properties_ kuweka ukubwa wa karatasi, duplex na ubora.

Ugunduzi kiotomatiki, ambapo vichapishaji kwenye mtandao huonekana bila kuongezwa, umezimwa kwa muda wakati unarekebishwa upya, ndiyo maana hatua ya kwanza hapo juu ni yako badala ya kiotomatiki. Kuchapisha kwenye faili ya PDF hufanya kazi bila kichapishaji chochote kabisa.

### Jinsi ya kubadilisha mahali ambapo picha za skrini au rekodi za skrini huhifadhiwa?

Picha za skrini zilizohifadhiwa huenda `~/Pictures/Screenshots` kwa chaguomsingi. Kutumia saraka nyingine, ongeza hii kwenye faili chini ya `~/.config/uwsm/env.d/` (kama `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Unaweza kufanya hivyo hivyo kwa rekodi za skrini kwa kutumia `OMARCHY_SCREENRECORD_DIR`.

Omasnap huunda saraka yake ya picha za skrini kiotomatiki. Unda saraka ya kurekodi skrini mwenyewe, kisha washa upya Omarchy ili mabadiliko yoyote ya mazingira yaanze kutumika.

### Jinsi ya kufanya spika + kamera ya wavuti ifanye kazi kwenye Apple Studio Display yangu?

Ungedhani kuwa yote yanapaswa kufanya kazi kwa kuchomeka USB C tu, lakini kwa bahati mbaya si hivyo. Suluhisho nililolipata kuifanya ifanye kazi kwa uhakika ni kutumia [kebo ya WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kisha spika na kamera ya wavuti hufanya kazi kama uchawi.

Kumbuka kuwa una udhibiti wa mwanga uliojengwa ndani katika Omarchy kwa Skrini za Apple (Studio na XDR zote) kwa kutumia vitufe vya kawaida vya mwanga vya kibodi.

### Jinsi ya kuondoa programu zote za ziada?

Kama hutaki programu kama Obsidian au LibreOffice au vitu vingine vyovyote vilivyosakinishwa awali, unaweza kuviondoa kwa urahisi sana.

Endesha _Ondoa > Package_ kuona kila kifurushi kilichosakinishwa. Kisha unaweza kuchagua kifurushi chochote unachotaka kuondoa kwa tab, na kuanza kuondoa kila kitu ulichochagua kwa return.

Na unaweza kutumia _Ondoa > Web App_ kutoka menyu ya Omarchy kuondoa programu zozote za wavuti zilizosakinishwa awali usizotaka.

Au endesha _Ondoa > Preinstalls_ kufagia nyongeza zote zilizosakinishwa awali — programu za wavuti, TUIs, na programu za hiari — kwa mkupuo mmoja. Vitufe vya mkato vilivyoziwasha huenda nazo, kwa hivyo unabaki na slate safi ya ufungaji wa kujaza na yako mwenyewe katika `~/.config/hypr/bindings.lua`.

---

Kwa makosa na sehemu zilizovunjika, tazama [sehemu ya Kutatua matatizo](45-troubleshooting.md).
