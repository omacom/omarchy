# Ag Tosú

Suiteáiltear Omarchy le ISO. Is féidir leat roghnú idir suiteáil lán-diosca, a ghlacann seilbh ar an tiomántán ar fad, nó suiteáil spáis shaor, a chuireann Omarchy sa spás neamhleithdháilte ar thiomántán — sin é an chaoi a ndéanann tú dúbailt-tosú in éineacht le Windows nó OS eile (féach [suiteáil dúbailt-tosaithe](50-dual-boot-install.md) — tabhair faoi deara go mbeidh ort BitLocker a mhúchadh in Windows ar dtús). Cibé bealach, is é criptiú iomlán an réamhshocrú don tsuiteáil, agus scriosfaidh an rogha lán-diosca an tiomántán roghnaithe, mar sin déan cinnte cúltaca a dhéanamh sula n-úsáideann tú ceann atá ann cheana!

Ar Apple Silicon Mac, suiteálann tú ó macOS ina ionad sin, gan ISO ná bata USB. Féach [Omarchy do Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Íoslódáil ISO Omarchy](https://omarchy.org/) ar dtús, cuir ar bhata USB é (úsáid [Rufus](https://rufus.ie/) ar Windows, [balenaEtcher](https://etcher.balena.io/) ar Mac, nó [caligula](https://github.com/ifd3f/caligula) ar Linux), agus tosaigh ón mbata.

_Ní mór duit Secure Boot agus/nó TPM a mhúchadh sa BIOS. Caithfidh tú iad seo a mhúchadh chun go mbeidh tú in ann Omarchy a shuiteáil. Is scéimeanna slándála Microsoft iad atá beartaithe do Windows agus do dháiltí Linux atá cleamhnaithe le Microsoft._

Ansin freagair na ceisteanna cumraíochta, agus deimhnigh iad mar seo:

 ![install-config](images/install-config.webp)

Ansin roghnaigh tiomántán do do shuiteáil, agus suigh siar agus féach ar sheó na suiteála. Is féidir é a dhéanamh i níos lú ná nóiméad ar na meaisíní nua-aimseartha is tapúla, ach níor cheart go dtógfadh sé níos mó ná 5 nóiméad fiú ar ríomhaire níos sine.

 ![install-done](images/install-done.webp)

Anois tá tú réidh le Omarchy!

### Bain úsáid as méarchlár sreangaithe nó 2.4ghz!

Ní ligfidh an criptiú lán-diosca duit an focal faire a chur isteach ó mhéarchlár Bluetooth ag am tosaithe. Díreach mar nach féidir leat méarchlár Bluetooth a úsáid chun dul isteach sa BIOS ar PC. Beidh méarchlár uait a úsáideann dongle 2.4ghz nó cábla (atá i bhfad níos deise ó thaobh moille de ar aon nós!). Is breá liom féin an [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Suiteáil d'úinéir eile

Má tá tú ag socrú meaisín do dhuine eile — ball teaghlaigh, fostaí nua, ceannaitheoir — níor cheart duit na ceisteanna pearsanta a fhreagairt ar a son. Buail `Ctrl + C` ar an gcéad scáileán den tsuiteálaí (roghnú an mhéarchláir), agus tairgfidh Omarchy an meaisín a ullmhú d'úinéir eile ina ionad sin. Suiteálann an córas láithreach, ach cuirtear an socrú pearsanta ar fad — leagan amach an mhéarchláir, ainm úsáideora, focal faire — ar athlá go dtí go dtosaíonn an meaisín den chéad uair. Tá an tiomántán criptithe de réir réamhshocruithe fós, agus éiríonn an focal faire a roghnaíonn an t-úinéir nua ar an gcéad tosú sin ina fhocal faire criptithe freisin. (Is féidir meaisín a bhí in úsáid agat cheana a thabhairt ar aghaidh gan athshuiteáil freisin — féach [an ríomhaire a athshocrú](48-security.md).)

### Suiteálacha gan lucht freastail

Is féidir leis an ISO suiteáil go hiomlán leis féin freisin — gan méarchlár, gan draoi — nuair a thugtar a chumraíocht dó ar an dara tiomántán. Sin é an chaoi le caitheamh le Omarchy mar bhuníomhá do VMs agus do mheaisíní cabhlaigh. Féach [suiteálacha gan lucht freastail](51-unattended-installs.md).

### Suiteálacha gan criptiú

Suiteáiltear Omarchy le criptiú de réir réamhshocruithe. Is é an rogha shábháilte, fhreagrach é d'aon ríomhaire a d'fhéadfaí a chailleadh nó a ghoid. Níor mhaith leat go mbeadh aon duine a bhfuil rochtain aige ar do chrua-earraí in ann do shonraí a fháil!

Ach i gcúinsí speisialta, cosúil le suiteálacha cianda Omarchy ar ríomhairí cosanta nó le haghaidh suiteálacha sealadacha gan sonraí íogaire, b'fhéidir gur mhaith leat suiteáil gan criptiú. Is féidir leat `Ctrl + C` a bhualadh ar an deimhniú formáidithe diosca chun athrú go suiteáil gan criptiú.

### Teanga

Labhraíonn Omarchy 50 teanga — an tacar céanna le omarchy.org — agus is é English an réamhshocrú. Chun athrú, oscail roghchlár Omarchy agus téigh go _Setup > Region > Language_, nó rith `omarchy language <code>` i dteirminéal (taispeánann `omarchy language list` na cóid). Athraíonn an roghchlár, an deasc, agus fógraí Omarchy féin teanga láithreach, agus leanann gach feidhmchlár a osclaíonn tú ina dhiaidh sin freisin. Athraíonn aipeanna a bhí oscailte cheana nuair a atosaíonn tú iad.

Chun an teanga a choinneáil ach dátaí, amanna, uimhreacha, airgead, aonaid agus méideanna páipéir a scríobh mar a dhéanann réigiún eile (English le dátaí Eorpacha agus clog 24 uair an chloig, abair), roghnaigh réigiún faoi _Setup > Region > Formats_, áit a dtaispeánann gach rogha sampla, nó rith `omarchy region formats <code>` (taispeánann `omarchy region formats list` na cóid). Téann _Same as language_ ar ais go formáidí na teanga féin. Cosúil le hathrú teanga, sroicheann sé na haipeanna a osclaíonn tú ina dhiaidh sin.

### Cabhair má tá tú i sáinn

Má tá tú i sáinn, is gnách go bhfaighidh tú duine éigin atá sásta cabhrú sa chainéal _#omarchy-help_ ar [Discord an phobail](https://omarchy.org/discord).
