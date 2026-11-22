# Nuashonruithe

Coinnítear Omarchy agus do phacáistí cothrom le dáta trí _Nuashonrú > Omarchy_ sa roghchlár Omarchy (`Super + Space`).

Suiteáiltear Omarchy féin mar ghnáthphacáistí pacman ó [Stór Pacáistí Omarchy](https://github.com/omacom-io/omarchy-pkgs), mar sin suiteálann nuashonrú [an eisiúint is déanaí de Omarchy](https://github.com/omacom/omarchy/releases), ritheann sé aon aistrithe atá ar feitheamh chun do chóras a chur i sionc leis an gceann is déanaí, agus nuashonraíonn sé gach pacáiste córais ó [Scáthán Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) agus [AUR](https://aur.archlinux.org/) (má tá aon phacáistí AUR suiteáilte agat).

Nuair a dhéantar eisiúintí nua, beidh deilbhín saighead chiorclach le feiceáil ar dheis do chloig. Cliceáil air agus tosóidh an próiseas nuashonraithe.

![update-available](images/update-available.webp)

### Ceithre bhealach

Déantar Omarchy a nuashonrú ar cheithre bhealach: stable, RC, edge, agus dev. Tosaíonn suiteálacha nua ar an mbealach stable, a leanann na [heisiúintí oifigiúla](https://github.com/omacom/omarchy/releases/), chomh maith leis an [scáthán Arch Omarchy stable](https://github.com/omacom-io/omarchy-mirror) atá mí taobh thiar den cheann is déanaí, ionas gur féidir linn aon neamh-chomhoiriúnachtaí nua a dteastaíonn athruithe cumraíochta uathu a aimsiú sula gcuireann siad fadhbanna ar dhaoine.

Ach más mian leat cabhrú leis na fadhbanna féideartha sin a aimsiú, is féidir leat rith ar an mbealach edge. Coinneoidh sé sin do phacáistí Omarchy ag leanúint na bhforbairtí is déanaí, agus ligfidh sé duit nuashonrú chuig na pacáistí Arch is déanaí chomh luath agus a bhíonn siad ar fáil. Níor cheart duit é seo a dhéanamh ach amháin má tá taithí agat ar Linux, agus má tá a fhios agat conas córas a bhfuil fadhbanna aige a aisghabháil.

Roimh aon mhóreisiúint nua, déanfaimid bailíochtú deiridh ar an mbealach RC. Má tá suim agat cabhrú leis an snas deiridh, tar isteach linn i #omarchy-release-candidates ar Discord.

Ar deireadh, tá an bealach dev ann, a nascann Omarchy go díreach le cóip git den chód foinseach in `~/omarchy`, in éineacht le pacáistí edge. Níor cheart duit an bealach seo a úsáid ach amháin má tá taithí agat mar úsáideoir Linux, má tá tú ag obair go díreach ar Omarchy, agus má tá tú sásta glacadh le briseadh.

Is féidir leat malartú idir bealaí trí _Nuashonrú > Bealach_ sa roghchlár Omarchy (nó `omarchy channel set <stable|rc|edge|dev>` sa teirminéal, le `omarchy channel current` chun a fheiceáil cá bhfuil tú).

### Ag Malartú Eithne

Tosnaíonn Omarchy lena eithne `linux-omarchy` féin, ach is féidir leat cinn eile a choinneáil suiteáilte taobh leis, mar eithne stoc Arch `linux` nó leagan turgnamhach atá á thástáil agat. Nuair a bhíonn níos mó ná ceann amháin ann, liostaíonn _Nuashonrú > Eithne_ sa roghchlár Omarchy iad le marc in aice leis an gceann a thosnaíonn de réir réamhshocraithe. Roghnaigh ceann eile, cuir isteach d'fhocal faire uair amháin, agus tosóidh sé tar éis an chéad atosaigh eile. Fanann na heithní eile sa roghchlár tosaithe, mar sin is féidir leat ceann a roghnú de láimh fós má thugann an réamhshocrú nua trioblóid duit. Sa teirminéal, is é `omarchy kernel` é chun an réamhshocrú reatha a fheiceáil, `omarchy kernel list` chun a bhfuil suiteáilte a fheiceáil, agus `omarchy kernel set <kernel>` chun malartú.

### Nuashonruithe dochtearraí

Ní hiad do phacáistí an t-aon rud a éiríonn sean. Seolann go leor ríomhairí glúine agus forimeallach dochtearraí BIOS, SSD, agus duga tríd an Linux Vendor Firmware Service, agus gheobhaidh agus suiteálfaidh _Nuashonrú > Dochtearraí_ sa roghchlár Omarchy cibé rud atá ag fanacht le do chrua-earraí. Suiteálann sé `fwupd` an chéad uair a ritheann tú é. Ní féidir go leor dochtearraí a scríobh ach amháin le linn atosaigh, mar sin ná bíodh iontas ort má iarrtar ceann ort.

Nuair is gá duit socrú sa BIOS féin a athrú, coinnigh `Alt` síos sa roghchlár córais (`Super + Escape`) agus athraíonn _Atosaigh_ go _Atosaigh chuig BIOS_, a atosnaíonn go díreach isteach i socrú na ndochtearraí gan ort an eochair cheart a aimsiú ag am tosaithe. Sa teirminéal, is é `omarchy system firmware` é.

### Rabhadh faoi nuashonruithe díreacha pacman/yay

Má tá taithí agat ar Arch cheana féin, b'fhéidir go mbeadh cathú ort `pacman -Syu` nó `yay -Syu` a rith tú féin, ach má dhéanann tú é sin, caillfidh tú an seat, na haistrithe, agus na nuashonruithe cumraíochta a ritheann Omarchy in éineacht le pacáistí nua. Sin é an fáth go stopfaidh Omarchy uasghrádú díreach córais agus go dtreoróidh sé chuig `omarchy update` tú ina ionad. (Má tá a fhios agat go fírinneach cad atá á dhéanamh agat, inseoidh an garda duit conas é a sheachbhóthar le haghaidh idirbheart amháin.)

### Drochnuashonruithe a Aisrolladh

Má bhíonn fadhb agat riamh tar éis nuashonrú a dhéanamh, is féidir leat do chóras a aisrolladh chuig an seat a tógadh roimh an nuashonrú. Níl le déanamh ach atosú agus an seat sa roghchlár lódála tosaithe ón am sular thosaigh tú an nuashonrú a roghnú.

![bootloader](images/bootloader.webp)

Má tá do chomhaid chumraíochta truaillithe ar bhealach éigin, is féidir leat athshuiteáil Omarchy a dhéanamh freisin trí `omarchy reinstall` a úsáid sa teirminéal. Athshuiteálfaidh sé seo gach pacáiste réamhshocraithe Omarchy, cuirfidh sé ar stable thú (edge ar Apple Silicon) agus íosghrádóidh sé aon phacáistí atá ró-nua, agus athshocróidh sé gach comhad cumraíochta. Tabhair faoi deara go bhforscríobhfar gach athrú cumraíochta úsáideora a rinne tú ar réamhshocruithe Omarchy agus é seo á dhéanamh agat!
