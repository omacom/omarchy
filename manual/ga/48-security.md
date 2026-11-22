# Slándáil

Glacann Omarchy an tslándáil an-dáiríre. Is córas oibriúcháin é seo atá i gceist a bheith in ann agat a úsáid chun _Fíorobair_ a dhéanamh sa _Domhan Réadúil_. Áit nach féidir le ríomhaire glúine a chailleadh a bheith ina éigeandáil slándála. Seo mar sin a dhéanaimid é:

1. *Tá criptiú lán-diosca ar siúl de réir réamhshocraithe*: Is é seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, tá na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup). Ligeann an suiteálaí duit é a roghnú gan é a dhéanamh do mheaisíní caithte (féach [Ag tosú](02-getting-started.md)); níl aon chosaint seo ag suiteáil gan criptiú, agus is féidir le haon duine a bhfuil an tiomántán ina sheilbh aige é a léamh.
2. *Tá balla dóiteáin ar siúl de réir réamhshocraithe*: Tá gach trácht isteach blocáilte de réir réamhshocraithe, le cúpla eisceacht: port 53317 do [LocalSend](https://localsend.org/); fiosruithe DNS chuig réiteoir an ríomhaire féin ag seoladh droichid Docker (172.17.0.1), a nglactar leo ó na raonta seoltaí príobháideacha a thugann Docker dá choimeádáin; agus DNS ilchraolta (port 5353), a ligeann do phrintéirí agus do ghléasanna eile ar do líonra a chéile a aimsiú agus a fhógraíonn ainm do ríomhaire ann freisin. Anuas orthu sin, coinníonn an balla dóiteáin lamháltais chaighdeánacha UFW do ping, do sheoladh a fháil ó do ródaire (DHCP), agus d'fhionnachtain UPnP. Tá fiú ssh múchta go dtí go gcuireann tú ar siúl é via _Socrú > Slándáil > SSHD_, a údaraíonn d'eochair SSH, a mhúchann logáil isteach le pasfhocal, agus ansin amháin a osclaíonn port 22 (teoranta de réir ráta in aghaidh brúidiúlachta). Glasálaimid síos fiú rochtain Docker ag baint úsáide as socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go mbíonn aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa lena suiteáil ag baint úsáide as `omarchy-update`. Bíonn tú i gcónaí ag rith na leaganacha is déanaí, is sláine de gach rud ar an mbealach sin.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhíonn Omarchy ag brath ach ar phacáistí ó stórtha core/extra/multilib Arch féin (stórtha Arch Linux ARM ar mheaisíní ARM, móide Asahi ALARM ar Apple Silicon) agus óna Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ón AUR, ach ní dhéanann an tsuiteáil bhunúsach sin — ní tharraingíonn ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, ón AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáileacháin Omarchy — na ISOs, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath láidir DDoS Cloudflare agus á óstáil ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomántán ag an tosú, agus an ceann lena logálann tú isteach agus lena n-úsáideann tú `sudo`. Déanann an socrú iad mar an gcéanna. Is féidir an dá cheann a athrú faoi _Nuashonrú > Pasfhocal_ i roghchlár Omarchy — _Criptiú Tiomántáin_ don chéad cheann, _Úsáideoir_ don dara ceann. Iarrann athrú phasfhocal an tiomántáin an ceann reatha ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Criptiú Tiomántáin_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois agus críochnaíonn sé an t-athrú.

## Meaisín a thabhairt ar aghaidh a d'úsáid tú cheana féin

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Bain > Athshocrú Monarchan_ i roghchlár Omarchy, clóscríobh `reset` chun deimhniú, cuir isteach do phasfhocal criptithe tiomántáin má iarrtar ort, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach na pacáistí agus na hathruithe córais go léir a rinne tú ó shuiteáil, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha óstála, agus gach rud. Is é a thagann ar ais suas ná treoraí an tsocraithe ón gcéad tosú, réidh dá úinéir nua a ainm féin, a phasfhocal féin, agus a phasfhocal criptithe féin a chur isteach.

Oibríonn sé trí athchóiriú a dhéanamh ar an seat bunlíne a thógann an suiteálaí, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ó ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh seachas scriosadh slán atá in athshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina áit.

## sudo gan phasfhocal

Uaireanta bíonn tú ag iarraidh ar `sudo` éirí as a bheith ag fiafraí, is minice nuair a bhíonn gníomhaire AI ag déanamh píosa fada oibre córais duit. Fiafraíonn _Socrú > Slándáil > Sudo Gan Phasfhocal_ cé chomh fada is cóir rochtain a cheadú: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go Buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar bharra an roghchláir fad is atá rochtain gníomhach. Cliceáil é nó rith an t-ordú arís chun rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, go díreach tar éis filleadh ó fhionraí a chuaigh thar an spriocdháta san áireamh. Cuireann atosú an ríomhaire deireadh leis go luath. Mhaireann rochtain bhuan trí atosuithe agus fanann sí ar siúl go dtí go ndíchumasaíonn tú í.

Cuireann nuashonrú nó baint phacáiste socruithe Omarchy deireadh le haon deontas sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaráis nó glanta, réitigh í sula ndéanann tú iarracht deontas eile a chumasú; ní chiallaíonn earráid nach bhfuil rochtain gan phasfhocal gníomhach.

Bí soiléir faoi seo: fad is atá sé ar siúl, is féidir le haon rud atá ag rith mar do úsáideoir aon rud a dhéanamh mar root gan a bheith fiafraíthe de. Is é sin an pointe go hiomlán, agus is é sin an riosca go hiomlán freisin.

## Eochracha Síniúcháin

Is é `40DFB630FF42BCFFB047046CF0134EE680CAC571` an eochair phoiblí do gach síniú ISO agus do phacáiste stór Omarchy ([deimhnigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach go réidh.

Is féidir leat síniú aon eisiúna ISO a aimsiú trí `.sig` a chur lena URL, cosúil le `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
