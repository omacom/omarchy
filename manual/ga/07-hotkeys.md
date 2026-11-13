# Eochracha Te

Is féidir leat na príomhcheangail méarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach eochracha te

Tá gach eochair the ar phlána, socraithe ag a modhnóirí, agus tá post amháin ag gach plána. Sin a choinníonn na heochracha te ó bheith ag meascadh lena chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá bhfuil rud éigin.

| Plána | Cad atá ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha tapa agus fógraí eolais | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` cadhnra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Má chuireann tú `Alt` le heochair the gheobhaidh tú leagan eile den rud céanna, ní rud éigin gan bhaint riamh:

- `Super + Shift + B` osclaíonn sé an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- `Super + Shift + E` osclaíonn sé ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- `Super + F` téann sé go scáileán iomlán; téann `Super + Alt + F` go leithead iomlán
- `Super + Ctrl + C` osclaíonn sé an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé gabháil scáileáin

Agus eochair the á cur leis agat:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair the atá ann cheana chun spás a dhéanamh. Faigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach le haghaidh leagan eile den eochair the gan é.

Briseann cúpla eochair the na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair go dteastaíonn `Super + Shift + S` uait le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Eangach aip |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosaigh, srl)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún fuinneog             |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + T`               | Scoránaigh fuinneog idir tílíocht/ar snámh             |
| `Super + J` | Scoránaigh suíomh fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh fuinneog a phreabadh ina greamaitheach agus ar snámh |
| `Super + L`               | Rothaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L`         | Rothaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl bhréagfhuinneoige (nádúrtha vs síneadh) |
| `Super + F`                 | Téigh go scáileán iomlán              |
| `Super + Alt + F`                 | Téigh go leithead iomlán              |
| `Super + Ctrl + F`                 | Téigh go scáileán iomlán taobh istigh den fhuinneog              |
| `Super + 1/2/3/4`         | Léim go spás oibre ar leith ar an monatóir i bhfócas |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir i bhfócas |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe seo ar an monatóir i bhfócas |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir i bhfócas |
| `Super + Shift + 1/2/3/4` | Bog fuinneog go spás oibre ar an monatóir i bhfócas |
| `Super + Shift + Alt + 1/2/3/4` | Bog fuinneog go spás oibre ar an monatóir i bhfócas gan í a leanúint |
| `Super + S` | Scoránaigh scratchpad iomlán |
| `Super + Alt + S` | Bog fuinneog go scratchpad iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog fuinneog go consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog fuinneog go dtí an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog spás oibre go dtí an monatóir sa treo sin |
| `Super + Arrow`  | Bog fócas go fuinneog i dtreo na saighde, ag trasnú go dtí an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow`  | Malartaigh fuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh fuinneog ar chlé |
| `Super + Equal` | Crap fuinneog ar chlé |
| `Super + Shift + Minus` | Crap fuinneog suas |
| `Super + Shift + Equal` | Leathnaigh fuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead fuinneoige |
| `Super + Home` | Athchóirigh leithead fuinneoige a sábháladh |
| `Super + Left Mouse` | Tarraing fuinneog timpeall |
| `Super + Right Mouse` | Athraigh méid fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir i bhfócas |
| `Super + G`               | Scoránaigh grúpáil fuinneoige      |
| `Super + Alt + G`               | Bog fuinneog amach as grúpáil      |
| `Super + Alt + Tab`               | Rothaigh idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Shift + Tab`               | Rothaigh ar gcúl idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Scroll Wheel` | Rothaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog ar leith sa ghrúpáil      |
| `Super + Alt + Arrow`  | Bog fuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga taobh istigh de ghrúpa tílíochta |
| `Super + Ctrl + Z` | Zúmáil isteach ar an scáileán (arís le haghaidh níos mó zúmála) |
| `Super + Ctrl + Alt + Z` | Zúmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Rothaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Rothaigh fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Rothaigh fócas ar gcúl trí mhonatóirí |

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá clóite ar an méarchlár. Ar mhéarchláir SAM is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`.

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
| `Super + Ctrl + Alt + E`           | Painéal clog domhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal barra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (trí LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (gabháil scáileáin/taifeadadh/piocadóir) |
| `Super + Ctrl + O` | Scoránaigh roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Piocadóir emoji |
| `Super + Ctrl + .` | Traschódaigh meáin |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |

## Coigeartuithe

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Gile scáileáin uasta |
| `Shift + Brightness Down` | Gile scáileáin íosta |
| `Alt + Brightness Up/Down` | Athruithe gile beachta 1% |
| `Alt + Volume Up/Down` | Athruithe toirte beachta 1% |
| `Keyboard Brightness Up/Down` | Soilsiú cúil méarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothaigh leibhéil soilsiú cúil an mhéarchláir |
| `Alt + Play` | An chéad traic eile |
| `Alt + Shift + Play` | Traic roimhe seo |

## Aipeanna a sheoladh

| Eochair The                  | Feidhm              |
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

Athraigh/cuir ceangail leis in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + A`           | Roghnaigh gach rud in aipanna a thacaíonn le `Ctrl + A`    |
| `Super + C`           | Cóipeáil    |
| `Super + X`           | Gearr (ní sa teirminéal)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil is greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha te gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Eochair The              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Gabháil scáileáin                      |
| `Super + Ctrl + Alt + C`            | Gabháil scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Print Screen` | Piocadóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan ceamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan ceamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ó aip ghréasáin nó ó bhrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha chuig `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Socrú > Réamhshocruithe > Deachtú_) |
| `Right Alt` | Coinnigh síos chun deachtú a dhéanamh (teastaíonn _Socrú > Réamhshocruithe > Deachtú_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair the ar dtús cén fhuaim atá uait, ansin tosaíonn sí ag taifeadadh. Brúigh arís í chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála ar fáil freisin faoi _Truicear > Gabháil_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh an t-aon chnaipe atá aige, roghnaigh óna roghanna, nó cuir ar ceal é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Cuir gach fógra ar ceal |
| `Super + Ctrl + ,` | Rialú fógraí leis an méarchlár  |
| `Super + Alt + ,` | Cuir an fógra is déanaí ar ceal  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh fógraí a chur ina dtost  |

## Stíl

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnach aonfhuinneoige |

Tá íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Suiteáil > Stíl > Cúlra_ i roghchlár Omarchy.

Tá gach rogha stíle ar fáil freisin faoi _Stíl_ i roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil agus díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint ríomhaire glúine ar/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú taispeána ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneoige |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc scáileáin iomláin (barra uachtarach + bearnaí fuinneoige) |

## Meabhrúcháin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán  |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán  |

## Fógraí eolais

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin an cadhnra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra  |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Painéil

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt painéal in aice leis (ingearach) |
| `Prefix + h` | Scoilt painéal thíos (cothrománach) |
| `Prefix + x` | Maraigh painéal |
| `Prefix + z` | Scoránaigh zúmáil painéil (scáileán iomlán) |
| `Alt + Enter` | Scoilt painéal thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt painéal in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh painéal (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir painéil |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid painéal |

### Fuinneoga

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh fuinneog |
| `Prefix + r` | Athainmnigh fuinneog |
| `Alt + 1-9` | Téigh go fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog fuinneog ar chlé/ar dheis |

### Seisiúin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh seisiún |
| `Prefix + R` | Athainmnigh seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | Seisiún roimhe seo |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scoir ón seisiún |

### Mód cóipeála (stíl vi)

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach i mód cóipeála |
| `v` | Tosaigh roghnú (i mód cóipeála) |
| `y` | Cóipeáil an roghnú (i mód cóipeála) |

### Ginearálta

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil cumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Pras ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fhochomhadlann |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphainéil |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty ag úsáid _Suiteáil > Teirminéal_ trí roghchlár Omarchy.

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
| `Ctrl + Left mouse` | Oscail nasc sa bhrabhsálaí |

## Bainisteoir Comhad

| Eochair The              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Téigh go conair                     |
| `Space`               | Réamhamharc ar chomhad (nascleanann saigheada) |
| `Alt + Up`       | Téigh suas go dtí an fillteán tuismitheora        |

## Neovim (le lazyvim)

### Nascleanúint

| Eochair The                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Taispeáin roghanna ordaithe            |
| `Space Space`              | Oscail comhad trí chuardach doiléir      |
| `Space E`                  | Scoránaigh barra taoibh                  |
| `Space G G`                | Taispeáin rialuithe git               |
| `Space S G`                | Cuardaigh ábhar comhaid             |
| `Ctrl + W W`               | Léim idir barra taoibh agus eagarthóir |
| `Ctrl + Left/right arrow`  | Athraigh méid an bharra taoibh          |
| `Shift + H`                      | Téigh go cluaisín comhaid ar chlé             |
| `Shift + L`                      | Téigh go cluaisín comhaid ar dheis            |
| `Space B D`                | Dún cluaisín comhaid                  |

### Agus tú sa bharra taoibh

| Eochair The                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `A`                        | Cuir comhad nua leis sa chomhadlann tuismitheora      |
| `Shift + A`                | Cuir fochomhadlann nua leis sa chomhadlann tuismitheora    |
| `D`                        | Scrios an comhad/comhadlann aibhsithe     |
| `M`                        | Bog an comhad/comhadlann aibhsithe       |
| `R`                        | Athainmnigh an comhad/comhadlann aibhsithe     |
| `?`                        | Taispeáin cabhair do gach ordú      |

[Féach na heochracha te Neovim go léir arna gcumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Tapa

Is féidir leat `Super + Ctrl + E` a úsáid chun piocadóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana tapa seo a úsáid.

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
| `Shift + CapsLock M E` | 🙄 | rolladh súl    |
| `Shift + CapsLock M I` | 😉 | caochadh       |
| `Shift + CapsLock M P` | 🙏 | urnaí |
| `Shift + CapsLock M D` | 🤤 | ag sileadh seile      |
| `Shift + CapsLock M M` | 💰 | airgead      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | sláinte      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánaithe Tapa

| Eochair The       | Comhlánú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a iontráladh é ag an socrú)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a iontráladh é ag an socrú)  |

Is féidir leat tuilleadh dod' chuid féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy-restart-xcompose` a rith sa teirminéal chun na hathruithe a chur i bhfeidhm.
