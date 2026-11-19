# Aicearraí

Is féidir leat na príomhcheangail mhéarchláir go léir a fheiceáil le `Super + K` (ceangail Tmux le `Super + Alt + K` agus ceangail Herdr le `Super + Ctrl + K`).

## Conas a leagtar amach aicearraí

Suíonn gach aicearra ar phlána, arna shocrú ag a mhionathraitheoirí, agus tá post amháin ag gach plána. Sin a choinníonn na haicearraí ó bheith ag meascadh le chéile, agus ciallaíonn sé gur féidir leat buille faoi thuairim a thabhairt de ghnáth cá gcónaíonn rud éigin.

| Plána | Cad a chónaíonn ann | Samplaí |
| --- | --- | --- |
| `Super + key` | An córas: fuinneoga, spásanna oibre, leaganacha amach, agus croí-roghchláir | `Super + Space` roghchlár Omarchy, `Super + W` dún fuinneog, `Super + F` scáileán iomlán |
| `Super + Shift + key` | Aipeanna | `Super + Shift + B` brabhsálaí, `Super + Shift + E` ríomhphost, `Super + Shift + N` eagarthóir |
| `Super + Ctrl + key` | Painéil agus roghchláir chórais | `Super + Ctrl + A` fuaim, `Super + Ctrl + N` líonra, `Super + Ctrl + C` roghchlár gabhála |
| `Super + Ctrl + Alt + key` | Gníomhartha gasta agus fógraí | `Super + Ctrl + Alt + T` taispeáin an t-am, `Super + Ctrl + Alt + B` ceallra, `Super + Ctrl + Alt + C` gabháil scáileáin |

Má chuireann tú `Alt` le haicearra, tugtar malairt den rud céanna duit, ní rud éigin gan bhaint riamh:

- Osclaíonn `Super + Shift + B` an brabhsálaí; osclaíonn `Super + Shift + Alt + B` fuinneog phríobháideach
- Osclaíonn `Super + Shift + E` ríomhphost; tosaíonn `Super + Shift + Alt + E` ceann nua
- Téann `Super + F` go scáileán iomlán; téann `Super + Alt + F` go leithead iomlán
- Osclaíonn `Super + Ctrl + C` an roghchlár gabhála; scipeálann `Super + Ctrl + Alt + C` an roghchlár agus tógann sé gabháil scáileáin

Agus aicearra á chur leis:

1. Roghnaigh an plána óna ndéanann sé, ansin roghnaigh an eochair.
2. Ná bog aicearra atá ann cheana chun spás a dhéanamh. Faigh eochair shaor ar an bplána ceart.
3. Ná húsáid `Alt` ach amháin le haghaidh malairte den aicearra gan é.

Briseann cúpla aicearra na rialacha seo mar go bhfuil siad áisiúil. Bogann nó aisiompaíonn `Shift` le saighead nó `Tab` in ionad aip a oscailt, agus oibríonn `Print`, na heochracha meán, `Alt + Tab`, agus `Ctrl + Alt + Del` mar a oibríonn siad i ngach áit eile. Eisceachtaí iad, ní patrúin le cóipeáil.

Mura n-oireann réamhshocrú duit (abair gur mian leat `Super + Shift + S` le haghaidh gabhálacha scáileáin mar atá ar Windows), athcheangail é in `~/.config/hypr/bindings.lua`.

