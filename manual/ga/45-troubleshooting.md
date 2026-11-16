# Fabhtcheartú

### Bhris mé mo chóras le nuashonrú!

Bain triail as ar dtús [do chóras a aisrolladh](47-system-snapshots.md) chuig an leagan roimh do nuashonrú is déanaí. Mura n-oibríonn sin, úsáid `omarchy-debug` chun do fhadhb a roinnt ar #omarchy-help sa Discord. Agus má theipeann ar gach rud, is féidir leat na cumraíochtaí agus na pacáistí réamhshocraithe a athshuiteáil le `omarchy-reinstall`.

### Cén fáth a bhfuil roinnt aipeanna chomh mór sin ar mo scáileán?

Glacann Omarchy leis go bhfuil scáileán ardtaifigh 2x agat, mar sin socraíonn sé `GDK_SCALE` go 2 go dtí go roghnaíonn tú scála sa phainéal monatóra. Má tá tú ar scáileán 1x agus má thagann aipeanna GTK nó X11 amach rómhór, roghnaigh 1x dó sa phainéal monatóra, nó cuir `hl.env("GDK_SCALE", "1")` le `~/.config/hypr/monitors.lua` (agus ansin atosaigh aon aip atá rómhór). Féach [an lámhleabhar ar mhonatóirí](33-monitors.md).

Maidir le Spotify, is féidir leat `Ctrl + Minus` a úsáid chun an comhéadan a chrapadh (agus `Ctrl + Plus` chun é a dhéanamh níos mó).

### Cén fáth ar stop gach ceangal eochrach Super agam ag obair?

Ar roinnt ríomhairí glúine ASUS ROG agus TUF, is corda é `Fn + Super` atá éasca a chailleadh a scoránaíonn glas eochrach Windows sa bhuanearra (atá ceaptha le haghaidh cearrbhachais ionas nach bhfágfaidh tú cluiche de thaisme). Ní insíonn aon rud ar an scáileán duit gur tharla sé. Fad atá an glas ar siúl, ní astaíonn Super aon rud ar chor ar bith — mar sin stopann gach ceangal Omarchy a úsáideann Super, agus tá cuma air gur bhris Hyprland.

Brúigh `Fn + Super` uair amháin sula dtéann tú ag tochailt i `~/.config/hypr/`, agus mura dtugann sé sin Super ar ais, brúigh arís é ionas nach bhfágfaidh tú an glas ar siúl. Ní Fn-lock é seo, nach n-athraíonn ach an méid a dhéanann an tsraith eochracha F.

### Stop mo Wi-Fi, Bluetooth, fuaim, nó ceap tadhaill ag obair díreach

Sula n-atosaíonn tú, bain triail as an bhfochóras ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Fuaim, agus Ceap Tadhaill ag _Nuashonrú > Crua-earraí_ sa roghchlár Omarchy, agus réitíonn atosú ceann acu formhór na gcásanna "d'oibrigh sé cúig nóiméad ó shin" — gléas cinn Bluetooth nach n-athcheanglóidh, ceap tadhaill a d'éag tar éis fionraí, fuaim a d'imigh nuair a dhíphlugáil tú monatóir.

### Cén fáth nach bhfuil mo challairí seachtracha ag seinm?

Is dócha mar nach bhfuil siad socraithe mar an príomh-aschur. Cliceáil ar an deilbhín callaire ar thaobh deas an bharra, agus osclóidh sé an fhuinneog aníos fuaime áit ar féidir leat an gléas aschuir a roghnú (agus fuaimeanna in aghaidh na haipe a mheascadh freisin).

### Fuaimeann callairí mo ríomhaire glúine aisteach

Ar roinnt ríomhairí glúine, cuireann Omarchy tiúnadh callaire i bhfeidhm go huathoibríoch a cheartaíonn freagairt minicíochta na gcallairí ionsuite. Insíonn `omarchy audio tuning status` duit an bhfuil ceann gníomhach ar do mheaisín, agus múchann `omarchy audio tuning off` é más fearr leat na callairí a chloisteáil amh.

### Cén fáth nach féidir liom logáil isteach nó sudo a úsáid le mo phasfhocal?

Is dócha gur chlóscríobh tú mícheart é an iomarca uaireanta agus gur glasáladh amach thú. Má tá sé seo ag tarlú ar an scáileán glais, is féidir leat `CTRL + ALT + F2` a bhrú chun TTY nua a thosú áit ar féidir leat logáil isteach mar root, ansin rith `faillock --reset --user [your-username]`. Athshocróidh sé sin an glasáil amach, agus beidh tú réidh le dul.

### Glactar le mo phasfhocal, ach fillim ar an scáileán logála isteach

Is féidir le comhad timpeallachta seisiúin briste cosc a chur ar an deasc tosú fiú nuair atá do phasfhocal ceart. Is fiú é seo a sheiceáil go háirithe tar éis duit `~/.config/uwsm/env.d/` a chur in eagar.

Brúigh `Ctrl + Alt + F2`, logáil isteach le d'ainm úsáideora agus do phasfhocal gnách, agus scrúdaigh iris úsáideora an tosaithe reatha:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cuardaigh earráid a ainmníonn ceann de do chomhaid timpeallachta, ar nós `bad substitution`, díreach roimh theachtaireacht nár aimsíodh marc aschuir env. Bog an comhad sin amach as `env.d` sula ndéanann tú iarracht logáil isteach arís. Mar shampla, má ainmníonn an earráid `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

Léimeann UWSM thar chomhad a bhfuil earráid chomhréire ann, ach is féidir le hearráid mharfach nach dtaispeántar ach amháin fad a ritheann an comhad, ar nós `bad substitution`, cosc a chur ar an deasc tosú fós. Ní dheisíonn aisrolladh seat córais na comhaid seo, mar ní aisrolltar `/home`.

Nuair is féidir leat logáil isteach, deisigh an chóip shábháilte sula mbogann tú ar ais í. Gabhann `sh -n` earráidí comhréire gan an comhad a rith, ach ní féidir leis gach earráid a tharlaíonn nuair a fhoinsítear é a ghabháil. Coinnigh críochfort oibre ar oscailt fad a dhéanann tú tástáil ar athruithe.

### Cén fáth nach bhfuil mo leideanna údaraithe 1Password le haghaidh 1Password SSH Agent / CLI le feiceáil?

Is féidir leis seo tarlú ar 2 chúis:

Le go mbeidh an leid cheadaithe shaibhir le feiceáil, caithfidh Socruithe > Ardsocruithe > Úsáid Luasghéarú Crua-earraí a bheith ar siúl. _Nóta: Teastaíonn atosú le go dtosóidh sé seo ag obair._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nó mura bhfuil 1Password seolta agat ó thosaigh tú suas, ní bheidh an leid le feiceáil.
