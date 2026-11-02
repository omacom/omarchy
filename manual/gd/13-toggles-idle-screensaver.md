# Toglaichean, tàmh & an sàbhalaiche-sgrìn

Chan e roghainn a th' ann an mòran dhe na dh'atharraicheas tu o latha gu latha. 'S e modh a th' ann a chuireas tu air fad uair a thìde agus a chuireas tu dheth a-rithist: solas na h-oidhche nuair a bhios tu ag obair anmoch, na cuir dragh orm fhad 's a bhios tu a' taisbeanadh, fuirich nad dhùisg fhad 's a bhios tu a' coimhead air rudeigin. 'S e toglaichean a chanas Omarchy riutha sin, agus obraichidh iad uile san aon dòigh — iuchair-ghrad, nì sa chlàr-taice agus àithne, agus buailidh iad uile an aon suidse.

### Clàr-taice nan toglaichean

Fosglaidh `Super + Ctrl + O` _Cuir gu dol > Toglaichean_ gu dìreach, no 's urrainn dhut coiseachd ann o chlàr-taice Omarchy (`Super + Space`). 'S e suidse a th' anns a h-uile rud air an liosta sin as urrainn dhut a thoglachadh gun smaoineachadh mu càite a bheil an staid air a cumail. Tha na suidsichean a bhuineas ri coltas an deasga ri thaobh, fo _Coltas_.

On tèirmineal, 's e `omarchy toggle <thing>` a th' anns na h-aon suidsichean. Ruith `omarchy toggle` leis fhèin airson am buidheann gu lèir fhaicinn.

