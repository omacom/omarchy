# Ag Tosú

Suiteáiltear Omarchy ag úsáid ISO. Is féidir leat roghnú idir suiteáil lándiosca, a ghlacann seilbh ar an tiomántán ar fad, nó suiteáil saorspáis, a chuireann Omarchy sa spás neamhdháilte ar thiomántán — sin é an chaoi a ndéanann tú dé-thosú in éineacht le Windows nó córas oibriúcháin eile (féach [suiteáil dé-thosaithe](50-dual-boot-install.md) — tabhair faoi deara go mbeidh ort BitLocker a mhúchadh i Windows ar dtús). Ar an dá bhealach, is é criptiú iomlán an réamhshocrú don tsuiteáil, agus scriosfaidh an rogha lándiosca an tiomántán roghnaithe, mar sin déan cinnte cúltaca a dhéanamh sula n-úsáideann tú ceann atá ann cheana!

[Íoslódáil ISO Omarchy](https://omarchy.org/) ar dtús, cuir ar mhaide USB é (úsáid [Rufus](https://rufus.ie/) ar Windows, [balenaEtcher](https://etcher.balena.io/) ar Mac, nó [caligula](https://github.com/ifd3f/caligula) ar Linux), agus tosagh ón maide.

_Caithfidh tú Secure Boot agus/nó TPM a mhúchadh sa BIOS. Caithfidh tú iad seo a mhúchadh chun go mbeidh tú in ann Omarchy a shuiteáil. Is scéimeanna slándála Microsoft iad atá beartaithe do Windows agus do dháiltí Linux atá cleamhnaithe le Microsoft._

Ansin freagair na ceisteanna cumraíochta, agus deimhnigh iad mar seo:

 ![install-config](images/install-config.webp)

Ansin roghnaigh tiomántán do do shuiteáil, agus suigh siar agus féach ar sheó na suiteála ag imeacht. Is féidir é a dhéanamh i níos lú ná nóiméad ar na meaisíní nua-aimseartha is tapúla, ach níor cheart go dtógfadh sé níos mó ná 5 nóiméad fiú ar ríomhaire níos sine.

 ![install-done](images/install-done.webp)

Anois tá tú réidh le haghaidh Omarchy!

### Úsáid méarchlár sreangaithe nó 2.4ghz!

Ní ligfidh an criptiú lándiosca duit an pasfhocal a iontráil ó mhéarchlár Bluetooth ag an am tosaithe. Díreach mar nach féidir leat méarchlár Bluetooth a úsáid chun dul isteach sa BIOS ar PC. Beidh méarchlár uait a úsáideann dongle 2.4ghz nó cábla (rud atá i bhfad níos deise ó thaobh na moille de ar aon nós!). Is breá liom féin an [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Suiteáil d'úinéir eile

Má tá tú ag socrú meaisín do dhuine eile — ball teaghlaigh, fostaí nua, ceannaitheoir — níor cheart duit a bheith ag freagairt na gceisteanna pearsanta ar a son. Brúigh `Ctrl + C` ar an gcéad scáileán ar fad den suiteálaí (roghnú an mhéarchláir), agus tairgfidh Omarchy an meaisín a ullmhú d'úinéir eile ina áit. Suiteálann an córas láithreach, ach cuirtear an socrú pearsanta ar fad — leagan amach an mhéarchláir, ainm úsáideora, pasfhocal — siar go dtí go dtosaíonn an meaisín den chéad uair. Tá an tiomántán criptithe de réir réamhshocruithe fós, agus déantar pasfhocal criptithe den phasfhocal a roghnaíonn an t-úinéir nua ar an gcéad tosú sin freisin. (Is féidir meaisín a bhfuil tú ag úsáid cheana a thabhairt ar aghaidh gan athshuiteáil freisin — féach [an ríomhaire a athshocrú](48-security.md).)

### Suiteálacha gan duine i láthair

Is féidir leis an ISO suiteáil go hiomlán leis féin freisin — gan méarchlár, gan treoraí — nuair a thugtar a chumraíocht dó ar an dara tiomántán. Sin é an chaoi le caitheamh le Omarchy mar íomhá bhunúsach do VMs agus do mheaisíní flít. Féach [suiteálacha gan duine i láthair](51-unattended-installs.md).

### Suiteálacha gan criptiú

Suiteáiltear Omarchy le criptiú de réir réamhshocruithe. Is é an rogha shábháilte, fhreagrach é d'aon ríomhaire a d'fhéadfaí a chailleadh nó a ghoid. Ní theastaíonn uait go mbeadh aon duine a bhfuil rochtain aige ar do chrua-earraí in ann do chuid sonraí a fháil!

Ach i gcúinsí speisialta, cosúil le suiteálacha cianda Omarchy ar ríomhairí cosanta nó do shuiteálacha caith-uaire gan sonraí íogaire, b'fhéidir gur mhaith leat suiteáil gan criptiú. Is féidir leat `Ctrl + C` a bhrú ar an deimhniú formáidithe diosca chun athrú go suiteáil gan criptiú.

### Teanga

Labhraíonn Omarchy 50 teanga — an tacar céanna le omarchy.org — agus is é Béarla an réamhshocrú. Chun athrú, oscail roghchlár Omarchy agus téigh go _Socrú > Réigiún > Teanga_, nó rith `omarchy language <code>` i dteirminéal (taispeánann `omarchy language list` na cóid). Athraíonn an roghchlár, an deasc, agus fógraí Omarchy féin teanga láithreach, agus leanann gach feidhmchlár a osclaíonn tú ina dhiaidh sin freisin. Athraíonn aipeanna a bhí oscailte cheana a luaithe a atosóidh tú iad.

Chun an teanga a choinneáil ach dátaí, amanna, uimhreacha, airgead, aonaid agus méideanna páipéir a scríobh mar a dhéanann réigiún eile (Béarla le dátaí Eorpacha agus clog 24 uair an chloig, mar shampla), roghnaigh réigiún faoi _Socrú > Réigiún > Formáidí_, áit a dtaispeánann gach rogha sampla, nó rith `omarchy region <code>` (taispeánann `omarchy region list` na cóid). Téann _Mar an gcéanna leis an teanga_ ar ais go formáidí na teanga féin. Cosúil le hathrú teanga, sroicheann sé na haipeanna a osclaíonn tú ina dhiaidh sin.

### Cabhair má tá tú i bhfostú

Má théann tú i bhfostú, is gnách go bhfaighidh tú duine éigin atá sásta cabhrú sa chainéal _#omarchy-help_ ar [Discord an phobail](https://omarchy.org/discord).
