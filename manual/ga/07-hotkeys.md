# Eochracha Teo

Is féidir leat na príomhcheangail méarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Mar atá eochracha teo leagtha amach

Suíonn gach eochair the ar phlána, arna shocrú ag a modhnóirí, agus tá post amháin ag gach plána. Sin a choinníonn na heochracha teo ó bheith ag cumasc le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` seat scáileáin |

Má chuireann tú `Alt` le heochair the gheobhaidh tú leagan malartach den rud céanna, ní rud gan gaol leis riamh:

- `Super + Shift + B` osclaíonn sé an brabhsálaí; `Super + Shift + Alt + B` osclaíonn sé fuinneog phríobháideach
- `Super + Shift + E` osclaíonn sé ríomhphost; `Super + Shift + Alt + E` tosaíonn sé ceann nua
- `Super + F` téann sé go scáileán iomlán; `Super + Alt + F` téann sé go leithead iomlán
- `Super + Ctrl + C` osclaíonn sé an roghchlár gabhála; `Super + Ctrl + Alt + C` scipeálann sé an roghchlár agus tógann sé seat scáileáin

Agus eochair the á cur leis:

1. Roghnaigh an plána ón méid a dhéanann sé, ansin roghnaigh an eochair.
2. Ná bog eochair the atá ann cheana le spás a dhéanamh. Aimsigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach amháin le haghaidh leagan malartach den eochair the gan é.

Briseann cúpla eochair the na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh seatanna scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Space`           | Roghchlár Omarchy (aipeanna agus gach rud eile)    |
| `Super + Alt + Space` | Eangach aipeanna |
| `Super + Escape` | Roghchlár córais (cuir ar fionraí, atosú, srl)  |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún fuinneog             |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + K` | Taispeáin gach eochair the |
| `Super + Alt + K` | Taispeáin eochracha teo tmux |
| `Super + Ctrl + K` | Taispeáin eochracha teo herdr |
| `Super + M` | Íoslaghdaigh fuinneog chuig an doca |
| `Super + T`               | Scoránaigh fuinneog idir tíliú/ar snámh             |
| `Super + J` | Scoránaigh suíomh na fuinneoige (cothrománach/ingearach) |
| `Super + O`               | Scoránaigh fuinneog a phreabadh isteach i mód greamaitheach agus ar snámh |
| `Super + L`               | Timthriallaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L`         | Timthriallaigh trí na leaganacha amach ar gcúl |
| `Super + P`               | Scoránaigh stíl bhréagfhuinneoige (nádúrtha v síneadh) |
| `Super + F`                 | Téigh go scáileán iomlán              |
| `Super + Alt + F`                 | Téigh go leithead iomlán              |
| `Super + Ctrl + F`                 | Téigh go scáileán iomlán taobh istigh den fhuinneog              |
| `Super + 1…9/0`         | Léim go spás oibre ar leith (is é 0 ná 10) ar an monatóir atá i bhfócas |
| `Super + Tab` | Léim go dtí an chéad spás oibre eile ar an monatóir atá i bhfócas |
| `Super + Shift + Tab` | Léim go dtí an spás oibre roimhe seo ar an monatóir atá i bhfócas |
| `Super + Ctrl + Tab` | Léim go dtí an spás oibre a bhí ann roimhe ar an monatóir atá i bhfócas |
| `Super + Shift + 1…9/0` | Bog fuinneog go spás oibre ar an monatóir atá i bhfócas |
| `Super + Shift + Alt + 1…9/0` | Bog fuinneog go spás oibre ar an monatóir atá i bhfócas gan leanúint léi |
| `Super + S` | Scoránaigh scratchpad iomlán |
| `Super + Alt + S` | Bog fuinneog go scratchpad iomlán |
| `Super + the key above Tab` (grave ar leaganacha amach SAM) | Scoránaigh consól Quake |
| `Super + Shift + the key above Tab` (grave ar leaganacha amach SAM) | Bog fuinneog go consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog fuinneog go dtí an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog spás oibre go dtí an monatóir sa treo sin |
| `Super + Arrow`  | Bog fócas go fuinneog i dtreo na saighde, ag trasnú go dtí an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow`  | Babhtáil fuinneog le ceann eile i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Minus` | Leathnaigh fuinneog ar chlé |
| `Super + Equal` | Crap fuinneog ar chlé |
| `Super + Shift + Minus` | Crap fuinneog suas |
| `Super + Shift + Equal` | Leathnaigh fuinneog síos |
| `Super + Alt + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos lú |
| `Super + Ctrl + Minus/Equal` | An t-athrú méide céanna i gcéimeanna níos mó |
| `Super + Alt + Home` | Sábháil leithead na fuinneoige |
| `Super + Home` | Athchóirigh leithead sábháilte na fuinneoige |
| `Super + Left Mouse` | Tarraing fuinneog thart |
| `Super + Right Mouse` | Athraigh méid na fuinneoige |
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir atá i bhfócas |
| `Super + G`               | Scoránaigh grúpáil fuinneog      |
| `Super + Alt + G`               | Bog fuinneog amach as grúpáil      |
| `Super + Alt + Tab`               | Timthriallaigh idir fuinneoga i ngrúpáil      |
| `Super + Alt + Shift + Tab`               | Timthriallaigh ar gcúl idir fuinneoga i ngrúpáil      |
| `Super + Alt + Scroll Wheel` | Timthriallaigh idir fuinneoga i ngrúpáil |
| `Super + Alt + 1/2/3/4/5`               | Léim go fuinneog ar leith i ngrúpáil      |
| `Super + Alt + Arrow`  | Bog fuinneog isteach i ngrúpáil i dtreo na saighde, lena n-áirítear ceann ar an monatóir ar an taobh sin |
| `Super + Ctrl + Left/Right`  | Bog idir fuinneoga taobh istigh de ghrúpa tílithe |
| `Super + Ctrl + Z` | Súmáil isteach ar an scáileán (arís le haghaidh tuilleadh súmála) |
| `Super + Ctrl + Alt + Z` | Súmáil amach go hiomlán ón scáileán |
| `Super + /` | Céim ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céim ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Timthriallaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Timthriallaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Timthriallaigh fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Timthriallaigh fócas ar gcúl trí mhonatóirí |
| `Super + I` | Athraigh teanga ionchuir (le níos mó ná leagan amach nó modh ionchuir amháin) |
| `Super + Shift + I` | Athraigh teanga ionchuir ar ais |

Ar thaibhléad tadhaill, aistríonn svaidhpeanna trí mhéar agus ceithre mhéar spásanna oibre, bogann siad fuinneoga, agus osclaíonn siad an roghchlár agus consól Quake; féach [méarchlár, luch, agus taibhléad tadhaill](34-keyboard-mouse-trackpad.md) le haghaidh na ngothaí.

Úsáideann aicearraí athraithe méide eochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá clóite ar an méarchlár. Ar mhéarchláir SAM is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`.

