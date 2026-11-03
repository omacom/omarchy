# Ag Tosú

Suiteáiltear Omarchy le ISO. Is féidir leat roghnú idir suiteáil lán-diosca, a ghlacann seilbh ar an tiomántán ar fad, nó suiteáil spáis shaor, a chuireann Omarchy sa spás neamhleithdháilte ar thiomántán — sin é an chaoi a ndéanann tú dé-thosú taobh le Windows nó córas oibriúcháin eile (féach [suiteáil dé-thosaithe](50-dual-boot-install.md) — tabhair faoi deara go mbeidh ort BitLocker a mhúchadh in Windows ar dtús). Cibé bealach, criptiú iomlán is ea an réamhshocrú don tsuiteáil, agus scriosfaidh an rogha lán-diosca an tiomántán roghnaithe, mar sin déan cinnte cúltaca a dhéanamh sula n-úsáideann tú ceann atá ann cheana!

[Íoslódáil ISO Omarchy](https://omarchy.org/) ar dtús, cuir ar mhéaróg USB é (úsáid [Rufus](https://rufus.ie/) ar Windows, [balenaEtcher](https://etcher.balena.io/) ar Mac, nó [caligula](https://github.com/ifd3f/caligula) ar Linux), agus tosaigh ón méaróg.

_Caithfidh tú Secure Boot agus/nó TPM a mhúchadh sa BIOS. Caithfidh tú iad seo a mhúchadh le go mbeidh tú in ann Omarchy a shuiteáil. Is scéimeanna slándála de chuid Microsoft iad atá ceaptha do Windows agus do dháiltí Linux atá cleamhnaithe le Microsoft._

Ansin freagair na ceisteanna cumraíochta, agus deimhnigh iad mar seo:

 ![install-config](images/install-config.webp)

Ansin roghnaigh tiomántán do do shuiteáil, agus suigh siar agus féach ar sheó na suiteála. Is féidir é a dhéanamh i níos lú ná nóiméad ar na meaisíní nua-aimseartha is tapúla, ach níor cheart go dtógfadh sé níos mó ná 5 nóiméad fiú ar ríomhaire níos sine.

 ![install-done](images/install-done.webp)

Anois tá tú réidh le haghaidh Omarchy!

### Bain úsáid as méarchlár sreangaithe nó 2.4ghz!

Ní ligfidh an criptiú lán-diosca duit an focal faire a iontráil ó mhéarchlár Bluetooth ag am tosaithe. Díreach mar nach féidir leat méarchlár Bluetooth a úsáid chun dul isteach sa BIOS ar PC. Beidh méarchlár uait a úsáideann dongal 2.4ghz nó cábla (rud atá i bhfad níos deise ó thaobh moille de ar aon nós!). Is breá liom féin an [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Suiteáil d'úinéir eile

Má tá meaisín á shocrú agat do dhuine eile — ball teaghlaigh, fostaí nua, ceannaitheoir — níor cheart duit na ceisteanna pearsanta a fhreagairt ar a son. Brúigh `Ctrl + C` ar an gcéad scáileán den suiteálaí (roghnú an mhéarchláir), agus tairgfidh Omarchy an meaisín a ullmhú d'úinéir eile ina ionad sin. Suiteálann an córas láithreach, ach cuirtear an socrú pearsanta ar fad — leagan amach an mhéarchláir, ainm úsáideora, focal faire — ar athlá go dtí go dtosaíonn an meaisín den chéad uair. Bíonn an tiomántán criptithe de réir réamhshocraithe fós, agus déantar focal faire criptithe freisin den fhocal faire a roghnaíonn an t-úinéir nua ar an gcéad tosú sin. (Is féidir meaisín a bhí in úsáid agat cheana a thabhairt ar aghaidh gan athshuiteáil freisin — féach [an ríomhaire a athshocrú](48-security.md).)

### Suiteálacha gan duine i láthair

Is féidir leis an ISO suiteáil go hiomlán leis féin freisin — gan méarchlár, gan treoraí — nuair a thugtar a chumraíocht dó ar an dara tiomántán. Sin é an chaoi le caitheamh le Omarchy mar bhuníomhá do VManna agus do mheaisíní flít. Féach [suiteálacha gan duine i láthair](51-unattended-installs.md).

### Suiteálacha gan criptiú

Suiteáiltear Omarchy le criptiú de réir réamhshocraithe. Is é an rogha shábháilte, fhreagrach é d'aon ríomhaire a d'fhéadfaí a chailleadh nó a ghoid. Ní mian leat go mbeadh duine ar bith a bhfuil rochtain aige ar do chrua-earraí in ann do chuid sonraí a fháil!

Ach i gcúinsí speisialta, cosúil le suiteálacha cianda Omarchy ar ríomhairí cosanta nó le haghaidh suiteálacha indiúscartha gan sonraí íogaire, b'fhéidir gur mian leat suiteáil gan criptiú. Is féidir leat `Ctrl + C` a bhrú ar an deimhniú formáidithe diosca chun athrú go suiteáil gan criptiú.

### Teanga

Labhraíonn Omarchy 50 teanga — an tacar céanna le omarchy.org — agus is é an Béarla an réamhshocrú. Chun athrú, oscail roghchlár Omarchy agus téigh go _Socrú > Teanga_, nó rith `omarchy language <code>` i dteirminéal (taispeánann `omarchy language list` na cóid). Athraíonn an roghchlár, an deasc, agus fógraí Omarchy féin teanga láithreach, agus leanann gach feidhmchlár a osclaíonn tú ina dhiaidh sin iad freisin. Athraíonn aipeanna a bhí oscailte cheana a luaithe a atosaíonn tú iad.

### Cabhair má tá tú i bhfostú

Má tá tú i bhfostú, de ghnáth is féidir leat duine a aimsiú atá sásta cabhrú sa chainéal _#omarchy-help_ ar [Discord an phobail](https://omarchy.org/discord).
