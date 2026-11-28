# Maswali Yanayoulizwa Mara kwa Mara

### Je, ninabadilishaje kati ya mipangilio ya kibodi?

Hariri faili yako ya `~/.config/hypr/input.lua` na uongeze hii ili kubadilisha kati ya mipangilio kwa `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Upau utaonyesha kiotomatiki mpangilio wako wa sasa wa kibodi mara tu unapokuwa na mipangilio mingi iliyosanidiwa (na unaweza kuubofya ili kubadilisha pia).

### Je, ninabadilishaje umbizo la saa kuwa la saa 12?

Bofya kulia saa iliyo kwenye upau ili kuzunguka katika umbizo za kawaida, ikiwa ni pamoja na zile za saa 12. Unaweza pia kuweka umbizo moja kwa moja:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Hii itaonyesha Jumapili 10:55 AM.

### Je, ninabadilishaje eneo langu la saa?

Endesha _Usanidi > Eneo > Eneo la Saa_ katika menyu ya Omarchy na uchague kutoka kwenye orodha. Ikiwa eneo la saa ni sahihi lakini saa yenyewe imepoteza usahihi, _Sasisha > Saa_ huwasha upya ulandanishi wa saa kwa ajili yako.

### Je, ninabadilishaje DNS yangu, kushiriki Wi-Fi yangu, au kukagua kasi ya muunganiko wangu?

Yote hayo yako katika [mtandao](35-networking.md).

### Je, ninapimaje kasi ya diski yangu?

_Anzisha > Jaribio la Kasi > Jaribio la Kasi ya Diski_ hupima kasi ya moja kwa moja ya kusoma na kuandika kwenye diski yako, au `omarchy disk speedtest` kutoka kwenye terminali.

### Je, ninaongezaje printa?

Uchapishaji umewekwa na unafanya kazi mara moja bila usanidi wa ziada, na unaongeza kila printa mwenyewe kutoka _Mipangilio ya Uchapishaji_ katika kizindua programu (`Super + Alt + Space`).

Chagua _Ongeza_, na uipe muda wa kutafuta: printa iliyochomekwa kupitia USB, na printa nyingi za mtandao, hutafutwa na kupatikana kwa ajili yako. Ikiwa yako haiko kwenye orodha, chagua _Printa ya Mtandao > Internet Printing Protocol (ipp)_ na uweke anwani yake — skrini ya printa yenyewe au ukurasa wake wa wavuti utakuambia anwani hiyo ni ipi, kwa kawaida ni kitu kama `192.168.1.50` yenye foleni ya `ipp/print`. Kisha _Endelea_ hutoa kiendeshi, ambapo printa ya kisasa hufanya kazi vizuri zaidi kwenye wasifu wa _IPP Everywhere_ usiohitaji kiendeshi na printa ya zamani huhitaji kiendeshi cha modeli yake yenyewe.

Bofya kulia printa na uchague _Weka kama Chaguo-msingi_ ili kuchagua ipi programu zako zitatumia kwanza, na _Sifa_ ili kuweka ukubwa wa karatasi, uchapishaji wa pande mbili na ubora.

Ugunduzi wa kiotomatiki, ambapo printa zilizo kwenye mtandao huonekana bila kuongezwa, umezimwa kwa muda wakati unafanyiwa marekebisho, ndiyo maana hatua ya kwanza hapo juu ni yako badala ya kuwa ya kiotomatiki. Kuchapisha hadi faili ya PDF hufanya kazi bila printa yoyote kabisa.

### Je, ninabadilishaje mahali ambapo picha za skrini au rekodi za skrini huhifadhiwa?

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kama chaguo-msingi. Ili kutumia saraka nyingine, ongeza hii kwenye faili iliyo chini ya `~/.config/uwsm/env.d/` (kama `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Unaweza kufanya vivyo hivyo kwa rekodi za skrini kwa kutumia `OMARCHY_SCREENRECORD_DIR`.

Omasnap huunda saraka yake ya picha za skrini kiotomatiki. Unda saraka ya rekodi za skrini mwenyewe, kisha uwashe upya Omarchy ili mabadiliko yoyote ya mazingira yaanze kutumika.

### Je, ninawashaje spika + kamera ya wavuti kwenye Apple Studio Display yangu?

Ungedhani kuwa kila kitu kinapaswa kufanya kazi kwa kuchomeka tu USB C, lakini kwa bahati mbaya sivyo ilivyo. Suluhisho nililopata ili lifanye kazi kwa uhakika ni kutumia [kebo ya WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kisha spika na kamera ya wavuti hufanya kazi vizuri sana bila matatizo.

Kumbuka kuwa una udhibiti wa mwangaza uliojengwa ndani katika Omarchy kwa Apple Displays (Studio na XDR zote mbili) kwa kutumia vitufe vya kawaida vya mwangaza vya kibodi.

### Je, ninaondokana vipi na programu zote za ziada?

Ikiwa hutaki programu kama Obsidian au LibreOffice au kitu chochote kingine kilichosakinishwa awali, unaweza kukiondoa kwa urahisi sana.

Endesha _Ondoa > Kifurushi_ ili kuona kila kifurushi kilichosakinishwa. Kisha unaweza kuchagua kifurushi chochote unachotaka kuondoa kwa tab, na kuanza kuondoa kila ulichochagua kwa return.

Na unaweza kutumia _Ondoa > Programu ya Wavuti_ kutoka kwenye menyu ya Omarchy ili kuondoa programu zozote za wavuti zilizosakinishwa awali ambazo huzitaki.

Au endesha _Ondoa > Vilivyosakinishwa Awali_ ili kufagia programu zote za ziada zilizosakinishwa awali — programu za wavuti, TUI, na programu za hiari — kwa mara moja. Vitufe vya mkato vilivyozizindua huondoka nazo, hivyo unabaki na orodha safi ya vifungo vya kujaza na vyako mwenyewe katika `~/.config/hypr/bindings.lua`.

---

Kwa makosa na vitu vilivyoharibika, angalia [sehemu ya Utatuzi wa Matatizo](45-troubleshooting.md).
