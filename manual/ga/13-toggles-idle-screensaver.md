# Scoránaigh, Díomhaoin & an Spárálaí Scáileáin

Níl cuid mhór den mhéid a athraíonn tú ó lá go lá ina shocrú i ndáiríre. Is mód é a chasann tú air ar feadh uair an chloig agus as arís: solas oíche agus tú ag obair go déanach, ná cuir isteach air agus tú ag cur i láthair, fan i do dhúiseacht agus tú ag féachaint ar rud éigin. Tugann Omarchy scoránaigh orthu sin, agus oibríonn siad go léir ar an mbealach céanna — aicearra, iontráil roghchláir, agus ordú, iad go léir ag bualadh an lasc chéanna.

### An roghchlár scorán

Osclaíonn `Super + Ctrl + O` _Spreagadh > Scorán_ go díreach, nó is féidir leat siúl ann ón roghchlár Omarchy (`Super + Space`). Is lasc é gach rud ar an liosta sin ar féidir leat a chasadh gan smaoineamh ar cá bhfuil an staid á stóráil. Suíonn lasca don chuma atá ar an deasc in aice leis, faoi _Dealramh_.

Ón teirminéal, is iad na lasca céanna `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Scorán | Aicearra | Ordú |
| ------ | ------ | ------- |
| Solas oíche | — | `omarchy toggle nightlight` |
| Ciúnaigh fógraí | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúiseacht (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairteála | — | `omarchy toggle crash-capture` |
| Spárálaí scáileáin | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sioncrónú téama | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Deasc lánscáileáin (gan barra, gan bearnaí) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Beochan, doiléire agus scáthanna | — | `omarchy toggle animations` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Scáileán tadhaill | — | `omarchy device touchscreen` |
| Fionraí | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy device gpu hybrid` |

Cónaíonn lasca an cheap tadhaill, an scáileáin tadhaill, agus an GPU hibrideaigh faoi _Spreagadh > Crua-earraí_ (`Super + Ctrl + H`) seachas faoi Scorán, mar nach dtaispeántar iad ach amháin nuair a bhíonn an chrua-earra sin agat i ndáiríre. Maireann lasca an cheap tadhaill agus an scáileáin tadhaill tar éis athlódáil Hyprland — sábháiltear ainm an ghléis díchumasaithe chuig comhad beag staide a léann Hyprland ar an tosú chun é a dhíchumasú arís.

Coinníonn _Dealramh_ an barra roghchláir agus beochan, móide cúpla rud nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán na ceallra sa bharra, leagan amach réamhshocraithe an spáis oibre, agus faoi _Fuinneoga_, bearnaí fuinneog (`Super + Shift + Backspace`) agus an ghné chearnógach 1 fhuinneog (`Super + Ctrl + Backspace`).

Nuair nach bhfuil GPU ag Hyprland le tarraingt leis agus nuair a rindreálann sé ar an CPU ina ionad (llvmpipe), mar atá ar Mhacanna nach dtacaítear lena GPU go fóill, i bhformhór na meaisíní fíorúla, nó nuair a theipeann ar thiománaí grafaicí lódáil, casann Omarchy beochan, doiléire agus scáthanna as don seisiún sin agus insíonn sé duit é uair amháin le fógra. Tugann _Dealramh > Beochan Ar_ ar ais iad, agus cuimhníonn Omarchy air sin do sheisiúin níos déanaí freisin.

Níl sa chuid is mó díobh seo ach comhad brataí faoi `~/.local/state/omarchy/toggles/`. Más mian leat brainse a dhéanamh ar cheann acu i script, tugann `omarchy-toggle-enabled` cód fágála duit in ionad tú a chur á chuardach:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ainmnítear na bratacha don staid as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair a bhíonn mód ar siúl, faigheann tú glyph beag i lár an bharra uachtair in aice leis an gclog. Is é sin an ghiuirléid táscairí, agus iompraíonn sí taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach air, agus fan i do dhúiseacht, móide rabhaidh fad atá sudo gan phasfhocal ar siúl nó fad atá duine ceangailte le seisiún cianda.