## Nascleanúint

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Space` | Roghchlár Omarchy (aipeanna agus gach rud eile) |
| `Super + Alt + Space` | Greille aipeanna |
| `Super + Escape` | Roghchlár an chórais (cuir ar fionraí, atosaigh, srl) |
| `Super + Ctrl + L` | Glasáil an ríomhaire |
| `Super + W` or `Super + Q` | Dún an fhuinneog |
| `Ctrl + Alt + Del` | Dún gach fuinneog |
| `Super + T` | Scoránaigh fuinneog idir tíliú/ar snámh |
| `Super + J` | Scoránaigh suíomh fuinneoige (cothrománach/ingearach) |
| `Super + O` | Scoránaigh fuinneog ag preabadh isteach i sticky'n'floating |
| `Super + L` | Timthriallaigh trí na leaganacha amach dwindle, scrollaithe, agus ar snámh |
| `Super + Alt + L` | Timthriallaigh trí na leaganacha amach ar gcúl |
| `Super + P` | Scoránaigh stíl bhréagfhuinneoige (nádúrtha v sínte) |
| `Super + F` | Téigh go scáileán iomlán |
| `Super + Alt + F` | Téigh go leithead iomlán |
| `Super + Ctrl + F` | Téigh go scáileán iomlán taobh istigh den fhuinneog |
| `Super + 1/2/3/4` | Léim chuig spás oibre ar leith ar an monatóir faoi fhócas |
| `Super + Tab` | Léim chuig an gcéad spás oibre eile ar an monatóir faoi fhócas |
| `Super + Shift + Tab` | Léim chuig an spás oibre roimhe seo ar an monatóir faoi fhócas |
| `Super + Ctrl + Tab` | Léim chuig an iarspás oibre ar an monatóir faoi fhócas |
| `Super + Shift + 1/2/3/4` | Bog fuinneog chuig spás oibre ar an monatóir faoi fhócas |
| `Super + Shift + Alt + 1/2/3/4` | Bog fuinneog chuig spás oibre ar an monatóir faoi fhócas gan í a leanúint |
| `Super + S` | Scoránaigh an leabhar nótaí iomlán |
| `Super + Alt + S` | Bog fuinneog chuig an leabhar nótaí iomlán |
| `Super + Grave` | Scoránaigh consól Quake |
| `Super + Shift + Grave` | Bog fuinneog chuig consól Quake |
| `Super + Shift + Ctrl + Arrows` | Bog fuinneog chuig an monatóir sa treo sin |
| `Super + Shift + Alt + Arrows` | Bog spás oibre chuig an monatóir sa treo sin |
| `Super + Arrow` | Bog an fócas chuig fuinneog i dtreo na saighde, ag trasnú chuig an monatóir ar an taobh sin ag imeall an scáileáin |
| `Super + Shift + Arrow` | Malartaigh fuinneog le ceann eile i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
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
| `Super + Scroll Wheel` | Scrollaigh trí spásanna oibre ar an monatóir faoi fhócas |
| `Super + G` | Scoránaigh grúpáil fuinneog |
| `Super + Alt + G` | Bog fuinneog amach as an ngrúpáil |
| `Super + Alt + Tab` | Timthriallaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + Shift + Tab` | Timthriallaigh ar gcúl idir fuinneoga sa ghrúpáil |
| `Super + Alt + Scroll Wheel` | Timthriallaigh idir fuinneoga sa ghrúpáil |
| `Super + Alt + 1/2/3/4/5` | Léim chuig fuinneog ar leith sa ghrúpáil |
| `Super + Alt + Arrow` | Bog fuinneog isteach sa ghrúpáil i dtreo na saighde, ceann ar an monatóir ar an taobh sin san áireamh |
| `Super + Ctrl + Left/Right` | Bog idir fuinneoga taobh istigh de ghrúpa tílíthe |
| `Super + Ctrl + Z` | Zúmáil isteach ar an scáileán (athdhéan le haghaidh tuilleadh zúmála) |
| `Super + Ctrl + Alt + Z` | Zúmáil amach go hiomlán ón scáileán |
| `Super + /` | Céimnigh ar aghaidh trí roghanna scálaithe monatóra |
| `Super + Alt + /` | Céimnigh ar gcúl trí roghanna scálaithe monatóra |
| `Alt + Tab` | Timthriallaigh ar aghaidh trí fhuinneoga ar an spás oibre gníomhach |
| `Alt + Shift + Tab` | Timthriallaigh ar gcúl trí fhuinneoga ar an spás oibre gníomhach |
| `Ctrl + Alt + Tab`| Timthriallaigh an fócas ar aghaidh trí mhonatóirí |
| `Ctrl + Alt + Shift + Tab`| Timthriallaigh an fócas ar gcúl trí mhonatóirí |

Úsáideann aicearraí athraithe méide na heochracha fisiciúla `code:20` agus `code:21` (XKB `<AE11>` agus `<AE12>`), beag beann ar na carachtair atá clóite ar an méarchlár. Ar mhéarchláir US is iad `-` agus `=` na heochracha seo; ar mhéarchláir Sheapánacha (JIS) is iad `-` agus `^` iad; ar mhéarchláir Spáinneacha is iad `'` agus `¡` iad. Ar JIS, is é `Super + ^` ná `Super + Equal`, agus is é `Super + Shift + -` (a chlóscríobhann `=`) ná `Super + Shift + Minus`.

