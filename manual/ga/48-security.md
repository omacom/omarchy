# Slándáil

Glacann Omarchy slándáil thar a bheith dáiríre. Tá sé i gceist gur córas oibriúcháin é seo is féidir leat a úsáid chun _Fíorobair_ a dhéanamh sa _Fíorshaol_. Áit nach féidir le ríomhaire glúine a chailleadh éigeandáil slándála a chruthú. Seo mar a dhéanaimid é, mar sin:

1. *Is éigeantach é criptiú lán-diosca*: Seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, tá na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup).
2. *Tá an balla dóiteáin cumasaithe de réir réamhshocraithe*: Cuirtear bac ar gach trácht isteach de réir réamhshocraithe ach amháin port 53317 do [LocalSend](https://localsend.org/). Tá fiú ssh múchta go dtí go gcasann tú air é trí _Setup > Security > SSHD_, a osclaíonn port 22 (teoranta ó thaobh ráta de in aghaidh fórsa brúidiúil) mar chuid den socrú. Glasálaimid síos fiú rochtain Docker ag baint úsáide as an socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a bheith nochta don domhan de thaisme.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé sin go mbíonn aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag baint úsáide as `omarchy-update`. Bíonn tú i gcónaí ag rith na leaganacha is déanaí agus is sláine de gach rud ar an mbealach sin.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhraitheann Omarchy ach ar phacáistí ó stórtha core/extra/multilib Arch féin agus óna Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ón AUR, ach ní dhéanann an tsuiteáil bhunúsach é — ní tharraingíonn ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, ón AUR.
5. *Cosnaíonn Cloudflare sinn ó DDoS*: Tá bonneagar dáileacháin Omarchy — na ISOanna, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath DDoS ollmhór Cloudflare agus á óstáil ar a CDN. Soláthraíonn sé sin infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomántán ag am tosaithe, agus an ceann lena logálann tú isteach agus a úsáideann tú le `sudo`. Déanann an socrú mar an gcéanna iad. Is féidir an dá cheann a athrú faoi _Update > Password_ i roghchlár Omarchy — _Drive Encryption_ don chéad cheann, _User_ don dara ceann. Iarrann athrú phasfhocal an tiomántáin an ceann reatha ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Drive Encryption_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomántán anois agus críochnaíonn sé an t-athrú.

## Meaisín atá úsáidte agat cheana a thabhairt ar aghaidh

Má tá tú ag tabhairt do mheaisín do dhuine eile, ní gá duit é a athshuiteáil. Rith _Setup > Reset Computer_ i roghchlár Omarchy, clóscríobh `reset` chun deimhniú, agus atosaigh. Scriosann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach na pacáistí agus na hathruithe córais go léir a rinne tú ó shuiteáil tú é, agus glanann sé céannacht an mheaisín — naisc líonra, eochracha óstaigh, agus gach rud. Is é an treoraí socraithe ón gcéad tosú a thagann ar ais, réidh dá úinéir nua a n-ainm féin, a bpasfhocal féin, agus a bpasfhocal criptiúcháin féin a chur isteach.

Oibríonn sé trí ghrianghraf bunlíne a thógann an suiteálaí a athchóiriú, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ón ISO Omarchy. Agus ar thiomántán gan criptiú, is scriosadh é athshocrú seachas scriosadh slán, mar sin má bhí na sonraí íogair, déan suiteáil úr ina ionad.

## sudo gan phasfhocal

Uaireanta ba mhaith leat go stopfadh `sudo` ag iarraidh, go minic nuair a bhíonn gníomhaire AI ag déanamh tréimhse fada oibre córais duit. Iarrann _Setup > Security > Passwordless Sudo_ cé chomh fada is ceart rochtain a cheadú: **15 nóiméad**, **1 Uair**, **1 Lá**, nó **Go Buan**. Feictear deilbhín rabhaidh dearg in aice leis na táscairí eile ar an mbarra roghchláir fad atá an rochtain gníomhach. Cliceáil é nó rith an t-ordú arís chun an rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh freisin le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain ama in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a chuaigh thar an spriocdháta. Cuireann atosú an ríomhaire deireadh leis go luath. Maireann rochtain bhuán trí atosuithe agus fanann sí cumasaithe go dtí go ndíchumasaíonn tú í.

Cuireann nuashonrú nó baint phacáiste socruithe Omarchy deireadh le haon deontas sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glantacháin, réitigh í sula ndéanann tú iarracht deontas eile a chumasú; ní chiallaíonn earráid go bhfuil rochtain gan phasfhocal neamhghníomhach.

Bí soiléir faoi seo: fad atá sé ar siúl, is féidir le haon rud atá ag rith mar d'úsáideoir aon rud a dhéanamh mar root gan ceist a chur. Sin an pointe ar fad, agus sin an riosca ar fad freisin.

## Eochracha Síniúcháin

Is í an eochair phoiblí do gach síniú ISO agus do phacáiste stóir Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([fíoraigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach gan uaim.

Is féidir leat síniú aon eisiúna ISO a fháil trí `.sig` a chur lena URL, cosúil le `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
