# Aicearraí Méarchláir

Is féidir leat na príomh-cheangail méarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach aicearraí

Tá gach aicearra ar phlána, arna shocrú ag a mhodhnóirí, agus tá post amháin ag gach plána. Sin a choinníonn na haicearraí ó bheith ina mbrablach, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth faoi cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún an fhuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` cadhnra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Tugann `Alt` a chur le haicearra malairt den rud céanna duit, ní rud neamhghaolmhar riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` an ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go scáileán iomlán; téann `Super + Alt + F` go leithead iomlán
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus glacann sé gabháil scáileáin

Agus aicearra á chur leis:

1. Roghnaigh an plána ón méid a dhéanann sé, ansin roghnaigh an eochair.
2. Ná bog aicearra atá ann cheana chun spás a dhéanamh. Aimsigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach amháin le haghaidh malairte den aicearra gan é.

Briseann cúpla aicearra na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó le `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Eangach aipeanna |
| `Super + Escape` | Roghchlár an chórais (cuir ar fionraí, atosú, srl)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún an fhuinneog             |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin gach aicearra |
| `Super + Alt + K` | Taispeáin aicearraí tmux |
| `Super + Ctrl + K` | Taispeáin aicearraí herdr |
| `Super + M` | Íoslaghdaigh an fhuinneog chuig an duga |
| `Super + T`               | Scoránaigh an fhuinneog idir tílíocht/ar snámh             |
| `Super + J` | Scoránaigh suíomh na fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh an fhuinneog a chur i mód greamaitheach ar snámh |
| `Super + L`               | Timthriallaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L`         | Timthriallaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl na bréagfhuinneoige (nádúrtha v sínte) |
| `Super + F`                 | Téigh go scáileán iomlán              |
| `Super + Alt + F`                 | Téigh go leithead iomlán              |
| `Super + Ctrl + F`                 | Téigh go scáileán iomlán taobh istigh den fhuinneog              |
| `Super + 1…9/0`         | Léim go spás oibre ar leith (is é 0 ná 10) ar an monatóir atá i bhfócas |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir atá i bhfócas |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe ar an monatóir atá i bhfócas |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir atá i bhfócas |
| `Super + Shift + 1…9/0` | Bog an fhuinneog go spás oibre ar an monatóir atá i bhfócas |
| `Super + Shift + Alt + 1…9/0` | Bog an fhuinneog go spás oibre ar an monatóir atá i bhfócas gan leanúint léi |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog an fhuinneog go dtí an scratchpad iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog an fhuinneog go consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog an fhuinneog go dtí an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog an spás oibre go dtí an monatóir sa treo sin |
| `Super + Arrow`  | Bog an fócas go fuinneog i dtreo na saighde, ag trasnú go dtí an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow`  | Malartaigh an fhuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh an fhuinneog ar chlé |
| `Super + Equal` | Crap an fhuinneog ar chlé |
| `Super + Shift + Minus` | Crap an fhuinneog suas |
| `Super + Shift + Equal` | Leathnaigh an fhuinneog anuas |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing an fhuinneog thart |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir atá i bhfócas |
| `Super + G`               | Scoránaigh grúpáil na fuinneoige      |
| `Super + Alt + G`               | Bog an fhuinneog amach as an ngrúpáil      |
| `Super + Alt + Tab`               | Timthriallaigh idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Shift + Tab`               | Timthriallaigh ar gcúl idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Scroll Wheel` | Timthriallaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog ar leith sa ghrúpáil      |
| `Super + Alt + Arrow`  | Bog an fhuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga taobh istigh de ghrúpa tílíochta |
| `Super + Ctrl + Z` | Súmáil isteach ar an scáileán (déan arís é le haghaidh níos mó súmála) |
| `Super + Ctrl + Alt + Z` | Súmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe an mhonatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe an mhonatóra |
| `Alt + Tab` | Timthriallaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Timthriallaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Timthriallaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Timthriallaigh an fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh an teanga ionchuir (le níos mó ná leagan amach nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh an teanga ionchuir ar ais |

Ar thaibhleog tadhaill, aistríonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus taibhleog tadhaill](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá clóite ar an méarchlár. Ar mhéarchláir US is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`.

## Rialuithe an chórais

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painéal fuaime    |
| `Super + Ctrl + B`           | Painéal Bluetooth    |
| `Super + Ctrl + N`           | Painéal Wi-Fi/líonra    |
| `Super + Ctrl + D`           | Painéal taispeána    |
| `Super + Ctrl + P`           | Painéal cumhachta    |
| `Super + Ctrl + X`           | Painéal gníomhairí    |
| `Super + Ctrl + Alt + X`           | Painéal samhlacha áitiúla    |
| `Super + Ctrl + Alt + D`           | Painéal féilire    |
| `Super + Ctrl + Alt + E`           | Painéal clog domhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal an bharra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh an roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódáil meán |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |
| `Power` key | Roghchlár an chórais |
| `Super + Shift + Copilot` key | Roghchlár Omarchy |

## Coigeartuithe

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Gile uasta an scáileáin |
| `Shift + Brightness Down` | Gile íosta an scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar an ngile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar an toirt |
| `Keyboard Brightness Up/Down` | Soilsiú cúil an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Timthriallaigh leibhéil shoilsiú cúil an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Soilsiú cúil an mhéarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh an t-aschur fuaime |
| `Touchpad Toggle` | Cas an taibhleog tadhaill air nó as |
| `Display` key | Timthriallaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad traic eile |
| `Alt + Shift + Play` | An traic roimhe |