## Rialtáin chórais

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Painéal fuaime |
| `Super + Ctrl + B` | Painéal Bluetooth |
| `Super + Ctrl + N` | Painéal Wifi/líonra |
| `Super + Ctrl + D` | Painéal taispeána |
| `Super + Ctrl + P` | Painéal cumhachta |
| `Super + Ctrl + X` | Painéal gníomhairí |
| `Super + Ctrl + Alt + D` | Painéal féilire |
| `Super + Ctrl + Alt + E` | Painéal cloig dhomhanda |
| `Super + Ctrl + 1-9` | Scoránaigh painéal an bharra de réir suímh |
| `Super + Ctrl + S` | Roghchlár comhroinnte (via LocalSend) |
| `Super + Ctrl + C` | Rialtáin gabhála (gabháil scáileáin/taifeadadh/roghnóir) |
| `Super + Ctrl + O` | Roghchlár scoránaithe |
| `Super + Ctrl + H` | Roghchlár crua-earraí |
| `Super + Ctrl + E` | Roghnóir emoji |
| `Super + Ctrl + .` | Traschódaigh meáin |
| `Super + Shift + Ctrl + A` | Roghnaigh gníomhaire AI |

## Coigeartuithe

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Gile uasta an scáileáin |
| `Shift + Brightness Down` | Gile íosta an scáileáin |
| `Alt + Brightness Up/Down` | Athruithe beachta 1% ar an ngile |
| `Alt + Volume Up/Down` | Athruithe beachta 1% ar an toirt |
| `Keyboard Brightness Up/Down` | Cúlsholas an mhéarchláir níos gile/níos doiléire |
| `Keyboard Backlight` | Timthriallaigh leibhéil chúlsholais an mhéarchláir |
| `Alt + Play` | An chéad rian eile |
| `Alt + Shift + Play` | An rian roimhe seo |

## Aipeanna a sheoladh

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Return` | Teirminéal |
| `Super + Alt + Return` | Teirminéal Tmux |
| `Super + Ctrl + Return` | Herdr (bainisteoir gníomhairí) |
| `Super + Shift + Return` | Brabhsálaí |
| `Super + Shift + Alt + B` | Brabhsálaí (príobháideach/incognito) |
| `Super + Shift + F` | Bainisteoir comhad |
| `Super + Shift + Alt + F` | Bainisteoir comhad in cwd an teirminéil |
| `Super + Shift + M` | Ceol (Spotify) |
| `Super + Shift + Alt + M` | Ceol (cliamp) |
| `Super + Shift + /` | Bainisteoir pasfhocal (1password) |
| `Super + Shift + Q` | Áireamhán (Omacalc) |
| `Super + Shift + T` | Gníomhaíocht (btop) |
| `Super + Shift + N` | Eagarthóir (Neovim) |
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
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Athraigh/cuir ceangail leis in `~/.config/hypr/bindings.lua`.

## Gearrthaisce uilíoch

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + A` | Roghnaigh gach rud in aipeanna a thacaíonn le `Ctrl + A` |
| `Super + C` | Cóipeáil |
| `Super + X` | Gearr (ní sa teirminéal) |
| `Super + V` | Greamaigh |
| `Super + Ctrl + V` | Bainisteoir gearrthaisce |

De ghnáth ar Linux, teastaíonn `Ctrl + Shift + C/V` uait chun cóipeáil's greamú a dhéanamh sa teirminéal agus `Ctrl + C/V` chun é a dhéanamh i ngach áit eile. Oibríonn na haicearraí gearrthaisce aontaithe Omarchy seo i ngach áit.

## Gabháil

| Aicearra | Feidhm |
| ------------------- | ------------------------------ |
| `Print Screen` | Gabháil scáileáin |
| `Super + Ctrl + Alt + C` | Gabháil scáileáin (an seat céanna, le haghaidh méarchlár gan eochair Print Screen) |
| `Super + Ctrl + C` | Roghchlár gabhála |
| `Alt + Print Screen` | Taifeadadh scáileáin |
| `Super + Shift + Ctrl + Alt + C` | Taifeadadh scáileáin gan fuaim, ag scipeáil an roghchláir (buail arís chun stopadh) |
| `Super + Print Screen` | Roghnóir datha |
| `Super + Ctrl + Print Screen` | Eastóscadh téacs chuig an ngearrthaisce |
| `Super + Alt + [` | Déan forleagan an cheamara gréasáin níos lú agus tú ag taifeadadh |
| `Super + Alt + ]` | Déan forleagan an cheamara gréasáin níos mó agus tú ag taifeadadh |
| `Alt + Shift + L` | Cóipeáil an URL reatha ó webapp nó ón mbrabhsálaí |
| `Alt + Shift + D` | Íoslódáil an físeán ar an leathanach reatha chuig `~/Videos` |
| `Alt + Space` | Tosaigh/stop deachtú (teastaíonn _Socruithe > Réamhshocruithe > Deachtú_) |
| `Right Alt` | Coinnigh chun deachtú (teastaíonn _Socruithe > Réamhshocruithe > Deachtú_) |

