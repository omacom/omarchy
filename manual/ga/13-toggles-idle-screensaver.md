# Scoráin, Díomhaoin & an Spárálaí Scáileáin

Níl a lán den mhéid a athraíonn tú ó lá go lá ina shocrú i ndáiríre. Is mód é a chasann tú air ar feadh uaire agus as arís: solas oíche agus tú ag obair go déanach, ná cuir isteach orm agus tú ag cur i láthair, fan i do dhúiseacht agus tú ag breathnú ar rud éigin. Tugann Omarchy scoráin orthu sin, agus oibríonn siad go léir ar an mbealach céanna — aicearra eochrach, iontráil roghchláir, agus ordú, iad go léir ag bualadh an lasc chéanna.

### Roghchlár na scorán

Osclaíonn `Super + Ctrl + O` _Trigger > Toggle_ go díreach, nó is féidir leat siúl ann ón roghchlár Omarchy (`Super + Space`). Is lasc é gach rud ar an liosta sin is féidir leat a chasadh gan smaoineamh ar an áit a bhfuil an staid ina cónaí. Suíonn lasca don chaoi a bhfuil cuma ar an deasc in aice leis, faoi _Appearance_.

Ón teirminéal, is iad na lasca céanna `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Scorán | Aicearra | Ordú |
| ------ | ------ | ------- |
| Solas oíche | — | `omarchy toggle nightlight` |
| Tostaigh fógraí | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúiseacht (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairteála | — | `omarchy toggle crash-capture` |
| Spárálaí scáileáin | — | `omarchy toggle screensaver` |
| Sioncronú téama [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Scáileán tadhaill | — | `omarchy toggle touchscreen` |
| Fionraí | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy toggle hybrid gpu` |

Tá lasca an cheap tadhaill, an scáileáin tadhaill, agus an GPU hibrideach ina gcónaí faoi _Trigger > Hardware_ (`Super + Ctrl + H`) seachas faoi Toggle, mar nach dtaispeántar iad ach amháin nuair atá an crua-earraí sin agat i ndáiríre. Maireann cinn an cheap tadhaill agus an scáileáin tadhaill tar éis athlódáil Hyprland — sábháiltear ainm an ghléis díchumasaithe chuig comhad beag staide a léann Hyprland ag am tosaithe chun é a dhíchumasú arís.

Tá an barra roghchláir agus beochan i _Appearance_, móide roinnt rudaí nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán na ceallra sa bharra, leagan amach réamhshocraithe an spáis oibre, agus faoi _Windows_, bearnaí fuinneog (`Super + Shift + Backspace`) agus an cóimheas cearnógach 1-fhuinneog (`Super + Ctrl + Backspace`).

Níl sa chuid is mó díobh seo ach comhad brataí faoi `~/.local/state/omarchy/toggles/`. Más mian leat brainse a dhéanamh ar cheann i script, tugann `omarchy-toggle-enabled` cód scoir duit in ionad tú a chur á chuardach:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ainmnítear na bratacha don staid as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair atá mód ar siúl, faigheann tú glif bheag i lár an bharra uachtair in aice leis an gclog. Sin an ghiuirléid táscairí, agus iompraíonn sí deachtú, taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach orm, agus fan i do dhúiseacht.

