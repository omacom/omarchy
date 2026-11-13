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

Upau utaonyesha kiotomatiki mpangilio wako wa sasa wa kibodi mara tu unapokuwa umesanidi mipangilio mingi (na unaweza kuubofya ili kubadilisha pia).

### Je, ninabadilishaje umbizo la saa kuwa la saa 12?

Bofya kulia kwenye saa iliyo kwenye upau ili kuzunguka katika miundo ya kawaida, ikiwemo ile ya saa 12. Unaweza pia kuweka umbizo moja kwa moja:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Hii itaonyesha Jumapili 10:55 AM.

### Je, ninabadilishaje eneo langu la saa?

Endesha _Sasisha > Eneo la Saa_ katika menyu ya Omarchy na uchague kutoka kwenye orodha. Ikiwa eneo la saa ni sahihi lakini saa yenyewe imechelewa, _Sasisha > Saa_ huwasha upya usawazishaji wa saa kwa ajili yako.

### Je, ninabadilishaje DNS yangu, kushiriki Wi-Fi yangu, au kuangalia kasi ya muunganisho wangu?

Hayo yote yapo katika [mtandao](35-networking.md).

### Je, ninaangaliaje jinsi diski yangu ilivyo na kasi?

_Anzisha > Jaribio la Kasi > Jaribio la Kasi ya Diski_ hupima kasi ya moja kwa moja ya kusoma na kuandika kwenye hifadhi yako, au `omarchy disk speedtest` kutoka kwenye terminali.

### Je, ninaongezaje kichapishi?

Uchapishaji umesanidiwa na unafanya kazi mara moja, na unaongeza kila kichapishi mwenyewe kutoka _Mipangilio ya Uchapishaji_ katika kianzisha programu (`Super + Space`).

Chagua _Ongeza_, na uipe muda wa kutafuta: kichapishi kilichochomekwa kupitia USB, na vichapishi vingi vya mtandao, hupatikana kwa ajili yako. Ikiwa chako hakipo kwenye orodha, chagua _Kichapishi cha Mtandao > Internet Printing Protocol (ipp)_ na uingize anwani yake — onyesho la kichapishi chenyewe au ukurasa wake wa wavuti utakuambia hiyo ni nini, kwa kawaida kitu kama `192.168.1.50` chenye foleni ya `ipp/print`. _Mbele_ kisha hutoa kiendeshi, ambapo kichapishi cha kisasa hufanya kazi vyema zaidi kwenye wasifu usiohitaji kiendeshi wa _IPP Everywhere_ na cha zamani hutaka kiendeshi cha modeli yenyewe.

Bofya kulia kwenye kichapishi na uchague _Weka kama Chaguo-msingi_ ili kuchagua kile ambacho programu zako hukifikia kwanza, na _Sifa_ ili kuweka ukubwa wa karatasi, uchapishaji wa pande mbili na ubora.

Ugunduzi wa kiotomatiki, ambapo vichapishi vilivyo kwenye mtandao huonekana bila kuongezwa, umezimwa kwa muda wakati unafanyiwa marekebisho, ndiyo maana hatua ya kwanza hapo juu ni yako badala ya kuwa ya kiotomatiki. Kuchapisha kwenye faili ya PDF hufanya kazi bila kichapishi chochote kabisa.

### Je, ninabadilishaje mahali ambapo picha za skrini au rekodi za skrini zinahifadhiwa?

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kwa chaguo-msingi. Ili kutumia saraka nyingine, ongeza hii kwenye faili iliyo chini ya `~/.config/uwsm/env.d/` (kama `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Unaweza kufanya vivyo hivyo kwa rekodi za skrini kwa kutumia `OMARCHY_SCREENRECORD_DIR`.

Omasnap huunda saraka yake ya picha za skrini kiotomatiki. Unda saraka ya rekodi za skrini mwenyewe, kisha uanzishe upya Omarchy ili mabadiliko yoyote kati ya hayo ya mazingira yaanze kutumika.

### Je, ninawashaje spika + kamera ya wavuti kwenye Apple Studio Display yangu?

Ungedhani kuwa kila kitu kinapaswa kufanya kazi kwa kuchomeka tu USB C, lakini kwa bahati mbaya sivyo ilivyo. Suluhisho nililopata ili lifanye kazi kwa uhakika ni kutumia [kebo ya WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kisha spika na kamera ya wavuti hufanya kazi vizuri sana bila matatizo.

Kumbuka kuwa una udhibiti wa mwangaza uliojengewa ndani katika Omarchy kwa ajili ya Skrini za Apple (Studio na XDR zote mbili) kwa kutumia vitufe vya kawaida vya mwangaza vya kibodi.

### Je, ninaondoaje programu zote za ziada?

Ikiwa hutaki programu kama Obsidian au LibreOffice au programu nyingine zozote zilizosakinishwa awali, unaweza kuziondoa kwa urahisi sana.

Endesha _Ondoa > Kifurushi_ ili kuona kila kifurushi kilichosakinishwa. Kisha unaweza kuchagua kifurushi chochote ungependa kukiondoa kwa tab, na kuanza kuondoa kila ulichokichagua kwa return.

Na unaweza kutumia _Ondoa > Programu ya Wavuti_ kutoka kwenye menyu ya Omarchy ili kuondoa programu zozote za wavuti zilizosakinishwa awali usizozitaka.

Au endesha _Ondoa > Vilivyosakinishwa Awali_ ili kufagia programu zote za ziada zilizosakinishwa awali — programu za wavuti, TUI, na programu za hiari — kwa mara moja. Mikato ya kibodi iliyozianzisha huondoka pamoja nazo, kwa hivyo unabaki na orodha safi ya mikato ya kujaza kwa yako mwenyewe katika `~/.config/hypr/bindings.lua`.

---

Kwa hitilafu na vitu vilivyoharibika, angalia [sehemu ya Utatuzi wa Matatizo](45-troubleshooting.md).