## Rialuithe córais

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Painéal fuaime    |
| `Super + Ctrl + B`           | Painéal Bluetooth    |
| `Super + Ctrl + N`           | Painéal Wifi/líonra    |
| `Super + Ctrl + D`           | Painéal taispeána    |
| `Super + Ctrl + P`           | Painéal cumhachta    |
| `Super + Ctrl + X`           | Painéal gníomhairí    |
| `Super + Ctrl + Alt + X`           | Painéal samhlacha áitiúla    |
| `Super + Ctrl + Alt + D`           | Painéal féilire    |
| `Super + Ctrl + Alt + E`           | Painéal cloig dhomhanda    |
| `Super + Ctrl + 1-9`           | Scoránaigh painéal barra de réir suímh    |
| `Super + Ctrl + S` | Roghchlár comhroinnte (via LocalSend) |
| `Super + Ctrl + C` | Rialuithe gabhála (seat scáileáin/-taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Scoránaigh roghchlár |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódaigh meáin |
| `Super + Shift + Ctrl + A` | Tosaigh do ghníomhaire réamhshocraithe |
| `Power` eochair | Roghchlár córais |
| `Super + Shift + Copilot` eochair | Roghchlár Omarchy |

## Coigeartuithe

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Uasghile scáileáin |
| `Shift + Brightness Down` | Íosghile scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar ghile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar thoirt |
| `Keyboard Brightness Up/Down` | Soilsiú cúil méarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Timthriallaigh leibhéil soilsiú cúil an mhéarchláir |
| `Ctrl + Brightness Up/Down` | Soilsiú cúil méarchláir níos gile/níos doiléire, ar mhéarchláir gan a n-eochracha féin |
| `Mic Mute` | Balbhaigh an micreafón |
| `Shift + Mute` | Athraigh aschur fuaime |
| `Touchpad Toggle` | Cas an taibhléad tadhaill air nó as |
| `Display` eochair | Timthriallaigh leagan amach an spáis oibre |
| `Alt + Play` | An chéad rian eile |
| `Alt + Shift + Play` | Rian roimhe seo |

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
| `Super + Shift + Q` or `Calculator` eochair  | Áireamhán (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, a luaithe a shuiteáiltear é)    |
| `Super + Shift + T`           | Gníomhaíocht (btop)    |
| `Super + Shift + N`           | Eagarthóir (Plain, nó do réamhshocrú roghnaithe)  |
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
| `Super + X`           | Gearr (ní sa teirminéal)    |
| `Super + V`           | Greamaigh    |
| `Super + Ctrl + V`           | Bainisteoir gearrthaisce    |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na heochracha teo gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Eochair The              | Feidhm                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Seat scáileáin                      |
| `Super + Ctrl + Alt + C`            | Seat scáileáin (an seat céanna, do mhéarchláir gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen`            | Taifeadadh scáileáin                     |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (buail arís é chun stopadh) |
| `Super + Print Screen` | Roghnóir dathanna |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan ceamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan ceamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ón aip ghréasáin nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha go `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Socrú > Réamhshocruithe > Deachtú_) |
| `Right Alt` | Coinnigh síos chun deachtú (teastaíonn _Socrú > Réamhshocruithe > Deachtú_) |

Le taifeadtaí scáileáin, fiafraíonn an eochair the ar dtús cén fhuaim atá uait, ansin tosaíonn sí ag taifeadadh. Buail arís í chun stopadh. Féach [seatanna scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála ar fáil freisin faoi _Spreagadh > Gabháil_ sa roghchlár Omarchy (`Super + Space`).

## Fógraí

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh a aon chnaipe amháin, roghnaigh óna roghanna, nó cuir ar ceal é nuair nach bhfuil aon cheann aige  |
| `Super + Shift + ,` | Cuir gach fógra ar ceal |
| `Super + Ctrl + ,` | Rialú fógraí leis an méarchlár  |
| `Super + Alt + ,` | Cuir an fógra is déanaí ar ceal  |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí  |
| `Super + Ctrl + Alt + ,` | Scoránaigh tostú fógraí  |

## Stíl

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnógach aonfhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin via _Suiteáil > Stíl > Cúlra_ sa roghchlár Omarchy.

Tá gach rogha stíle ar fáil freisin faoi _Cuma_ sa roghchlár Omarchy (`Super + Space`).

## Scoránaigh

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil agus díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine air/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra barr  |
| `Shift + Mute` | Athraigh go dtí an chéad aschur fuaime eile |
| `Shift + Play` | Athraigh go dtí an chéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneog |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc scáileáin iomláin (barra barr + bearnaí fuinneog) |

## Meabhrúcháin

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán  |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán  |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán  |

## Nótaí

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin am mar fhógra  |
| `Super + Ctrl + Alt + B` | Taispeáin ceallra mar fhógra  |
| `Super + Ctrl + Alt + W` | Scoránaigh aimsir mar fhógra  |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt pána thíos (cothrománach) |
| `Prefix + x` | Maraigh pána |
| `Prefix + z` | Scoránaigh súmáil pána (scáileán iomlán) |
| `Alt + Enter` | Scoilt pána thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid pánaí |

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
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + [` | Téigh isteach i mód cóipeála |
| `v` | Tosaigh roghnú (i mód cóipeála) |
| `y` | Cóipeáil roghnú (i mód cóipeála) |

### Ginearálta

| Eochair The                  | Feidhm              |
| ----------------------- | --------------------- |
| `Prefix + q` | Athlódáil cumraíocht |
| `Prefix + ?` | Taispeáin ceangail eochracha Tmux |
| `Prefix + :` | Leid ordaithe |

### Feidhmeanna leagan amach Tmux

Ní mór na feidhmeanna seo a rith taobh istigh de sheisiún Tmux.

| Ordú | Feidhm |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha le heagarthóir, AI, agus teirminéal |
| `tdlm <ai> [<second_ai>]` | Cruthaigh leagan amach forbartha in aghaidh an fhofhillteáin |
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty ag baint úsáide as _Suiteáil > Teirminéal_ trí roghchlár Omarchy.

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
| `Space Space`              | Oscail comhad via cuardach doiléir      |
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
| `A`                        | Cuir comhad nua leis san fhillteán tuismitheora      |
| `Shift + A`                | Cuir fofhillteán nua leis san fhillteán tuismitheora    |
| `D`                        | Scrios comhad/fillteán aibhsithe     |
| `M`                        | Bog comhad/fillteán aibhsithe       |
| `R`                        | Athainmnigh comhad/fillteán aibhsithe     |
| `?`                        | Taispeáin cabhair le haghaidh gach ordú      |

[Féach gach eochair the Neovim arna cumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emojis Gasta

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana gasta seo a úsáid.

| Eochair The       | EM | Leid       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | aoibh      |
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
| `Shift + CapsLock M E` | 🙄 | rolladh súile    |
| `Shift + CapsLock M I` | 😉 | caochadh       |
| `Shift + CapsLock M P` | 🙏 | paidir |
| `Shift + CapsLock M D` | 🤤 | prislín      |
| `Shift + CapsLock M M` | 💰 | airgead      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tósta      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannacht |
| `Shift + CapsLock M A` |💪 | géag |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánuithe Gasta

| Eochair The       | Comhlánú       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach é ag an socrú)  |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach é ag an socrú)  |

Is féidir leat níos mó díot féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy restart xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
