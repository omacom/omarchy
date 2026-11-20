# Lascanna, Díomhaointeas & an Spárálaí Scáileáin

A lán de na rudaí a athraíonn tú ó lá go lá, ní socrú ceart é ar chor ar bith. Is mód é a chasann tú air ar feadh uaire agus as arís: solas oíche agus tú ag obair go déanach, ná cuir isteach orm agus tú ag cur i láthair, fan i do dhúiseacht agus tú ag féachaint ar rud éigin. Tugann Omarchy lascanna orthu sin, agus oibríonn siad go léir ar an mbealach céanna — eochair aicearra, iontráil roghchláir, agus ordú, iad go léir ag bualadh an lasc chéanna.

### Roghchlár na lascanna

Osclaíonn `Super + Ctrl + O` _Truicear > Lasc_ go díreach, nó is féidir leat siúl ann ó roghchlár Omarchy (`Super + Space`). Is lasc é gach rud ar an liosta sin is féidir leat a chasadh gan smaoineamh ar cá bhfuil an staid á stóráil. Suíonn lascanna don chuma atá ar an deasc in aice leis, faoi _Dealramh_.

Ón teirminéal, is iad na lascanna céanna ná `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Lasc | Eochair aicearra | Ordú |
| ------ | ------ | ------- |
| Solas oíche | — | `omarchy toggle nightlight` |
| Ciúnaigh fógraí | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúiseacht (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairteála | — | `omarchy toggle crash-capture` |
| Spárálaí scáileáin | — | `omarchy toggle screensaver` |
| Sioncronú téama [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Scáileán tadhaill | — | `omarchy device touchscreen` |
| Cuir ar fionraí | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy toggle hybrid gpu` |

Tá lascanna an cheap tadhaill, an scáileáin tadhaill, agus an GPU hibrideach faoi _Truicear > Crua-earraí_ (`Super + Ctrl + H`) seachas faoi Lasc, mar ní thaispeántar iad ach amháin nuair a bhíonn an crua-earraí sin agat i ndáiríre. Maireann lascanna an cheap tadhaill agus an scáileáin tadhaill tar éis athlódáil Hyprland — sábháiltear ainm an ghléis díchumasaithe i gcomhad beag staide a léann Hyprland ag an am tosaithe chun é a dhíchumasú arís.

Coinníonn _Dealramh_ an barra roghchláir agus na beochanaí, móide cúpla rud nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán na ceallraí sa bharra, leagan amach réamhshocraithe an spáis oibre, agus faoi _Fuinneoga_, bearnaí fuinneog (`Super + Shift + Backspace`) agus an ghné chearnógach 1 fhuinneog (`Super + Ctrl + Backspace`).

Nuair nach bhfuil GPU ag Hyprland chun tarraingt leis agus nuair a rindreálann sé ar an CPU ina áit (llvmpipe), mar atá ar Macanna nach dtacaítear lena GPU go fóill, i bhformhór na meaisíní fíorúla, nó nuair a theipeann ar thiománaí grafaicí lódáil, casann Omarchy beochanaí, doiléireacht agus scáthanna as don seisiún sin agus insíonn sé duit é uair amháin le fógra. Tugann _Dealramh > Beochanaí Ar_ ar ais iad, agus cuimhníonn Omarchy air sin do sheisiúin níos déanaí freisin.

Níl sa chuid is mó díobh seo ach comhad brataí faoi `~/.local/state/omarchy/toggles/`. Más mian leat brainse a dhéanamh ar cheann acu i script, tugann `omarchy-toggle-enabled` cód fágála duit in ionad tú a chur á lorg:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ainmnítear na bratacha don staid as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair a bhíonn mód ar siúl, faigheann tú gliof beag i lár an bharra uachtaraigh in aice leis an gclog. Sin giuirléid na dtáscairí, agus iompraíonn sí deachtú, taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach orm, agus fan i do dhúiseacht.

