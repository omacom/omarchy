# Slándáil

Glacann Omarchy an tslándáil an-dáiríre. Tá sé seo i gceist a bheith ina chóras oibriúcháin is féidir leat a úsáid chun _Fíorobair_ a dhéanamh sa _Domhan Fíor_. Áit nach féidir le ríomhaire glúine a chailleadh éigeandáil slándála a chruthú. Mar sin seo an méid a dhéanaimid:

1. *Tá criptiú lándiosca éigeantach*: Is é seo an chéim is tábhachtaí chun cosaint fhisiciúil do shonraí a dhaingniú. Má chailltear nó má ghoidtear do ríomhaire, tá na sonraí criptithe go hiomlán ag baint úsáide as LUKS caighdeánach (Linux Unified Key Setup).
2. *Tá an balla dóiteáin cumasaithe de réir réamhshocraithe*: Blocáiltear an trácht isteach go léir de réir réamhshocraithe ach amháin port 53317 do [LocalSend](https://localsend.org/). Tá fiú ssh múchta go dtí go gcuireann tú air é trí _Socrú > Security > SSHD_, a osclaíonn port 22 (ráta teoranta in aghaidh brute force) mar chuid den socrú. Glasálaimid rochtain Docker fiú ag baint úsáide as an socrú [ufw-docker](https://github.com/chaifeng/ufw-docker) chun cosc a chur ar do choimeádáin a nochtadh go timpisteach don domhan.
3. *Bíonn na nuashonruithe is déanaí ag Arch i gcónaí*: Is dáileadh rollach é Arch, an distro bunúsach ar a bhfuil Omarchy tógtha. Ciallaíonn sé seo go bhfuil aon leochaileacht slándála a aimsítear agus a phaisteáiltear in aon phacáiste ar fáil go tapa le suiteáil ag baint úsáide as `omarchy-update`. Tá tú ag rith na leaganacha is déanaí, is sláine de gach rud ar an mbealach sin i gcónaí.
4. *Coinníonn Omarchy a phacáistí agus a scáthán féin*: Ní bhraitheann Omarchy ach ar phacáistí ó stórtha core/extra/multilib Arch féin agus a Stór Pacáistí Omarchy féin de réir réamhshocraithe. Is féidir leat bogearraí a shuiteáil go díreach ón AUR, ach ní dhéanann an tsuiteáil bhunúsach amhlaidh — ní tharraingíonn ach cúpla suiteáil roghnach, cosúil leis na brabhsálaithe tríú páirtí, ón AUR.
5. *Cosnaíonn Cloudflare muid ó DDoS*: Tá bonneagar dáilte Omarchy go léir — na ISOanna, pacáistí Omarchy, scáthán Arch — cosanta taobh thiar de sciath DDoS ollmhór Cloudflare agus óstáilte ar a CDN. Soláthraíonn sé seo infhaighteacht den scoth.

## Do phasfhocail a athrú

Tá dhá phasfhocal agat ar shuiteáil chriptithe: an ceann a dhíghlasálann an tiomáint ag am tosaithe, agus an ceann a logálann tú isteach agus a dhéanann `sudo` leis. Déanann an Socrú mar an gcéanna iad. Is féidir an dá cheann a athrú faoi _Nuashonraigh > Password_ sa roghchlár Omarchy — _Drive Encryption_ don chéad cheann, _User_ don dara ceann. Iarrann pasfhocal an tiománaithe a athrú an ceann reatha ar dtús, mar sin bíodh sé ar láimh agat. Má chuirtear isteach ar athrú, rith _Drive Encryption_ arís: iarrann sé an pasfhocal a dhíghlasálann an tiomáint anois agus críochnaíonn sé an t-athrú.

## Meaisín atá úsáidte agat cheana a thabhairt ar aghaidh

Má tá do mheaisín á thabhairt ar aghaidh agat chuig duine éigin eile, ní gá duit é a athshuiteáil. Rith _Socrú > Reset Computer_ sa roghchlár Omarchy, clóscríobh `reset` chun a dheimhniú, agus atosaigh. Glanann sé sin gach cuntas úsáideora agus gach rud in `/home`, caitheann sé amach na pacáistí agus na hathruithe córais go léir a rinne tú ó shuiteáil, agus glanann sé féiniúlacht an mheaisín — naisc líonra, eochracha óstacha, agus gach rud. Is é a thagann ar ais suas ná an treoraí socraithe ón gcéad tosú, réidh dá úinéir nua a n-ainm féin, a bpasfhocal, agus a bpasfhocal criptithe a chur isteach.

Oibríonn sé tríd an seat bonnlíne a thógann an suiteálaí a chur ar ais, mar sin níl sé ar fáil ach ar mheaisíní a suiteáladh ó ISO Omarchy. Agus ar thiomáint gan chriptiú, is scriosadh seachas scrios slán é athshocrú, mar sin má bhí na sonraí íogair, déan suiteáil úr ina áit sin.

## Sudo gan phasfhocal

Uaireanta teastaíonn uait go stopfadh `sudo` ag fiafraí, is minice nuair atá gníomhaire AI ag déanamh stráice fada oibre córais duit. Fiafraíonn _Socrú > Security > Passwordless Sudo_ cé chomh fada le rochtain a cheadú: **15 minutes**, **1 Hour**, **1 Day**, nó **Permanently**. Bíonn deilbhín rabhaidh dearg le feiceáil in aice leis na táscairí barra roghchláir eile fad is atá rochtain gníomhach. Cliceáil air nó rith an t-ordú arís chun rochtain a mhúchadh. Is féidir leat do líon nóiméad féin (ó 1 go 1440) a chur ar aghaidh freisin le `omarchy-sudo-passwordless 30`, nó `omarchy-sudo-passwordless permanent` a úsáid.

Téann rochtain uainithe in éag go huathoibríoch, lena n-áirítear díreach tar éis atosú ó fhionraí a thrasnaigh an spriocdháta. Críochnaíonn an ríomhaire a atosú go luath é. Maireann buanrochtain atosuithe agus fanann sí cumasaithe go dtí go ndíchumasóidh tú í.

Críochnaíonn pacáiste socruithe Omarchy a nuashonrú nó a bhaint aon deontas sealadach sula n-athraíonn a thacaíocht éaga. Má thuairiscíonn an t-ordú earráid údaraithe nó glantacháin, réitigh é sula ndéanann tú iarracht deontas eile a chumasú; ní chiallaíonn earráid nach bhfuil rochtain gan phasfhocal neamhghníomhach.

Bí soiléir machnaimh faoin gceann seo: fad is atá sé ar siúl, is féidir le haon rud atá ag rith mar d'úsáideoir aon rud a dhéanamh mar root gan a bheith á fhiafraí. Sin an pointe ar fad, agus is é an riosca ar fad é freisin.

## Eochracha Sínithe

Is é an eochair phoiblí do shínithe ISO go léir agus pacáiste repo Omarchy ná `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([fíoraigh ag openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Tá sé seo sa phacáiste `omarchy/omarchy-keyring` freisin agus úsáidfear é chun aon nuashonruithe féideartha a rolladh amach gan uaim.

Is féidir leat an síniú d'aon eisiúint ISO a fháil trí .sig a chur leis an URL. Cosúil le https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
