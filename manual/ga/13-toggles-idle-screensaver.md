# Scoráin, Díomhaoin & an Coigilteoir Scáileáin

Ní socrú i ndáiríre é go leor den mhéid a athraíonn tú ó lá go lá. Is mód é a chasann tú air ar feadh uair an chloig agus as arís: solas oíche fad is atá tú ag obair go déanach, ná cuir isteach fad is atá tú ag cur i láthair, fan i do dhúis fad is atá tú ag féachaint ar rud éigin. Tugann Omarchy scoráin orthu sin, agus oibríonn siad ar fad ar an mbealach céanna — eochair ghasta, iontráil roghchláir, agus ordú, ar fad ag bualadh an lasc chéanna.

### Roghchlár na scorán

Osclaíonn `Super + Ctrl + O` _Spreag > Scoránaigh_ go díreach, nó is féidir leat siúl ann ó roghchlár Omarchy (`Super + Space`). Is lasc é gach rud sa liosta sin is féidir leat a chasadh gan smaoineamh ar an áit a bhfuil an stát. Suíonn lasca maidir le cuma na deisce in aice leis, faoi _Spreag > Cuma_.

Ón teirminéal, is iad na lasca céanna ná `omarchy toggle <thing>`. Rith `omarchy toggle` leis féin chun an grúpa ar fad a fheiceáil.

