# Eochracha Teo

Is féidir leat na príomhcheangail méarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach eochracha teo

Suíonn gach eochair the ar phlána, arna shocrú ag a modhnóirí, agus tá jab amháin ag gach plána. Sin a choinníonn na heochracha teo ó bheith ag meascadh le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` lánscáileán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha tapa agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Tugann `Alt` a chur le heochair the malairt den rud céanna duit, ní rud éigin neamhghaolmhar riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go lánscáileán; téann `Super + Alt + F` go lánleithead
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé gabháil scáileáin

Agus eochair the á cur leis:

1. Roghnaigh an plána ón méid a dhéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair the atá ann cheana chun spás a dhéanamh. Faigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach amháin le haghaidh malairt den eochair the gan é.

Briseann cúpla eochair the na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Eisceachtaí atá iontu, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Eangach aipeanna |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosú, srl)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún an fhuinneog             |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin gach eochair the |
| `Super + Alt + K` | Taispeáin eochracha teo tmux |
| `Super + Ctrl + K` | Taispeáin eochracha teo herdr |
| `Super + M` | Íoslaghdaigh an fhuinneog go dtí an duga |
| `Super + T`               | Scoránaigh an fhuinneog idir tíliú/ar snámh             |
| `Super + J` | Scoránaigh suíomh na fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh an fhuinneog a phreabadh isteach i sticky'n'floating |
| `Super + L`               | Timthriallaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L`         | Timthriallaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl bhréagfhuinneoige (nádúrtha vs síneadh) |
| `Super + F`                 | Téigh go lánscáileán              |
| `Super + Alt + F`                 | Téigh go lánleithead              |
| `Super + Ctrl + F`                 | Téigh go lánscáileán laistigh den fhuinneog              |
| `Super + 1…9/0`         | Léim go spás oibre ar leith (is é 0 ná 10) ar an monatóir ar a bhfuil an fócas |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir ar a bhfuil an fócas |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe ar an monatóir ar a bhfuil an fócas |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir ar a bhfuil an fócas |
| `Super + Shift + 1…9/0` | Bog an fhuinneog go spás oibre ar an monatóir ar a bhfuil an fócas |
| `Super + Shift + Alt + 1…9/0` | Bog an fhuinneog go spás oibre ar an monatóir ar a bhfuil an fócas gan leanúint |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog an fhuinneog go dtí an scratchpad iomlán |
| `Super + the key above Tab` (grave on US layouts) | Scoránaigh consól Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Bog an fhuinneog go consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog an fhuinneog go dtí an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog an spás oibre go dtí an monatóir sa treo sin |
| `Super + Arrow`  | Bog an fócas go fuinneog i dtreo na saighde, ag trasnú go dtí an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow`  | Malartaigh an fhuinneog le ceann eile i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
| `Super + Minus` | Leathnaigh an fhuinneog ar chlé |
| `Super + Equal` | Crap an fhuinneog ar chlé |
| `Super + Shift + Minus` | Crap an fhuinneog suas |
| `Super + Shift + Equal` | Leathnaigh an fhuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing an fhuinneog thart |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir ar a bhfuil an fócas |
| `Super + G`               | Scoránaigh grúpáil fuinneog      |
| `Super + Alt + G`               | Bog an fhuinneog amach as an ngrúpáil      |
| `Super + Alt + Tab`               | Timthriallaigh idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Shift + Tab`               | Timthriallaigh ar gcúl idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Scroll Wheel` | Timthriallaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog ar leith sa ghrúpáil      |
| `Super + Alt + Arrow`  | Bog an fhuinneog isteach sa ghrúpáil i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga laistigh de ghrúpa tílithe |
| `Super + Ctrl + Z` | Súmáil isteach ar an scáileán (déan arís é le haghaidh tuilleadh súmála) |
| `Super + Ctrl + Alt + Z` | Súmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Timthriallaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Timthriallaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Timthriallaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Timthriallaigh an fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh teanga ionchuir (le níos mó ná leagan amach nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh teanga ionchuir ar ais |

Ar thadhaillín, aistríonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus tadhaillín](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann athrú méide an dá eochair ar dheis ó 0, cibé rud a phriontálann do mhéarchlár orthu: `-` agus `=` ar mhéarchláir US, `+` agus `´` ar an Danmhairgis agus ar an tSualainnis, `+` agus `\` ar an Ioruais, `ß` agus `´` ar an nGearmáinis, `'` agus `¡` ar an Spáinnis, agus `-` agus `^` ar an tSeapáinis (JIS). Liostaíonn `Super + K` iad mar a phriontálann do mhéarchlár iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`. Úsáideann scálú monatóra agus an bainisteoir pasfhocal `/`; ar leaganacha amach nach gclóscríobhann `/` ach le Shift, mar a dhéanann an chuid is mó de na cinn Eorpacha, úsáideann siad an eochair ar chlé ó Shift ar dheis ina ionad (`-` ar an Danmhairgis agus ar an nGearmáinis).

