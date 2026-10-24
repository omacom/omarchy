# Fabhtcheartú

### Bhris mé mo chóras le nuashonrú!

Bain triail ar dtús as [do chóras a chur ar ais](47-system-snapshots.md) chuig an leagan roimh do nuashonrú is déanaí. Mura n-oibríonn sé sin, úsáid `omarchy-debug` chun do fhadhb a roinnt ar #omarchy-help sa Discord. Agus má theipeann air sin go léir, is féidir leat na cumraíochtaí agus na pacáistí réamhshocraithe a athshuiteáil ag baint úsáide as `omarchy-reinstall`.

### Cén fáth a bhfuil roinnt feidhmchlár chomh mór sin ar mo thaispeáint?

Glacann Omarchy le taispeáint ardtaifigh 2x, a éilíonn `GDK_SCALE` a shocrú go 2 i `~/.config/hypr/monitors.lua`. Ach má tá tú ar thaispeáint 1x, is féidir leat `local omarchy_gdk_scale = 2` a athrú go 1 (agus ansin aon fheidhmchlár atá ró-mhór a atosú). Féach [an lámhleabhar ar mhonatóirí](33-monitors.md).

Do Spotify, is féidir leat `Ctrl + Minus` a úsáid chun an comhéadan úsáideora a chrapadh (agus `Ctrl + Plus` chun é a dhéanamh níos mó).

### Stop mo Wi-Fi, Bluetooth, fuaim, nó ceap tadhaill ag obair díreach anois

Sula n-atosaíonn tú, bain triail as an bhfochóras ciontach a atosú leis féin. Tá Wi-Fi, Bluetooth, Audio, agus Trackpad ag _Nuashonraigh > Hardware_ sa roghchlár Omarchy, agus réitíonn ceann díobh sin a athluchtú formhór na gcásanna "d'oibrigh sé cúig nóiméad ó shin" — cluasán Bluetooth nach n-athnascfaidh, ceap tadhaill a d'éag tar éis fionraí, fuaim a d'imigh nuair a dhíphlugáil tú monatóir.

### Cén fáth nach bhfuil mo challairí seachtracha ag seinm?

Is dócha toisc nach bhfuil siad socraithe mar an príomh-aschur. Cliceáil ar an deilbhín callaire ar thaobh na láimhe deise den bharra, agus osclóidh sé an preabfhuinneog toirte áit ar féidir leat an gléas aschuir a roghnú (agus toirteanna in aghaidh an fheidhmchláir a mheascadh freisin).

### Fuaimíonn callairí mo ríomhaire glúine as

Ar roinnt ríomhairí glúine, cuireann Omarchy tiúnadh callaire i bhfeidhm go huathoibríoch a cheartaíonn freagairt minicíochta na gcallairí ionsuite. Insíonn `omarchy audio tuning status` duit an bhfuil ceann gníomhach ar do mheaisín, agus múchann `omarchy audio tuning off` é más fearr leat na callairí a chloisteáil amh.

### Cén fáth nach féidir liom logáil isteach nó sudo le mo phasfhocal?

Is dócha gur chlóscríobh tú mícheart é an iomarca uaireanta agus gur glasáladh amach thú. Má tá sé seo ag tarlú ar an scáileán glais, is féidir leat `CTRL + ALT + F2` a bhualadh chun TTY nua a thosú áit ar féidir leat logáil isteach mar root, ansin `faillock --reset --user [your-username]` a rith. Athshocróidh sé sin an glasáil amach, agus beidh tú réidh le dul.

### Cén fáth nach bhfuil mo leideanna údaraithe 1Password do Ghníomhaire SSH / CLI 1Password le feiceáil?

Is féidir leis seo tarlú ar 2 chúis:

Chun go mbeidh an leid cheadaithe shaibhir le feiceáil, caithfidh Settings > Advanced > Use Hardware Acceleration a bheith casta air. _Nóta: Éilíonn sé seo atosú chun tosú ag obair._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nó mura bhfuil 1Password seolta agat ó thosaigh tú suas, ní bheidh an leid le feiceáil.