Le taifeadtaí scáileáin, fiafraíonn an t-aicearra ar dtús cén fhuaim atá uait, ansin tosaíonn sé ag taifeadadh. Buail arís é chun stopadh. Féach [gabhálacha scáileáin agus taifeadadh](12-screenshots-recording.md) le haghaidh na sonraí.

Tá gach rogha gabhála inrochtana freisin faoi _Truicear > Gabháil_ i roghchlár Omarchy (`Super + Space`).

## Fógraí

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + ,` | Gníomhaigh ar an bhfógra is déanaí: oscail é nó brúigh a chnaipe aonair, roghnaigh óna roghanna, nó caith uait é nuair nach bhfuil aon cheann aige |
| `Super + Shift + ,` | Caith uait gach fógra |
| `Super + Ctrl + ,` | Rialú fógraí leis an méarchlár |
| `Super + Alt + ,` | Caith uait an fógra is déanaí |
| `Super + Shift + Alt + ,` | Oscail stair na bhfógraí |
| `Super + Ctrl + Alt + ,` | Scoránaigh tostú fógraí |

## Stíl

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Roghnaigh téama nua (freisin `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Roghnaigh cúlra an téama (freisin `Super + Ctrl + Space`) |
| `Super + Backspace` | Scoránaigh trédhearcacht ar fhuinneog |
| `Super + Ctrl + Backspace` | Scoránaigh gné chearnach aonfhuinneoige |

Cónaíonn íomhánna cúlra breise in `~/.config/omarchy/backgrounds/<theme name>`. Ar fáil freisin via _Suiteáil > Stíl > Cúlra_ i roghchlár Omarchy.

Tá gach rogha stíle inrochtana freisin faoi _Stíl_ i roghchlár Omarchy (`Super + Space`).

## Scoráin

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Scoránaigh glasáil agus díomhaoin |
| `Super + Ctrl + Delete` | Scoránaigh taispeáint an ríomhaire glúine ar siúl/as |
| `Super + Ctrl + Alt + Delete` | Scoránaigh scáthánú thaispeáint an ríomhaire glúine |
| `Super + Shift + Space` | Scoránaigh an barra uachtarach |
| `Shift + Mute` | Athraigh chuig an gcéad aschur fuaime eile |
| `Shift + Play` | Athraigh chuig an gcéad fhoinse meán eile |
| `Super + Shift + Backspace` | Scoránaigh bearnaí fuinneoige |
| `Super + Ctrl + Alt + F` | Scoránaigh deasc scáileáin iomláin (barra uachtarach + bearnaí fuinneoige) |

## Meabhrúcháin

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Socraigh meabhrúchán |
| `Super + Ctrl + Alt + R` | Féach gach meabhrúchán |
| `Super + Ctrl + Shift + R` | Glan gach meabhrúchán |

## Fógraí gearra

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Taispeáin an t-am mar fhógra |
| `Super + Ctrl + Alt + B` | Taispeáin an ceallra mar fhógra |
| `Super + Ctrl + Alt + W` | Scoránaigh an aimsir mar fhógra |

## Tmux

Is í an eochair réimíre ná `Ctrl + Space` (oibríonn `Ctrl + B` freisin). Is féidir leat na ceangail seo a athrú in `~/.config/tmux/tmux.conf`.

### Pánaí

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + v` | Scoilt pána in aice leis (ingearach) |
| `Prefix + h` | Scoilt pána thíos (cothrománach) |
| `Prefix + x` | Maraigh an pána |
| `Prefix + z` | Scoránaigh zúmáil an phána (scáileán iomlán) |
| `Alt + Enter` | Scoilt pána thíos (gan réimír) |
| `Alt + Shift + Enter` | Scoilt pána in aice leis (gan réimír) |
| `Alt + Escape` | Maraigh an pána (gan réimír) |
| `Ctrl + Alt + Arrows` | Bog idir pánaí |
| `Ctrl + Alt + Shift + Arrows` | Athraigh méid na bpánaí |

### Fuinneoga

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + c` | Fuinneog nua |
| `Prefix + k` | Maraigh an fhuinneog |
| `Prefix + r` | Athainmnigh an fhuinneog |
| `Alt + 1-9` | Téigh chuig fuinneog ar leith |
| `Alt + Arrow Left/Right` | Bog idir fuinneoga |
| `Alt + Shift + Arrow Left/Right` | Bog an fhuinneog ar chlé/ar dheis |