## Rialuithe córais

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painéal fuaime    |
| `Super + Ctrl + B`           | Painéal Bluetooth    |
| `Super + Ctrl + N`           | Painéal Wi-Fi/líonra    |
| `Super + Ctrl + D`           | Painéal taispeána    |
| `Super + Ctrl + P`           | Painéal cumhachta    |
| `Super + Ctrl + X`           | Painéal gníomhairí    |
| `Super + Ctrl + Alt + D`           | Painéal féilire    |
| `Super + Ctrl + Alt + E`           | Painéal cloig dhomhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal an bharra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh an roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódáil meáin |
| `Super + Shift + Ctrl + A` | Cuir tús le do ghníomhaire réamhshocraithe |
| `Power` key | Roghchlár córais |
| `Super + Shift + Copilot` key | Roghchlár Omarchy |

## Coigeartuithe

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile scáileáin |
| `Shift + Brightness Down` | Íosghile scáileáin |
| `Alt + Brightness Up/Down` | Athruithe gile beachta 1% |
| `Alt + Volume Up/Down` | Athruithe toirte beachta 1% |
| `Keyboard Brightness Up/Down` | Cúlsholas méarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Timthriallaigh leibhéil chúlsholais an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Cúlsholas méarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh an t-aschur fuaime |
| `Touchpad Toggle` | Cuir an tadhaillín ar siúl nó as |
| `Display` key | Timthriallaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad rian eile |
| `Alt + Shift + Play` | An rian roimhe |

