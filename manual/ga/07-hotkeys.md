# Eochracha Aicearra

Is féidir leat na príomhcheangail mhéarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Mar a leagtar amach na heochracha aicearra

Suíonn gach eochair aicearra ar phlána, arna socrú ag a modhnóirí, agus tá post amháin ag gach plána. Sin a choisceann na heochracha aicearra ó bheith ag meascadh le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` lánscáileán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha tapa agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` cadhnra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Má chuireann tú `Alt` le heochair aicearra faigheann tú leagan eile den rud céanna, ní rud éigin neamhghaolmhar riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go lánscáileán; téann `Super + Alt + F` go lánleithead
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus glacann sé gabháil scáileáin

Nuair a chuireann tú eochair aicearra leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair aicearra atá ann cheana chun spás a dhéanamh. Aimsigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach le haghaidh leagan eile den eochair aicearra gan é.

Briseann cúpla eochair aicearra na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Space` | Roghchlár Omarchy (aipeanna agus gach rud eile) |
| `Super + Alt + Space` | Greille aip |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosaigh, srl) |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún an fhuinneog |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin na heochracha aicearra go léir |
| `Super + Alt + K` | Taispeáin eochracha aicearra tmux |
| `Super + Ctrl + K` | Taispeáin eochracha aicearra herdr |
| `Super + M` | Íoslaghdaigh fuinneog chuig an duga |
| `Super + T` | Scoránaigh fuinneog idir tíliú/ar snámh |
| `Super + J` | Scoránaigh suíomh fuinneoige (cothrománach/ingearach) |
| `Super + O` | Scoránaigh an fhuinneog a phreabadh isteach i sticky'n'floating |
| `Super + L` | Rothaigh trí leaganacha amach dwindle, scrolling, agus floating |
| `Super + Alt + L` | Rothaigh trí na leaganacha amach ar gcúl |
| `Super + P` | Scoránaigh stíl fuinneoige pseudo (natural v stretch) |
| `Super + F` | Téigh go lánscáileán |
| `Super + Alt + F` | Téigh go lánleithead |
| `Super + Ctrl + F` | Téigh go lánscáileán taobh istigh den fhuinneog |
| `Super + 1…9/0` | Léim chuig spás oibre ar leith (is é 0 ná 10) ar an monatóir atá i bhfócas |
| `Super + Tab` | Léim chuig an gcéad spás oibre eile ar an monatóir atá i bhfócas |
| `Super + Shift + Tab` | Léim chuig an spás oibre roimhe seo ar an monatóir atá i bhfócas |
| `Super + Ctrl + Tab` | Léim chuig an spás oibre a bhí ann roimhe ar an monatóir atá i bhfócas |
| `Super + Shift + 1…9/0` | Bog fuinneog chuig spás oibre ar an monatóir atá i bhfócas |
| `Super + Shift + Alt + 1…9/0` | Bog fuinneog chuig spás oibre ar an monatóir atá i bhfócas gan í a leanúint |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog fuinneog chuig an scratchpad iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog fuinneog chuig consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog fuinneog chuig an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog spás oibre chuig an monatóir sa treo sin |
| `Super + Arrow` | Bog an fócas chuig fuinneog i dtreo na saighde, ag trasnú chuig an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow` | Malartaigh fuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh fuinneog ar chlé |
| `Super + Equal` | Cúngaigh fuinneog ar chlé |
| `Super + Shift + Minus` | Cúngaigh fuinneog suas |
| `Super + Shift + Equal` | Leathnaigh fuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing an fhuinneog thart |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir atá i bhfócas |
| `Super + G` | Scoránaigh grúpáil fuinneoige |
| `Super + Alt + G` | Bog fuinneog amach as an ngrúpáil |
| `Super + Alt + Tab` | Rothaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + Shift + Tab` | Rothaigh ar gcúl idir fuinneoga sa ghrúpáil |
| `Super + Alt + Scroll Wheel` | Rothaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5` | Léim chuig fuinneog ar leith sa ghrúpáil |
| `Super + Alt + Arrow` | Bog fuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right` | Bog idir fuinneoga taobh istigh de ghrúpa tílithe |
| `Super + Ctrl + Z` | Súmáil isteach ar an scáileán (athdhéan le haghaidh níos mó súmála) |
| `Super + Ctrl + Alt + Z` | Súmáil go hiomlán amach as an scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe an mhonatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe an mhonatóra |
| `Alt + Tab` | Rothaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Rothaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Rothaigh an fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh teanga ionchuir (le níos mó ná leagan amach nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh teanga ionchuir ar ais |

Ar cheap tadhaill, aistríonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus ceap tadhaill](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), is cuma cad iad na carachtair atá clóite ar an méarchlár. Ar mhéarchláir SAM is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`.