Cuirtear táscairí neamhghníomhacha i bhfolach. Cuir an luch thar áit ar bith ar an bharra agus céimníonn siad isteach maolaithe, ionas gur féidir leat cliceáil ar cheann chun é a chasadh air gan a aicearra eochrach a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach as arís é. Más fearr leat iad go léir a fheiceáil an t-am ar fad, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` in `~/.config/omarchy/shell.json` — féach [an barra uachtarach](05-the-top-bar.md) chun a fháil amach conas a chumraítear giuirléidí barra.

### Solas oíche

Teasaíonn solas oíche an scáileán go 4000K, agus cuireann scoránú arís ar ais go 6500K é. Cas é ón roghchlár scorán (`Super + Ctrl + O`) nó le `omarchy toggle nightlight`. Tá sé tiomáinte ag hyprsunset, a thosaíonn an scorán duit mura bhfuil sé ar siúl cheana.

De réir réamhshocraithe ní dhéanann hyprsunset tada le do scáileán ar chor ar bith. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl chéannachta go beacht ionas go bhfanann an taispeántas gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a bheith á scoránú de réir an chloig, cuir próifíl ama ina áit sin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin tosaigh hyprsunset ag am logála isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an scorán socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach orm

Tostaíonn `Super + Ctrl + Alt + ,` fógraí. Ní phreabann aon tóstaí aníos fad atá sé ar siúl, agus suíonn táscaire an chloig le líne tríd sa bharra chun a mheabhrú duit cén fáth ar tháinig ciúnas ar an deasc.

Ní chailltear tada, áfach. Coinnítear fógraí tostaithe siar: cuir an cúpla deireanach ar ais ar an scáileán le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile.

Tagann dhá chineál teachtaireachta tríd i gcónaí: tóstaí deimhnithe Omarchy féin do rud éigin a rinne tú díreach ("Theme changed", "Screenshot saved"), agus foláirimh chriticiúla a seoltar ón líne ordaithe. Ní cháilíonn aipeanna comhrá a mharcálann gach rud mar chriticiúil chun a mbealach a bhrú os do chomhair.

### Díomhaoin

Is leis an mblaosc Omarchy iompar díomhaoin, agus is bloc barrleibhéil `idle` iad na hamanna in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Is soicindí an dá uimhir a chomhairtear ón nóiméad a d'éirigh tú díomhaoin — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an spárálaí scáileáin aníos tar éis dhá nóiméad go leith agus glacann an scáileán glais seilbh ag cúig nóiméad, cibé acu a rith an spárálaí scáileáin nó nár rith. Sábháil an comhad agus glacann an blaosc na hamanna nua láithreach.

Má dhíbhíonn tú an spárálaí scáileáin roimh spriocdháta an ghlais, comhairtear sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach thú as sracfhéachaint a thabhairt ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaoin ar fad, casann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúiseacht air, agus feictear táscaire an chupáin caife sa bharra. Sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mian leat breathnú uirthi. Buail arís é chun dul ar ais go dtí an gnáthrud. Priontálann `omarchy toggle idle status` an staid reatha mar JSON má theastaíonn sí uait ó script.

Baineann sé seo le glasáil agus leis an spárálaí scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus ag geimhriú in [codladh an chórais](36-system-sleep.md).

### An spárálaí scáileáin

Is ealaín ASCII é spárálaí scáileáin Omarchy a ritheann trí éifeachtaí téacs randamacha, cás amháin in aghaidh an mhonatóra. Scoireann aon eochair nó gluaiseacht luiche é.

Is féidir leat é a thosú ar éileamh ó _System > Screensaver_ (`Super + Esc`), a chuireann suas é fiú má tá spárálaí scáileáin an díomhaoin casta as agat. Níl aon aicearra eochrach ceangailte leis de réir réamhshocraithe.

Casann `omarchy toggle screensaver` an ceann díomhaoin as, más fearr leat dul díreach ó bheith ag obair go bheith faoi ghlas. Teastaíonn teirminéal uaidh a bhfuil a fhios aige conas a chumrú — Alacritty, Foot, Ghostty, nó Kitty — agus inseoidh sé sin duit más rud éigin eile é do theirminéal réamhshocraithe.

Is leatsa an lógó a tharraingíonn sé a athrú, faoi _Appearance > Branding > Screensaver_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glais

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sin an scáileán glais ón mblaosc Omarchy, bánann sé an taispeántas, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann ionas nach mbeidh tú ag clóscríobh do phasfhocail san aibítir mhícheart, agus — má tá sé ar siúl agat — glasálann sé 1Password ar an mbealach amach.

Glacann an scáileán glais le pasfhocal, agus glacfaidh sé le méarlorg freisin a luaithe a bheidh ceann socraithe agat. Tá sin, agus na bealaí eile chun fíordheimhniú a dhéanamh, clúdaithe in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