Bíonn táscairí neamhghníomhacha i bhfolach. Cuir do chúrsóir áit ar bith ar an mbarra agus céimníonn siad isteach maolaithe, ionas gur féidir leat ceann a chliceáil chun é a chasadh air gan a aicearra a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach as arís é. Más fearr leat iad go léir a fheiceáil an t-am ar fad, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` in `~/.config/omarchy/shell.json` — féach [an barra uachtarach](05-the-top-bar.md) chun a fháil amach conas a chumraítear giuirléidí barra.

### Solas oíche

Teasaíonn solas oíche an scáileán go 4000K, agus cuireann scoránú arís ar ais go 6500K é. Cas é ón roghchlár scorán (`Super + Ctrl + O`) nó le `omarchy toggle nightlight`. Tá sé á thiomáint ag hyprsunset, a thosaíonn an scorán duit mura bhfuil sé ar siúl cheana.

De réir réamhshocraithe ní dhéanann hyprsunset aon rud ar chor ar bith le do scáileán. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl chéannachta go beacht ionas go bhfanann an taispeáint gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a athrú de réir an chloig, cuir próifíl ama ina ionad sin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin tosaigh hyprsunset ag logáil isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an scorán socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach air

Ciúnaíonn `Super + Ctrl + Alt + ,` fógraí. Ní phreabann aon tóstaí aníos fad atá sé ar siúl, agus suíonn an táscaire cloig le líne thairis sa bharra chun a mheabhrú duit cén fáth ar tháinig ciúnas ar an deasc.

Ní chailltear aon rud, áfach. Coinnítear fógraí ciúnaithe siar: cuir an cúpla deireanach ar ais ar an scáileán le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile.

Tagann trí chineál teachtaireachta tríd go fóill: tóstaí deimhnithe Omarchy féin do rud a rinne tú díreach ("Athraíodh an téama", "Sábháladh an seat scáileáin"), foláirimh chriticiúla a sheoltar ón líne ordaithe, agus cóid fhíorúcháin. Ní cháilíonn aipeanna comhrá a mharcálann gach rud mar chriticiúil chun a mbealach a fhórsáil os do chomhair.

### Díomhaoin

Is le blaosc Omarchy iompar díomhaoin, agus is bloc `idle` den leibhéal uachtarach in `~/.config/omarchy/shell.json` iad na hamanna:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Is soicindí an dá uimhir a chomhairtear ón nóiméad a d'éirigh tú díomhaoin — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an spárálaí scáileáin aníos tar éis dhá nóiméad go leith agus glacann an scáileán glasa seilbh ag cúig nóiméad, cibé acu a rith an spárálaí scáileáin nó nár rith. Sábháil an comhad agus glacann an blaosc na hamanna nua suas ar an bpointe.

Má dhíbheann tú an spárálaí scáileáin roimh spriocdháta an ghlasa, comhairtear sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach thú as sracfhéachaint a thabhairt ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaoin go hiomlán, casann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúiseacht air, agus feictear táscaire an chupáin caife sa bharra. Is é sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mian leat féachaint uirthi. Buail arís é chun dul ar ais go dtí an gnáthrud. Priontálann `omarchy toggle idle status` an staid reatha mar JSON más gá duit í ó script.

Baineann sé seo le glasáil agus leis an spárálaí scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus ag geimhriú in [codladh an chórais](36-system-sleep.md).

### An spárálaí scáileáin

Is ealaín ASCII é spárálaí scáileáin Omarchy a ritheann trí éifeachtaí téacs randamacha, cás amháin in aghaidh an mhonatóra. Fágann aon eochair nó gluaiseacht luiche é.

Is féidir leat é a thosú ar éileamh ó _Córas > Spárálaí Scáileáin_ (`Super + Esc`), a fhórsálann aníos é fiú má tá an spárálaí scáileáin díomhaoin casta as agat. Níl aon aicearra ceangailte leis de réir réamhshocraithe.

Is é `omarchy toggle screensaver` an rud a chasann an ceann díomhaoin as, más fearr leat dul díreach ón obair go dtí glasáilte. Dúnann aon eochair, cliceáil, scrollú nó gluaiseacht luiche é.

Is leat an lógó a tharraingíonn sé a athrú, faoi _Dealramh > Brandáil > Spárálaí Scáileáin_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glasa

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sin an scáileán glasa ó bhlaosc Omarchy, bánann sé an taispeáint, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann ionas nach bhfuil tú ag clóscríobh do phasfhocail san aibítir mícheart, agus — má tá sé ar siúl agat — glasálann sé 1Password ar an mbealach amach.

Glacann an scáileán glasa le pasfhocal, agus glacfaidh sé le méarlorg freisin a luaithe a bheidh ceann socraithe agat. Clúdaítear é sin, agus na bealaí eile chun fíordheimhniú, in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
