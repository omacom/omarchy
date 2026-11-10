# Ceisteanna Coitianta

### Conas a athraím idir leaganacha méarchláir?

Cuir do chomhad `~/.config/hypr/input.lua` in eagar agus cuir é seo leis chun athrú idir leaganacha ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Taispeánfaidh an barra do leagan méarchláir reatha go huathoibríoch a luaithe a bheidh leaganacha iolracha cumraithe agat (agus is féidir leat cliceáil air chun athrú freisin).

### Conas a athraím formáid an chloig go 12 uair an chloig?

Cliceáil ar dheis ar an gclog sa bharra chun timthriall a dhéanamh trí na formáidí coitianta, lena n-áirítear na cinn 12 uair an chloig. Is féidir leat an fhormáid a shocrú go díreach freisin:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Taispeánfaidh sé seo Sunday 10:55 AM.

### Conas a athraím mo chrios ama?

Rith _Nuashonraigh > Timezone_ sa roghchlár Omarchy agus roghnaigh ón liosta. Má tá an crios ama i gceart ach má tá an clog féin imithe ar seachrán, atosaíonn _Nuashonraigh > Time_ an sioncrónú ama duit.

### Conas a athraím mo DNS, a roinnim mo Wi-Fi, nó a sheiceálaim luas mo naisc?

Cónaíonn siad sin go léir i [líonrú](35-networking.md).

### Conas a sheiceálaim cé chomh tapa is atá mo dhiosca?

Tomhaiseann _Spreag > Tástáil luais > Tástáil luais diosca_ luas léite agus scríofa beo ar do thiomáint, nó `omarchy disk speedtest` ón teirminéal.

### Cén fáth nach féidir liom síniú isteach i mo chuntas Google i Chromium?

Ní sheoltar an tógáil Chromium foinse oscailte shimplí leis na dintiúir OAuth a éilíonn Google le haghaidh síniú isteach i gcuntas. Rith _Suiteáil > Service > Chromium Account_ sa roghchlár Omarchy chun iad a chur leis, atosaigh an brabhsálaí, agus rachaidh an síniú isteach tríd.

### Conas a chuirim printéir leis?

Tá priontáil socraithe agus ag rith díreach as an mbosca, agus cuireann tú gach printéir leat féin ó _Print Settings_ sa lainseálaí feidhmchlár (`Super + Space`).

Roghnaigh _Add_, agus tabhair nóiméad dó le breathnú: aimsítear printéir plugáilte isteach thar USB, agus formhór na bprintéirí líonra, duit. Mura bhfuil do cheannsa sa liosta, roghnaigh _Network Printer > Internet Printing Protocol (ipp)_ agus cuir isteach a sheoladh — inseoidh taispeáint an phrintéara féin nó a leathanach gréasáin duit cad é sin, rud éigin cosúil le `192.168.1.50` de ghnáth le scuaine de `ipp/print`. Tairgeann _Forward_ tiománaí ansin, áit a n-oibríonn printéir nua-aimseartha is fearr ar an bpróifíl gan tiománaí _IPP Everywhere_ agus teastaíonn tiománaí na samhla féin ó cheann níos sine.

Cliceáil ar dheis ar phrintéir agus roghnaigh _Set as Default_ chun a roghnú cén ceann a shroicheann d'fheidhmchláir ar dtús, agus _Properties_ chun méid páipéir, déphléacs agus cáilíocht a shocrú.

Tá an fionnachtain uathoibríoch, áit a mbíonn printéirí ar an líonra le feiceáil gan iad a chur leis, múchta go sealadach fad is atá sé á athoibriú, agus sin an fáth go bhfuil an chéad chéim thuas leatsa seachas go huathoibríoch. Oibríonn priontáil chuig comhad PDF gan printéir ar bith ar chor ar bith.

### Conas a athraím an áit a sábháiltear seatanna scáileáin nó taifeadtaí scáileáin?

Téann seatanna scáileáin sábháilte go `~/Pictures/Screenshots` de réir réamhshocraithe. Chun comhadlann eile a úsáid, cuir é seo le comhad faoi `~/.config/uwsm/env.d/` (cosúil le `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Is féidir leat an rud céanna a dhéanamh do thaifeadtaí scáileáin ag baint úsáide as `OMARCHY_SCREENRECORD_DIR`.

Cruthaíonn Omasnap a chomhadlann seatanna scáileáin go huathoibríoch. Cruthaigh an chomhadlann taifeadta scáileáin tú féin, ansin atosaigh Omarchy chun go dtiocfaidh ceachtar athrú timpeallachta i bhfeidhm.

### Conas a chuirim na callairí + an ceamara gréasáin ag obair ar mo Apple Studio Display?

Shílfeá go n-oibreodh sé go léir díreach USB C a phlugáil isteach, ach ar an drochuair ní mar sin atá. Is é an réiteach atá aimsithe agam chun é a chur ag obair go hiontaofa ná [an cábla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) a úsáid. Ansin oibríonn na callairí agus an ceamara gréasáin go hiontach.

Cuimhnigh go bhfuil rialú gile ionsuite agat in Omarchy do na Taispeántais Apple (Studio agus XDR araon) ag baint úsáide as na gnáthchnaipi gile méarchláir.

### Conas a gheobhaidh mé réidh leis na bogearraí breise go léir?

Mura dteastaíonn cláir cosúil le Obsidian nó LibreOffice nó aon cheann den ábhar réamhshuiteáilte eile uait, is féidir leat é a bhaint go han-éasca.

Rith _Bain > Package_ chun gach pacáiste atá suiteáilte a fheiceáil. Ansin is féidir leat aon phacáiste is mian leat a bhaint a roghnú le tab, agus tosú ag baint gach rud atá roghnaithe agat le return.

Agus is féidir leat _Bain > Web App_ a úsáid ón roghchlár Omarchy chun aon cheann de na feidhmchláir gréasáin réamhshuiteáilte nach dteastaíonn uait a bhaint.

Nó rith _Bain > Preinstalls_ chun na breiseanna réamhshuiteáilte go léir a scuabadh amach — feidhmchláir gréasáin, TUIanna, agus feidhmchláir roghnacha — in aon turas amháin. Imíonn na heochracha te a sheol iad leo, mar sin fágtar scláta glan naisc agat le líonadh le do chinn féin i `~/.config/hypr/bindings.lua`.

---

Le haghaidh earráidí agus píosaí briste, féach [an chuid Fabhtcheartaithe](45-troubleshooting.md).
