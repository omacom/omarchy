# Lasca Scoránaithe, Díomhaointeas & an Spárálaí Scáileáin

Ní socrú i ndáiríre é cuid mhór den mhéid a athraíonn tú ó lá go lá. Is mód é a chasann tú air ar feadh uaire agus as arís: solas oíche agus tú ag obair go déanach, ná cuir isteach agus tú i mbun cur i láthair, fan i do dhúiseacht agus tú ag féachaint ar rud éigin. Tugann Omarchy lasca scoránaithe orthu sin, agus oibríonn siad go léir ar an mbealach céanna — eochair aicearra, iontráil roghchláir, agus ordú, iad go léir ag bualadh na lasc céanna.

### An roghchlár scoránaithe

Osclaíonn `Super + Ctrl + O` _Spreagadh > Scorán_ go díreach, nó is féidir leat siúl ann ón roghchlár Omarchy (`Super + Space`). Lasc is ea gach rud ar an liosta sin ar féidir leat í a chasadh gan smaoineamh ar cá bhfuil an staid á stóráil. Suíonn lasca don chaoi a bhfuil cuma ar an deasc in aice leis, faoi _Cuma_.

Ón teirminéal, is iad na lasca céanna ná `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Scorán | Eochair Aicearra | Ordú |
| ------ | ------ | ------- |
| Solas oíche | — | `omarchy toggle nightlight` |
| Fógraí a thostú | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúiseacht (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairte | — | `omarchy toggle crash-capture` |
| Spárálaí scáileáin | — | `omarchy toggle screensaver` |
| Sioncrónú téama [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Scáileán tadhaill | — | `omarchy toggle touchscreen` |
| Fionraí | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy toggle hybrid gpu` |

Cónaíonn lasca an cheap tadhaill, an scáileáin tadhaill, agus an GPU hibridigh faoi _Spreagadh > Crua-earraí_ (`Super + Ctrl + H`) seachas faoi Scorán, mar nach dtaispeántar iad ach amháin nuair a bhíonn na crua-earraí sin agat i ndáiríre. Maireann lasca an cheap tadhaill agus an scáileáin tadhaill tar éis athlódáil Hyprland — sábháiltear ainm an ghléis díchumasaithe i gcomhad beag staide a léann Hyprland ag an am tosaithe chun é a dhíchumasú arís.

Coinníonn _Cuma_ an barra roghchláir agus beochan, móide cúpla rud nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán na ceallra sa bharra, leagan amach réamhshocraithe an spáis oibre, agus faoi _Windows_, bearnaí fuinneoige (`Super + Shift + Backspace`) agus gné chearnógach 1 fhuinneog (`Super + Ctrl + Backspace`).

Nuair nach bhfuil aon GPU ag Hyprland chun tarraingt leis agus nuair a rindreálann sé ar an CPU ina áit (llvmpipe), mar atá ar ríomhairí Mac nach dtacaítear lena GPU go fóill, sa chuid is mó de na meaisíní fíorúla, nó nuair a theipeann ar thiománaí grafaice lódáil, casann Omarchy beochan, doiléire agus scáthanna as don seisiún sin agus insíonn sé duit é uair amháin le fógra. Tugann _Cuma > Beochan Air_ ar ais iad, agus cuimhníonn Omarchy air sin do sheisiúin níos déanaí freisin.

Níl sa chuid is mó díobh seo ach comhad brataí faoi `~/.local/state/omarchy/toggles/`. Más mian leat brainse a dhéanamh ar cheann acu i script, tugann `omarchy-toggle-enabled` cód fágála duit in ionad tú a chur á chuardach:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Ainmnítear na bratacha don staid as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair a bhíonn mód air, faigheann tú gliof beag i lár an bharra uachtair in aice leis an gclog. Is é sin an ghiuirléid táscairí, agus iompraíonn sí deachtú, taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach, agus fan i do dhúiseacht.

