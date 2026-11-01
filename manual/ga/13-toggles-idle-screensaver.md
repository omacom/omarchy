# Scoránaigh, Díomhaointeas & an Spárálaí Scáileáin

Ní suíomh i ndáiríre é cuid mhór de na rudaí a athraíonn tú ó lá go lá. Is mód é a chasann tú air ar feadh uair an chloig agus as arís: solas oíche agus tú ag obair go déanach, ná cuir isteach agus tú ag cur i láthair, fan i do dhúiseacht agus tú ag breathnú ar rud éigin. Scoránaigh a thugann Omarchy orthu sin, agus oibríonn siad go léir ar an mbealach céanna — eochair aicearra, iontráil roghchláir, agus ordú, iad go léir ag bualadh an lasc chéanna.

### An roghchlár scoránaigh

Osclaíonn `Super + Ctrl + O` _Trigger > Toggle_ go díreach, nó is féidir leat siúl ann ón roghchlár Omarchy (`Super + Space`). Is lasc gach rud ar an liosta sin is féidir leat a chasadh gan smaoineamh ar an áit a bhfuil an staid ina cónaí. Suíonn lasca don chuma atá ar an deasc in aice leis, faoi _Appearance_.

Ón teirminéal, is iad na lasca céanna `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Scorán | Eochair aicearra | Ordú |
| ------ | ------ | ------- |
| Solas oíche | — | `omarchy toggle nightlight` |
| Ciúnaigh fógraí | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúiseacht (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairteála | — | `omarchy toggle crash-capture` |
| Spárálaí scáileáin | — | `omarchy toggle screensaver` |
| Sioncrónú téama [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Scáileán tadhaill | — | `omarchy toggle touchscreen` |
| Cuir ar fionraí | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy toggle hybrid gpu` |

Tá na lasca ceap tadhaill, scáileán tadhaill, agus GPU hibrideach faoi _Trigger > Hardware_ (`Super + Ctrl + H`) seachas faoi Toggle, mar nach dtaispeántar iad ach amháin nuair a bhíonn an crua-earraí sin agat i ndáiríre. Maireann na cinn ceap tadhaill agus scáileán tadhaill tar éis athlódáil Hyprland — sábháiltear ainm an ghléis dhíchumasaithe chuig comhad beag staide a léann Hyprland ar thosú chun é a dhíchumasú arís.

Tá an barra roghchláir agus beochan in _Appearance_, móide roinnt rudaí nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán na ceallraí sa bharra, leagan amach réamhshocraithe an spáis oibre, agus faoi _Windows_, bearnaí fuinneog (`Super + Shift + Backspace`) agus an cóimheas gné cearnach 1 fhuinneog (`Super + Ctrl + Backspace`).

Níl sa chuid is mó díobh seo ach comhad brataí faoi `~/.local/state/omarchy/toggles/`. Más mian leat brainse a dhéanamh ar cheann i script, tugann `omarchy-toggle-enabled` cód fágála duit in ionad tú a chur á chuardach:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ainmnítear na bratacha don staid as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair a bhíonn mód ar siúl, faigheann tú glíf beag i lár an bharra barr in aice leis an gclog. Sin an ghiuirléid táscairí, agus iompraíonn sí deachtú, taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach, agus fan i do dhúiseacht.

