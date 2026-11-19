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

Bofya kulia saa iliyo kwenye upau ili kuzunguka kati ya umbizo za kawaida, zikiwemo zile za saa 12. Unaweza pia kuweka umbizo moja kwa moja:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Hii itaonyesha Jumapili 10:55 AM.

### Je, ninabadilishaje eneo langu la saa?

Endesha _Setup > Region > Timezone_ kwenye menyu ya Omarchy na uchague kutoka kwenye orodha. Ikiwa eneo la saa ni sahihi lakini saa yenyewe imepotoka, _Update > Time_ huanzisha upya usawazishaji wa saa kwa ajili yako.

### Je, ninabadilishaje DNS yangu, kushiriki Wi-Fi yangu, au kukagua kasi ya muunganisho wangu?

Hayo yote yako katika [masuala ya mtandao](35-networking.md).

### Je, ninakaguaje jinsi diski yangu ilivyo na kasi?

_Trigger > Speed Test > Disk Speed Test_ hupima kasi ya moja kwa moja ya kusoma na kuandika kwenye diski yako, au `omarchy disk speedtest` kutoka kwenye terminali.

### Je, ninaongezaje kichapishi?

Uchapishaji umesanidiwa na unafanya kazi kuanzia mwanzo, na unaongeza kila kichapishi mwenyewe kutoka _Print Settings_ katika kizindua programu (`Super + Space`).

Chagua _Add_, na uipe muda wa kutafuta: kichapishi kilichounganishwa kwa USB, na vichapishi vingi vya mtandao, hupatikana kwa ajili yako. Ikiwa chako hakipo kwenye orodha, chagua _Network Printer > Internet Printing Protocol (ipp)_ na uingize anwani yake — onyesho la kichapishi chenyewe au ukurasa wake wa wavuti utakuambia hiyo ni nini, kwa kawaida kitu kama `192.168.1.50` chenye foleni ya `ipp/print`. _Forward_ kisha hutoa kiendeshi, ambapo kichapishi cha kisasa hufanya kazi vizuri zaidi kwenye wasifu usiohitaji kiendeshi wa _IPP Everywhere_ na cha zamani hutaka kiendeshi chenyewe cha modeli hiyo.

Bofya kulia kichapishi na uchague _Set as Default_ ili kuchagua kile ambacho programu zako hukifikia kwanza, na _Properties_ ili kuweka ukubwa wa karatasi, duplex na ubora.

Ugunduzi wa kiotomatiki, ambapo vichapishi vilivyo kwenye mtandao huonekana bila kuongezwa, umezimwa kwa muda huku ukifanyiwa kazi upya, ndiyo sababu hatua ya kwanza hapo juu ni yako badala ya kuwa ya kiotomatiki. Kuchapisha kwenye faili ya PDF hufanya kazi bila kichapishi chochote kabisa.

### Je, ninabadilishaje mahali ambapo picha za skrini au rekodi za skrini huhifadhiwa?

Picha za skrini zilizohifadhiwa huenda kwenye `~/Pictures/Screenshots` kwa chaguo-msingi. Ili kutumia saraka nyingine, ongeza hii kwenye faili iliyo chini ya `~/.config/uwsm/env.d/` (kama `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Unaweza kufanya vivyo hivyo kwa rekodi za skrini kwa kutumia `OMARCHY_SCREENRECORD_DIR`.

Omasnap huunda saraka yake ya picha za skrini kiotomatiki. Unda saraka ya rekodi za skrini mwenyewe, kisha uanzishe upya Omarchy ili mabadiliko yoyote kati ya hayo ya mazingira yaanze kutumika.

### Je, ninapataje spika + kamera ya wavuti zifanye kazi kwenye Apple Studio Display yangu?

Ungedhani kwamba yote yanapaswa kufanya kazi kwa kuunganisha tu USB C, lakini kwa bahati mbaya sivyo ilivyo. Suluhisho nililolipata ili kuifanya ifanye kazi kwa uhakika ni kutumia [kebo ya WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Kisha spika na kamera ya wavuti hufanya kazi bila shida yoyote.

Kumbuka kwamba una udhibiti wa mwangaza uliojengewa ndani katika Omarchy kwa ajili ya Apple Displays (Studio na XDR zote mbili) kwa kutumia vitufe vya kawaida vya mwangaza vya kibodi.

### Je, ninaondoaje programu zote za ziada?

Ikiwa hutaki programu kama Obsidian au LibreOffice au vitu vingine vyovyote vilivyosakinishwa awali, unaweza kuviondoa kwa urahisi sana.

Endesha _Remove > Package_ ili kuona kila kifurushi kilichosakinishwa. Kisha unaweza kuchagua kifurushi chochote ambacho ungependa kukiondoa kwa tab, na kuanza kuondoa kila kitu ulichochagua kwa return.

Na unaweza kutumia _Remove > Web App_ kutoka kwenye menyu ya Omarchy ili kuondoa programu zozote za wavuti zilizosakinishwa awali ambazo huzitaki.

Au endesha _Remove > Preinstalls_ ili kufagia programu zote za ziada zilizosakinishwa awali — programu za wavuti, TUI, na programu za hiari — kwa wakati mmoja. Vitufe vya mkato vilivyozizindua huondoka pamoja nazo, hivyo unabaki na ukurasa safi wa miunganisho ya kujaza kwa yako mwenyewe katika `~/.config/hypr/bindings.lua`.

---

Kwa makosa na vitu vilivyoharibika, angalia [sehemu ya Utatuzi wa Matatizo](45-troubleshooting.md).