Bíonn táscairí neamhghníomhacha i bhfolach. Cuir an luchóg os cionn áit ar bith ar an mbarra agus céimníonn siad isteach go doiléir, ionas gur féidir leat cliceáil ar cheann chun é a chasadh air gan a eochair aicearra a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach as arís é. Más fearr leat iad go léir a fheiceáil an t-am ar fad, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` in `~/.config/omarchy/shell.json` — féach [an barra uachtarach](05-the-top-bar.md) chun a fháil amach conas a chumraítear giuirléidí an bharra.

### Solas oíche

Teasaíonn solas oíche an scáileán go 4000K, agus cuireann a chasadh arís ar ais go 6500K é. Cas é ón roghchlár lascanna (`Super + Ctrl + O`) nó le `omarchy toggle nightlight`. Tá sé á thiomáint ag hyprsunset, a thosaíonn an lasc duit mura bhfuil sé ag rith cheana féin.

De réir réamhshocraithe ní dhéanann hyprsunset aon rud ar bith le do scáileán. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl aitheantais go beacht ionas go bhfanann an taispeántas gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a chasadh de réir an chloig, cuir próifíl ama ina áit:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin tosaigh hyprsunset ag an am logála isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an lasc socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach orm

Ciúnaíonn `Super + Ctrl + Alt + ,` fógraí. Ní thagann aon tósta aníos fad a bhíonn sé ar siúl, agus suíonn táscaire an chloig faoi chros sa bharra chun a mheabhrú duit cén fáth ar éirigh an deasc chomh ciúin sin.

Ní chailltear aon rud, áfach. Coinnítear fógraí ciúnaithe siar: cuir na cinn dheireanacha ar ais ar an scáileán le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile.

Tagann dhá chineál teachtaireachta tríd fós: tóstaí deimhnithe Omarchy féin do rud a rinne tú díreach anois ("Téama athraithe", "Seat scáileáin sábháilte"), agus foláirimh chriticiúla a sheoltar ón líne ordaithe. Ní cháilíonn aipeanna comhrá a mharcálann gach rud mar chriticiúil chun a mbealach a bhrú os do chomhair.

### Díomhaointeas

Is leis an mblaosc Omarchy an t-iompar díomhaoin, agus is bloc barrleibhéil `idle` in `~/.config/omarchy/shell.json` iad na huainithe:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Is soicindí an dá uimhir a chomhairtear ón nóiméad a d'éirigh tú díomhaoin — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an spárálaí scáileáin aníos tar éis dhá nóiméad go leith agus glacann an scáileán glasála seilbh ag cúig nóiméad, bíodh an spárálaí scáileáin rite nó ná bíodh. Sábháil an comhad agus glacann an blaosc na huainithe nua láithreach.

Má dhíbríonn tú an spárálaí scáileáin roimh spriocdháta an ghlais, comhairtear sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach thú as sracfhéachaint a thabhairt ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaointeas ar fad, casann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúiseacht air, agus feictear táscaire an chupáin caife sa bharra. Sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mian leat féachaint uirthi. Buail arís é chun dul ar ais go dtí an gnáthrud. Priontálann `omarchy toggle idle status` an staid reatha mar JSON más gá duit é ó script.

Baineann sé seo le glasáil agus leis an spárálaí scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus ag geimhriú in [codladh an chórais](36-system-sleep.md).

### An spárálaí scáileáin

Is ealaín ASCII é spárálaí scáileáin Omarchy ag rith trí éifeachtaí randamacha téacs, aon chás amháin in aghaidh an mhonatóra. Fágann aon eochair nó gluaiseacht luchóige é.

Is féidir leat é a thosú ar éileamh ó _Córas > Spárálaí Scáileáin_ (`Super + Esc`), a chuireann suas é fiú má tá an spárálaí scáileáin díomhaoin casta as agat. Níl aon eochair aicearra ceangailte leis de réir réamhshocraithe.

Is é `omarchy toggle screensaver` a chasann an ceann díomhaoin as, más fearr leat dul díreach ón obair go glasáilte. Dúnann aon eochair, cliceáil, scrollú nó gluaiseacht luchóige é.

Is leatsa an lógó a tharraingíonn sé a athrú, faoi _Dealramh > Brandáil > Spárálaí Scáileáin_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glasála

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sé sin an scáileán glasála ón mblaosc Omarchy, bánann sé an taispeántas, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann ionas nach mbíonn tú ag clóscríobh d'fhocal faire san aibítir mhícheart, agus — má tá sé ar siúl agat — glasálann sé 1Password ar an mbealach amach.

Tógann an scáileán glasála focal faire, agus tógfaidh sé méarlorg freisin nuair a bheidh ceann socraithe agat. Clúdaítear é sin, agus na bealaí eile chun fíordheimhniú a dhéanamh, in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
