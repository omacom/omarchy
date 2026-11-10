# Meareochracha

Is féidir leat na príomhcheangail mhéarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach meareochracha

Suíonn gach meareochair ar phlána, arna shocrú ag a modhnóirí, agus tá post amháin ag gach plána. Sin a choinníonn na meareochracha ó bheith ag meascadh le chéile, agus ciallaíonn sé gur féidir leat a thomhas de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad atá ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún an fhuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir an chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha tapa agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Má chuirtear `Alt` le meareochair tugtar leagan den rud céanna duit, ní rud éigin nach mbaineann leis riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go scáileán iomlán; téann `Super + Alt + F` go leithead iomlán
- Osclaíonn `Super + Ctrl + C` roghchlár na gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé gabháil scáileáin

Nuair a chuirtear meareochair leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog meareochair atá ann cheana chun spás a dhéanamh. Aimsigh eochair shaor ar an plána ceart.
3. Ná húsáid `Alt` ach amháin le haghaidh leagan den mheareochair gan é.

Briseann cúpla meareochair na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Greille aipeanna |
| `Super + Escape` | Roghchlár an chórais (cur ar fionraí, atosú, srl.)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` nó `Super + Q` | Dún an fhuinneog             |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + T`               | Scoránaigh an fhuinneog idir tílíocht/snámhach             |
| `Super + J` | Scoránaigh suíomh na fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh an fhuinneog a phreabadh isteach i mód greamaitheach agus snámhach |
| `Super + L`               | Rothlaigh trí na leaganacha amach dwindle, scrollaithe, agus snámhacha |
| `Super + Alt + L`         | Rothlaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl bhréagfhuinneoige (nádúrtha v síneadh) |
| `Super + F`                 | Téigh go scáileán iomlán              |
| `Super + Alt + F`                 | Téigh go leithead iomlán              |
| `Super + Ctrl + F`                 | Téigh go scáileán iomlán taobh istigh den fhuinneog              |
| `Super + 1/2/3/4`         | Léim go spás oibre sonrach ar an monatóir fócasaithe |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir fócasaithe |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe ar an monatóir fócasaithe |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir fócasaithe |
| `Super + Shift + 1/2/3/4` | Bog an fhuinneog go spás oibre ar an monatóir fócasaithe |
| `Super + Shift + Alt + 1/2/3/4` | Bog an fhuinneog go spás oibre ar an monatóir fócasaithe gan í a leanúint |
| `Super + S` | Scoránaigh an scratchpad iomlán |
| `Super + Alt + S` | Bog an fhuinneog go dtí an scratchpad iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog an fhuinneog go consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog an fhuinneog go dtí an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog an spás oibre go dtí an monatóir sa treo sin |
| `Super + Arrow`  | Bog an fócas go fuinneog i dtreo na saighde, ag trasnú go dtí an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow`  | Malartaigh fuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh an fhuinneog ar chlé |
| `Super + Equal` | Laghdaigh an fhuinneog ar chlé |
| `Super + Shift + Minus` | Laghdaigh an fhuinneog suas |
| `Super + Shift + Equal` | Leathnaigh an fhuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing an fhuinneog thart |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir fócasaithe |
| `Super + G`               | Scoránaigh grúpáil fuinneog      |
| `Super + Alt + G`               | Bog an fhuinneog amach as an ngrúpáil      |
| `Super + Alt + Tab`               | Rothlaigh idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Shift + Tab`               | Rothlaigh ar gcúl idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Scroll Wheel` | Rothlaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog shonrach sa ghrúpáil      |
| `Super + Alt + Arrow`  | Bog an fhuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga taobh istigh de ghrúpa tílíochta |
| `Super + Ctrl + Z` | Súmáil isteach ar an scáileán (athdhéan le haghaidh tuilleadh súmála) |
| `Super + Ctrl + Alt + Z` | Súmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe an mhonatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe an mhonatóra |
| `Alt + Tab` | Rothlaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothlaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Rothlaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Rothlaigh an fócas ar gcúl trí mhonatóirí |

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá priontáilte ar an méarchlár. Ar mhéarchláir US is `-` agus `=` iad na heochracha seo; ar mhéarchláir Seapánacha (JIS) is `-` agus `^` iad; ar mhéarchláir Spáinneacha is `'` agus `¡` iad. Ar JIS, is `Super + Equal` é `Super + ^`, agus is `Super + Shift + Minus` é `Super + Shift + -` (a chlóscríobhann `=`).

## Rialuithe an chórais

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painéal fuaime    |
| `Super + Ctrl + B`           | Painéal Bluetooth    |
| `Super + Ctrl + N`           | Painéal Wi-Fi/líonra    |
| `Super + Ctrl + D`           | Painéal taispeána    |
| `Super + Ctrl + P`           | Painéal cumhachta    |
| `Super + Ctrl + Alt + D`           | Painéal féilire    |
| `Super + Ctrl + Alt + E`           | Painéal cloig dhomhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal an bharra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh an roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódáil meán |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |

## Coigeartuithe

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Gile uasta an scáileáin |
| `Shift + Brightness Down` | Gile íosta an scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta gile 1% |
| `Alt + Volume Up/Down` | Athruithe beachta toirte 1% |
| `Keyboard Brightness Up/Down` | Solas cúlra an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothlaigh trí leibhéil sholas cúlra an mhéarchláir |
| `Alt + Play` | An chéad traic eile |
| `Alt + Shift + Play` | Traic roimhe |

