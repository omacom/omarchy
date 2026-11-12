# Dealbhan-clàir an t-siostaim

Cruthaichidh sinn dealbhan-clàir gu fèin-obrachail aig gach ùrachadh Omarchy, ach ma tha thu airson feadhainn agad fhèin a chruthachadh, 's urrainn dhut `omarchy-snapshot create` a chleachdadh.

Gus dealbh-chlàir a bhùtadh agus aiseag, taghaidh tu e o luchdaiche-bùtaidh Limine. (Ma tha thu a' bùtadh dìreach gu sgrìn dì-chrioptachadh Omarchy an-dràsta, feumaidh tu Limine a thaghadh mar roghainn bùtaidh tron BIOS an toiseach.)

Air an sgrìn sin, tagh an dealbh-chlàir dhan a bheil thu airson bùtadh a rèir a' chinn-latha is an tionndaidh. Chì thu an tionndadh de dh'Omarchy a bh' ann aig àm an deilbh-làithrich san oisean gu h-ìosal air an taobh chlì.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Nuair a ruigeas tu a-staigh, nochdaidh brath ag innse dhut gu bheil thu ann an dealbh-chlàir a ghabhas bùtadh, agus ma bhriogas tu air, tòisichidh e pròiseas an aiseig. Air neo, 's urrainn dhut `omarchy-snapshot restore` a chleachdadh.

 ![snapshots-restore](images/snapshots-restore.webp)

Aisigidh seo siostam-fhaidhlichean an fhreumha agad, ach chan e `/home`. Mar sin, obraichidh e airson ùrachadh siostaim briste a thilleadh, ach chan ann airson faidhlichean pearsanta a chaill thu fhaighinn air ais.

Tha seo a' ciallachadh cuideachd gun tèid am pasgan `~/.config` agad a chumail mar a tha e. Mar sin, ma tha thu a' tilleadh gu tionndadh nas tràithe de leabharlann no aplacaid a stòras faidhlichean rèiteachaidh ann am fòrmat ùr, feumaidh tu sin a rèiteachadh thu fhèin.

_An aire: Chan eil an gleus seo ri fhaighinn ach air stàlaidhean a chleachdas luchdaiche-bùtaidh Limine, agus 's e sin am bun-roghainn o Omarchy 2.0. Chan eil e ri fhaighinn ma tha GRUB no systemd-boot agad._

### Leum thar clàr-taice a' bhùtaidh

Mura bean thu ri clàr-taice a' bhùtaidh idir is mura bheil thu ag iarraidh ach gun tèid an t-inneal dìreach gu sgrìn an dì-chrioptachaidh, ruith _Suidheachadh > Bùtadh dìreach_ ann an clàr-taice Omarchy. Cuiridh sin ris innteart EFI a tha a' comharrachadh Omarchy gu dìreach, ach am bùt am firmware e gun stad aig Limine.

'S e an aon dìth a th' ann agus an tè air an tug sinn iomradh aig a' bhàrr: le bùtadh dìreach air, feumaidh tu Limine a thaghadh o chlàr-taice bùtaidh a' BIOS agad an toiseach airson faighinn gu dealbh-chlàir. Ruith _Suidheachadh > Bùtadh dìreach_ a-rithist gus an t-innteart a thoirt air falbh agus tilleadh gu bùtadh tro Limine. Cha chòrd innteartan EFI gnàthaichte ri cuid a firmware, mar sin diùltaidh an suidheachadh ruith air firmware American Megatrends agus Apple.
