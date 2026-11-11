# Eochracha Aicearra

Is féidir leat na príomhcheangaltáin méarchláir go léir a fheiceáil le `Super + K` (ceangaltáin Tmux le `Super + Alt + K` agus ceangaltáin Herdr le `Super + Ctrl + K`).

## Mar a leagtar amach na heochracha aicearra

Tá gach eochair aicearra ina suí ar phlána, socraithe ag a modhnóirí, agus post amháin ag gach plána. Sin a choinníonn na heochracha aicearra ó bheith ag cumasc le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá bhfuil rud ina chónaí.

| Plána | Cad atá ina chónaí ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` lánscáileán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` seat scáileáin |

Má chuireann tú `Alt` le heochair aicearra tugann sé leagan malartach den rud céanna duit, ní rud éigin neamhghaolmhar riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go lánscáileán; téann `Super + Alt + F` go lánleithead
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé seat scáileáin

Agus eochair aicearra á cur leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair aicearra atá ann cheana le spás a dhéanamh. Aimsigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach le haghaidh leagan malartach den eochair aicearra gan é.

Briseann roinnt eochracha aicearra na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Is eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair go dteastaíonn `Super + Shift + S` uait le haghaidh seatanna scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Eangach aipeanna |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosú, srl)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún fuinneog             |
| `Ctrl + Alt + Del` | Dún na fuinneoga go léir |
| `Super + T`               | Scoránaigh fuinneog idir tíliú/ar snámh             |
| `Super + J` | Scoránaigh suíomh fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh fuinneog a phreabadh isteach i sticky'n'floating |
| `Super + L`               | Rothlaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L`         | Rothlaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl bhréagfhuinneoige (nádúrtha v stráice) |
| `Super + F`                 | Téigh go lánscáileán              |
| `Super + Alt + F`                 | Téigh go lánleithead              |
| `Super + Ctrl + F`                 | Téigh go lánscáileán taobh istigh den fhuinneog              |
| `Super + 1/2/3/4`         | Léim go spás oibre ar leith ar an monatóir faoi fhócas |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir faoi fhócas |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe seo ar an monatóir faoi fhócas |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir faoi fhócas |
| `Super + Shift + 1/2/3/4` | Bog fuinneog go spás oibre ar an monatóir faoi fhócas |
| `Super + Shift + Alt + 1/2/3/4` | Bog fuinneog go spás oibre ar an monatóir faoi fhócas gan dul ina diaidh |
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
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing fuinneog timpeall |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir faoi fhócas |
| `Super + G`               | Scoránaigh grúpáil fuinneoige      |
| `Super + Alt + G`               | Bog fuinneog amach as grúpáil      |
| `Super + Alt + Tab`               | Rothlaigh idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Shift + Tab`               | Rothlaigh ar gcúl idir fuinneoga sa ghrúpáil      |
| `Super + Alt + Scroll Wheel` | Rothlaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog ar leith sa ghrúpáil      |
| `Super + Alt + Arrow`  | Bog fuinneog isteach sa ghrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga taobh istigh de ghrúpa tílithe |
| `Super + Ctrl + Z` | Zúmáil isteach ar an scáileán (arís le haghaidh tuilleadh zúmála) |
| `Super + Ctrl + Alt + Z` | Zúmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Rothlaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Rothlaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Rothlaigh fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Rothlaigh fócas ar gcúl trí mhonatóirí |

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá clóite ar an méarchlár. Ar mhéarchláir US is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is `Super + Equal` é `Super + ^`, agus is `Super + Shift + Minus` é `Super + Shift + -` (a chlóscríobhann `=`).