Folaítear táscairí neamhghníomhacha. Cuir an cúrsóir thar áit ar bith ar an mbarra agus céimníonn siad isteach maolaithe, ionas gur féidir leat ceann a chliceáil chun é a chasadh air gan a eochair aicearra a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach as arís é. Más fearr leat iad go léir a fheiceáil an t-am ar fad, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` in `~/.config/omarchy/shell.json` — féach [an barra barr](05-the-top-bar.md) chun a fháil amach conas a chumraítear giuirléidí barra.

### Solas oíche

Teasaíonn solas oíche an scáileán go 4000K, agus cuireann casadh arís é ar ais go 6500K é. Cas é ón roghchlár scoránaigh (`Super + Ctrl + O`) nó le `omarchy toggle nightlight`. Tá sé tiomáinte ag hyprsunset, a thosaíonn an scorán duit mura bhfuil sé ar siúl cheana.

De réir réamhshocraithe ní dhéanann hyprsunset aon rud ar chor ar bith le do scáileán. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl chéannachta go beacht ionas go bhfanann an taispeántas gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a athrú de réir an chloig, cuir próifíl ama ina áit:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin tosaigh hyprsunset ag logáil isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an scorán socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach

Ciúnaíonn `Super + Ctrl + Alt + ,` fógraí. Ní phreabann aon tóstaí aníos fad atá sé ar siúl, agus suíonn an táscaire cloig le líne tríd sa bharra chun a mheabhrú duit cén fáth a bhfuil an deasc ciúin anois.

Ní chailltear aon rud, áfach. Coinnítear fógraí ciúnaithe siar: cuir na cinn dheireanacha ar ais ar an scáileán le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile.

Tagann dhá chineál teachtaireachta tríd i gcónaí: tóstaí deimhnithe Omarchy féin do rud a rinne tú díreach ("Téama athraithe", "Seat scáileáin sábháilte"), agus foláirimh chriticiúla a sheoltar ón líne ordaithe. Ní cháilíonn aipeanna comhrá a mharcálann gach rud criticiúil chun a mbealach a bhrú os do chomhair.

### Díomhaointeas

Is le blaosc Omarchy iompar díomhaoin, agus is bloc `idle` ar an leibhéal barr in `~/.config/omarchy/shell.json` na huainithe:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Is soicindí an dá uimhir arna gcomhaireamh ón nóiméad a d'éirigh tú díomhaoin — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an spárálaí scáileáin aníos tar éis dhá nóiméad go leith agus glacann an scáileán glais seilbh ag cúig nóiméad, cibé ar rith an spárálaí scáileáin nó nár rith. Sábháil an comhad agus glacann an bhlaosc na huainithe nua láithreach.

Má dhíbheann tú an spárálaí scáileáin roimh an spriocdháta glais, áirítear sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach tú as sracfhéachaint a thabhairt ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaointeas ar fad, casann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúiseacht air, agus feictear an táscaire cupáin caife sa bharra. Sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mian leat breathnú uirthi. Buail arís é chun dul ar ais go dtí an gnáthrud. Priontálann `omarchy toggle idle status` an staid reatha mar JSON más gá duit í ó script.

Baineann sé seo le glasáil agus leis an spárálaí scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus ag geimhriú in [codladh an chórais](36-system-sleep.md).

### An spárálaí scáileáin

Is ealaín ASCII é spárálaí scáileáin Omarchy ag rith trí éifeachtaí téacs randamacha, cás amháin in aghaidh an mhonatóra. Fágann aon eochair nó gluaiseacht luiche é.

Is féidir leat é a thosú ar éileamh ó _System > Screensaver_ (`Super + Esc`), a bhrúnn aníos é fiú má chas tú an spárálaí scáileáin díomhaoin as. Níl aon eochair aicearra ceangailte leis de réir réamhshocraithe.

Is é `omarchy toggle screensaver` a chasann an ceann díomhaoin as, más fearr leat dul díreach ó bheith ag obair go bheith faoi ghlas. Dúnann aon eochair, cliceáil, scrolláil nó gluaiseacht luiche é.

Is leatsa an lógó a tharraingíonn sé a athrú, faoi _Appearance > Branding > Screensaver_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glais

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sin scáileán glais ó bhlaosc Omarchy, bánann sé an taispeántas, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann ionas nach bhfuil tú ag clóscríobh do phasfhocail san aibítir mícheart, agus — má tá sé ar siúl agat — glasálann sé 1Password ar an mbealach amach.

Glacann an scáileán glais le pasfhocal, agus glacfaidh sé le méarlorg freisin nuair a bheidh ceann socraithe agat. Clúdaítear sin, agus na bealaí eile chun fíordheimhniú a dhéanamh, in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