## Rialuithe córais

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painéal fuaime |
| `Super + Ctrl + B` | Painéal Bluetooth |
| `Super + Ctrl + N` | Painéal wifi/líonra |
| `Super + Ctrl + D` | Painéal taispeána |
| `Super + Ctrl + P` | Painéal cumhachta |
| `Super + Ctrl + X` | Painéal gníomhairí |
| `Super + Ctrl + Alt + X` | Painéal samhlacha áitiúla |
| `Super + Ctrl + Alt + D` | Painéal féilire |
| `Super + Ctrl + Alt + E` | Painéal cloig dhomhanda |
| `Super + Ctrl + 1-9` | Scoránaigh painéal an bharra de réir suímh |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh an roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódáil meán |
| `Super + Shift + Ctrl + A` | Tosaigh do ghníomhaire réamhshocraithe |
| `Power` key | Roghchlár córais |
| `Super + Shift + Copilot` key | Roghchlár Omarchy |

## Coigeartuithe

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile an scáileáin |
| `Shift + Brightness Down` | Íosghile an scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar an ngile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar an toirt |
| `Keyboard Brightness Up/Down` | Cúlsholas an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothaigh leibhéil chúlsholais an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Cúlsholas an mhéarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh an t-aschur fuaime |
| `Touchpad Toggle` | Cas an ceap tadhaill air nó as |
| `Display` key | Rothaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad rian eile |
| `Alt + Shift + Play` | An rian roimhe seo |

