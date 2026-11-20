# Eochairghiorruithe

Is féidir leat na príomhcheangail méarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach na heochairghiorruithe

Tá gach eochairghiorrú suite ar phlána, socraithe ag a mhodhnóirí, agus tá jab amháin ag gach plána. Sin a choinníonn na heochairghiorruithe ó bheith ag cumasc le chéile, agus ciallaíonn sé gur féidir leat tomhas a dhéanamh de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` lánscáileán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Trí `Alt` a chur le heochairghiorrú, faigheann tú malairt den rud céanna, ní rud éigin nach bhfuil gaol ar bith aige leis:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` lánscáileán; téann `Super + Alt + F` ar an leithead iomlán
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé gabháil scáileáin

Agus eochairghiorrú á chur leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochairghiorrú atá ann cheana le spás a dhéanamh. Aimsigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach le haghaidh malairte den eochairghiorrú gan é.

Briseann cúpla eochairghiorrú na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó le `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` ar an mbealach a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Space` | Roghchlár Omarchy (aipeanna agus gach rud eile) |
| `Super + Alt + Space` | Greille aipeanna |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosaigh, srl.) |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún an fhuinneog |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin gach eochairghiorrú |
| `Super + Alt + K` | Taispeáin eochairghiorruithe tmux |
| `Super + Ctrl + K` | Taispeáin eochairghiorruithe herdr |
| `Super + M` | Íoslaghdaigh an fhuinneog chuig an doca |
| `Super + T` | Scoránaigh an fhuinneog idir tílíocht/ar snámh |
| `Super + J` | Scoránaigh suíomh na fuinneoige (cothrománach/ingearach) |
| `Super + O` | Scoránaigh an fhuinneog a phreabadh isteach sa mhód greamaitheach 's ar snámh |
| `Super + L` | Rothlaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L` | Rothlaigh trí na leaganacha amach droim ar ais |
| `Super + P` | Scoránaigh stíl na fuinneoige bréige (nádúrtha v síneadh) |
| `Super + F` | Gabh lánscáileán |
| `Super + Alt + F` | Gabh ar an leithead iomlán |
| `Super + Ctrl + F` | Gabh lánscáileán taobh istigh den fhuinneog |
| `Super + 1…9/0` | Léim chuig spás oibre ar leith (is é 0 ná 10) ar an monatóir ar a bhfuil fócas |
| `Super + Tab` | Léim chuig an gcéad spás oibre eile ar an monatóir ar a bhfuil fócas |
| `Super + Shift + Tab` | Léim chuig an spás oibre roimhe ar an monatóir ar a bhfuil fócas |
| `Super + Ctrl + Tab` | Léim chuig an spás oibre a bhí ann roimhe ar an monatóir ar a bhfuil fócas |
| `Super + Shift + 1…9/0` | Bog an fhuinneog chuig spás oibre ar an monatóir ar a bhfuil fócas |
| `Super + Shift + Alt + 1…9/0` | Bog an fhuinneog chuig spás oibre ar an monatóir ar a bhfuil fócas gan í a leanúint |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog an fhuinneog chuig an scratchpad iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog an fhuinneog chuig consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog an fhuinneog chuig an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog an spás oibre chuig an monatóir sa treo sin |
| `Super + Arrow` | Bog an fócas chuig fuinneog i dtreo na saighde, ag trasnú chuig an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow` | Babhtáil fuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh an fhuinneog ar chlé |
| `Super + Equal` | Cúngaigh an fhuinneog ar chlé |
| `Super + Shift + Minus` | Cúngaigh an fhuinneog suas |
| `Super + Shift + Equal` | Leathnaigh an fhuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing an fhuinneog timpeall |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir ar a bhfuil fócas |
| `Super + G` | Scoránaigh grúpáil fuinneog |
| `Super + Alt + G` | Bog an fhuinneog amach as an ngrúpáil |
| `Super + Alt + Tab` | Rothlaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + Shift + Tab` | Rothlaigh ar gcúl idir fuinneoga sa ghrúpáil |
| `Super + Alt + Scroll Wheel` | Rothlaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5` | Léim chuig fuinneog ar leith sa ghrúpáil |
| `Super + Alt + Arrow` | Bog an fhuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right` | Bog idir fuinneoga taobh istigh de ghrúpa tílíochta |
| `Super + Ctrl + Z` | Zúmáil isteach ar an scáileán (arís le haghaidh níos mó zúmaithe) |
| `Super + Ctrl + Alt + Z` | Zúmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe an mhonatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe an mhonatóra |
| `Alt + Tab` | Rothlaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothlaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab` | Rothlaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab` | Rothlaigh an fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh teanga ionchuir (le níos mó ná leagan amach nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh teanga ionchuir ar ais |

Ar cheap tadhaill, aistríonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus ceap tadhaill](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), is cuma cén carachtar atá clóite ar an méarchlár. Ar mhéarchláir US is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is `Super + Equal` é `Super + ^`, agus is `Super + Shift + Minus` é `Super + Shift + -` (a chlóscríobhann `=`).

