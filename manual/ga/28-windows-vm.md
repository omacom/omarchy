# Windows VM

Cuireann Omarchy bealach éasca ar fáil chun Windows a rith trí Docker VM. Is féidir leat é a shuiteáil trí _Suiteáil > Windows_ a úsáid ón roghchlár Omarchy (`Super + Space`).

Teastaíonn fhíorúchán KVM ó do mheaisín chuige seo, rud atá ag formhór acu — ach tá sé múchta sa BIOS uaireanta, agus inseoidh an suiteálaí duit má tá sin amhlaidh. Beidh an spás diosca uait freisin: cibé rud a thugann tú do Windows, móide thart ar 10GB don íomhá féin.

Iarrann an suiteálaí cé mhéad RAM, cé mhéad croíleacan LAP, agus cé mhéad diosca a thabhairt ar láimh (is é 64GB nó níos mó an t-íosmhéid ciallmhar), ansin ainm úsáideora agus pasfhocal Windows. Fág iad sin folamh agus gheobhaidh tú `docker` / `admin`. Tógann an íoslódáil tamall — tá 10-15 nóiméad gnáth — agus is féidir leat an dul chun cinn a leanúint sa bhrabhsálaí ag `http://127.0.0.1:8006`. Spreagann an brabhsálaí an t-ainm úsáideora agus pasfhocal céanna sula n-osclóidh sé an consól.

 ![windows-vm](images/windows-vm.webp)

## É a Úsáid

Nuair atá sé suiteáilte, lainseáil _Windows_ ón lainseálaí aipeanna. Tosaíonn sé sin an VM mura bhfuil sé ag rith cheana agus nascann sé tú thar RDP, lánscáileán. Tabhair 15-30 soicind dó ar thús fuar.

Iompraíonn seisiún RDP fuaim, do mhicreafón, agus gearrthaisce chomhroinnte, mar sin oibríonn cóipeáil téacs idir Linux agus Windows gan stró. Leanann an taifeach d'fhuinneog, agus cuireann Omarchy scálú do thaispeána ar aghaidh, mar sin ní praiseach doiléir é ar scáileán HiDPI.

Nuair a dhúnann tú fuinneog RDP, múchtar an VM go huathoibríoch. Más fhearr leat é a fhágáil ag rith — abair go bhfuil rud éigin ag obair ann — lainseáil é le `omarchy windows vm launch --keep-alive` ina ionad.

Tá an chuid eile de na rialuithe ar an ordú céanna:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Comhaid a Chomhroinnt

Déantar an eolaire `~/Windows` i do eolaire baile a chomhroinnt go huathoibríoch leis an VM. Cuir comhaid ann más mian leat iad a bheith inrochtana ag Windows. Níl rochtain ag an VM ar aon chuid eile de do chóras comhaid, mar sin tá tú slán ó aon rud dána ar thaobh Windows. Tá a diosca fíorúil féin ar fáil ag `~/.windows`.

Fanann na conairí baile familiar sin ar a gcórais chomhaid féin. Is féidir leo a bheith ina symlinks chuig eolairí ar leatsa iad freisin, rud atá úsáideach nuair a chónaíonn an diosca fíorúil ar thiomántán níos mó. Tomhaiseann an suiteálaí spás saor ar an gcóras comhaid ina bhfuil `~/.windows` i ndáiríre, ní gá gurb é an córas comhaid ina bhfuil do eolaire baile.

Coinnigh an diosca agus na conairí comhroinnte mar eolairí ar leithligh neamh-fhorluí. Folmhaíonn baint an eolaire diosca d'aon ghnó ach caomhnaíonn sé an eolaire comhroinnte. Díreach roimh scriosadh, déanann Omarchy seiceáil teorannaithe coimeádta agus diúltaíonn sé aon rud a bhaint má imíonn an seiceáil sin as am nó mura féidir léi a chruthú go bhfuil an dá chrann ar leithligh.

Sula dtosaíonn an VM, osclaíonn Omarchy agus greamaíonn sé an dá eolaire sin, ansin ceanglaíonn sé na hinoidí eolaire cruinne ar chrúnna príobháideacha in aghaidh an úsáideora thíos `/var/lib/omarchy/windows/mounts`. Ní fheiceann Docker ach na crúnna sin atá faoi chosaint root. Caomhnaíonn sé seo suíomhanna saincheaptha diosca agus cuireann sé cosc ar phróiseas eile ag rith mar tusa ó chonair sheiceáilte a mhalartú sula n-úsáideann an coimeádán pribhléideach í. Déantar eolairí diosca agus comhroinnte reatha a dhéineú go mód `0700` le linn aistrithe ionas nach féidir le cuntais áitiúla eile a n-ábhar a bhrabhsáil.

Tá calafoirt an VM ceangailte le localhost amháin, mar sin ní féidir le rud ar bith ar do líonra an meaisín Windows a bhaint amach. Éilíonn an consól gréasáin an t-ainm úsáideora agus pasfhocal Windows cumraithe freisin, rud a chuireann cosc ar chuntas áitiúil eile an VM a thiomáint trí chalafort 8006.

## Teorainneacha agus ceadúnasú

Níl aon pasáiste GPU leis an socrú seo, mar sin níl sé oiriúnach do chearrbhachas nó eagarthóireacht físeáin. Is bealach iontach é chun Microsoft Office a rith nó cibé rud eile nach mór duit a bheith agat.

Is é an leagan suiteáilte ná Windows 11 Pro, neamhghníomhachtaithe. Beidh d'eochair cheadúnais féin ag teastáil uait chun na gnéithe geataithe a úsáid.

Má tháinig an ríomhaire seo le Windows, tá an eochair OEM fós sa fhirmearaí fiú tar éis Omarchy a shuiteáil. Priontáil é le `omarchy windows key`. Tá an eochair sin ceangailte leis an meaisín seo — gníomhachtóidh sí Windows athshuiteáilte ar an gcrua-earraí seo, ach de ghnáth ní ghníomhachtóidh sí an VM.

Is féidir leat an leithdháileadh acmhainní a athrú níos déanaí trí `omarchy-windows-vm install` a rith arís, rud a athscríobhann cumraíocht an VM ó do fhreagraí. Cónaíonn an comhad compose féin anois ag `/var/lib/omarchy/windows/docker-compose.yml` agus is le root é — tá sé sin d'aon ghnó, ionas nach féidir le próiseas ag rith mar tusa é a athscríobh agus an t-ardú pribhléideach a chur ag gléasadh do diosca iomlán isteach sa choimeádán. Más gá duit é a chur in eagar de láimh (mar shampla chun gléas USB a ghléasadh), cuir in eagar é le `sudo` agus féach na roghanna go léir ar [thionscadal Dockur Windows](https://github.com/dockur/windows).

Chun fáil réidh leis an rud iomlán, úsáid _Bain > Windows_ ón roghchlár Omarchy. Scriosann sé sin diosca an VM agus a sonraí go léir, mar sin cinntigh go bhfuil aon rud a bhfuil tábhacht leis as `~/Windows` ar dtús.