## Rialuithe córais

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painéal fuaime    |
| `Super + Ctrl + B`           | Painéal Bluetooth    |
| `Super + Ctrl + N`           | Painéal Wifi/líonra    |
| `Super + Ctrl + D`           | Painéal taispeána    |
| `Super + Ctrl + P`           | Painéal cumhachta    |
| `Super + Ctrl + X`           | Painéal gníomhairí    |
| `Super + Ctrl + Alt + D`           | Painéal féilire    |
| `Super + Ctrl + Alt + E`           | Painéal clog domhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal barra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (via LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (seat scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir Emoji |
| `Super + Ctrl + .` | Traschódaigh meáin |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |

## Coigeartuithe

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile scáileáin |
| `Shift + Brightness Down` | Íosghile scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar ghile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar thoirt |
| `Keyboard Brightness Up/Down` | Cúlsholas méarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Rothlaigh leibhéil chúlsholais an mhéarchláir |
| `Alt + Play` | An chéad traic eile |
| `Alt + Shift + Play` | Traic roimhe seo |

## Aipeanna a sheoladh

| Eochair Aicearra                  | Feidhm              |
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

Athraigh/cuir ceangaltáin leis in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + A`           | Roghnaigh uile in aipeanna a thacaíonn le `Ctrl + A`    |
| `Super + C`           | Cóipeáil    |
| `Super + X`           | Gearr (ní sa teirminéal)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, bíonn `Ctrl + Shift + C/V` de dhíth ort chun cóipeáil's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha aicearra gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Eochair Aicearra              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Seat scáileáin                      |
| `Super + Ctrl + Alt + C`            | Seat scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs go dtí an ghearrthaisce |
| `Super + Alt + [` | Déan forleagan ceamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan ceamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ó webapp nó Chromium |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha go `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Setup > Defaults > Dictation_) |
| `Right Alt` | Coinnigh síos chun deachtú (teastaíonn _Setup > Defaults > Dictation_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair aicearra ar dtús cén fhuaim atá uait, ansin tosaíonn sé ag taifeadadh. Buail arís é chun stopadh. Féach [seatanna scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála inrochtana freisin faoi _Trigger > Capture_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh a aon chnaipe amháin, roghnaigh óna roghanna, nó díbh é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Díbh na fógraí go léir |
| `Super + Ctrl + ,` | Rialú fógraí leis an méarchlár  |
| `Super + Alt + ,` | Díbh an fógra is déanaí  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh tostú fógraí  |

## Stíl

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnógach aonfhuinneoige |

Tá íomhánna cúlra breise ina gcónaí in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin trí _Install > Style > Background_ i roghchlár Omarchy.

Tá gach rogha stíle inrochtana freisin faoi _Style_ i roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil nuair atá díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint ríomhaire glúine ar siúl/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú taispeána ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra barr  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneoige |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc lánscáileáin (barra barr + bearnaí fuinneoige) |

## Meabhrúcháin

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach na meabhrúcháin go léir  |
| `Super + Ctrl + Shift + R` | Glan na meabhrúcháin go léir  |

## Fógraí eolais

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin ceallra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh aimsir mar fhógra  |

## Tmux

Is í `Ctrl + Space` an eochair réimíre (`Ctrl + B` a oibríonn freisin). Is féidir leat na ceangaltáin seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt pána thíos (cothrománach) |
| `Prefix + x` | Maraigh pána |
| `Prefix + z` | Scoránaigh zúmáil pána (lánscáileán) |
| `Alt + Enter` | Scoilt pána thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánaí |

### Fuinneoga

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh fuinneog |
| `Prefix + r` | Athainmnigh fuinneog |
| `Alt + 1-9` | Téigh go fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog fuinneog ar chlé/ar dheis |

### Seisiúin

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh seisiún |
| `Prefix + R` | Athainmnigh seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | Seisiún roimhe seo |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scar ó sheisiún |

### Mód cóipeála (stíl vi)

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach i mód cóipeála |
| `v` | Tosaigh roghnú (i mód cóipeála) |
| `y` | Cóipeáil roghnú (i mód cóipeála) |

### Ginearálta

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil cumraíocht |
| `Prefix + ?` | Taispeáin ceangaltáin eochrach Tmux |
| `Prefix + :` | Pras ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fhochomhadlann |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty trí _Install > Terminal_ a úsáid trí roghchlár Omarchy.

| Eochair Aicearra                  | Feidhm              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
| `Ctrl + Shift + O` | Scoilt nua in aice leis |
| `Ctrl + Alt + Arrows` | Bog idir scoilteanna |
| `Super + Ctrl + Shift + Arrows` | Athraigh méid na scoilte faoi 10 líne |
| `Super + Ctrl + Shift + Alt + Arrows` | Athraigh méid na scoilte faoi 100 líne |
| `Ctrl + Shift + T` | Táb nua  |
| `Ctrl + Shift + Arrows` | Bog idir tábaí |
| `Alt + Numbers` | Téigh go táb ar leith |
| `Shift + Pg Up/Down` | Scrollaigh an stair |
| `Ctrl + Left mouse` | Oscail nasc sa brabhsálaí |

## Bainisteoir Comhad

| Eochair Aicearra              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Téigh go conair                     |
| `Space`               | Réamhamharc ar chomhad (déanann saigheada nascleanúint) |
| `Alt + Up`       | Téigh suas go dtí an fillteán tuismitheora        |

## Neovim (le lazyvim)

### Nascleanúint

| Eochair Aicearra                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Taispeáin roghanna ordaithe            |
| `Space Space`              | Oscail comhad trí chuardach doiléir      |
| `Space E`                  | Scoránaigh barra taoibh                  |
| `Space G G`                | Taispeáin rialuithe git               |
| `Space S G`                | Cuardaigh ábhar comhaid             |
| `Ctrl + W W`               | Léim idir barra taoibh agus eagarthóir |
| `Ctrl + Left/right arrow`  | Athraigh méid an bharra taoibh          |
| `Shift + H`                      | Téigh go táb comhaid ar chlé             |
| `Shift + L`                      | Téigh go táb comhaid ar dheis            |
| `Space B D`                | Dún táb comhaid                  |

### Agus tú sa bharra taoibh

| Eochair Aicearra                   | Feidhm                        |
| ------------------------ | ------------------------------- |
| `A`                        | Cuir comhad nua leis i gcomhadlann tuismitheora      |
| `Shift + A`                | Cuir fochomhadlann nua leis i gcomhadlann tuismitheora    |
| `D`                        | Scrios comhad/comhadlann aibhsithe     |
| `M`                        | Bog comhad/comhadlann aibhsithe       |
| `R`                        | Athainmnigh comhad/comhadlann aibhsithe     |
| `?`                        | Taispeáin cabhair do na horduithe go léir      |

[Féach na heochracha aicearra Neovim go léir atá cumraithe ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Tapa

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana tapa seo a úsáid.

| Eochair Aicearra       | EM | Leid       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | miongháire      |
| `Shift + CapsLock M C` | 😂 | gol        |
| `Shift + CapsLock M L` | 😍 | grá       |
| `Shift + CapsLock M V` | ✌️ | bua    |
| `Shift + CapsLock M H` | ❤️ | croí      |
| `Shift + CapsLock M Y` | 👍 | sea        |
| `Shift + CapsLock M N` | 👎 | ní hea         |
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
| `Shift + CapsLock M G` |👋 | beannú |
| `Shift + CapsLock M A` |💪 | lámh |
| `Shift + CapsLock M B` |🤯 | séideadh |

## Críochnaithe Tapa

| Eochair Aicearra       | Críochnú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach ag an socrú)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach ag an socrú)  |

Is féidir leat níos mó díot féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy-restart-xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
