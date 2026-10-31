# Fabhtcheartú

### Bhris mé mo chóras le nuashonrú!

Bain triail ar dtús as [do chóras a chur ar ais](47-system-snapshots.md) go dtí an leagan a bhí ann roimh an nuashonrú is déanaí uait. Mura n-oibríonn sin, úsáid `omarchy-debug` chun do fhadhb a roinnt ar #omarchy-help sa Discord. Agus mura n-éiríonn le haon cheann de sin, is féidir leat na cumraíochtaí agus na pacáistí réamhshocraithe a athshuiteáil le `omarchy-reinstall`.

### Cén fáth a bhfuil roinnt aipeanna chomh mór sin ar mo thaispeántas?

Glacann Omarchy leis go bhfuil taispeántas ardtaifigh 2x agat, mar sin socraíonn sé `GDK_SCALE` go 2 go dtí go roghnaíonn tú scála sa phainéal monatóra. Má tá tú ar thaispeántas 1x agus má thagann aipeanna GTK nó X11 amach ró-mhór, roghnaigh 1x dó sa phainéal monatóra, nó cuir `hl.env("GDK_SCALE", "1")` le `~/.config/hypr/monitors.lua` (agus ansin atosaigh aon aip atá ró-mhór). Féach [an lámhleabhar ar mhonatóirí](33-monitors.md).

Le haghaidh Spotify, is féidir leat `Ctrl + Minus` a úsáid chun an comhéadan a dhéanamh níos lú (agus `Ctrl + Plus` chun é a dhéanamh níos mó).

### Cén fáth ar stop gach ceangal eochrach Super de mo chuid ag obair?

Ar roinnt ríomhairí glúine ASUS ROG agus TUF, is corda é `Fn + Super` atá furasta a chailleadh a scoránaíonn glas eochrach Windows sa bhuanfhirmware (atá ann le haghaidh cearrbhachais ionas nach bhfágfaidh tú cluiche de thaisme). Ní insíonn aon rud ar an scáileán duit gur tharla sé. Fad atá an glas ar siúl, ní astaíonn Super aon rud ar chor ar bith — mar sin stopann gach ceangal Omarchy a úsáideann Super díreach, agus is cosúil gur bhris Hyprland.

Brúigh `Fn + Super` uair amháin sula dtosaíonn tú ag tochailt isteach in `~/.config/hypr/`, agus mura dtugann sé sin Super ar ais, brúigh arís é ionas nach bhfágfaidh tú an glas ar siúl. Ní Fn-lock é seo, nach n-athraíonn ach an méid a dhéanann an tsraith eochracha F.

### Stop mo Wi-Fi, Bluetooth, fuaim, nó ceap tadhaill ag obair díreach

Sula n-atosaíonn tú, bain triail as an bhfochóras atá ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Audio, agus Trackpad in _Update > Hardware_ sa roghchlár Omarchy, agus glanann athlódáil ceann díobh sin an chuid is mó de na cásanna “d’oibrigh sé cúig nóiméad ó shin” — gléas cinn Bluetooth nach n-athcheanglóidh, ceap tadhaill a chuaigh marbh tar éis fionraí, fuaim a d’imigh nuair a dhíphlugáil tú monatóir.

### Cén fáth nach bhfuil mo challairí seachtracha ag seinm?

Is dócha toisc nach bhfuil siad socraithe mar an príomh-aschur. Cliceáil ar an deilbhín callaire ar an taobh deas den bharra, agus osclóidh sé an aníos toirte áit ar féidir leat an gléas aschuir a roghnú (agus toirteanna in aghaidh na haipe a mheascadh freisin).

### Tá fuaim aisteach ar challairí mo ríomhaire glúine

Ar roinnt ríomhairí glúine, cuireann Omarchy tiúnadh callaire i bhfeidhm go huathoibríoch a cheartaíonn freagairt minicíochta na gcallairí ionsuite. Insíonn `omarchy audio tuning status` duit an bhfuil ceann gníomhach ar do mheaisín, agus múchann `omarchy audio tuning off` é más fearr leat na callairí a chloisteáil amh.

### Cén fáth nach féidir liom logáil isteach nó sudo a úsáid le mo phasfhocal?

Is dócha gur chlóscríobh tú mícheart é an iomarca uaireanta agus gur cuireadh glas ort. Má tá sé seo ag tarlú ar an scáileán glais, is féidir leat `CTRL + ALT + F2` a bhrú chun TTY nua a thosú áit ar féidir leat logáil isteach mar root, ansin rith `faillock --reset --user [your-username]`. Athshocróidh sé sin an glasáil, agus tá tú réidh le dul.

### Cén fáth nach bhfuil leideanna údaraithe 1Password le haghaidh 1Password SSH Agent / CLI le feiceáil?

Is féidir leis seo tarlú ar 2 chúis:

Ionas go mbeidh an leid cheadaithe shaibhir le feiceáil, ní mór Settings > Advanced > Use Hardware Acceleration a bheith ar siúl. _Nóta: Éilíonn sé seo atosú chun tosú ag obair._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nó mura bhfuil 1Password seolta agat ó thosaigh tú suas, ní bheidh an leid le feiceáil.
