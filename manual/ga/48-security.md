# Slándáil

Glacann Omarchy le slándáil go fíordháiríre. Tá sé seo i gceist a bheith ina chóras oibriúcháin is féidir leat a úsáid chun _Fíorobair_ a dhéanamh sa _Domhan Fíor_. Áit nach féidir le ríomhaire glúine caillte éigeandáil slándála a chruthú. Seo mar sin a dhéanaimid é:

1. *Tá criptiú lán-diosca ar siúl de réir réamhshocraithe*: Seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, tá na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup). Ligeann an suiteálaí duit diúltú dó le haghaidh meaisíní caithimh (féach [Ag tosú](02-getting-started.md)); níl aon chuid den chosaint seo ag suiteáil gan criptiú, agus is féidir le haon duine a bhfuil an tiomántán ina sheilbh aige é a léamh.
2. *Tá an balla dóiteáin cumasaithe de réir réamhshocraithe*: Tá an trácht isteach go léir blocáilte de réir réamhshocraithe, le cúpla eisceacht: port 53317 le haghaidh [LocalSend](https://localsend.org/); fiosrúcháin DNS chuig réiteoir an ríomhaire féin ag seoladh droichid Docker (172.17.0.1), a nglactar leo ó na raonta seoltaí príobháideacha a thugann Docker dá choimeádáin; agus DNS ilchraolta (port 5353), a ligeann do phrintéirí agus do ghléasanna eile ar do líonra a chéile a aimsiú agus a fhógraíonn ainm do ríomhaire ansin freisin. Anuas orthu sin, coinníonn an balla dóiteáin ceadanna caighdeánacha UFW le haghaidh ping, seoladh a fháil ó do ródaire (DHCP), agus fionnachtain UPnP. Tá fiú ssh múchta go dtí go gcuireann tú ar siúl é trí _Setup > Security > SSHD_, a osclaíonn port 22 (teoranta ó thaobh ráta in aghaidh brute force) mar chuid den socrú. Dúnaimid rochtain Docker síos fiú ag baint úsáide as socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí i gcónaí ag Arch*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go mbíonn aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag baint úsáide as `omarchy-update`. Bíonn tú ag rith na leaganacha is déanaí agus is sláine de gach rud i gcónaí ar an mbealach sin.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhraitheann Omarchy ach ar phacáistí ó stórtha core/extra/multilib Arch féin agus óna Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ó AUR, ach ní dhéanann an tsuiteáil bhunúsach é — níl ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, a tharraingíonn ón AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáilte Omarchy — na ISOanna, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath DDoS ollmhór Cloudflare agus óstáilte ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil criptithe: an ceann a dhíghlasálann an tiomántán ag am tosaithe, agus an ceann a logálann tú isteach leis agus a úsáideann tú le `sudo`. Déanann an Socrú an dá cheann mar an gcéanna. Is féidir an dá cheann a athrú faoi _Update > Password_ i roghchlár Omarchy — _Drive Encryption_ don chéad cheann, _User_ don dara ceann. Iarrann athrú phasfhocal an tiomántáin an ceann reatha ort ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Drive Encryption_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois agus críochnaíonn sé an t-athrú.

## Meaisín a d'úsáid tú cheana a thabhairt ar aghaidh

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Setup > Reset Computer_ i roghchlár Omarchy, clóscríobh `reset` le deimhniú, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach na pacáistí agus na hathruithe córais go léir a rinne tú ó shuiteáil, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha óstach, agus gach rud. Is é an draoi socraithe ón gcéad tosú a thagann ar ais, réidh dá úinéir nua a n-ainm, a bpasfhocal, agus a bpasfhocal criptithe féin a chur isteach.

Oibríonn sé trí shnapghraf bunlíne a thógann an suiteálaí a athchóiriú, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ó ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh seachas scriosadh slán atá i gceist le hathshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina ionad.

## sudo gan phasfhocal

Uaireanta ba mhaith leat go stopfadh `sudo` ag fiafraí, is minice nuair a bhíonn gníomhaire AI ag déanamh stráice fada d'obair chórais duit. Fiafraíonn _Setup > Security > Passwordless Sudo_ cá fhad a cheadófar rochtain: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go Buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar bharra an roghchláir fad a bhíonn an rochtain gníomhach. Cliceáil é nó rith an t-ordú arís chun an rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh freisin le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a chuaigh thar an spriocdháta. Críochnaíonn atosú an ríomhaire go luath í. Maireann rochtain bhuán trí aththosuithe agus fanann sí cumasaithe go dtí go ndíchumasaíonn tú í.

Críochnaíonn nuashonrú nó baint phacáiste socruithe Omarchy aon deontas sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glantacháin, réitigh í sula ndéanann tú iarracht deontas eile a chumasú; ní chiallaíonn earráid nach bhfuil rochtain gan phasfhocal neamhghníomhach.

Bí soiléir faoi seo: fad atá sé ar siúl, is féidir le haon rud atá ag rith mar d'úsáideoir aon rud a dhéanamh mar root gan a bheith fiafraíthe de. Sin é an pointe ar fad, agus sin é an riosca ar fad freisin.

## Eochracha Síniúcháin

Is í an eochair phoiblí le haghaidh sínithe ISO go léir agus phacáiste stór Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([fíoraigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach go réidh.

Is féidir leat síniú aon eisiúna ISO a fháil trí `.sig` a chur lena URL, cosúil le `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