| Scorán | Eochair ghasta | Ordú |
| ------ | ------ | ------- |
| Solas oíche | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Ciúnaigh fógraí | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Fan i do dhúis (gan glas díomhaoin) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Gabháil tuairte | — | `omarchy toggle crash-capture` |
| Coigilteoir scáileáin | — | `omarchy toggle screensaver` |
| Sionc téama [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra roghchláir | `Super + Shift + Space` | `omarchy toggle bar` |
| Ceap tadhaill | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Scáileán tadhaill | — | `omarchy toggle touchscreen` |
| Cuir ar fionraí | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Tá lasca an cheap tadhaill, an scáileáin tadhaill, agus Hybrid GPU faoi _Spreag > Crua-earraí_ (`Super + Ctrl + H`) seachas faoi Scoránaigh, mar ní thaispeántar iad ach nuair a bhíonn na crua-earraí sin agat i ndáiríre. Maireann na cinn cheap tadhaill agus scáileáin tadhaill athlódáil Hyprland — sábháiltear ainm an ghléis dhíchumasaithe chuig comhad stáit beag a léann Hyprland ag am tosaithe chun é a dhíchumasú arís.

Coinníonn _Spreag > Cuma_ barra an roghchláir agus na beochana, móide cúpla rud nach orduithe `omarchy toggle` iad ach a iompraíonn ar an mbealach céanna: céatadán ceallra sa bharra, leagan amach réamhshocraithe an spáis oibre, bearnaí fuinneoige (`Super + Shift + Backspace`), agus gné chearnógach 1-fhuinneoige (`Super + Ctrl + Backspace`).

Ní fíor ach comhad brataí faoi `~/.local/state/omarchy/toggles/` an chuid is mó díobh seo. Más mian leat brainse a dhéanamh ar cheann i script, tugann `omarchy-toggle-enabled` cód imeachta duit in ionad tú a chur ag lorg:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Tá na bratacha ainmnithe don stát as — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ciallaíonn a láithreacht go bhfuil an ghné díchumasaithe.

### Táscairí sa bharra

Nuair a bhíonn mód air, faigheann tú glif beag i lár an bharra bharr in aice leis an gclog. Sin giuirléid na dtáscairí, agus iompraíonn sí deachtú, taifeadadh scáileáin, meabhrúcháin ar feitheamh, solas oíche, ná cuir isteach, agus fan i do dhúis.

Tá táscairí neamhghníomhacha i bhfolach. Hover an limistéar timpeall orthu agus maolaíonn siad isteach, mar sin is féidir leat ceann a chliceáil chun é a chur air gan a eochair ghasta a bheith ar eolas agat. Casann cliceáil ar cheann gníomhach é as arís. Más fearr leat iad uile a fheiceáil i gcónaí, socraigh `alwaysShow` go `true` ar an iontráil `omarchy.indicators` i `~/.config/omarchy/shell.json` — féach [an barra barr](05-the-top-bar.md) maidir le conas a chumraítear giuirléidí barra.

### Solas oíche

Téann `Super + Ctrl + N` an scáileán go 4000K, agus cuireann é a bhualadh arís ar ais go 6500K é. Tá sé á thiomáint ag hyprsunset, a thosaíonn an scorán duit mura bhfuil sé ag rith cheana.

De réir réamhshocraithe ní dhéanann hyprsunset rud ar bith le do scáileán ar chor ar bith. Tagann `~/.config/hypr/hyprsunset.conf` le próifíl chéannachta go beacht mar sin fanann an taispeáint gan teagmháil go dtí go n-iarrann tú teas. Más fearr leat é a athrú de réir an chloig, cuir próifíl ama ina áit sin:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Ansin tosaigh hyprsunset ag logáil isteach trí `o.launch_on_start("hyprsunset")` a chur le `~/.config/hypr/autostart.lua`. Tá an péire 4000K/6500K a úsáideann an scorán socraithe, mar sin is é an comhad cumraíochta an áit a dtéann tú más mian leat teocht dhifriúil.

### Ná cuir isteach

Ciúnaíonn `Super + Ctrl + ,` fógraí. Ní thaispeántar tóstaí fad is atá sé air, agus suíonn táscaire an chloig scriosta sa bharra chun a mheabhrú duit cén fáth a bhfuil an deasc ciúin.

Ní chailltear rud ar bith, áfach. Scríobhtar fógra ciúnaithe go díreach isteach i do stair fógraí, arb é go beacht an taifead atá uait nuair a thagann tú ar ais agus a smaoiníonn tú cad a chaill tú. Oscail é le `Super + Shift + Alt + ,`. Féach [fógraí](10-notices.md) don chuid eile de scéal na bhfógraí.

Tagann dhá chineál teachtaireachta tríd fós: tóstaí deimhnithe Omarchy féin do rud éigin a rinne tú díreach ("Theme changed", "Screenshot saved"), agus foláirimh chriticiúla a sheoltar ón líne ordaithe. Ní cháilíonn aipeanna comhrá a mharcálann gach rud criticiúil chun a mbealach a bhrú os do chomhair.

### Díomhaoin

Is le blaosc Omarchy iompar díomhaoin, agus is bloc `idle` ar an leibhéal is airde iad na huainíochtaí i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Is soicindí a chomhairtear ón nóiméad a chuaigh tú díomhaoin an dá uimhir — ní óna chéile. Mar sin leis na réamhshocruithe, tagann an coigilteoir scáileáin suas tar éis dhá nóiméad go leith agus glacann an scáileán glasa seilbh ag cúig nóiméad, cibé acu a rith an coigilteoir scáileáin nó nár rith. Sábháil an comhad agus glacann an bhlaosc na huainíochtaí nua láithreach.

Má dhíbheann tú an coigilteoir scáileáin roimh spriocdháta an ghlasa, áirítear é sin mar ghníomhaíocht agus cealaítear an glas ar feitheamh. Ní ghlasáiltear amach thú as súil a chaitheamh ar do mheaisín.

Chun stop a chur le glasáil ar dhíomhaoin go hiomlán, cuireann `Super + Ctrl + I` — nó `omarchy toggle idle` — fan i do dhúis air, agus taispeántar táscaire cupáin caife sa bharra. Sin an ceann le bualadh roimh chur i láthair fada nó tógáil ar mhaith leat féachaint air. Buail arís é chun dul ar ais go gnáth. Priontálann `omarchy toggle idle status` an stát reatha mar JSON má theastaíonn sé uait ó script.

Baineann sé seo le glasáil agus leis an gcoigilteoir scáileáin, ní le cumhacht. Tá a socrú féin ag fionraí agus geimhriú i [codladh córais](36-system-sleep.md).

### An coigilteoir scáileáin

Is ealaín ASCII é coigilteoir scáileáin Omarchy ag rith trí éifeachtaí téacs randamacha, sampla amháin in aghaidh an mhonatóra. Imíonn aon eochair nó gluaiseacht luiche as.

Is féidir leat é a thosú ar éileamh ó _Córas > Coigilteoir scáileáin_ (`Super + Esc`), a chuireann iachall air suas fiú má mhúch tú an coigilteoir scáileáin díomhaoin. Níl eochair ghasta ceangailte leis de réir réamhshocraithe.

Is é `omarchy toggle screensaver` an méid a mhúchann an ceann díomhaoin, más fearr leat dul go díreach ó bheith ag obair go bheith glasáilte. Teastaíonn teirminéal uaidh a bhfuil a fhios aige conas a chumrú — Alacritty, Foot, Ghostty, nó Kitty — agus inseoidh sé duit amhlaidh más rud éigin eile é do theirminéal réamhshocraithe.

Is leatsa an lógó a tharraingíonn sé a athrú, faoi _Stíl > Coigilteoir scáileáin_. Uaslódáil png nó svg agus tiontaíonn Omarchy go ASCII é. Féach [brandáil](41-branding.md).

### An scáileán glasa

Glasálann `Super + Ctrl + L` an meaisín. Ritheann sé sin an scáileán glasa ó bhlaosc Omarchy, bánann sé an taispeáint, athshocraíonn sé leagan amach do mhéarchláir go dtí an chéad cheann mar sin ní bhíonn tú ag clóscríobh do phasfhocail san aibítir mícheart, agus — má tá sé ag rith agat — glasálann sé 1Password ar an mbealach amach.

Glacann an scáileán glasa le pasfhocal, agus glacfaidh sé le méarlorg freisin nuair a bheidh ceann socraithe agat. Clúdaítear é sin, agus na slite eile chun fíordheimhniú, in [fíordheimhniú crua-earraí](37-hardware-authentication.md).
