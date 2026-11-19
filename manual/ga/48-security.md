# Slándáil

Glacann Omarchy leis an slándáil go fíordháiríre. Tá sé i gceist gur córas oibriúcháin é seo ar féidir leat a úsáid chun _Fíorobair_ a dhéanamh sa _Domhan Fíor_. Áit nach féidir le ríomhaire glúine a chailliúint géarchéim slándála a chruthú. Seo mar sin a dhéanaimid é:

1. *Tá criptiú lán-diosca ar siúl de réir réamhshocraithe*: Is é seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, bíonn na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup). Ligeann an suiteálaí duit rogha an diúltaithe a dhéanamh do mheaisíní indiúscartha (féach [Tús a chur leis](02-getting-started.md)); níl aon chuid den chosaint seo ag suiteáil gan criptiú, agus is féidir le haon duine a bhfuil an tiomántán ina sheilbh aige é a léamh.
2. *Tá an balla dóiteáin cumasaithe de réir réamhshocraithe*: Cuirtear bac ar gach trácht isteach de réir réamhshocraithe, le cúpla eisceacht: port 53317 do [LocalSend](https://localsend.org/); fiosrúcháin DNS chuig réiteoir an ríomhaire féin ag seoladh droichid Docker (172.17.0.1), a nglactar leo ó na raonta seoltaí príobháideacha a thugann Docker dá choimeádáin; agus DNS ilchraolta (port 5353), a ligeann do phrintéirí agus do ghléasanna eile ar do líonra a chéile a aimsiú agus a fhógraíonn ainm do ríomhaire ansin freisin. Ar a bharr sin, coinníonn an balla dóiteáin lamháltais chaighdeánacha UFW do ping, do sheoladh a fháil ó do ródaire (DHCP), agus d'fhionnachtain UPnP. Tá ssh féin múchta fiú go dtí go gcuireann tú ar siúl é trí _Socraigh > Slándáil > SSHD_, a osclaíonn port 22 (teoranta ó thaobh ráta de i gcoinne ionsaí brúidiúil) mar chuid den socrú. Déanaimid rochtain Docker a ghlasáil síos fiú ag baint úsáide as an socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go mbíonn aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag baint úsáide as `omarchy-update`. Bíonn tú ag rith na leaganacha is déanaí agus is sláine de gach rud ar an mbealach sin i gcónaí.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhraitheann Omarchy ach ar phacáistí ó stórtha core/extra/multilib Arch féin agus óna Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ó AUR, ach ní dhéanann an tsuiteáil bhunúsach é sin — ní tharraingíonn ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, ó AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáileacháin Omarchy — na ISOanna, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath láidir DDoS Cloudflare agus á óstáil ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomántán ag am tosaithe, agus an ceann a úsáideann tú chun logáil isteach agus le `sudo`. Déanann an Socrú mar an gcéanna iad. Is féidir an dá cheann a athrú faoi _Nuashonraigh > Pasfhocal_ sa roghchlár Omarchy — _Criptiú Tiomántáin_ don chéad cheann, _Úsáideoir_ don dara ceann. Iarrann athrú phasfhocal an tiomántáin an ceann reatha ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Criptiú Tiomántáin_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois agus críochnaíonn sé an t-athrú.

## Meaisín atá úsáidte agat cheana a thabhairt ar aghaidh

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Bain > Athshocrú Monarcha_ sa roghchlár Omarchy, clóscríobh `reset` chun deimhniú, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach na pacáistí agus na hathruithe córais go léir a rinne tú ó shuiteáil, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha óstaigh, agus gach rud. Is é an rud a thagann ar ais suas ná draoi an tsocraithe ón gcéad tosú, réidh dá úinéir nua a n-ainm, a bpasfhocal, agus a bpasfhocal criptithe féin a chur isteach.

Oibríonn sé trí shnapghraf bunlíne an suiteálaí a athbhunú, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ó ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh seachas scriosadh slán atá i gceist le hathshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina ionad sin.

## sudo gan phasfhocal

Uaireanta bíonn tú ag iarraidh go stopfadh `sudo` ag iarraidh, go minic nuair a bhíonn gníomhaire AI ag déanamh tréimhse fada oibre córais duit. Fiafraíonn _Socraigh > Slándáil > Sudo gan Pasfhocal_ cé chomh fada is cóir rochtain a cheadú: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar bharra an roghchláir fad atá an rochtain gníomhach. Cliceáil air nó rith an t-ordú arís chun an rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh freisin le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a chuaigh thar an spriocdháta. Cuireann atosú an ríomhaire deireadh léi go luath. Mairfidh rochtain bhuan trí atosuithe agus fanann sí cumasaithe go dtí go ndíchumasaíonn tú í.

Cuireann nuashonrú nó baint phacáiste socruithe Omarchy deireadh le haon deonú sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glantacháin, réitigh í sula ndéanann tú iarracht deonú eile a chumasú; ní chiallaíonn earráid nach bhfuil rochtain gan phasfhocal gníomhach.

Bí soiléir faoi seo: fad atá sé ar siúl, is féidir le haon rud atá ag rith mar do úsáideoir aon rud a dhéanamh mar root gan ceist a chur. Sin an pointe ar fad, agus is é an riosca ar fad é freisin.

## Eochracha Síniúcháin

Is í an eochair phoiblí do gach síniú ISO agus do phacáiste stóir Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([fíoraigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach go réidh.

Is féidir leat an síniú d'aon eisiúint ISO a fháil trí `.sig` a chur lena URL, cosúil le `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
