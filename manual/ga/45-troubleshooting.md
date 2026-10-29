# Fabhtcheartú

### Bhris mé mo chóras le nuashonrú!

Ar dtús, bain triail as [do chóras a rolladh ar ais](47-system-snapshots.md) go dtí an leagan a bhí ann roimh an nuashonrú is déanaí agat. Mura n-oibríonn sin, úsáid `omarchy-debug` chun do fhadhb a roinnt ar #omarchy-help sa Discord. Agus má theipeann ar gach rud eile, is féidir leat na cumraíochtaí agus na pacáistí réamhshocraithe a athshuiteáil le `omarchy-reinstall`.

### Cén fáth a bhfuil roinnt aipeanna chomh mór sin ar mo thaispeántas?

Glacann Omarchy leis go bhfuil taispeántas ardtaifigh 2x agat, rud a éilíonn `GDK_SCALE` a shocrú go 2 i `~/.config/hypr/monitors.lua`. Ach má tá taispeántas 1x agat, is féidir leat `local omarchy_gdk_scale = 2` a athrú go 1 (agus ansin aon aip atá rómhór a atosú). Féach [an lámhleabhar faoi mhonatóirí](33-monitors.md).

Maidir le Spotify, is féidir leat `Ctrl + Minus` a úsáid chun an comhéadan a chrapadh (agus `Ctrl + Plus` chun é a mhéadú).

### Cén fáth ar stop gach ceangal eochrach Super agam ag obair?

Ar roinnt ríomhairí glúine ASUS ROG agus TUF, is teaglaim eochracha í `Fn + Super` atá furasta a chailleadh, a scoránaíonn glas eochair Windows sa bhunearra (atá ceaptha le haghaidh cearrbhachais ionas nach bhfágfaidh tú cluiche de thaisme). Ní insíonn aon rud ar an scáileán duit gur tharla sé. Fad atá an glas ar siúl, ní astaíonn Super aon rud ar chor ar bith — mar sin stopann gach ceangal Omarchy a úsáideann Super, agus tá cuma air gur bhris Hyprland.

Brúigh `Fn + Super` uair amháin sula dtosaíonn tú ag tochailt i `~/.config/hypr/`, agus mura dtugann sin Super ar ais, brúigh arís é ionas nach bhfágfaidh tú an glas ar siúl. Ní glas Fn é seo, nach n-athraíonn ach an rud a dhéanann an tsraith eochracha F.

### Stop mo Wi-Fi, Bluetooth, fuaim, nó ceap tadhaill ag obair go tobann

Sula n-atosaíonn tú, bain triail as an bhfochóras atá ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Fuaim, agus Ceap Tadhaill in _Nuashonraigh > Crua-earraí_ i roghchlár Omarchy, agus réitíonn athlódáil ceann acu formhór na gcásanna “d’oibrigh sé cúig nóiméad ó shin” — seit chinn Bluetooth nach n-athnascfaidh, ceap tadhaill a d’éag tar éis fionraí, fuaim a d’imigh nuair a dhíphlugáil tú monatóir.

### Cén fáth nach bhfuil mo challairí seachtracha ag seinm?

Is dócha toisc nach bhfuil siad socraithe mar an phríomh-aschur. Cliceáil ar an deilbhín callaire ar an taobh deas den bharra, agus osclóidh sé an preabfhuinneog fuaime áit ar féidir leat an gléas aschuir a roghnú (agus leibhéil fuaime gach aipe a mheascadh freisin).

### Fuaimeann callairí mo ríomhaire glúine aisteach

Ar roinnt ríomhairí glúine, cuireann Omarchy tiúnadh callaire i bhfeidhm go huathoibríoch a cheartaíonn freagairt minicíochta na gcallairí ionsuite. Insíonn `omarchy audio tuning status` duit an bhfuil ceann gníomhach ar do mheaisín, agus múchann `omarchy audio tuning off` é más fearr leat na callairí a chloisteáil amh.

### Cén fáth nach féidir liom logáil isteach nó sudo a úsáid le mo phasfhocal?

Is dócha gur chlóscríobh tú mícheart é an iomarca uaireanta agus gur cuireadh faoi ghlas thú. Má tharlaíonn sé seo ar an scáileán glais, is féidir leat `CTRL + ALT + F2` a bhualadh chun TTY nua a thosú áit ar féidir leat logáil isteach mar root, ansin `faillock --reset --user [your-username]` a rith. Athshocróidh sin an glasáil amach, agus beidh tú réidh le dul.

### Cén fáth nach bhfuil mo leideanna údaraithe 1Password le haghaidh 1Password SSH Agent / CLI ag teacht chun cinn?

Is féidir leis seo tarlú ar 2 chúis:

Chun go dtiocfaidh an leid shaibhir cheadaithe chun cinn, caithfidh Socruithe > Ardroghanna > Úsáid Luasghéarú Crua-earraí a bheith ar siúl. _Nóta: Caithfear atosú chun go dtosóidh sé seo ag obair._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nó mura bhfuil 1Password seolta agat ó thosaigh tú an meaisín, ní thiocfaidh an leid chun cinn.
