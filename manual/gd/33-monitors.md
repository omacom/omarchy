# Monatairean

Gabhaidh Omarchy ris mar bhun-roghainn gu bheil thu a' ruith air uidheam-taisbeanaidh retina a làimhsicheas sgèileadh 2x. Seo na tha a dhìth ort airson nan cruthan-clò prògramaidh snasail, geura sin. 'S ann air a shon seo a tha cha mhòr a h-uile laptop ùr àrd-ìre le sgrìn àrd-dhùmhlachd air a ghleusadh. 'S e seo na bhiodh tu airson a ruith air 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) no 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ach mura bheil thu a' ruith uidheam-taisbeanaidh le PPI de 218 no barrachd, bidh thu airson roghainnean a' mhonatair atharrachadh. Mar eisimpleir, ma tha 4K 27" no 32" agad, 's urrainn dhut sgèileadh bloigheach a chleachdadh le bhith a' fosgladh `~/.config/hypr/monitors.lua` (le _Suidheachadh > Monatairean_ ann an clàr-taice Omarchy) agus a' leum gun mholadh airson a' mheasgachaidh sin:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ma tha thu a' cleachdadh uidheam-taisbeanaidh 1080p no 1440p, 's dòcha nach bi thu ag iarraidh ach sgèileadh 1x, mar sin cleachd:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Bidh atharraichean air `GDK_SCALE` an sàs do dh'aplacaidean a thòisicheas às dèidh an atharrachaidh (agus cha ghabh GTK ach ri àireamhan slàna, mar sin cùm e aig an àireamh shlàn as fhaisge air sgèileadh a' mhonatair agad). Mar sin dèan cinnteach gun dùin thu na h-uinneagan agad a tha ro mhòr às dèidh an atharrachaidh (no dùin a h-uile uinneag le `Ctrl + Alt + Del`!).

'S urrainn dhut cuideachd a dhol tro na prìomh cho-mheasan sgèilidh (1x, 1.25x, 1.6x, 2x, 3x, 4x) gu luath le `Super + /` gus a dhol nas àirde agus `Super + Alt + /` gus a dhol nas ìsle. Ma tha an rèiteachadh bunaiteach agad, mairidh na h-atharraichean seo às dèidh ath-thòiseachadh cuideachd.

### Teacsa a dhèanamh nas motha no nas lugha

Atharraichidh sgèileadh a' mhonatair meud a h-uile càil. Mas e _teacsa_ nas motha no nas lugha a tha a dhìth ort a-mhàin, tha aon phutan agad air a shon:

```
omarchy display text size 14
```

Gabhaidh sin meud ann am piogsailean eadar 9 agus 20, agus gluaisidh e slige Omarchy, aplacaidean GTK agus an tèirmineal agad còmhla, ach am fan an deasg air fad co-rèireach. Ruith e gun argamaid gus faicinn far a bheil thu, agus `omarchy display text size reset` gus tilleadh dhan bhun-roghainn. 'S e Foot an aon fhear a tha air dheireadh: chan eil dòigh aige an rèiteachadh aige ath-luchdadh, mar sin cumaidh tèirmineil a tha a' ruith am meud a bh' aca gus am fosgail thu fear ùr.

### Sgrìnichean laptop a leudachadh agus a sgàthanachadh

Nuair a cheanglas tu sgrìn on taobh a-muigh ris an laptop agad, thèid an t-uidheam-taisbeanaidh a leudachadh gu fèin-obrachail. Ach 's urrainn dhut sin atharrachadh gu sgàthanachadh le _Cuir gu dol > Bathar-cruaidh_ ann an clàr-taice Omarchy no le `Super + Ctrl + Alt + Delete`. Tha seo gu sònraichte feumail mas e proiseactar a th' anns an sgrìn on taobh a-muigh agus ma tha thu airson rudeigin a shealltainn fhad 's a bhios tu ag obair.

Nuair a bhios tu a' leudachadh, ma dhùineas tu mullach an laptop, thèid an sgrìn inntearnail a chur dheth gu fèin-obrachail. Ma dh'fhosglas tu am mullach, thèid a cur air a-rithist. 'S urrainn dhut seo a stiùireadh le làimh cuideachd le _Cuir gu dol > Bathar-cruaidh_ ann an clàr-taice Omarchy no le `Super + Ctrl + Delete`.

### Iomadh sgrìn a chur an òrdugh

Obraichidh Hyprland gu math le iomadh sgrìn. Leugh barrachd mu mar a chuireas tu an òrdugh iad ann [an docamaideadh mu mhonatairean aig Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Ann an Omarchy, thèid iad seo ann an `~/.config/hypr/monitors.lua` mar nithean `hl.monitor` — thig am faidhle le eisimpleirean ann am beachdan airson monatair sònraichte a cheangal ri dùmhlachd-bhreacaidh, ionad agus cuairteachadh.

Tha rumannan-obrach 1 gu 10 aig gach monatair dha fhèin, mar sin ciallaichidh `Super + 1` a' chiad rùm-obrach air a' mhonatair air a bheil thu an-còmhnaidh. Air cùl na seallaidh, àireamhaichidh Hyprland na rumannan-obrach thar nam monatairean uile fhathast: gheibh sgrìn an laptop agad (no a' chiad mhonatair) 1–10, an ath mhonatair 11–20, is mar sin air adhart, agus cumaidh gach monatair am bloca aige gach turas a cheanglas tu a-steach e. Cleachd na h-àireamhan sin ma sgrìobhas tu [riaghailtean rumannan-obrach](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) no riaghailtean uinneagan airson monatair sònraichte, mar sin 's e rùm-obrach 12 an dàrna rùm-obrach air an dàrna monatair agad. Seallaidh `~/.local/state/omarchy/monitor-workspaces` dè am bloca a th' aig gach monatair.

Obraichidh na h-iuchraichean-saighde thar monatairean a tha a' co-roinneadh oir sa cho-dhealbhachd agad. Chan eil sgrìnichean nach suath ri chèile ach aig oisean, no aig a bheil beàrn eatarra, nan nàbaidhean, mar sin cleachd `Ctrl + Alt + Tab` gus a dhol eatarra.

| Iuchair ghoirid | Thar mhonatairean |
| --- | --- |
| `Super + Arrow` | Gluaisidh e am fòcas dhan mhonatair air an taobh sin nuair nach eil uinneag air fhàgail san taobh sin |
| `Super + Shift + Arrow` | Malairtidh e àite ri uinneag air a' mhonatair air an taobh sin |
| `Super + Alt + Arrow` | Gluaisidh e an uinneag gu buidheann air a' mhonatair air an taobh sin |
| `Super + Shift + Ctrl + Arrow` | Gluaisidh e an uinneag dhan mhonatair air an taobh sin, dhan rùm-obrach a tha e a' sealltainn |
| `Super + Shift + Alt + Arrow` | Gluaisidh e an rùm-obrach dhan mhonatair air an taobh sin, a' cumail na h-àireimh aige ma tha i saor |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Gluaisidh e am fòcas dhan ath mhonatair no dhan fhear roimhe, ge b' e dè a' cho-dhealbhachd |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Fanaidh iad air a' mhonatair air a bheil thu |

'S urrainn dhut sùil a thoirt air [Hyprmon](https://github.com/erans/hyprmon/) cuideachd, ma tha thu ag iarraidh TUI gus do chuideachadh le ionad iomadh sgrìn.

### An t-soilleireachd a stiùireadh

Thèid soilleireachd a' mhonatair a stiùireadh leis na h-iuchraichean foincsein sònraichte airson soilleireachd suas/sìos. Ma chumas tu sìos Shift fhad 's a bhrùthas tu iad, thèid thu chun na soilleireachd as motha no as lugha. Stiùirichidh na h-iuchraichean an t-uidheam-taisbeanaidh air a bheil am fòcas agad, mar sin thèid monatairean on taobh a-muigh a bhruidhneas DDC/CI a ghleusadh san aon dòigh ri sgrìn an laptop.

### Uidheaman-taisbeanaidh Apple

Ma tha thu a' cleachdadh uidheam-taisbeanaidh Apple, obraichidh iuchraichean soilleireachd àbhaisteach a' mheur-chlàir gu fèin-obrachail cuideachd, ma tha am fòcas agad air an uidheam-taisbeanaidh Apple. Nìthear seo leis an àithne `asdcontrol`.

Thoir an aire, ma tha thu a' cleachdadh uidheam-taisbeanaidh Apple 6K XDR, gum faic thu sgrìn thaibhseil air liosta `hyprctl monitors` agad 's dòcha. 'S urrainn dhut seo a chur dheth le rudeigin mar `hl.monitor({ output = "DP-2", disabled = true })` le _Suidheachadh > Monatairean_.

Air innealan Intel, bu chòir dhut ceangal ri uidheaman-taisbeanaidh Apple le càball Thunderbolt àbhaisteach. Air innealan eile às aonais Thunderbolt, mar as trice feumaidh tu [càball DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) a chleachdadh gus toirt air obrachadh.