## Aipeanna a sheoladh

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Return`           | Teirminéal    |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir gníomhairí) |
| `Super + Shift + Return` or `Super + Shift + B`  | Brabhsálaí    |
| `Super + Shift + Alt + B`           | Brabhsálaí (príobháideach/incognito)    |
| `Super + Shift + F`           | Bainisteoir comhad    |
| `Super + Shift + Alt + F`           | Bainisteoir comhad i cwd an teirminéil    |
| `Super + Shift + M`           | Ceol (Spotify)    |
| `Super + Shift + Alt + M`           | Ceol (cliamp)    |
| `Super + Shift + /`           | Bainisteoir pasfhocal (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Áireamhán (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, nuair atá sé suiteáilte)    |
| `Super + Shift + T`           | Gníomhaíocht (btop)    |
| `Super + Shift + N`           | Eagarthóir (Plain, nó an réamhshocrú atá roghnaithe agat)  |
| `Super + Shift + C`           | Féilire ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Ríomhphost ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ríomhphost nua ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Do ghníomhaire réamhshocraithe, nó ChatGPT go dtí go roghnaíonn tú ceann |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Teachtaire (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Teachtaire (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Teachtaire (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Scríbhneoireacht (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (postáil nua) |
| `Super + Shift + Y`           | YouTube |

Athraigh/cuir ceangail leis in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + A`           | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A`    |
| `Super + C`           | Cóipeáil    |
| `Super + X`           | Gearr (ní sa teirminéal é)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha teo gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Eochair The              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Gabháil scáileáin                      |
| `Super + Ctrl + Alt + C`            | Gabháil scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (brúigh arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs go dtí an ghearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aip ghréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha go `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh síos chun deachtú a dhéanamh (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair the ar dtús cén fhuaim atá uait, ansin tosaíonn sí ag taifeadadh. Brúigh arís í chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála inrochtana freisin faoi _Trigger > Capture_ sa roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh a aon chnaipe amháin, roghnaigh óna roghanna, nó dímheas é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Dímheas gach fógra |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár  |
| `Super + Alt + ,` | Dímheas an fógra is déanaí  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh fógraí a thostú  |

## Stíl

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh cóimheas cearnógach aonfhuinneoige |

Tá íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ sa roghchlár Omarchy.

Tá gach rogha stíle inrochtana freisin faoi _Appearance_ sa roghchlár Omarchy (`Super + Space`).

## Scoráin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil nuair atá sé díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine ar siúl/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc lánscáileáin (barra uachtarach + bearnaí fuinneog) |

## Meabhrúcháin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán  |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán  |

## Fógraí faisnéise

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin an ceallra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra  |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánna

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt an pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt an pána thíos (cothrománach) |
| `Prefix + x` | Maraigh an pána |
| `Prefix + z` | Scoránaigh súmáil pána (lánscáileán) |
| `Alt + Enter` | Scoilt an pána thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt an pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh an pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánna |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánna |

### Fuinneoga

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh an fhuinneog |
| `Prefix + r` | Athainmnigh an fhuinneog |
| `Alt + 1-9` | Téigh go fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog an fhuinneog ar chlé/ar dheis |

### Seisiúin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh an seisiún |
| `Prefix + R` | Athainmnigh an seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh an roghnú (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnú (sa mhód cóipeála) |

### Ginearálta

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Leideadh ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith laistigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha de réir foeolaire |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty trí _Install > Terminal_ a úsáid tríd an roghchlár Omarchy.

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Cluaisín nua  |
| `Ctrl + Shift + Arrows` | Bog idir cluaisíní |
| `Alt + Numbers` | Téigh go cluaisín ar leith |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail an nasc sa bhrabhsálaí |

## Bainisteoir Comhad

| Eochair The              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Téigh go conair                     |
| `Space`               | Réamhamharc ar chomhad (déanann saigheada nascleanúint) |
| `Alt + Up`       | Téigh suas go dtí an máthairfhillteán        |

## Neovim (le lazyvim)

### Nascleanúint

| Eochair The                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Taispeáin roghanna ordaithe            |
| `Space Space`              | Oscail comhad trí chuardach doiléir      |
| `Space E`                  | Scoránaigh an barra taoibh                  |
| `Space G G`                | Taispeáin rialuithe git               |
| `Space S G`                | Cuardaigh ábhar comhaid             |
| `Ctrl + W W`               | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow`  | Athraigh méid an bharra taoibh          |
| `Shift + H`                      | Téigh go dtí an cluaisín comhaid ar chlé             |
| `Shift + L`                      | Téigh go dtí an cluaisín comhaid ar dheis            |
| `Space B D`                | Dún an cluaisín comhaid                  |

### Agus tú sa bharra taoibh

| Eochair The                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `A`                        | Cuir comhad nua leis sa mháthair-eolaire      |
| `Shift + A`                | Cuir foeolaire nua leis sa mháthair-eolaire    |
| `D`                        | Scrios an comhad/eolaire atá aibhsithe     |
| `M`                        | Bog an comhad/eolaire atá aibhsithe       |
| `R`                        | Athainmnigh an comhad/eolaire atá aibhsithe     |
| `?`                        | Taispeáin cabhair do gach ordú      |

[Féach gach eochair the Neovim atá cumraithe ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Thapa

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an rogha ar an ngearrthaisce nó is féidir leat na roghanna rochtana tapa seo a úsáid.

| Eochair The       | EM | Leid       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gáire      |
| `Shift + CapsLock M C` | 😂 | gol        |
| `Shift + CapsLock M L` | 😍 | grá       |
| `Shift + CapsLock M V` | ✌️ | bua    |
| `Shift + CapsLock M H` | ❤️ | croí      |
| `Shift + CapsLock M Y` | 👍 | tá        |
| `Shift + CapsLock M N` | 👎 | níl         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | mian       |
| `Shift + CapsLock M R` | 🤘 | rac       |
| `Shift + CapsLock M K` | 😘 | póg       |
| `Shift + CapsLock M E` | 🙄 | súilrolladh    |
| `Shift + CapsLock M I` | 😉 | meangadh       |
| `Shift + CapsLock M P` | 🙏 | guí |
| `Shift + CapsLock M D` | 🤤 | seile      |
| `Shift + CapsLock M M` | 💰 | airgead      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tósta      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánaithe Thapa

| Eochair The       | Comhlánú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a iontráladh é le linn na socraithe)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a iontráladh é le linn na socraithe)  |

Is féidir leat tuilleadh díobh féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy restart xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