## Aipeanna a sheoladh

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Return`           | Teirminéal    |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir gníomhairí) |
| `Super + Shift + Return`           | Brabhsálaí    |
| `Super + Shift + Alt + B`           | Brabhsálaí (príobháideach/incognito)    |
| `Super + Shift + F`           | Bainisteoir comhad    |
| `Super + Shift + Alt + F`           | Bainisteoir comhad i cwd an teirminéil    |
| `Super + Shift + M`           | Ceol (Spotify)    |
| `Super + Shift + Alt + M`           | Ceol (cliamp)    |
| `Super + Shift + /`           | Bainisteoir pasfhocal (1password)    |
| `Super + Shift + Q`           | Áireamhán (Omacalc)    |
| `Super + Shift + T`           | Gníomhaíocht (btop)    |
| `Super + Shift + N`           | Eagarthóir (Neovim)  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Athraigh/cuir ceangail in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + A`           | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A`    |
| `Super + C`           | Cóipeáil    |
| `Super + X`           | Gearr (ní sa teirminéal é)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil agus greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na meareochracha aontaithe gearrthaisce Omarchy seo i ngach áit.

## Gabháil

| Meareochair              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Gabháil scáileáin                      |
| `Super + Ctrl + Alt + C`            | Gabháil scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ó webapp nó ó Chromium |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha go `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh síos chun deachtú a dhéanamh (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an mheareochair ar dtús cén fhuaim atá uait, ansin tosaíonn sí ag taifeadadh. Brúigh arís í chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála ar fáil freisin faoi _Trigger > Capture_ sa roghchlár Omarchy (`Super + Space`).

## Fógraí

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh an t-aon chnaipe atá aige, roghnaigh óna roghanna, nó cuir ar ceal é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Cuir gach fógra ar ceal |
| `Super + Ctrl + ,` | Rialaigh fógraí leis an méarchlár  |
| `Super + Alt + ,` | Cuir an fógra is déanaí ar ceal  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh ciúnú fógraí  |

## Stíl

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnógach aonfhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ sa roghchlár Omarchy.

Tá gach rogha stíle ar fáil freisin faoi _Style_ sa roghchlár Omarchy (`Super + Space`).

## Scoráin

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil nuair atá díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine ar siúl/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtair  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc scáileáin iomláin (barra uachtair + bearnaí fuinneog) |

## Meabhrúcháin

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán  |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán  |

## Nótaí

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin an ceallra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra  |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pannaí

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt panna in aice leis (ingearach) |
| `Prefix + h` | Scoilt panna thíos (cothrománach) |
| `Prefix + x` | Marbh panna |
| `Prefix + z` | Scoránaigh súmáil panna (scáileán iomlán) |
| `Alt + Enter` | Scoilt panna thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt panna in aice leis (gan réimír) |
| `Alt + Escape` | Marbh panna (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pannaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpannaí |

### Fuinneoga

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Marbh fuinneog |
| `Prefix + r` | Athainmnigh fuinneog |
| `Alt + 1-9` | Téigh go fuinneog shonrach |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog an fhuinneog ar chlé/ar dheis |

### Seisiúin

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Marbh seisiún |
| `Prefix + R` | Athainmnigh seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | Seisiún roimhe |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach sa mhód cóipeála |
| `v` | Tosaigh roghnú (sa mhód cóipeála) |
| `y` | Cóipeáil an roghnú (sa mhód cóipeála) |

### Ginearálta

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil an chumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Leid ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha de réir fochomhadlainne |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphanna |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty le _Install > Terminal_ tríd an roghchlár Omarchy.

| Meareochair                  | Feidhm              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Cluaisín nua  |
| `Ctrl + Shift + Arrows` | Bog idir cluaisíní |
| `Alt + Numbers` | Téigh go cluaisín sonrach |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail nasc sa bhrabhsálaí |

## Bainisteoir Comhad

| Meareochair              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Téigh go conair                     |
| `Space`               | Réamhamharc ar chomhad (déanann na saigheada nascleanúint) |
| `Alt + Up`       | Téigh suas go dtí an fillteán tuismitheora        |

## Neovim (le lazyvim)

### Nascleanúint

| Meareochair                   | Feidhm                        |
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

| Meareochair                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `A`                        | Cuir comhad nua sa chomhadlann tuismitheora      |
| `Shift + A`                | Cuir fochomhadlann nua sa chomhadlann tuismitheora    |
| `D`                        | Scrios an comhad/comhadlann aibhsithe     |
| `M`                        | Bog an comhad/comhadlann aibhsithe       |
| `R`                        | Athainmnigh an comhad/comhadlann aibhsithe     |
| `?`                        | Taispeáin cabhair do gach ordú      |

[Féach na meareochracha Neovim go léir arna gcumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Tapa

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana tapa seo a úsáid.

| Meareochair       | EM | Leid       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | gáire      |
| `Shift + CapsLock M C` | 😂 | gol        |
| `Shift + CapsLock M L` | 😍 | grá       |
| `Shift + CapsLock M V` | ✌️ | bua    |
| `Shift + CapsLock M H` | ❤️ | croí      |
| `Shift + CapsLock M Y` | 👍 | sea        |
| `Shift + CapsLock M N` | 👎 | níl         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | mian       |
| `Shift + CapsLock M R` | 🤘 | rac       |
| `Shift + CapsLock M K` | 😘 | póg       |
| `Shift + CapsLock M E` | 🙄 | rolladh súl    |
| `Shift + CapsLock M I` | 😉 | caochadh       |
| `Shift + CapsLock M P` | 🙏 | guí |
| `Shift + CapsLock M D` | 🤤 | ag sileadh seile      |
| `Shift + CapsLock M M` | 💰 | airgead      |
| `Shift + CapsLock M X` | 🎉 | ceiliúradh |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tósta      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánaithe Tapa

| Meareochair       | Comhlánú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach é ag an socrú)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach é ag an socrú)  |

Is féidir leat tuilleadh dod' chuid féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy-restart-xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
