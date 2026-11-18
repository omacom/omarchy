# FAQ

### Conas a aistrím idir leagan amach méarchláir?

Cuir eagar ar do chomhad `~/.config/hypr/input.lua` agus cuir é seo leis chun aistriú idir leagan amach ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Taispeánfaidh an barra do leagan amach méarchláir reatha go huathoibríoch a luaithe a bhíonn leagan amach iolracha cumraithe agat (agus is féidir leat cliceáil air chun aistriú freisin).

### Conas a athraím formáid an chloig go 12 uair?

Cliceáil ar dheis ar an gclog sa bharra chun dul tríd na formáidí coitianta, lena n-áirítear na cinn 12 uair. Is féidir leat an fhormáid a shocrú go díreach freisin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Taispeánfaidh sé seo Dé Domhnaigh 10:55 AM.

### Conas a athraím mo chrios ama?

Rith _Update > Timezone_ sa roghchlár Omarchy agus roghnaigh ón liosta. Má tá an crios ama ceart ach má tá an clog féin tar éis imeacht le sruth, atosaíonn _Update > Time_ an sioncronú ama duit.

### Conas a athraím mo DNS, a roinnim mo Wi-Fi, nó a sheiceálaim luas mo cheangail?

Tá siad sin go léir i [líonrú](35-networking.md).

### Conas a sheiceálaim cé chomh tapa is atá mo dhiosca?

Tomhaiseann _Trigger > Speed Test > Disk Speed Test_ luas léite agus scríofa beo ar do thiomántán, nó `omarchy disk speedtest` ón teirminéal.

### Conas a chuirim printéir leis?

Tá an phriontáil socraithe agus ag rith díreach as an mbosca, agus cuireann tú gach printéir leis tú féin ó _Print Settings_ sa lainseálaí feidhmchlár (`Super + Space`).

Roghnaigh _Add_, agus tabhair nóiméad dó chun cuardach a dhéanamh: aimsítear duit printéir atá plugáilte isteach thar USB, agus formhór na bprintéirí líonra. Mura bhfuil do cheannsa ar an liosta, roghnaigh _Network Printer > Internet Printing Protocol (ipp)_ agus cuir a sheoladh isteach — inseoidh taispeáint an phrintéara féin nó a leathanach gréasáin duit cad é sin, rud éigin cosúil le `192.168.1.50` de ghnáth le scuaine de `ipp/print`. Cuireann _Forward_ tiománaí ar fáil ansin, áit a n-oibríonn printéir nua-aimseartha is fearr ar an bpróifíl gan tiománaí _IPP Everywhere_ agus a dteastaíonn tiománaí an mhúnla féin ó cheann níos sine.

Cliceáil ar dheis ar phrintéir agus roghnaigh _Set as Default_ chun a roghnú cé acu a úsáideann do chuid aipeanna ar dtús, agus _Properties_ chun méid an pháipéir, déthaobhach agus cáilíocht a shocrú.

Tá an fhionnachtain uathoibríoch, áit a bhfeictear printéirí ar an líonra gan iad a chur leis, múchta go sealadach agus í á hathoibriú, agus sin an fáth gurb é an chéad chéim thuas do chéimse seachas ceann uathoibríoch. Oibríonn priontáil chuig comhad PDF gan aon phrintéir ar chor ar bith.

### Conas a athraím cá sábháiltear seatanna scáileáin nó taifeadtaí scáileáin?

Téann seatanna scáileáin sábháilte go `~/Pictures/Screenshots` de réir réamhshocraithe. Chun eolaire eile a úsáid, cuir é seo le comhad faoi `~/.config/uwsm/env.d/` (cosúil le `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Is féidir leat an rud céanna a dhéanamh do thaifeadtaí scáileáin ag úsáid `OMARCHY_SCREENRECORD_DIR`.

Cruthaíonn Omasnap a eolaire seatanna scáileáin go huathoibríoch. Cruthaigh an t-eolaire taifeadtaí scáileáin tú féin, ansin atosaigh Omarchy chun go dtiocfaidh ceachtar athrú timpeallachta i bhfeidhm.

### Conas a chuirim na callairí + an ceamara gréasáin ag obair ar mo Apple Studio Display?

Shílfeá gur chóir go n-oibreodh sé go léir ach é a phlugáil isteach le USB C, ach ar an drochuair ní mar sin atá. Is é an réiteach a d'aimsigh mé chun é a chur ag obair go hiontaofa ná [an cábla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) a úsáid. Ansin oibríonn na callairí agus an ceamara gréasáin go binn.

Cuimhnigh go bhfuil rialú gile ionsuite agat in Omarchy do na Apple Displays (Studio agus XDR araon) ag úsáid na ngnáthchnaipe gile méarchláir.

### Conas a fhaighim réidh leis na bogearraí breise go léir?

Mura dteastaíonn cláir cosúil le Obsidian nó LibreOffice nó aon cheann den ábhar réamhshuiteáilte eile uait, is féidir leat iad a bhaint go han-éasca.

Rith _Remove > Package_ chun gach pacáiste atá suiteáilte a fheiceáil. Ansin is féidir leat aon phacáiste ar mhaith leat é a bhaint a roghnú le tab, agus tosú ag baint gach rud atá roghnaithe agat le return.

Agus is féidir leat _Remove > Web App_ a úsáid ón roghchlár Omarchy chun aon cheann de na haipeanna gréasáin réamhshuiteáilte nach dteastaíonn uait a bhaint.

Nó rith _Remove > Preinstalls_ chun na breiseáin réamhshuiteáilte go léir — aipeanna gréasáin, TUIs, agus feidhmchláir roghnacha — a scuabadh amach in aon iarracht amháin. Imíonn na hotkeys a lainseáil iad in éineacht leo, mar sin fágtar slate glan ceangal agat le líonadh le do chuid féin i `~/.config/hypr/bindings.lua`.

---

Le haghaidh earráidí agus codanna briste, féach [an rannóg Fabhtcheartaithe](45-troubleshooting.md).
