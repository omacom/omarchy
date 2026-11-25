# Eochracha Te

Is féidir leat na príomhcheangail mhéarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Mar a leagtar amach eochracha te

Suíonn gach eochair the ar phlána, arna shocrú ag a modhnóirí, agus tá post amháin ag gach plána. Sin a choinníonn na heochracha te ó bheith ag meascadh le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leagan amach, agus príomh-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin am, `Super + Ctrl + Alt + B` ceallraí, `Super + Ctrl + Alt + C` seat scáileáin |

Má chuireann tú `Alt` le heochair the, tugann sé leagan malartach den rud céanna duit, ní rud neamhghaolmhar riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go scáileán iomlán; téann `Super + Alt + F` go lánleithead
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé seat scáileáin

Agus eochair the á cur leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair the atá ann cheana chun spás a dhéanamh. Faigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach le haghaidh leagain mhalartaigh den eochair the gan é.

Briseann cúpla eochair the na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh seatanna scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Space` | Roghchlár Omarchy (aipeanna agus gach rud eile) |
| `Super + Alt + Space` | Greille aipeanna |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosú, srl) |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún fuinneog |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin gach eochair the |
| `Super + Alt + K` | Taispeáin eochracha te tmux |
| `Super + Ctrl + K` | Taispeáin eochracha te herdr |
| `Super + M` | Íoslaghdaigh fuinneog chuig an deic |
| `Super + T` | Scoránaigh fuinneog idir tíliú/snámh |
| `Super + J` | Scoránaigh suíomh fuinneoige (cothrománach/ingearach) |
| `Super + O` | Scoránaigh fuinneog a chur ar snámh go greamaitheach |
| `Super + L` | Rothaigh trí leagan amach dwindle, scrolling, agus floating |
| `Super + Alt + L` | Rothaigh trí na leagan amach ar gcúl |
| `Super + P` | Scoránaigh stíl fuinneoige pseudo (natural v stretch) |
| `Super + F` | Téigh go scáileán iomlán |
| `Super + Alt + F` | Téigh go lánleithead |
| `Super + Ctrl + F` | Téigh go scáileán iomlán taobh istigh den fhuinneog |
| `Super + 1…9/0` | Léim chuig spás oibre ar leith (is é 0 ná 10) ar an monatóir faoi fhócas |
| `Super + Tab` | Léim chuig an gcéad spás oibre eile ar an monatóir faoi fhócas |
| `Super + Shift + Tab` | Léim chuig an spás oibre roimhe ar an monatóir faoi fhócas |
| `Super + Ctrl + Tab` | Léim chuig an spás oibre a bhí ann roimhe ar an monatóir faoi fhócas |
| `Super + Shift + 1…9/0` | Bog fuinneog chuig spás oibre ar an monatóir faoi fhócas |
| `Super + Shift + Alt + 1…9/0` | Bog fuinneog chuig spás oibre ar an monatóir faoi fhócas gan í a leanúint |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog fuinneog chuig an scratchpad iomlán |
| `Super + the key above Tab` (grave on US layouts) | Scoránaigh consól Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Bog fuinneog chuig consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog fuinneog chuig an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog spás oibre chuig an monatóir sa treo sin |
| `Super + Arrow` | Bog fócas chuig fuinneog i dtreo na saighde, ag trasnú chuig an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow` | Malartaigh fuinneog le ceann eile i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
| `Super + Minus` | Leathnaigh fuinneog ar chlé |
| `Super + Equal` | Laghdaigh fuinneog ar chlé |
| `Super + Shift + Minus` | Laghdaigh fuinneog aníos |
| `Super + Shift + Equal` | Leathnaigh fuinneog anuas |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing fuinneog timpeall |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir faoi fhócas |
| `Super + G` | Scoránaigh grúpáil fuinneog |
| `Super + Alt + G` | Bog fuinneog amach as grúpáil |
| `Super + Alt + Tab` | Rothaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + Shift + Tab` | Rothaigh ar gcúl idir fuinneoga sa ghrúpáil |
| `Super + Alt + Scroll Wheel` | Rothaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5` | Léim chuig fuinneog ar leith sa ghrúpáil |
| `Super + Alt + Arrow` | Bog fuinneog isteach sa ghrúpáil i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
| `Super + Ctrl + Left/Right` | Bog idir fuinneoga taobh istigh de ghrúpa tílithe |
| `Super + Ctrl + Z` | Zúmáil isteach ar an scáileán (athdhéan le haghaidh tuilleadh zúmála) |
| `Super + Ctrl + Alt + Z` | Zúmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Rothaigh ar aghaidh trí fuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothaigh ar gcúl trí fuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab` | Rothaigh fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab` | Rothaigh fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh teanga ionchuir (le níos mó ná leagan amach amháin nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh teanga ionchuir ar ais |

Ar thaibhléad tadhaill, athraíonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus taibhléad tadhaill](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann athrú méide an dá eochair ar dheis 0, cibé rud a phriontálann do mhéarchlár orthu: `-` agus `=` ar mhéarchláir US, `+` agus `´` ar Dhanmhairgis agus Sualainnis, `+` agus `\` ar Ioruais, `ß` agus `´` ar Ghearmáinis, `'` agus `¡` ar Spáinnis, agus `-` agus `^` ar Sheapáinis (JIS). Liostaíonn `Super + K` iad mar a phriontálann do mhéarchlár iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`. Úsáideann scálú monatóra agus an bainisteoir pasfhocal `/`; ar leagan amach nach gclóscríobhann `/` ach le Shift, mar a dhéanann an chuid is mó de na cinn Eorpacha, úsáideann siad an eochair ar chlé de Shift deas ina ionad (`-` ar Dhanmhairgis agus Gearmáinis).

## Rialuithe córais

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painéal fuaime |
| `Super + Ctrl + B` | Painéal Bluetooth |
| `Super + Ctrl + N` | Painéal Wifi/líonra |
| `Super + Ctrl + D` | Painéal taispeána |
| `Super + Ctrl + P` | Painéal cumhachta |
| `Super + Ctrl + X` | Painéal oibreán |
| `Super + Ctrl + Alt + D` | Painéal féilire |
| `Super + Ctrl + Alt + E` | Painéal clog domhanda |
| `Super + Ctrl + 1-9` | Scoránaigh painéal an bharra de réir suímh |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (seat scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódaigh meáin |
| `Super + Shift + Ctrl + A` | Tosaigh d'oibreán réamhshocraithe |
| `Power` key | Roghchlár córais |
| `Super + Shift + Copilot` key | Roghchlár Omarchy |

## Coigeartuithe

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile scáileáin |
| `Shift + Brightness Down` | Íosghile scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar ghile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar thoirt |
| `Keyboard Brightness Up/Down` | Soilsiú cúil an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothaigh leibhéil soilsiú cúil an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Soilsiú cúil an mhéarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh aschur fuaime |
| `Touchpad Toggle` | Cas an taibhléad tadhaill air nó as |
| `Display` key | Rothaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad traic eile |
| `Alt + Shift + Play` | An traic roimhe |

## Aipeanna a sheoladh

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Return` | Teirminéal |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir oibreán) |
| `Super + Shift + Return` or `Super + Shift + B` | Brabhsálaí |
| `Super + Shift + Alt + B` | Brabhsálaí (príobháideach/incognito) |
| `Super + Shift + F` | Bainisteoir comhad |
| `Super + Shift + Alt + F` | Bainisteoir comhad i cwd an teirminéil |
| `Super + Shift + M` | Ceol (Spotify) |
| `Super + Shift + Alt + M` | Ceol (cliamp) |
| `Super + Shift + /` | Bainisteoir pasfhocal (1password) |
| `Super + Shift + Q` or `Calculator` key | Áireamhán (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, a luaithe a shuiteáiltear é) |
| `Super + Shift + T` | Gníomhaíocht (btop) |
| `Super + Shift + N` | Eagarthóir (Plain, nó do réamhshocrú roghnaithe) |
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

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + A` | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A` |
| `Super + C` | Cóipeáil |
| `Super + X` | Gearr (ní sa teirminéal) |
| `Super + V` | Greamaigh |
| `Super + Ctrl + V` | Bainisteoir gearrthaisce |

De ghnáth ar Linux, bíonn `Ctrl + Shift + C/V` ag teastáil uait chun cóipeáil'greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha te gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Eochair The | Feidhm |
| ------------------- | ------------------------------ |
| `Print Screen` | Seat scáileáin |
| `Super + Ctrl + Alt + C` | Seat scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen` | Taifeadadh scáileáin |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (buail arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aipe gréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha chuig `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh chun deachtú a dhéanamh (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair the ar dtús cén fhuaim atá uait, ansin tosaíonn sé ag taifeadadh. Buail arís é chun stopadh. Féach [seatanna scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála inrochtana freisin faoi _Trigger > Capture_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh an t-aon chnaipe atá aige, roghnaigh óna roghanna, nó díbh é nuair nach bhfuil aon cheann aige |
| `Super + Shift + ,` | Díbh gach fógra |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár |
| `Super + Alt + ,` | Díbh an fógra is déanaí |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí |
| `Super + Ctrl + Alt + ,` | Scoránaigh fógraí a chur ina dtost |

## Stíl

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnach aon-fhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ i roghchlár Omarchy.

Tá gach rogha stíle inrochtana freisin faoi _Appearance_ i roghchlár Omarchy (`Super + Space`).

## Scoránaithe

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil nuair atá sé díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine air/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach |
| `Shift + Mute` | Athraigh chuig an gcéad aschur fuaime eile |
| `Shift + Play` | Athraigh chuig an gcéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc lánscáileáin (barra uachtarach + bearnaí fuinneog) |

## Meabhrúcháin

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán |

## Fógraí

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra |
| `Super + Ctrl + Alt + B` | Taispeáin an ceallraí mar fhógra |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (`Ctrl + B` oibríonn freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt pána faoina bhun (cothrománach) |
| `Prefix + x` | Maraigh pána |
| `Prefix + z` | Scoránaigh zúmáil pána (lánscáileán) |
| `Alt + Enter` | Scoilt pána faoina bhun (gan réimír) |
| `Alt + Shift + Enter` | Scoilt pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánaí |

### Fuinneoga

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh fuinneog |
| `Prefix + r` | Athainmnigh fuinneog |
| `Alt + 1-9` | Téigh chuig fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog fuinneog ar chlé/ar dheis |

### Seisiúin

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh seisiún |
| `Prefix + R` | Athainmnigh seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh roghnú (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnú (sa mhód cóipeála) |

### Ginearálta

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Pras ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fho-eolaire |
| `tsl <count> <command>` | Cruthaigh leagan amach scata ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty ag baint úsáide as _Install > Terminal_ trí roghchlár Omarchy.

| Eochair The | Feidhm |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua faoina bhun |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Cluaisín nua |
| `Ctrl + Shift + Arrows` | Bog idir cluaisíní |
| `Alt + Numbers` | Téigh chuig cluaisín ar leith |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail nasc sa bhrabhsálaí |

## Bainisteoir Comhad

| Eochair The | Feidhm |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Téigh chuig conair |
| `Space` | Réamhamharc ar chomhad (déanann saigheada nascleanúint) |
| `Alt + Up` | Téigh suas chuig an bhfillteán tuismitheora |

## Neovim (w/ lazyvim)

### Nascleanúint

| Eochair The | Feidhm |
| ------------------------ | ------------------------------- |
| `Space` | Taispeáin roghanna ordaithe |
| `Space Space` | Oscail comhad trí chuardach doiléir |
| `Space E` | Scoránaigh an barra taoibh |
| `Space G G` | Taispeáin rialuithe git |
| `Space S G` | Cuardaigh ábhar comhaid |
| `Ctrl + W W` | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow` | Athraigh méid an bharra taoibh |
| `Shift + H` | Téigh chuig an gcluaisín comhaid ar chlé |
| `Shift + L` | Téigh chuig an gcluaisín comhaid ar dheis |
| `Space B D` | Dún cluaisín comhaid |

### Agus tú sa bharra taoibh

| Eochair The | Feidhm |
| ------------------------ | ------------------------------- |
| `A` | Cuir comhad nua leis san eolaire tuismitheora |
| `Shift + A` | Cuir fo-eolaire nua leis san eolaire tuismitheora |
| `D` | Scrios an comhad/eolaire aibhsithe |
| `M` | Bog an comhad/eolaire aibhsithe |
| `R` | Athainmnigh an comhad/eolaire aibhsithe |
| `?` | Taispeáin cabhair do gach ordú |

[Féach gach eochair the Neovim arna cumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Gasta

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana gasta seo a úsáid.

| Eochair The | EM | Leid |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gáire |
| `Shift + CapsLock M C` | 😂 | gol |
| `Shift + CapsLock M L` | 😍 | grá |
| `Shift + CapsLock M V` | ✌️ | bua |
| `Shift + CapsLock M H` | ❤️ | croí |
| `Shift + CapsLock M Y` | 👍 | tá |
| `Shift + CapsLock M N` | 👎 | níl |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | guí |
| `Shift + CapsLock M R` | 🤘 | rac |
| `Shift + CapsLock M K` | 😘 | póg |
| `Shift + CapsLock M E` | 🙄 | rolladh súl |
| `Shift + CapsLock M I` | 😉 | caochadh |
| `Shift + CapsLock M P` | 🙏 | guí |
| `Shift + CapsLock M D` | 🤤 | seile |
| `Shift + CapsLock M M` | 💰 | airgead |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tósta |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannachadh |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánuithe Gasta

| Eochair The | Comhlánú |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | D'ainm (mar a iontráladh é ag an socrú) |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a iontráladh é ag an socrú) |

Is féidir leat tuilleadh díot féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy restart xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