## Rialuithe córais

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painéal fuaime |
| `Super + Ctrl + B` | Painéal Bluetooth |
| `Super + Ctrl + N` | Painéal Wi-Fi/líonra |
| `Super + Ctrl + D` | Painéal taispeána |
| `Super + Ctrl + P` | Painéal cumhachta |
| `Super + Ctrl + X` | Painéal gníomhairí |
| `Super + Ctrl + Alt + D` | Painéal féilire |
| `Super + Ctrl + Alt + E` | Painéal cloig dhomhanda |
| `Super + Ctrl + 1-9` | Scoránaigh painéal an bharra de réir suímh |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh an roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódáil meán |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |
| `Power` key | Roghchlár córais |
| `Super + Shift + Copilot` key | Roghchlár Omarchy |

## Coigeartuithe

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile an scáileáin |
| `Shift + Brightness Down` | Íosghile an scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar an ngile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar an toirt |
| `Keyboard Brightness Up/Down` | Cúlsholas an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothlaigh leibhéil chúlsholais an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Cúlsholas an mhéarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh an t-aschur fuaime |
| `Touchpad Toggle` | Cas an ceap tadhaill air nó as |
| `Display` key | Rothlaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad rian eile |
| `Alt + Shift + Play` | An rian roimhe |