## Aipeanna a sheoladh

| Aicearra                  | Feidhm              |
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
| `Super + Shift + D`           | Docker (lazydocker, nuair a bheidh sé suiteáilte)    |
| `Super + Shift + T`           | Gníomhaíocht (btop)    |
| `Super + Shift + N`           | Eagarthóir (Plain, nó do réamhshocrú roghnaithe)  |
| `Super + Shift + C`           | Féilire ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Ríomhphost ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ríomhphost nua ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + A`           | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A`    |
| `Super + C`           | Cóipeáil    |
| `Super + X`           | Gearr (ní sa teirminéal)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil'n'greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na haicearraí gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Aicearra              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Gabháil scáileáin                      |
| `Super + Ctrl + Alt + C`            | Gabháil scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (buail arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aip ghréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha go `~/Videos` |
| `Alt + Space` | Tosaigh/stop an deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh síos é chun deachtú (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an t-aicearra ar dtús cén fhuaim atá uait, ansin tosaíonn sé ag taifeadadh. Buail arís é chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála ar fáil freisin faoi _Trigger > Capture_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh an t-aon chnaipe atá aige, roghnaigh óna roghanna, nó cuir ar ceal é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Cuir gach fógra ar ceal |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár  |
| `Super + Alt + ,` | Cuir an fógra is déanaí ar ceal  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh fógraí a chur ina dtost  |

## Stíl

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh an trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh an ghné chearnógach aonfhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ i roghchlár Omarchy.

Tá gach rogha stíle ar fáil freisin faoi _Appearance_ i roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh an ghlasáil nuair a bhíonn sé díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine air/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra barr  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí na bhfuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh an deasc scáileáin iomláin (barra barr + bearnaí fuinneog) |

## Meabhrúcháin

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán  |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán  |

## Fógraí gairide

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin an cadhnra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra  |

## Tmux

Is é `Ctrl + Space` an eochair réimíre (`Ctrl + B` a oibríonn freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt an pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt an pána thíos (cothrománach) |
| `Prefix + x` | Maraigh an pána |
| `Prefix + z` | Scoránaigh súmáil an phána (lánscáileán) |
| `Alt + Enter` | Scoilt an pána thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt an pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh an pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánaí |

### Fuinneoga

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh an fhuinneog |
| `Prefix + r` | Athainmnigh an fhuinneog |
| `Alt + 1-9` | Téigh go fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog an fhuinneog ar chlé/ar dheis |

### Seisiúin

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh an seisiún |
| `Prefix + R` | Athainmnigh an seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh na seisiúin |
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh an roghnú (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnú (sa mhód cóipeála) |

### Ginearálta

| Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Leid ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fhodhireachtóra |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty ag baint úsáide as _Install > Terminal_ trí roghchlár Omarchy.

| Aicearra                  | Feidhm              |
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

| Aicearra              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Téigh go dtí an chonair                     |
| `Space`               | Réamhamharc ar an gcomhad (déanann na saigheada nascleanúint) |
| `Alt + Up`       | Téigh suas go dtí an fillteán tuismitheora        |

## Neovim (w/ lazyvim)

### Nascleanúint

| Aicearra                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Taispeáin roghanna ordaithe            |
| `Space Space`              | Oscail comhad trí chuardach doiléir      |
| `Space E`                  | Scoránaigh an barra taoibh                  |
| `Space G G`                | Taispeáin rialuithe git               |
| `Space S G`                | Cuardaigh ábhar an chomhaid             |
| `Ctrl + W W`               | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow`  | Athraigh méid an bharra taoibh          |
| `Shift + H`                      | Téigh go dtí an cluaisín comhaid ar chlé             |
| `Shift + L`                      | Téigh go dtí an cluaisín comhaid ar dheis            |
| `Space B D`                | Dún an cluaisín comhaid                  |

### Agus tú sa bharra taoibh

| Aicearra                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `A`                        | Cuir comhad nua leis sa chomhadlann tuismitheora      |
| `Shift + A`                | Cuir fofhillteán nua leis sa chomhadlann tuismitheora    |
| `D`                        | Scrios an comhad/fillteán aibhsithe     |
| `M`                        | Bog an comhad/fillteán aibhsithe       |
| `R`                        | Athainmnigh an comhad/fillteán aibhsithe     |
| `?`                        | Taispeáin cabhair do gach ordú      |

[Féach gach aicearra Neovim arna chumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Gasta

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana gasta seo a úsáid.

| Aicearra       | EM | Leid       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | miongháire      |
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
| `Shift + CapsLock M E` | 🙄 | rolladh súl    |
| `Shift + CapsLock M I` | 😉 | caochadh súile       |
| `Shift + CapsLock M P` | 🙏 | guí |
| `Shift + CapsLock M D` | 🤤 | ag sileadh seile      |
| `Shift + CapsLock M M` | 💰 | airgead      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tósta      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánaithe Gasta

| Aicearra       | Comhlánú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach é ag an socrú)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach é ag an socrú)  |

Is féidir leat níos mó de do chuid féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy restart xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