## Aipeanna a sheoladh

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Return` | Teirminéal |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir gníomhairí) |
| `Super + Shift + Return` or `Super + Shift + B` | Brabhsálaí |
| `Super + Shift + Alt + B` | Brabhsálaí (príobháideach/incognito) |
| `Super + Shift + F` | Bainisteoir comhad |
| `Super + Shift + Alt + F` | Bainisteoir comhad in cwd an teirminéil |
| `Super + Shift + M` | Ceol (Spotify) |
| `Super + Shift + Alt + M` | Ceol (cliamp) |
| `Super + Shift + /` | Bainisteoir pasfhocal (1password) |
| `Super + Shift + Q` or `Calculator` key | Áireamhán (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, nuair a bheidh sé suiteáilte) |
| `Super + Shift + T` | Gníomhaíocht (btop) |
| `Super + Shift + N` | Eagarthóir (Plain, nó an réamhshocrú a roghnaigh tú) |
| `Super + Shift + C` | Féilire ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Ríomhphost ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Ríomhphost nua ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Do ghníomhaire réamhshocraithe, nó ChatGPT go dtí go roghnóidh tú ceann |
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

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + A` | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A` |
| `Super + C` | Cóipeáil |
| `Super + X` | Gearr (ní sa teirminéal) |
| `Super + V` | Greamaigh |
| `Super + Ctrl + V` | Bainisteoir na gearrthaisce |

De ghnáth ar Linux, caithfidh tú `Ctrl + Shift + C/V` a úsáid chun cóipeáil's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha aicearra aontaithe gearrthaisce Omarchy seo i ngach áit.

## Gabháil

| Eochair Aicearra | Feidhm |
| ------------------- | ------------------------------ |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen` | Taifeadadh scáileáin |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fhuaim, ag scipeáil an roghchláir (buail arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Cuir forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Cuir forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aip ghréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha chuig `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh chun deachtú a dhéanamh (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair aicearra ar dtús cén fhuaim atá uait, ansin tosaíonn sí ag taifeadadh. Buail arís í chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála ar fáil freisin faoi _Trigger > Capture_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh an t-aon chnaipe atá aige, roghnaigh as a roghanna, nó cuir ar ceal é nuair nach bhfuil aon cheann aige |
| `Super + Shift + ,` | Cuir gach fógra ar ceal |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár |
| `Super + Alt + ,` | Cuir an fógra is déanaí ar ceal |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí |
| `Super + Ctrl + Alt + ,` | Scoránaigh fógraí a chur ina dtost |

## Stíl

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh cóimheas gné cearnógach aon-fhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ i roghchlár Omarchy.

Tá gach rogha stíle ar fáil freisin faoi _Appearance_ i roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil ar díomhaointeas |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine air/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach |
| `Shift + Mute` | Athraigh chuig an gcéad aschur fuaime eile |
| `Shift + Play` | Athraigh chuig an gcéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneoige |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc lánscáileáin (barra uachtarach + bearnaí fuinneoige) |

## Meabhrúcháin

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán |
| `Super + Ctrl + Alt + R` | Féach na meabhrúcháin go léir |
| `Super + Ctrl + Shift + R` | Glan na meabhrúcháin go léir |

## Nótaí fógra

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra |
| `Super + Ctrl + Alt + B` | Taispeáin an cadhnra mar fhógra |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Painéil

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt an painéal in aice leis (go hingearach) |
| `Prefix + h` | Scoilt an painéal thíos (go cothrománach) |
| `Prefix + x` | Maraigh an painéal |
| `Prefix + z` | Scoránaigh súmáil an phainéil (lánscáileán) |
| `Alt + Enter` | Scoilt an painéal thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt an painéal in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh an painéal (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir painéil |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpainéal |

### Fuinneoga

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh an fhuinneog |
| `Prefix + r` | Athainmnigh an fhuinneog |
| `Alt + 1-9` | Téigh chuig fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog fuinneog ar chlé/ar dheis |

### Seisiúin

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh an seisiún |
| `Prefix + R` | Athainmnigh an seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe seo |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh na seisiúin |
| `Prefix + d` | Scoir ón seisiún |

### Mód cóipeála (stíl vi)

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh an roghnúchán (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnúchán (sa mhód cóipeála) |

### Ginearálta

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Pras ordaithe |

### Feidhmeanna leagan amach Tmux

Caithfear na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fho-eolaire |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphainéil |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty trí _Install > Terminal_ a úsáid i roghchlár Omarchy.

| Eochair Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Táb nua |
| `Ctrl + Shift + Arrows` | Bog idir tába |
| `Alt + Numbers` | Téigh chuig táb ar leith |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail nasc sa bhrabhsálaí |

## Bainisteoir Comhad

| Eochair Aicearra | Feidhm |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Téigh chuig an gconair |
| `Space` | Réamhamharc ar chomhad (déanann na saigheada nascleanúint) |
| `Alt + Up` | Téigh suas chuig an máthairfhillteán |

## Neovim (w/ lazyvim)

### Nascleanúint

| Eochair Aicearra | Feidhm |
| ------------------------ | ------------------------------- |
| `Space` | Taispeáin roghanna ordaithe |
| `Space Space` | Oscail comhad trí chuardach doiléir |
| `Space E` | Scoránaigh an barra taoibh |
| `Space G G` | Taispeáin rialuithe git |
| `Space S G` | Cuardaigh ábhar an chomhaid |
| `Ctrl + W W` | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow` | Athraigh méid an bharra taoibh |
| `Shift + H` | Téigh chuig an táb comhaid ar chlé |
| `Shift + L` | Téigh chuig an táb comhaid ar dheis |
| `Space B D` | Dún an táb comhaid |

### Agus tú sa bharra taoibh

| Eochair Aicearra | Feidhm |
| ------------------------ | ------------------------------- |
| `A` | Cuir comhad nua leis sa mháthaireolaire |
| `Shift + A` | Cuir fo-eolaire nua leis sa mháthaireolaire |
| `D` | Scrios an comhad/eolaire aibhsithe |
| `M` | Bog an comhad/eolaire aibhsithe |
| `R` | Athainmnigh an comhad/eolaire aibhsithe |
| `?` | Taispeáin cabhair do na horduithe go léir |

[Féach na heochracha aicearra Neovim go léir arna gcumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Tapa

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnúchán ar an ngearrthaisce nó is féidir leat na roghanna gasta rochtana seo a úsáid.

| Eochair Aicearra | EM | Leid |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | meangadh gáire |
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
| `Shift + CapsLock M E` | 🙄 | súile a rolladh |
| `Shift + CapsLock M I` | 😉 | caochadh |
| `Shift + CapsLock M P` | 🙏 | urnaí |
| `Shift + CapsLock M D` | 🤤 | prioslú |
| `Shift + CapsLock M M` | 💰 | airgead |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tósta |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | lámh |
| `Shift + CapsLock M B` |🤯 | séideadh |

## Comhlánuithe Tapa

| Eochair Aicearra | Comhlánú |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach é le linn na socraithe) |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach é le linn na socraithe) |

Is féidir leat níos mó de do chuid féin a chur leis trí `~/.XCompose` a chur in eagar, agus ansin `omarchy restart xcompose` a rith sa teirminéal chun go nglacfar leis na hathruithe.