## Aipeanna a sheoladh

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Return` | Teirminéal |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir gníomhairí) |
| `Super + Shift + Return` or `Super + Shift + B` | Brabhsálaí |
| `Super + Shift + Alt + B` | Brabhsálaí (príobháideach/incognito) |
| `Super + Shift + F` | Bainisteoir comhad |
| `Super + Shift + Alt + F` | Bainisteoir comhad i cwd an teirminéil |
| `Super + Shift + M` | Ceol (Spotify) |
| `Super + Shift + Alt + M` | Ceol (cliamp) |
| `Super + Shift + /` | Bainisteoir pasfhocal (1password) |
| `Super + Shift + Q` or `Calculator` key | Áireamhán (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, nuair a bheidh sé suiteáilte) |
| `Super + Shift + T` | Gníomhaíocht (btop) |
| `Super + Shift + N` | Eagarthóir (Plain, nó an réamhshocrú atá roghnaithe agat) |
| `Super + Shift + C` | Féilire ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Ríomhphost ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Ríomhphost nua ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Teachtaire (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Teachtaire (WhatsApp) |
| `Super + Shift + Ctrl + G` | Teachtaire (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Scríbhneoireacht (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (postáil nua) |
| `Super + Shift + Y` | YouTube |

Athraigh/cuir ceangail leis in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + A` | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A` |
| `Super + C` | Cóipeáil |
| `Super + X` | Gearr (ní sa teirminéal) |
| `Super + V` | Greamaigh |
| `Super + Ctrl + V` | Bainisteoir gearrthaisce |

De ghnáth ar Linux, bíonn `Ctrl + Shift + C/V` ag teastáil uait chun cóipeáil 's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochairghiorruithe aontaithe gearrthaisce Omarchy seo i ngach áit.

## Gabháil

| Eochairghiorrú | Feidhm |
| ------------------- | ------------------------------ |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin (an seat céanna, le haghaidh méarchlár gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen` | Taifeadadh scáileáin |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (buail arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aip ghréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha chuig `~/Videos` |
| `Alt + Space` | Tosaigh/stad an deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh síos chun deachtú (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an eochairghiorrú ar dtús cén fhuaim atá uait, ansin tosaíonn sé ag taifeadadh. Buail arís é chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála inrochtana freisin faoi _Trigger > Capture_ sa roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhú ar an bhfógra is déanaí: é a oscailt nó a aon chnaipe amháin a bhrú, roghnú óna roghanna, nó é a chaitheamh amach nuair nach bhfuil ceann ar bith aige |
| `Super + Shift + ,` | Caitheadh amach gach fógra |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár |
| `Super + Alt + ,` | Caitheadh amach an fógra is déanaí |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí |
| `Super + Ctrl + Alt + ,` | Scoránaigh tostú na bhfógraí |

## Stíl

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh cóimheas cearnógach aonfhuinneoige |

Tá íomhánna cúlra breise ina gcónaí in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ sa roghchlár Omarchy.

Tá gach rogha stíle inrochtana freisin faoi _Appearance_ sa roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil nuair atá sé díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine air/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach |
| `Shift + Mute` | Athraigh chuig an gcéad aschur fuaime eile |
| `Shift + Play` | Athraigh chuig an gcéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc lánscáileáin (an barra uachtarach + bearnaí fuinneog) |

## Meabhrúcháin

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán |

## Fógraí faisnéise

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra |
| `Super + Ctrl + Alt + B` | Taispeáin an ceallra mar fhógra |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra |

## Tmux

Is é `Ctrl + Space` an eochair réimire (`Ctrl + B` a oibríonn freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt an pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt an pána thíos (cothrománach) |
| `Prefix + x` | Maraigh an pána |
| `Prefix + z` | Scoránaigh zúmáil an phána (lánscáileán) |
| `Alt + Enter` | Scoilt an pána thíos (gan réimir) |
| `Alt + Shift + Enter` | Scoilt an pána in aice leis (gan réimir) |
| `Alt + Escape` | Maraigh an pána (gan réimir) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánaí |

### Fuinneoga

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh an fhuinneog |
| `Prefix + r` | Athainmnigh an fhuinneog |
| `Alt + 1-9` | Gabh chuig fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog an fhuinneog ar chlé/ar dheis |

### Seisiúin

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh an seisiún |
| `Prefix + R` | Athainmnigh an seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh na seisiúin |
| `Prefix + d` | Dícheangail ón seisiún |

### Mód cóipeála (stíl vi)

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh an roghnú (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnú (sa mhód cóipeála) |

### Ginearálta

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail méarchláir Tmux |
| `Prefix + :` | Pras ordaithe |

### Feidhmeanna leagan amach Tmux

Caithfear na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fhochomhadlann |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Tá teirminéal Ghostty suiteáilte ag úsáid _Install > Terminal_ tríd an roghchlár Omarchy.

| Eochairghiorrú | Feidhm |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Táb nua |
| `Ctrl + Shift + Arrows` | Bog idir tábanna |
| `Alt + Numbers` | Gabh chuig táb ar leith |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail an nasc sa brabhsálaí |

## Bainisteoir Comhad

| Eochairghiorrú | Feidhm |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Gabh chuig an gconair |
| `Space` | Réamhamharc ar an gcomhad (déanann na saigheada nascleanúint) |
| `Alt + Up` | Gabh suas chuig an bhfillteán tuismitheora |

## Neovim (le lazyvim)

### Nascleanúint

| Eochairghiorrú | Feidhm |
| ------------------------ | ------------------------------- |
| `Space` | Taispeáin roghanna ordaithe |
| `Space Space` | Oscail comhad trí chuardach doiléir |
| `Space E` | Scoránaigh an barra taoibh |
| `Space G G` | Taispeáin rialuithe git |
| `Space S G` | Cuardaigh ábhar an chomhaid |
| `Ctrl + W W` | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow` | Athraigh méid an bharra taoibh |
| `Shift + H` | Gabh chuig an táb comhaid ar chlé |
| `Shift + L` | Gabh chuig an táb comhaid ar dheis |
| `Space B D` | Dún an táb comhaid |

### Agus tú sa bharra taoibh

| Eochairghiorrú | Feidhm |
| ------------------------ | ------------------------------- |
| `A` | Cuir comhad nua leis sa chomhadlann tuismitheora |
| `Shift + A` | Cuir fochomhadlann nua leis sa chomhadlann tuismitheora |
| `D` | Scrios an comhad/comhadlann aibhsithe |
| `M` | Bog an comhad/comhadlann aibhsithe |
| `R` | Athainmnigh an comhad/comhadlann aibhsithe |
| `?` | Taispeáin cabhair le haghaidh gach ordaithe |

[Féach na heochairghiorruithe Neovim go léir atá cumraithe ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Gasta

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an rogha ar an ngearrthaisce nó is féidir leat na roghanna rochtana gasta seo a úsáid.

| Eochairghiorrú | EM | Leid |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gáire |
| `Shift + CapsLock M C` | 😂 | gol |
| `Shift + CapsLock M L` | 😍 | grá |
| `Shift + CapsLock M V` | ✌️ | bua |
| `Shift + CapsLock M H` | ❤️ | croí |
| `Shift + CapsLock M Y` | 👍 | tá |
| `Shift + CapsLock M N` | 👎 | níl |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | mian |
| `Shift + CapsLock M R` | 🤘 | rac |
| `Shift + CapsLock M K` | 😘 | póg |
| `Shift + CapsLock M E` | 🙄 | rolladh súl |
| `Shift + CapsLock M I` | 😉 | caochadh |
| `Shift + CapsLock M P` | 🙏 | guí |
| `Shift + CapsLock M D` | 🤤 | drúil |
| `Shift + CapsLock M M` | 💰 | airgead |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tósta |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánaithe Gasta

| Eochairghiorrú | Comhlánú |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | D'ainm (mar a iontráladh é ag an socrú) |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a iontráladh é ag an socrú) |

Is féidir leat tuilleadh de do chuid féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy restart xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
