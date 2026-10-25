# Slándáil

Glacann Omarchy slándáil thar a bheith dáiríre. Tá sé i gceist gur córas oibriúcháin é seo ar féidir leat a úsáid chun _Obair Fhíor_ a dhéanamh sa _Domhan Fíor_. Áit nach féidir le cailliúint ríomhaire glúine géarchéim slándála a chruthú. Mar sin, seo a dhéanaimid:

1. *Tá criptiú lán-diosca éigeantach*: Is é seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, tá na sonraí criptithe go hiomlán ag úsáid LUKS caighdeánach (Linux Unified Key Setup).
2. *Tá an balla dóiteáin cumasaithe mar réamhshocrú*: Cuirtear bac ar gach trácht isteach mar réamhshocrú seachas port 53317 do [LocalSend](https://localsend.org/). Tá fiú ssh múchta go dtí go gcasann tú air é trí _Setup > Security > SSHD_, a osclaíonn port 22 (teoranta ó thaobh ráta de in aghaidh ionsaí le fórsa brúidiúil) mar chuid den socrú. Glasálaimid síos rochtain Docker fiú ag úsáid an tsocraithe [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an dáileadh bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go bhfuil aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag úsáid `omarchy-update`. Ar an mbealach sin, bíonn tú ag rith na leaganacha is déanaí agus is sláine de gach rud i gcónaí.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhraitheann Omarchy ach ar phacáistí ó stórtha core/extra/multilib Arch féin agus óna Stór Pacáistí Omarchy féin mar réamhshocrú. Is féidir leat bogearraí a shuiteáil go díreach ón AUR, ach ní dhéanann an tsuiteáil bhunúsach é sin — níl ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, a tharraingíonn ón AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáilte Omarchy — na ISOanna, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath láidir DDoS Cloudflare agus óstáilte ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomántán ag am tosaithe, agus an ceann a úsáideann tú chun logáil isteach agus le `sudo`. Déanann an socrú an dá cheann mar an gcéanna. Is féidir an dá cheann a athrú faoi _Update > Password_ i roghchlár Omarchy — _Drive Encryption_ don chéad cheann, _User_ don dara ceann. Iarrann athrú phasfhocal an tiomántáin an ceann reatha ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Drive Encryption_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois agus críochnaíonn sé an t-athrú.

## Meaisín atá úsáidte agat cheana a thabhairt ar aghaidh

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Setup > Reset Computer_ i roghchlár Omarchy, clóscríobh `reset` chun deimhniú, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach gach pacáiste agus athrú córais a rinne tú ó suiteáladh é, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha óstaigh, agus gach rud. Is é a thagann ar ais an treoraí socraithe ón gcéad tosú, réidh dá úinéir nua a n-ainm, a bpasfhocal, agus a bpasfhocal criptithe féin a chur isteach.

Oibríonn sé trí ghrianghraf bonnlíne a ghlacann an suiteálaí a athchóiriú, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ón ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh seachas scriosadh slán atá i gceist le hathshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina ionad.

## sudo gan phasfhocal

Uaireanta ba mhaith leat go stopfadh `sudo` ag iarraidh, go minic nuair a bhíonn gníomhaire AI ag déanamh tréimhse fhada oibre córais duit. Fiafraíonn _Setup > Security > Passwordless Sudo_ cé chomh fada is cóir rochtain a cheadú: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go Buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar an mbarra roghchláir fad atá an rochtain gníomhach. Cliceáil é nó rith an t-ordú arís chun an rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh freisin le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a chuaigh thar an spriocdháta. Cuireann atosú an ríomhaire deireadh léi go luath. Maireann rochtain bhuan trí atosuithe agus fanann sí cumasaithe go dtí go ndíchumasaíonn tú í.

Cuireann nuashonrú nó baint phacáiste socruithe Omarchy deireadh le haon deontas sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glanta, réitigh í sula ndéanann tú iarracht deontas eile a chumasú; ní chiallaíonn earráid go bhfuil rochtain gan phasfhocal neamhghníomhach.

Bí soiléir faoi seo: fad atá sé ar siúl, is féidir le haon rud atá ag rith mar d'úsáideoir aon rud a dhéanamh mar root gan ceist a chur. Sin an pointe ar fad, agus sin an riosca ar fad freisin.

## Eochracha Síniúcháin

Is í an eochair phoiblí do gach síniú ISO agus do phacáiste stóir Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([deimhnigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach gan uaim.

Is féidir leat an síniú d'aon eisiúint ISO a fháil trí .sig a chur leis an URL. Cosúil le https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
