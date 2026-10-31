# Ag Tosú

Suiteáiltear Omarchy trí ISO a úsáid. Is féidir leat roghnú idir suiteáil lándiosca, a thógann an tiomántán ar fad chuici féin, nó suiteáil i spás saor, a chuireann Omarchy sa spás neamhleithdháilte ar thiomántán — sin an chaoi a ndéanann tú tosú déach taobh le Windows nó OS eile (féach [suiteáil tosaithe déach](50-dual-boot-install.md) — tabhair faoi deara go mbeidh ort BitLocker a mhúchadh i Windows ar dtús). Ar cheachtar den dá chaoi, is criptiú iomlán réamhshocrú na suiteála, agus scriosfaidh an rogha lándiosca an tiomántán roghnaithe, mar sin bí cinnte cúltaca a dhéanamh sula n-úsáideann tú ceann atá ann cheana!

[Íoslódáil ISO Omarchy](https://omarchy.org/) ar dtús, cuir ar mhaide USB é (úsáid [balenaEtcher](https://etcher.balena.io/) ar Mac/Windows nó [caligula](https://github.com/ifd3f/caligula) ar Linux), agus tosaigh ón maide.

_Caithfidh tú Secure Boot agus/nó TPM a mhúchadh sa BIOS. Caithfidh tú iad seo a mhúchadh chun go mbeidh tú in ann Omarchy a shuiteáil. Scéimeanna slándála de chuid Microsoft iad atá ceaptha do Windows agus do dháiltí Linux atá cleamhnaithe le Microsoft._

Ansin freagair na ceisteanna cumraíochta, agus deimhnigh iad mar seo:

 ![install-config](images/install-config.webp)

Ansin roghnaigh tiomántán le haghaidh do shuiteála, agus suigh siar agus féach ar sheó na suiteála ar siúl. Is féidir é a dhéanamh i níos lú ná nóiméad ar na meaisíní nua-aimseartha is tapúla, ach níor cheart go dtógfadh sé níos mó ná 5 nóiméad fiú ar ríomhaire níos sine.

 ![install-done](images/install-done.webp)

Anois tá tú réidh le Omarchy!

### Úsáid méarchlár sreangaithe nó 2.4ghz!

Ní ligfidh an criptiú lándiosca duit an focal faire a chur isteach ó mhéarchlár Bluetooth ag an tosú. Díreach mar nach féidir leat méarchlár Bluetooth a úsáid chun dul isteach sa BIOS ar PC. Beidh méarchlár uait a úsáideann dongle 2.4ghz nó cábla (rud atá i bhfad níos deise ó thaobh na moille de ar aon nós!). Is breá liom féin an [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Suiteáil d'úinéir eile

Má tá meaisín á chur ar bun agat do dhuine eile — ball teaghlaigh, fostaí nua, ceannaitheoir — níor cheart duit na ceisteanna pearsanta a fhreagairt ar a son. Buail `Ctrl + C` ar an gcéad scáileán ar fad den suiteálaí (roghnú an mhéarchláir), agus tairgfidh Omarchy an meaisín a ullmhú d'úinéir eile ina ionad sin. Suiteálann an córas láithreach, ach cuirtear an socrú pearsanta ar fad — leagan amach an mhéarchláir, ainm úsáideora, focal faire — ar atráth go dtí go dtosaíonn an meaisín den chéad uair. Tá an tiomántán criptithe de réir réamhshocraithe fós, agus déantar an focal faire a roghnaíonn an t-úinéir nua ar an gcéad tosú sin mar fhocal faire an chriptithe chomh maith. (Is féidir meaisín a bhí in úsáid agat cheana a thabhairt ar aghaidh gan athshuiteáil freisin — féach [athshocrú an ríomhaire](48-security.md).)

### Suiteálacha gan freastal

Is féidir leis an ISO suiteáil go hiomlán leis féin freisin — gan méarchlár, gan draoi — nuair a thugtar a chumraíocht dó ar an dara tiomántán. Sin an chaoi le Omarchy a úsáid mar bhuníomhá do VMs agus do mheaisíní flít. Féach [suiteálacha gan freastal](51-unattended-installs.md).

### Suiteálacha gan criptiú

Suiteáiltear Omarchy le criptiú de réir réamhshocraithe. Is í an rogha shábháilte, fhreagrach í d'aon ríomhaire a d'fhéadfaí a chailleadh nó a ghoid. Níor mhaith leat go mbeadh aon duine a bhfuil rochtain aige ar do chrua-earraí in ann do shonraí a fháil!

Ach i gcúinsí speisialta, cosúil le suiteálacha Omarchy cianda ar ríomhairí faoi chosaint nó le haghaidh suiteálacha caith uait gan sonraí íogaire, b'fhéidir gur mhaith leat suiteáil gan criptiú. Is féidir leat `Ctrl + C` a bhualadh ar an deimhniú um fhormáidiú diosca chun athrú go suiteáil gan criptiú.

### Teanga

Labhraíonn Omarchy 50 teanga — an tacar céanna le omarchy.org — agus is é an Béarla an réamhshocrú. Chun athrú, oscail roghchlár Omarchy agus téigh go _Setup > Language_, nó rith `omarchy language <code>` i dteirminéal (taispeánann `omarchy language list` na cóid). Athraíonn an roghchlár, an deasc, agus fógraí Omarchy féin teanga láithreach, agus leanann gach feidhmchlár a osclaíonn tú ina dhiaidh sin é chomh maith. Athraíonn feidhmchláir a bhí ar oscailt cheana nuair a atosaíonn tú iad.

### Cabhair má théann tú i bhfostú

Má théann tú i bhfostú, is gnách go bhfaighidh tú duine éigin atá toilteanach cabhrú sa chainéal _#omarchy-help_ ar [Discord an phobail](https://omarchy.org/discord).