Bíonn táscairí neamhghníomhacha i bhfolach. Cuir an pointeoir os cionn áit ar bith ar an mbarra agus céimníonn siad isteach maolaithe, ionas gur féidir leat ceann a chliceáil chun é a chasadh air gan a eochair aicearra a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach as arís é. Más fearr leat iad go léir a fheiceáil an t-am ar fad, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` in `~/.config/omarchy/shell.json` — féach [an barra barr](05-the-top-bar.md) chun a fháil amach conas a chumraítear giuirléidí an bharra.

### Solas oíche

Téann solas oíche an scáileán go 4000K, agus cuireann scoránú arís ar ais go 6500K é. Cas é ón roghchlár scoránaithe (`Super + Ctrl + O`) nó le `omarchy toggle nightlight`. Tiomáintear é le hyprsunset, a thosaíonn an scorán duit mura bhfuil sé ar siúl cheana.

De réir réamhshocraithe ní dhéanann hyprsunset aon rud ar bith le do scáileán. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl chéannachta go beacht ionas go bhfanann an taispeántas gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a athrú de réir an chloig, cuir próifíl ama ina áit:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin cuir tús le hyprsunset ag logáil isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an scorán socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach

Tostaíonn `Super + Ctrl + Alt + ,` fógraí. Ní thagann aon tósta aníos fad a bhíonn sé air, agus suíonn an táscaire cloig le líne thairis sa bharra chun a mheabhrú duit cén fáth ar tháinig tost ar an deasc.

Ní chailltear aon rud, áfach. Coimeádtar fógraí tostaithe siar: cuir na cinn dheireanacha ar ais ar an scáileán le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile.

Tagann dhá chineál teachtaireachta tríd i gcónaí: tóstaí deimhnithe Omarchy féin do rud a rinne tú díreach ("Athraíodh an téama", "Sábháladh an seat scáileáin"), agus foláirimh chriticiúla a seoltar ón líne ordaithe. Ní cháilíonn aipeanna comhrá a mharcálann gach rud criticiúil chun a mbealach a bhrú os do chomhair.

### Díomhaointeas

Is leis an mblaosc Omarchy iompraíocht dhíomhaoin, agus is bloc barrleibhéil `idle` in `~/.config/omarchy/shell.json` iad na hamanna:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Soicindí atá sa dá uimhir arna gcomhaireamh ón nóiméad a d'éirigh tú díomhaoin — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an spárálaí scáileáin aníos tar éis dhá nóiméad go leith agus glacann an scáileán glais seilbh ag cúig nóiméad, cibé acu ar rith an spárálaí scáileáin nó nár rith. Sábháil an comhad agus glacann an bhlaosc na hamanna nua láithreach.

Má dhíbhíonn tú an spárálaí scáileáin roimh an spriocdháta glais, áirítear sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach thú as sracfhéachaint a thabhairt ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaointeas ar fad, casann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúiseacht air, agus feictear táscaire an chupáin caife sa bharra. Sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mian leat féachaint uirthi. Buail arís é chun dul ar ais go gnáth. Clónn `omarchy toggle idle status` an staid reatha mar JSON más gá duit é ó script.

Baineann sé seo le glasáil agus leis an spárálaí scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus ag geimhriú in [codladh an chórais](36-system-sleep.md).

### An spárálaí scáileáin

Ealaín ASCII is ea spárálaí scáileáin Omarchy ar siúl trí éifeachtaí randamacha téacs, aon chás amháin in aghaidh an mhonatóra. Fágann aon eochair nó gluaiseacht luiche é.

Is féidir leat é a thosú ar éileamh ó _Córas > Spárálaí Scáileáin_ (`Super + Esc`), a fhórsálann aníos é fiú má tá an spárálaí scáileáin díomhaoin casta as agat. Níl aon eochair aicearra ceangailte leis de réir réamhshocraithe.

Is é `omarchy toggle screensaver` a chasann an ceann díomhaoin as, más fearr leat dul díreach ó bheith ag obair go bheith faoi ghlas. Dúnann aon eochair, cliceáil, scrolláil nó gluaiseacht luiche é.

Is leatsa an lógó a tharraingíonn sé a athrú, faoi _Cuma > Brandáil > Spárálaí Scáileáin_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glais

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sé sin an scáileán glais ón mblaosc Omarchy, bánann sé an taispeántas, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann ionas nach bhfuil tú ag clóscríobh do phasfhocail san aibítir mhícheart, agus — má tá sé ar siúl agat — glasálann sé 1Password ar an mbealach amach.

Glacann an scáileán glais le pasfhocal, agus glacfaidh sé le méarlorg freisin a luaithe a bheidh ceann socraithe agat. Clúdaítear é sin, agus na bealaí eile chun fíordheimhniú, in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
