# Cadal an t-siostaim

Cuiridh Omarchy an dàil agus an cadal-geamhraidh an comas mar bhun-roghainn, ach ma tha duilgheadasan agad le fear seach fear dhiubh air an inneal agad, 's urrainn dhut an toglachadh dheth.

Air innealan NVIDIA GB10, leithid DGX Spark agus ASUS Ascent GX10, tha an dàil agus an cadal-geamhraidh dheth, mar a tha iad ann an DGX OS aig NVIDIA, oir cha deach a shealltainn fhathast gun obraich cadal air a' bhathar-chruaidh sin. Chan eil toglachadh na dàlach agus suidheachadh a' chadail-gheamhraidh iomchaidh an-sin. Gus cadal a chur air a-rithist, thoir air falbh `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` le `sudo rm`; tillidh Cuir na dhàil dhan chlàr-taice an uairsin, agus gabhaidh an cadal-geamhraidh suidheachadh mar air innealan eile. Ma ruitheas tu `sudo omarchy apply hardware --install-user "$USER"`, cuiridh sin am faidhle air ais.

### Pròifilean cumhachd

Air laptop, cumaidh Omarchy cuimhne air a' phròifil cumhachd agad fa leth airson nuair a bhios e ceangailte ris a' chumhachd agus nuair a bhios e a' ruith air a' bhataraidh, agus leumaidh e eatarra mar a chuireas tu a-steach is a bheir thu a-mach e. Gun atharrachadh, tha sin a' ciallachadh performance air AC agus balanced air a' bhataraidh.

Chì thu na tha an t-inneal agad a' tairgsinn le `omarchy powerprofiles list`, agus suidhichidh tu am fear a tha thu ag iarraidh airson na staid anns a bheil thu an-dràsta le `omarchy powerprofiles set autodetect power-saver`. Gus an staid eile a shuidheachadh gun dad a thoirt a-mach, ainmich i gu dìreach: `omarchy powerprofiles set battery power-saver`. Ge b' e dè a thaghas tu, 's e sin a gheibh thu air ais an ath thuras a bhios tu san staid sin.

### Toglaich an dàil

Toglaichidh tu an dàil le bhith a' ruith `omarchy toggle suspend` on tèirmineal. Cha dèan sin ach an roghainn a nochdadh/fhalach fo _Siostam_ (no `Super + Esc`), agus an uairsin chì thu a bheil e ag obair gu cunbhalach air an t-siostam agad. Mura bheil, 's urrainn dhut fhalach a-rithist leis an aon àithne.

### Toglaich an cadal-geamhraidh

Suidhichidh tu an cadal-geamhraidh le bhith a' ruith `omarchy hibernation setup` on tèirmineal. Cruthaichidh an cadal-geamhraidh fo-thomad /swap air draibh a' bhùtaidh agad a tha cho mòr ris an RAM fhiosaigeach agad, mar sin dèan cinnteach gu bheil pailteas rùim agad. Air inneal le 32GB, bidh feum agad air 32GB+ saor an-còmhnaidh airson an tomaid seo. Feumaidh an cadal-geamhraidh cuideachd an luchdaiche-bùtaidh bunaiteach Limine.

Nuair a bhios e air a shuidheachadh, chì thu an roghainn Cadal-geamhraidh fo _Siostam_ (no `Super + Esc`), agus an uairsin chì thu a bheil e ag obair gu cunbhalach air an t-siostam agad. Mura bheil, 's urrainn dhut a thoirt air falbh a-rithist le bhith a' ruith `omarchy hibernation remove`.
