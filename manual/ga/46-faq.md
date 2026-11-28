# FAQ

### Conas a aistrím idir leaganacha méarchláir?

Cuir do chomhad `~/.config/hypr/input.lua` in eagar agus cuir é seo leis chun aistriú idir leaganacha ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Taispeánfaidh an barra do leagan amach méarchláir reatha go huathoibríoch nuair a bheidh il-leaganacha cumraithe agat (agus is féidir leat cliceáil air chun aistriú freisin).

### Conas a athraím formáid an chloig go 12 uair an chloig?

Cliceáil ar dheis ar an gclog sa bharra chun dul tríd na formáidí coitianta, lena n-áirítear na cinn 12 uair an chloig. Is féidir leat an fhormáid a shocrú go díreach freisin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Taispeánfaidh sé seo Dé Domhnaigh 10:55 AM.

### Conas a athraím mo chrios ama?

Rith _Setup > Region > Timezone_ sa roghchlár Omarchy agus roghnaigh ón liosta. Má tá an crios ama ceart ach má tá an clog féin tar éis imeacht ar seachrán, atosaíonn _Update > Time_ an sioncronú ama duit.

### Conas a athraím mo DNS, conas a roinnim mo Wi-Fi, nó conas a sheiceálaim luas mo cheangail?

Tá siad sin go léir i [líonrú](35-networking.md).

### Conas a sheiceálaim cé chomh tapa is atá mo dhiosca?

Tomhaiseann _Trigger > Speed Test > Disk Speed Test_ luas beo léite agus scríofa ar do thiomántán, nó `omarchy disk speedtest` ón teirminéal.

### Conas a chuirim printéir leis?

Tá priontáil socraithe agus ag rith díreach as an mbosca, agus cuireann tú gach printéir leis tú féin ó _Print Settings_ sa lainseálaí feidhmchlár (`Super + Alt + Space`).

Roghnaigh _Add_, agus tabhair nóiméad dó chun cuardach a dhéanamh: aimsítear duit printéir atá plugáilte isteach thar USB, agus an chuid is mó de phrintéirí líonra. Mura bhfuil do cheannsa sa liosta, roghnaigh _Network Printer > Internet Printing Protocol (ipp)_ agus cuir a sheoladh isteach — inseoidh taispeáint an phrintéara féin nó a leathanach gréasáin duit cad é sin, rud éigin cosúil le `192.168.1.50` le scuaine de `ipp/print` de ghnáth. Ofrailfidh _Forward_ tiománaí ansin, áit a n-oibríonn printéir nua-aimseartha is fearr ar an bpróifíl gan tiománaí _IPP Everywhere_ agus a dteastaíonn tiománaí an mhúnla féin ó cheann níos sine.

Cliceáil ar dheis ar phrintéir agus roghnaigh _Set as Default_ chun a roghnú cé acu a úsáidfidh d'fheidhmchláir ar dtús, agus _Properties_ chun méid páipéir, duplex agus cáilíocht a shocrú.

Tá fionnachtain uathoibríoch, áit a bhfeictear printéirí ar an líonra gan iad a chur leis, múchta go sealadach agus í á hathoibriú, agus sin an fáth gur leatsa an chéad chéim thuas seachas go huathoibríoch. Oibríonn priontáil chuig comhad PDF gan aon phrintéir ar chor ar bith.

### Conas a athraím cá sábháiltear seatanna scáileáin nó taifeadtaí scáileáin?

Téann seatanna scáileáin sábháilte chuig `~/Pictures/Screenshots` de réir réamhshocraithe. Chun eolaire eile a úsáid, cuir é seo le comhad faoi `~/.config/uwsm/env.d/` (cosúil le `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Is féidir leat an rud céanna a dhéanamh le haghaidh taifeadtaí scáileáin ag úsáid `OMARCHY_SCREENRECORD_DIR`.

Cruthaíonn Omasnap a eolaire seatanna scáileáin go huathoibríoch. Cruthaigh an t-eolaire taifeadtaí scáileáin tú féin, ansin atosaigh Omarchy chun go dtiocfaidh ceachtar athrú timpeallachta i bhfeidhm.

### Conas a chuirim na cainteoirí + an ceamara gréasáin ag obair ar mo Apple Studio Display?

Shílfeá gur chóir go n-oibreodh sé go léir ach é a phlugáil isteach le USB C, ach ar an drochuair ní hea. Is é an réiteach a fuair mé chun é a chur ag obair go hiontaofa ná [an cábla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) a úsáid. Ansin oibríonn na cainteoirí agus an ceamara gréasáin go breá ar fad.

Cuimhnigh go bhfuil rialú gile ionsuite agat in Omarchy do na Apple Displays (Studio agus XDR araon) ag úsáid na ngnáthchnaipe gile méarchláir.

### Conas a bhainim an bogearra breise go léir?

Mura dteastaíonn uait cláir ar nós Obsidian nó LibreOffice nó aon cheann den ábhar réamhshuiteáilte eile, is féidir leat é a bhaint go han-éasca.

Rith _Remove > Package_ chun gach pacáiste atá suiteáilte a fheiceáil. Ansin is féidir leat aon phacáiste ar mhaith leat a bhaint a roghnú le tab, agus tosú ag baint gach rud atá roghnaithe agat le return.

Agus is féidir leat _Remove > Web App_ a úsáid ón roghchlár Omarchy chun aon cheann de na feidhmchláir ghréasáin réamhshuiteáilte nach dteastaíonn uait a bhaint.

Nó rith _Remove > Preinstalls_ chun na breiseáin réamhshuiteáilte go léir — feidhmchláir ghréasáin, TUIs, agus feidhmchláir roghnacha — a scuabadh amach in aon iarracht amháin. Imíonn na heochracha aicearra a sheol iad leo, mar sin fágtar leathanach glan de cheangail agat le líonadh le do chinn féin i `~/.config/hypr/bindings.lua`.

---

Le haghaidh earráidí agus rudaí briste, féach [an rannóg Fabhtcheartú](45-troubleshooting.md).
