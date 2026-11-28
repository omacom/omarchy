# Slándáil

Glacann Omarchy an tslándáil go fíordháiríre. Tá sé seo beartaithe mar chóras oibriúcháin is féidir leat a úsáid chun _Fíorobair_ a dhéanamh sa _Fhíorshaol_. Áit nach féidir le ríomhaire glúine a chailliúint éigeandáil slándála a chruthú. Mar sin seo mar a dhéanaimid é:

1. *Tá criptiú lándiosca ar siúl de réir réamhshocraithe*: Is í seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, bíonn na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup). Ligeann an suiteálaí duit éirí as ar mheaisíní caithte (féach [Ag tosú](02-getting-started.md)); níl aon chuid den chosaint seo ag suiteáil gan criptiú, agus is féidir le haon duine a bhfuil an tiomántán ina sheilbh aige é a léamh.
2. *Tá an balla dóiteáin cumasaithe de réir réamhshocraithe*: Cuirtear bac ar gach trácht isteach de réir réamhshocraithe, le cúpla eisceacht: port 53317 do [LocalSend](https://localsend.org/); ceisteanna DNS chuig réiteoir an ríomhaire féin ag seoladh droichid Docker (172.17.0.1), a nglactar leo ó na raonta seoltaí príobháideacha a thugann Docker dá choimeádáin; agus DNS ilchraolta (port 5353), a ligeann do phrintéirí agus do ghléasanna eile ar do líonra a chéile a aimsiú agus a fhógraíonn ainm do ríomhaire ansin freisin. Anuas orthu sin, coinníonn an balla dóiteáin liúntais chaighdeánacha UFW do ping, do sheoladh a fháil ó do ródaire (DHCP), agus d'fhionnachtain UPnP. Tá ssh múchta fiú go dtí go gcuireann tú ar siúl é trí _Socrú > Slándáil > SSHD_, a údaríonn d'eochair SSH, a mhúchann logálacha isteach le pasfhocal, agus a osclaíonn port 22 ansin amháin (teorannaithe ó thaobh ráta in aghaidh ionsaithe brúidiúla). Daingnímid rochtain Docker fiú ag baint úsáide as socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go mbíonn aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag baint úsáide as `omarchy-update`. Bíonn tú ag rith na leaganacha is déanaí agus is sláine de gach rud ar an mbealach sin i gcónaí.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhíonn Omarchy ag brath ach ar phacáistí ó stórtha core/extra/multilib Arch féin (Arch Linux ARM ar mheaisíní ARM, móide Asahi ALARM ar Apple Silicon) agus óna Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ó AUR, ach ní dhéanann an tsuiteáil bhunúsach é sin — ní tharraingíonn ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, ó AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáileacháin Omarchy — na ISOanna, pacáistí Omarchy, scáthán Arch — á gcosaint taobh thiar de sciath DDoS ollmhór Cloudflare agus á óstáil ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomántán ag am tosaithe, agus an ceann a logálann tú isteach leis agus a úsáideann tú le `sudo`. Déanann an socrú mar an gcéanna iad. Athraíonn _Nuashonrú > Pasfhocal_ sa roghchlár Omarchy an dá cheann ag an am céanna, ionas go bhfanann siad mar an gcéanna: iarrann sé pasfhocal reatha an tiomántáin, ansin an ceann nua, athraíonn sé ceann an tiomántáin agus ansin socraíonn sé do phasfhocal logála isteach le bheith mar an gcéanna leis. Gan criptiú tiomántáin ní athraíonn sé ach do phasfhocal logála isteach. Má chuirtear isteach ar athrú, rith _Nuashonrú > Pasfhocal_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois, críochnaíonn sé an t-athrú, agus socraíonn sé do phasfhocal logála isteach leis. Chun pasfhocal tiomántáin chriptithe eile a athrú, rith `omarchy-drive-password` i dteirminéal.

## Meaisín a d'úsáid tú cheana a thabhairt ar aghaidh

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Bain > Athshocrú Monarchan_ sa roghchlár Omarchy, clóscríobh `reset` chun é a dheimhniú, cuir isteach do phasfhocal criptithe tiomántáin má iarrtar é, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach gach pacáiste agus athrú córais a rinne tú ón tsuiteáil, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha ósta, agus gach rud. Is é a thagann ar ais suas ná an treoraí socraithe ón gcéad am tosaithe, réidh dá úinéir nua a n-ainm féin, a phasfhocal féin, agus a phasfhocal criptithe féin a chur isteach.

Oibríonn sé trí shnapghraf bunlíne a thógann an suiteálaí a athchóiriú, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ó ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh seachas scriosadh slán atá i gceist le hathshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina ionad.

## sudo gan pasfhocal

Uaireanta bíonn tú ag iarraidh go stopfaidh `sudo` ag fiafraí, is minice nuair a bhíonn gníomhaí AI ag déanamh tréimhse fada oibre córais duit. Fiafraíonn _Socrú > Slándáil > Sudo Gan Pasfhocal_ cá fhad a cheadófar rochtain: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go Buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar bharra an roghchláir fad a bhíonn an rochtain gníomhach. Cliceáil é nó rith an t-ordú arís chun an rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a thrasnaigh an spriocdháta. Cuireann atosú an ríomhaire deireadh leis go luath. Maireann rochtain bhuan trí atosaíochtaí agus fanann sí cumasaithe go dtí go ndíchumasaíonn tú í.

Cuireann nuashonrú nó baint phacáiste socruithe Omarchy deireadh le haon deonú sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glantacháin, réitigh í sula ndéanann tú iarracht deonú eile a chumasú; ní chiallaíonn earráid nach bhfuil rochtain gan pasfhocal gníomhach.

Bí soiléir faoi seo: fad atá sé ar siúl, is féidir le haon rud a ritheann mar d'úsáideoir aon rud a dhéanamh mar root gan ceist a chur. Is é sin an pointe ar fad, agus is é sin an riosca ar fad freisin.

## Eochracha Síniúcháin

Is í an eochair phoiblí do gach síniú ISO agus do phacáiste stóir Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([deimhnigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a chur i bhfeidhm go réidh.

Is féidir leat an síniú d'aon eisiúint ISO a fháil trí `.sig` a chur lena URL, cosúil le `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`. 
