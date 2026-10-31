# Dotfiles

Thèid Omarchy a rèiteachadh sa mhòr-chuid leis na "dotfiles" ris an canar, a tha a' fuireach ann an `~/.config`. 'S ann leatsa a tha na faidhlichean sin, airson nan atharraichean agad fhèin. Buinidh na faidhlichean a tha ann an `/usr/share/omarchy` do dh'Omarchy fhèin, agus cha bu chòir dhut gnothach a ghabhail riutha idir. Ma tha thu airson rud sam bith atharrachadh ann an `/usr/share/omarchy`, sgrìobh thairis air an luach ann an `~/.config` na àite.

'S urrainn dhut na prìomh rèiteachaidhean a dheasachadh dìreach o chlàr-taice Omarchy (`Super + Space`), mar _Suidheachadh > Monatairean_, _Suidheachadh > Ceanglaichean iuchrach_, _Suidheachadh > Ion-chur_ agus _Suidheachadh > Rèiteachadh > [faidhle]_. Nuair a nì thu mar seo e, thèid pròiseas sam bith a dh'fheumas ath-thòiseachadh às dèidh do rèiteachadh atharrachadh ath-thòiseachadh gu fèin-obrachail nuair a dh'fhàgas tu an deasaiche (Neovim mar bhun-roghainn — `:wq`, cùm cuimhne! — ach 's urrainn dhut sin atharrachadh le _Suidheachadh > Bun-roghainnean > Deasaiche_).

Seo liosta nam prìomh fhaidhlichean ann an `~/.config` agus na tha iad a' stiùireadh:

| Faidhle                  | Adhbhar              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Prìomh rèiteachadh Hyprland. Luchdaichidh e bun-roghainnean Omarchy agus na faidhlichean thar-sgrìobhaidh agad gu h-ìosal. [Barrachd mu rèiteachaidhean Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Na ceanglaichean iuchrach agad fhèin agus na dh'atharraich thu sna bun-roghainnean. |
| `~/.config/hypr/monitors.lua` | Stiùirichidh e na monatairean agad, an dùmhlachd-bhreacaidh agus an ionad. |
| `~/.config/hypr/input.lua` | Stiùirichidh e co-dhealbhachd a' mheur-chlàir, an luchag agus roghainnean a' phada-suathaidh. |
| `~/.config/hypr/looknfeel.lua` | Stiùirichidh e na beàrnan, na h-iomallan, na beòthachaidhean agus a' chòrr dhen choltas. |
| `~/.config/hypr/autostart.lua` | Stiùirichidh e pròiseasan a bharrachd a thòisicheas leis an t-seisean. |
| `~/.config/omarchy/shell.json` | Stiùirichidh e slige Omarchy: ionad, co-dhealbhachd agus widgets a' bhàir, cho math ri amannan an t-sàbhalaiche-sgrìn, a' ghlasaidh agus na tàmh. |
| `~/.config/foot/foot.ini` | Stiùirichidh e an tèirmineal agad (is e foot am bun-roghainn). |
| `~/.XCompose` | Mìnichidh e na h-emoji luath agad agus fèin-choileanadh d' ainm is do phuist-d. Dèan cinnteach gun ruith thu `omarchy-restart-xcompose` às dèidh dhut atharrachadh. |

Ma nì thu tòrr atharraichean gus an suidheachadh agad a ghleusadh, 's math an smuain lethbhreac-glèidhidh a dhèanamh de na dotfiles seo uile. [Tha Stow math air a shon sin](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Na h-aplacaidean agad fhèin a thòiseachadh leis an t-seisean

Ma tha thu ag iarraidh gun ruith rudeigin gach turas a chlàraicheas tu a-steach — deamhan sioncronachaidh, aplacaid cabadaich, an sgriobt agad fhèin — cuir ann an `~/.config/hypr/autostart.lua` e:

```lua
o.launch_on_start("my-service")
```

Tòisichidh sin an àithne mar phàirt dhen t-seisean, ach am bi e air a sgioblachadh mar bu chòir nuair a chlàraicheas tu a-mach a-rithist.

### Sgriobtaichean a ruith air tachartasan an t-siostaim

Cuiridh Omarchy dubhain (hooks) gu dol aig dòrlach de dh'amannan, agus 's urrainn dhut na sgriobtaichean agad fhèin a chrochadh orra. Tha iad a' fuireach ann an `~/.config/omarchy/hooks/<event>.d/`, aon phasgan do gach tachartas, agus ruithidh gach faidhle so-ghnìomhaichte a tha ann nuair a thachras an tachartas:

| Tachartas | Cuin a ruitheas e |
| ----- | ------------ |
| `post-boot` | Dìreach às dèidh dhan deasg tòiseachadh |
| `post-update` | Faisg air deireadh `omarchy update`, às dèidh nam pacaidean, nan imrichean agus ath-thòiseachadh nan seirbheisean, mus tèid innealan mise ùrachadh |
| `pre-refresh-pacman` | Às dèidh do `omarchy refresh pacman` rèiteachadh nam pacaidean ath-shioncronachadh, mus ùraich e na pacaidean; ruithidh atharrachadh seanail e rè an aon cheum ath-nuadhachaidh sin |
| `theme-set` | Às dèidh atharrachadh ùrlair (ainm an ùrlair ann an `$1`) |
| `font-set` | Às dèidh atharrachadh cruth-clò (ainm a' chrutha-chlò ann an `$1`) |
| `battery-low` | Nuair a dh'fhàsas am bataraidh ìosal (an ceudad ann an `$1`) |

'S ann san dubhan `pre-refresh-pacman` a bhuineas ionadan-tasgaidh gnàthaichte no loidhnichean `IgnorePkg`, oir ruithidh e ro ghnothach nam pacaidean. Ruithidh an dà dhubhan co-cheangailte ri ùrachaidhean mar an cleachdaiche agad às dèidh do dh'Omarchy an t-ùghdarrachadh sudo san tasgadan aige fhalamhachadh, mar sin feumaidh dubhan a chleachdas `sudo` an t-ùghdarrachadh aige fhèin agus dh'fhaoidte gun iarr e d' fhacal-faire.

Tha faidhle `.sample` sna pasganan sin mu thràth a sheallas cruth dubhain — thoir `.sample` far an ainm gus a chur gu obair. Gus sgriobt a sgrìobh thu an àiteigin eile a stàladh, cleachd `omarchy hook install post-boot ~/my-hook`, a chuireas lethbhreac dheth ann agus a nì so-ghnìomhaichte e.

### Na nithean agad fhèin a chur ris a' chlàr-taice

'S urrainn dhut clàr-taice Omarchy (`Super + Space`) a leudachadh le na loidhnichean agad fhèin le bhith a' deasachadh `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Tha iuchair id le puingean aig gach nì, agus 's e an id a chuireas na àite e sa chraoibh, mar sin nochdaidh `personal` air a' phrìomh chlàr-taice agus nochdaidh `personal.notes` na bhroinn:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ma chleachdas tu id a tha ann mu thràth, sgrìobhaidh tu thairis air an loidhne sin an àite fear ùr a chur ris. Thig am faidhle leis a h-uile raon a tha ri fhaighinn, air am mìneachadh ann am beachdan.

### Na exports, na foincseanan agus na h-aliasan agad fhèin a chur ris an t-slige

Thig Omarchy le dòrlach de dh'aliasan goireasach agus foincseanan feumail, ach tha e glè chumanta gum bi thu airson feadhainn agad fhèin a chur ris. Bu chòir dhut aliasan, foincseanan agus exports a chur ris ann an `~/.bashrc`. Cha tèid sgrìobhadh thairis air an fhaidhle seo le ùrachaidhean. Ma tha thu airson gin de bhun-roghainnean Omarchy atharrachadh, 's urrainn dhut an cur ris an-seo gu sàbhailte cuideachd.

### Faidhlichean inntearnail Omarchy atharrachadh

Seall, 's e an coimpiutair agadsa a th' ann. 'S urrainn dhut rud sam bith a thogras tu a dhèanamh leis, ach chomhairlichinn dhut gun a bhith ag atharrachadh nam faidhlichean ann an `/usr/share/omarchy` gu dìreach. Buinidh iad do phacaid pacman Omarchy, mar sin thèid sgrìobhadh thairis air na h-atharraichean agad leis an ath ùrachadh. 'S fheàrr dhut sgrìobhadh thairis air luach bunaiteach sam bith nach toil leat ann am pasgan `~/.config/*` na àite.

'S urrainn dhut cha mhòr a h-uile càil atharrachadh mar sin, can na ceanglaichean iuchrach bunaiteach. Deasaich `~/.config/hypr/bindings.lua` gus, mar eisimpleir, [Joplin](https://joplinapp.org/) a chur an àite [Obsidian](https://obsidian.md/) (stàlaich e le `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

Bheir `o.rebind` air falbh an ceangal a tha ann mus cuir e am fear ùr ris. Gabhaidh e na h-aon argamaidean ri `o.bind`, a' gabhail a-steach taiceadairean tòiseachaidh agus roghainnean ceangail. Cleachd `o.bind` gus ceangal a chur ris, no `hl.unbind` gus fear a thoirt air falbh gun fhear eile a chur na àite.

Ma tha thu dìorrasach a bhith a' cladhach ann am faidhlichean inntearnail Omarchy, leum gun t-seanail dev le _Ùraich > Seanail > Dev_. Ceanglaidh sin Omarchy ri lethbhreac git de chòd tùsail ann an `~/omarchy`, agus faodaidh tu atharrachadh mar a thogras do chridhe. Chan eil duine an-seo gus innse dhut dè nì thu!

### Atharraichean sam bith ath-shuidheachadh

Ma nì thu brochan de na rèiteachaidhean, 's urrainn dhut an tilleadh gu na bun-roghainnean uair sam bith le _Ùraich > Rèiteachadh_ ann an clàr-taice Omarchy. No le bhith a' ruith `omarchy reinstall configs` gus a h-uile càil ath-shuidheachadh.
