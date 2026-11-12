# Taic do Mhac

Tha taic thogte aig Omarchy do **Mhacs Intel**. Tha corra chuingealachadh aithnichte ann aig an àm seo, ach fhad 's a tha thu mothachail orra is coma leat iad, 's urrainn dhut beatha ùr a thoirt dha na seann Mhacs agad le Omarchy a chur orra.

Thoir an aire nach eil taic dhìreach ann do stàladh air Mac sreath-M aig an àm seo. Gheibh thu barrachd fiosrachaidh mu shuidheachadh na cùise seo ann an #omarchy-on-other air an [Discord](https://discord.gg/tXFUdasqhY) againn.

Ann an deuchainn shìmplidh, fhuair sinn piseach 36% air dèanadas MacBook Pro 2019 dìreach le bhith a' stàladh Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy a stàladh air Mac

Chan eil taic aig Omarchy aig an àm seo ach a bhith na **aon** OS a-mhàin air an inneal. Rè an stàlaidh, thèid an draibh a shuathadh às agus cha ghabh MacOS a bhùtadh tuilleadh.

'S urrainn dhut aiseag fhathast às a dhèidh seo le Internet Recovery ma thogras tu.

Airson na pàirt seo, gabhaidh sinn ris gun do leugh thu [A' tòiseachadh](02-getting-started.md) mu thràth is gu bheil an draibh USB agad deiseil. Mura do rinn, dèan sin an-dràsta.

#### Cuir Secure Boot à comas

Feumaidh tu Secure Boot aig Apple a chur à comas gus an draibh USB bùtaidh a bhùtadh, agus an OS cuideachd. Airson a chur à comas, dèan na leanas:

1. Cuir dheth am Mac agad
2. Cuir air e agus brùth is cùm Command-R _sa bhad_ gus am faic thu an sgrìn luchdaidh a' nochdadh
3. Tagh an cleachdaiche agad agus cuir a-steach am facal-faire agad ma thèid iarraidh ort
4. Nuair a bhios tu air sgrìn an aiseig, tagh **Utilities > Startup Security Utility** o bhàr a' chlàir-thaice
5. Cuir a-steach am facal-faire agad nuair a thèid iarraidh ort airson dearbhadh
6. Tagh "No Security" o roghainnean Secure Boot
7. Tagh "Allow booting from external or removable media" o roghainnean External Boot

#### Tòisich an stàladh

1. Cuir a-steach an draibh USB
2. Ath-thòisich am Mac agad agus brùth is cùm Option _sa bhad_ gus am faic thu sgrìn de dh'uidheaman bùtaidh
3. Tagh an t-uidheam orains EFI Boot
4. Lean air adhart leis an [stàladh àbhaisteach](02-getting-started.md)

Mothaichidh an stàlaichear do bhathar-cruaidh Mac is cuiridh e na càraidhean a tha a dhìth an sàs gu fèin-obrachail: draibhearan is firmware Wi-Fi Broadcom, an draibhear meur-chlàir SPI air na modailean MacBook a dh'fheumas e, agus càradh NVMe airson cur na dhàil air na h-aon mhodailean sin.

### Cuingealachaidhean aithnichte

Tha buill na coimhearsnachd an-còmhnaidh ag obair air fuasglaidhean dha na dùbhlain seo, mar sin ma tha iad nan trioblaid dhut, thig a-steach do #omarchy-on-other air an [Discord](https://discord.gg/tXFUdasqhY) againn is faic a bheil dòighean ùra ann airson am fuasgladh.

#### Uidheaman le sliseag T1

Chaidh sliseag T1 aig Apple a thoirt a-steach anmoch ann an 2016 agus cha deach a cleachdadh ach anns a' chiad ghinealach de mhodailean MacBook Pro le Touch Bar.
- MacBook Pro 13-òirleach (2016, dà phort Thunderbolt 3) – Modail: A1706
- MacBook Pro 13-òirleach (2016, ceithir puirt Thunderbolt 3) – Modail: A1708
- MacBook Pro 15-òirleach (2016) – Modail: A1707

#### Duilgheadasan aithnichte

- Chan obraich an Touch Bar
- Chan obraich an fhuaim

#### Uidheaman le sliseag T2

Chaidh sliseag tèarainteachd T2 aig Apple a thoirt a-steach ann an 2017. Chaidh stad a chur air sliseag T2 leis a' ghluasad gu Apple silicon (sliseagan sreath-M) a' tòiseachadh ann an 2020.

- iMac Pro (2017) – Modail: A1862
- MacBook Pro 13-òirleach (2018, ceithir puirt Thunderbolt 3) – Modail: A1989
- MacBook Pro 15-òirleach (2018) – Modail: A1990
- MacBook Air (Retina, 13-òirleach, 2018) – Modail: A1932
- Mac mini (2018) – Modail: A1998
- MacBook Pro 13-òirleach (2019, dà phort Thunderbolt 3) – Modail: A2159
- MacBook Pro 13-òirleach (2019, ceithir puirt Thunderbolt 3) – Modail: A2178
- MacBook Pro 15-òirleach (2019) – Modail: A1990
- iMac (Retina 5K, 27-òirleach, 2020) – Modail: A2115 (iMac20,1 agus iMac20,2)
- MacBook Pro 13-òirleach (2020, dà phort Thunderbolt 3) – Modail: A2265
- MacBook Pro 15-òirleach (2020) – Modail: A1990

Air na modailean seo, suidhichidh an stàlaichear gu fèin-obrachail an kernel `linux-t2` air a bheil bad-càraidh, rèiteachadh fuaime T2, firmware Wi-Fi/Bluetooth Broadcom aig Apple, agus smachd air an fhanaiche le `t2fanrd`. Ruithidh an Touch Bar air an taic thogte san kernel a tha coltach ri Boot Camp.