| Toglaiche | Iuchair-ghrad | Àithne |
| ------ | ------ | ------- |
| Solas na h-oidhche | — | `omarchy toggle nightlight` |
| Mùch na brathan | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Fuirich nad dhùisg (gun ghlasadh nuair a bhios e na thàmh) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Glacadh thuislidhean | — | `omarchy toggle crash-capture` |
| Sàbhalaiche-sgrìn | — | `omarchy toggle screensaver` |
| Sioncronachadh ùrlar [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Bàr a' chlàir-thaice | `Super + Shift + Space` | `omarchy toggle bar` |
| Pada-suathaidh | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Sgrìn-suathaidh | — | `omarchy toggle touchscreen` |
| Cuir na dhàil | — | `omarchy toggle suspend` |
| GPU hibrideach | — | `omarchy toggle hybrid gpu` |

Tha suidsichean a' phada-suathaidh, na sgrìn-suathaidh agus a' GPU hibridich fo _Cuir gu dol > Bathar-cruaidh_ (`Super + Ctrl + H`) seach fo Toglaichean, a chionn 's nach nochd iad ach nuair a bhios am bathar-cruaidh sin agad dha-rìribh. Mairidh an fheadhainn airson a' phada-suathaidh is na sgrìn-suathaidh nuair a nì thu ath-luchdadh air Hyprland — thèid ainm an uidheim a chaidh a chur à comas a shàbhaladh ann am faidhle staide beag a leughas Hyprland aig an toiseach airson a chur à comas a-rithist.

Tha bàr a' chlàir-thaice agus na beòthachaidhean fo _Coltas_, cuide ri rud no dhà nach e àitheantan `omarchy toggle` a th' annta ach a ghiùlaineas iad fhèin san aon dòigh: ceudad a' bhataraidh sa bhàr, co-dhealbhachd bhunaiteach nan rumannan-obrach, agus fo _Uinneagan_, beàrnan nan uinneagan (`Super + Shift + Backspace`) agus an co-mheas ceàrnagach airson aon uinneag (`Super + Ctrl + Backspace`).

Chan eil anns a' mhòr-chuid dhiubh ach faidhle brataich fo `~/.local/state/omarchy/toggles/`. Ma tha thu airson meur a ghabhail a-rèir fear dhiubh ann an sgriobt, bheir `omarchy-toggle-enabled` còd fàgail dhut seach a bhith a' toirt ort a dhol ga lorg:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Tha na brataichean air an ainmeachadh air an staid "dheth" — `screensaver-off`, `suspend-off`, `bar-off` — mar sin ma tha iad ann, tha an gleus à comas.

### Comharran sa bhàr

Nuair a bhios modh air, chì thu glif beag ann am meadhan a' bhàir gu h-àrd ri taobh an uaireadair. 'S e widget nan comharran a th' ann, agus giùlainidh e deachdadh, clàradh na sgrìn, cuimhneachain ri thighinn, solas na h-oidhche, na cuir dragh orm agus fuirich nad dhùisg.

Bidh comharran neo-ghnìomhach falaichte. Cuir an luchag os cionn àite sam bith air a' bhàr agus nochdaidh iad gu fann, ach an urrainn dhut briogadh air fear airson a chur air gun fhios a bhith agad air a iuchair-ghrad. Ma bhriogas tu air fear gnìomhach, thèid a chur dheth a-rithist. Nam b' fheàrr leat iad uile fhaicinn fad na h-ùine, suidhich `alwaysShow` gu `true` air an nì `omarchy.indicators` ann an `~/.config/omarchy/shell.json` — faic [am bàr gu h-àrd](05-the-top-bar.md) airson mar a thèid widgets a' bhàir a rèiteachadh.

### Solas na h-oidhche

Blàthaichidh solas na h-oidhche an sgrìn gu 4000K, agus ma thoglaicheas tu e a-rithist, thèid a thilleadh gu 6500K. Toglaich e o chlàr-taice nan toglaichean (`Super + Ctrl + O`) no le `omarchy toggle nightlight`. 'S e hyprsunset a dh'obraicheas e, agus tòisichidh an toglaiche e dhut mur eil e a' ruith mu thràth.

A thaobh bun-roghainn, cha dèan hyprsunset dad idir ris an sgrìn agad. Thig `~/.config/hypr/hyprsunset.conf` le pròifil aithne dìreach airson 's nach bean dad ris an sgrìn gus an iarr thu blàths. Nam b' fheàrr leat gun atharraich e a-rèir an uaireadair, cuir pròifil ùine na àite:

```
profile {
    time = 20:00
    temperature = 4000
}
```

An uairsin tòisich hyprsunset nuair a chlàraicheas tu a-steach le bhith a' cur `o.launch_on_start("hyprsunset")` ri `~/.config/hypr/autostart.lua`. Tha an dà luach 4000K/6500K a chleachdas an toglaiche suidhichte, mar sin 's e am faidhle rèiteachaidh an t-àite airson teòthachd eile.

### Na cuir dragh orm

Mùchaidh `Super + Ctrl + Alt + ,` na brathan. Cha nochd brath-pronnaidh sam bith fhad 's a bhios e air, agus bidh comharra a' chluig le crois air na shuidhe sa bhàr airson do chur na do chuimhne carson a tha an deasg air fàs sàmhach.

Ach cha tèid dad air chall. Thèid na brathan a chaidh a mhùchadh a chumail air ais: cuir an fheadhainn mu dheireadh air an sgrìn a-rithist le `Super + Shift + Alt + ,`. Faic [na brathan](10-notices.md) airson a' chòrr.

Gheibh dà sheòrsa teachdaireachd troimhe fhathast: brathan-pronnaidh dearbhaidh Omarchy fhèin airson rudeigin a rinn thu an-dràsta ("Chaidh an t-ùrlar atharrachadh", "Chaidh an glacadh-sgrìn a shàbhaladh"), agus rabhaidhean èiginneach a thèid a chur on loidhne-àithne. Cha bhuin aplacaidean cabadaich a chomharraicheas a h-uile rud mar èiginneach airson iad fhèin a phutadh air beulaibh do shùilean ris an fheadhainn sin.

### Tàmh

'S ann le slige Omarchy a tha giùlan an tàimh, agus tha na h-amannan ann am bloca `idle` aig a' bhàrr-ìre ann an `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

'S e diogan a th' anns an dà àireamh, air an cunntadh on mhionaid a chaidh thu na do thàmh — chan ann o chèile. Mar sin, leis na bun-roghainnean, nochdaidh an sàbhalaiche-sgrìn an ceann dà mhionaid gu leth agus gabhaidh an sgrìn-ghlasaidh thairis aig còig mionaidean, co-dhiù an do ruith an sàbhalaiche-sgrìn no nach do ruith. Sàbhail am faidhle agus togaidh an t-slige na h-amannan ùra sa bhad.

Ma chuireas tu an sàbhalaiche-sgrìn air falbh mus tig àm a' ghlasaidh, thèid sin a chunntadh mar ghnìomhachd agus thèid an glasadh ri thighinn a sgur. Cha tèid do ghlasadh a-mach dìreach air sgàth 's gun tug thu sùil air an inneal agad.

Airson stad a chur air glasadh nuair a bhios e na thàmh uile gu lèir, cuiridh `Super + Ctrl + I` — no `omarchy toggle idle` — fuirich nad dhùisg air, agus nochdaidh comharra a' chupa-chofaidh sa bhàr. 'S e sin am fear ri bhualadh ro thaisbeanadh fada no ro thogail a tha thu airson coimhead air. Buail e a-rithist airson tilleadh gu àbhaist. Clò-bhuailidh `omarchy toggle idle status` an staid làithreach mar JSON ma tha feum agad air ann an sgriobt.

Tha seo mu dhèidhinn glasadh agus an sàbhalaiche-sgrìn, chan ann mu chumhachd. Tha an suidheachadh fhèin aig cur na dhàil agus cadal-geamhraidh ann an [cadal an t-siostaim](36-system-sleep.md).

### An sàbhalaiche-sgrìn

'S e ealain ASCII a th' ann an sàbhalaiche-sgrìn Omarchy a' ruith tro èifeachdan teacsa air thuaiream, aon ionstans air gach monatair. Fàgaidh tu e le iuchair sam bith no le gluasad na luchaige.

'S urrainn dhut a thòiseachadh nuair a thogras tu o _Siostam > Sàbhalaiche-sgrìn_ (`Super + Esc`), agus sparraidh sin air nochdadh e fiù 's ma chuir thu sàbhalaiche-sgrìn an tàimh dheth. Chan eil iuchair-ghrad ceangailte ris a thaobh bun-roghainn.

'S e `omarchy toggle screensaver` a chuireas am fear a bhuineas ris an tàmh dheth, nam b' fheàrr leat a dhol dìreach o obair gu glasadh. Feumaidh e tèirmineal air a bheil fios aige mar a rèiticheas e e — Alacritty, Foot, Ghostty no Kitty — agus innsidh e sin dhut mas e rudeigin eile a th' anns an tèirmineal bhunaiteach agad.

'S ann agadsa a tha an suaicheantas a tharraingeas e airson atharrachadh, fo _Coltas > Branndadh > Sàbhalaiche-sgrìn_. Luchdaich suas png no svg agus iompaichidh Omarchy gu ASCII e. Faic [branndadh](41-branding.md).

### An sgrìn-ghlasaidh

Glasaidh `Super + Ctrl + L` an t-inneal. Ruithidh sin an sgrìn-ghlasaidh o shlige Omarchy, falamhaichidh e an sgrìn, ath-shuidhichidh e co-dhealbhachd a' mheur-chlàir agad air a' chiad tè ach nach bi thu a' sgrìobhadh an fhacail-fhaire agad san aibidil chearr, agus — ma tha e a' ruith agad — glasaidh e 1Password air an t-slighe a-mach.

Gabhaidh an sgrìn-ghlasaidh facal-faire, agus gabhaidh i lorg-meòir cuideachd nuair a bhios tu air fear a shuidheachadh. Tha sin, agus na dòighean eile air dearbhadh, air am mìneachadh ann an [dearbhadh le bathar-cruaidh](37-hardware-authentication.md).
