# Windows VM

Cuireann Omarchy bealach éasca ar fáil chun Windows a rith trí Docker VM ar mheaisíní x86_64. Is féidir leat é a shuiteáil le _Install > Windows_ ón roghchlár Omarchy (`Super + Space`).

Teastaíonn fíorúlú KVM ó do mheaisín chuige seo, rud atá ag an gcuid is mó — ach bíonn sé múchta sa BIOS uaireanta, agus inseoidh an suiteálaí duit más amhlaidh atá. Beidh spás diosca ag teastáil uait freisin: cibé méid a thugann tú do Windows, móide thart ar 10GB don íomhá féin.

Fiafraíonn an suiteálaí díot cé mhéad RAM, cé mhéad croí CPU, agus cé mhéad diosca le tabhairt dó (is é 64GB nó níos mó an bunmhéid ciallmhar), ansin ainm úsáideora agus pasfhocal Windows. Fág bán iad sin agus gheobhaidh tú `docker` / `admin`. Tógann an íoslódáil tamall — is gnách 10-15 nóiméad — agus is féidir leat an dul chun cinn a leanúint sa bhrabhsálaí ag `http://127.0.0.1:8006`. Iarrann an brabhsálaí an t-ainm úsáideora agus an pasfhocal céanna sula n-osclaíonn sé an consól.

 ![windows-vm](images/windows-vm.webp)

## É a úsáid

Nuair atá sé suiteáilte, seol _Windows_ ón seoladóir feidhmchlár. Tosaíonn sé sin an VM mura bhfuil sé ag rith cheana agus nascann sé thú thar RDP, ar lánscáileán. Tabhair 15-30 soicind dó ar thús fuar.

Iompraíonn seisiún RDP fuaim, do mhicreafón, agus gearrthaisce chomhroinnte, mar sin oibríonn cóipeáil téacs idir Linux agus Windows gan stró. Leanann an taifeach do fhuinneog, agus cuireann Omarchy scálú do thaispeántais ar aghaidh, mar sin ní bheidh sé ina praiseach dhoiléir ar scáileán HiDPI.

Nuair a dhúnann tú fuinneog RDP, múchtar an VM go huathoibríoch. Más fearr leat é a fhágáil ag rith — abair go bhfuil rud éigin ag obair leis ann — seol le `omarchy windows vm launch --keep-alive` é ina ionad sin.

Tá an chuid eile de na rialuithe ar an ordú céanna:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Comhaid a roinnt

Déantar an chomhadlann `~/Windows` i do chomhadlann bhaile a roinnt go huathoibríoch leis an VM. Cuir comhaid ansin más mian leat go mbeidh teacht ag Windows orthu. Níl teacht ag an VM ar aon chuid eile de do chóras comhad, mar sin tá tú sábháilte ó aon rud gráiniúil ar thaobh Windows. Tá a dhiosca fíorúil féin ar fáil ag `~/.windows`.

Fanann na cosáin bhaile aithnidiúla sin ar a gcórais comhad féin. Is féidir leo a bheith ina naisc shiombalacha chuig comhadlanna leatsa freisin, rud atá úsáideach nuair a bhíonn an diosca fíorúil ar thiomántán níos mó. Tomhaiseann an suiteálaí spás saor ar an gcóras comhad ina bhfuil `~/.windows` i ndáiríre, ní gá gurb é an córas comhad ina bhfuil do chomhadlann bhaile.

Coinnigh na cosáin diosca agus chomhroinnte mar chomhadlanna ar leith nach bhforluíonn ar a chéile. Folmhaíonn baint an chomhadlann diosca d’aon ghnó ach caomhnaíonn sí an chomhadlann chomhroinnte. Díreach roimh an scriosadh, déanann Omarchy seiceáil imshrianta theoranta agus diúltaíonn sé aon rud a bhaint má théann an tseiceáil sin thar am nó mura féidir léi a chruthú go bhfuil an dá chrann ar leith.

Sula dtosaíonn an VM, osclaíonn Omarchy an dá chomhadlann sin agus pinneálann sé iad, ansin ceanglaíonn sé ionóidí cruinne na gcomhadlann ar ancairí príobháideacha in aghaidh an úsáideora faoi bhun `/var/lib/omarchy/windows/mounts`. Ní fheiceann Docker ach na hancairí sin atá cosanta ag root. Caomhnaíonn sé seo suíomhanna diosca saincheaptha agus cuireann sé cosc ar phróiseas eile atá ag rith mar thusa cosán seiceáilte a mhalartú sula n-úsáideann an coimeádán pribhléideach é. Déantar comhadlanna diosca agus comhroinnte atá ann cheana a theannadh go mód `0700` le linn ascnaimh ionas nach féidir le cuntais áitiúla eile a n-ábhar a bhrabhsáil.

Tá calafoirt an VM ceangailte le localhost amháin, mar sin ní féidir le haon rud ar do líonra an meaisín Windows a bhaint amach. Éilíonn an consól gréasáin ainm úsáideora agus pasfhocal cumraithe Windows freisin, rud a chuireann cosc ar chuntas áitiúil eile an VM a thiomáint trí chalafort 8006.

## Teorainneacha agus ceadúnú

Níl pas-obair GPU ar fáil leis an socrú seo, mar sin níl sé oiriúnach do chearrbhachas ná d’eagarthóireacht físe. Is bealach iontach é chun Microsoft Office a rith nó cibé rud eile nach mór duit a bheith agat.

Is é Windows 11 Pro an leagan a shuiteáiltear, gan ghníomhachtú. Beidh d’eochair cheadúnais féin ag teastáil uait chun na gnéithe geataithe a úsáid.

Má tháinig an ríomhaire seo le Windows, tá an eochair OEM fós i bhfirmware fiú tar éis Omarchy a shuiteáil. Priontáil í le `omarchy windows key`. Tá an eochair sin ceangailte leis an meaisín seo — ghníomhachtóidh sí Windows athshuiteáilte ar an gcrua-earra seo, ach de ghnáth ní ghníomhachtóidh sí an VM.

Is féidir leat an leithdháileadh acmhainní a athrú níos déanaí trí `omarchy windows vm install` a rith i teirminéal, a athscríobhann cumraíocht an VM ó do fhreagraí. Tá an comhad compose féin anois ag `/var/lib/omarchy/windows/docker-compose.yml` agus is le root é — tá sé sin d’aon ghnó, ionas nach féidir le próiseas atá ag rith mar thusa é a athscríobh agus an tabhairt chun cinn phribhléideach a chur ag gléasadh do dhiosca ar fad isteach sa choimeádán. Más gá duit é a chur in eagar de láimh (mar shampla chun gléas USB a ghléasadh), cuir in eagar le `sudo` é agus féach na roghanna go léir ar [thionscadal Dockur Windows](https://github.com/dockur/windows).

Chun an rud ar fad a bhaint, bain úsáid as _Remove > Windows_ ón roghchlár Omarchy. Scriosann sé sin diosca an VM i `~/.windows` agus gach rud atá suiteáilte taobh istigh de Windows, mar sin cóipeáil aon rud a theastaíonn uait amach as an VM ar dtús. Fágtar do fhillteán comhroinnte `~/Windows` mar atá sé.