### Seisiúin

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + C` | Seisiún nua |
| `Prefix + K` | Maraigh an seisiún |
| `Prefix + R` | Athainmnigh an seisiún |
| `Prefix + N` | An chéad seisiún eile |
| `Prefix + P` | An seisiún roimhe seo |
| `Alt + Arrow Up/Down` | Bog idir seisiúin |
| `Prefix + s` | Liostaigh seisiúin |
| `Prefix + d` | Scar ón seisiún |

### Mód cóipeála (stíl vi)

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Prefix + [` | Iontráil mód cóipeála |
| `v` | Tosaigh an roghnú (i mód cóipeála) |
| `y` | Cóipeáil an roghnú (i mód cóipeála) |

### Ginearálta

| Aicearra | Feidhm |
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
| `tsl <count> <command>` | Cruthaigh leagan amach saithe ilphána |

## Teirminéal Ghostty

Suiteáiltear teirminéal Ghostty ag úsáid _Suiteáil > Teirminéal_ via roghchlár Omarchy.

| Aicearra | Feidhm |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Scoilt nua thíos |
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

| Aicearra | Feidhm |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Téigh chuig an gcosán |
| `Space` | Réamhamharc ar chomhad (déanann saighead nascleanúint) |
| `Alt + Up` | Téigh suas chuig an máthairfhillteán |

## Neovim (w/ lazyvim)

### Nascleanúint

| Aicearra | Feidhm |
| ------------------------ | ------------------------------- |
| `Space` | Taispeáin roghanna ordaithe |
| `Space Space` | Oscail comhad via cuardach doiléir |
| `Space E` | Scoránaigh an barra taoibh |
| `Space G G` | Taispeáin rialtáin git |
| `Space S G` | Cuardaigh ábhar an chomhaid |
| `Ctrl + W W` | Léim idir an barra taoibh agus an t-eagarthóir |
| `Ctrl + Left/right arrow` | Athraigh méid an bharra taoibh |
| `Shift + H` | Téigh chuig an gcluaisín comhaid ar chlé |
| `Shift + L` | Téigh chuig an gcluaisín comhaid ar dheis |
| `Space B D` | Dún an cluaisín comhaid |

### Agus tú sa bharra taoibh

| Aicearra | Feidhm |
| ------------------------ | ------------------------------- |
| `A` | Cuir comhad nua leis sa mháthaireolaire |
| `Shift + A` | Cuir foeolaire nua leis sa mháthaireolaire |
| `D` | Scrios an comhad/eolaire aibhsithe |
| `M` | Bog an comhad/eolaire aibhsithe |
| `R` | Athainmnigh an comhad/eolaire aibhsithe |
| `?` | Taispeáin cabhair le haghaidh gach ordaithe |

[Féach na haicearraí Neovim go léir arna gcumrú ag LazyVim](https://www.lazyvim.org/keymaps).

## Emoji Gasta

Is féidir leat `Super + Ctrl + E` a úsáid chun roghnóir emoji iomlán a thaispeáint a chuirfidh an roghnú ar an ngearrthaisce nó is féidir leat na roghanna rochtana gasta seo a úsáid.

| Aicearra | EM | Leid |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | miongháire |
| `Shift + CapsLock M C` | 😂 | gol |
| `Shift + CapsLock M L` | 😍 | grá |
| `Shift + CapsLock M V` | ✌️ | bua |
| `Shift + CapsLock M H` | ❤️ | croí |
| `Shift + CapsLock M Y` | 👍 | sea |
| `Shift + CapsLock M N` | 👎 | ní hea |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | guí |
| `Shift + CapsLock M R` | 🤘 | rac |
| `Shift + CapsLock M K` | 😘 | póg |
| `Shift + CapsLock M E` | 🙄 | rolladh súl |
| `Shift + CapsLock M I` | 😉 | caochadh súile |
| `Shift + CapsLock M P` | 🙏 | guigh |
| `Shift + CapsLock M D` | 🤤 | ag prislíneacht |
| `Shift + CapsLock M M` | 💰 | airgead |
| `Shift + CapsLock M X` | 🎉 | ceiliúradh |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tósta |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | beannú |
| `Shift + CapsLock M A` |💪 | lámh |
| `Shift + CapsLock M B` |🤯 | ag séideadh |

## Comhlánuithe Gasta

| Aicearra | Comhlánú |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | D'ainm (mar a cuireadh isteach é le linn na socraithe) |
| `Shift + CapsLock Space E` | Do ríomhphost (mar a cuireadh isteach é le linn na socraithe) |

Is féidir leat tuilleadh de do chuid féin a chur leis trí `~/.XCompose` a chur in eagar, ansin `omarchy-restart-xcompose` a rith sa teirminéal chun na hathruithe a phiocadh suas.
