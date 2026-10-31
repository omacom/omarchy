# An t-ùrlar agad fhèin a dhèanamh

'S urrainn dhut na h-ùrlaran agad fhèin a chur ri `~/.config/omarchy/themes`. Dèan lethbhreac de dh'fhear dhen fheadhainn a tha ann mar bhunait (seall ann an `/usr/share/omarchy/themes`), agus gleus e gu do thoil. Fhad 's a bhios an t-ùrlar agad sa phasgan sin, bidh e ri fhaighinn ann an clàr-taice taghadh nan ùrlaran.

'S e `colors.toml` am prìomh fhaidhle a dh'fheumas tu a ghleusadh. Mìnichidh sin seata nan dathan a thèid a chleachdadh an uairsin gus rèiteachaidhean a ghintinn airson an tèirmineil (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, agus slige Omarchy gu lèir (am bàr gu h-àrd, an clàr-taice, na brathan, an OSD agus an sgrìn-ghlasaidh).

'S urrainn dhut cuideachd an aplacaid Aether a tha na lùib a chleachdadh gus ùrlar ùr a chruthachadh le eadar-aghaidh ghrafaigeach bhrèagha far an cluich thu le dathan is an lorg thu cùlaibh. Dìreach tòisich e o ghriod nan aplacaidean air `Super + Alt + Space`.

### Na tha ann an ùrlar stàlaichte

Faodaidh rud sam bith a bhith ann an ùrlar a sgrìobhas tu fhèin ann an `~/.config/omarchy/themes` — 's e an inneal agad fhèin is am faidhle agad fhèin a th' ann, is cuiridh Omarchy an sàs a h-uile càil dheth.

Cumaidh ùrlar a stàlaicheas tu o ionad-tasgaidh cuideigin eile le `omarchy theme install` gach rud a tha na dhath, agus caillidh e an dòrlach fhaidhlichean a ruitheadh còd air an inneal agad: faidhle `.lua` sam bith, rèiteachaidhean an tèirmineil (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), agus `vscode.json`. 'S e Lua a th' ann an `hyprland.lua` ùrlair a ruitheas an compositor agad aig àm clàradh a-steach, ainmichidh rèiteachadh tèirmineil am prògram a thòisicheas an tèirmineal agad, agus ainmichidh `vscode.json` leudachan VSCode ri stàladh. Bu chòir do dh'ùrlar cuideigin eile atharrachadh mar a choimheadas an deasg agad, ach chan ann dè a ruitheas e.

Obraichidh a h-uile càil eile fhathast dìreach mar a sgrìobh ùghdar an ùrlair e — thèid `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, na cùlaibh is na ro-sheallaidhean uile a chumail. Chan eil ach na chaidh a leigeil seachad air ath-ghintinn o `colors.toml` air an inneal agad.

Aithnichidh Omarchy an dà sheòrsa o chèile a rèir 's a bheil ionad-tasgaidh git aig an ùrlar na bhroinn fhèin, agus 's e sin na dh'fhàgas `omarchy theme install` às a dhèidh nuair a nì e clòn dheth. Mar sin, fanaidh ùrlar a sgrìobh thu fhèin leatsa, agus fanaidh fear a thug thu far an eadar-lìn na dhathan a-mhàin.

### Modh soilleir

Ma tha thu a' dèanamh ùrlar sa mhodh shoilleir, suidhich `mode = "light"` aig barr a' `colors.toml` agad. Thèid a chur an cois a' mhodh shoilleir anns na h-aplacaidean uile gu fèin-obrachail an uairsin. (Obraichidh an seann dòigh fhathast cuideachd, far an cuir thu faidhle falamh air a bheil `light.mode` ann am freumh an ùrlair agad.)

### Dathan nan ìomhaigheagan

Ma tha thu airson dathan ìomhaigheagan a' mhanaidseir fhaidhlichean a mhaidseadh ris an ùrlar agad, cuir ris faidhle air a bheil `icons.theme` le ainm seata nan ìomhaigheagan a tha thu airson cleachdadh. A thaobh bun-roghainn, seo na roghainnean: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Dealbh toirt a' ghlais dheth

Thèid ùrlaran a thig le dealbhan `unlock.png` agus `preview-unlock.png` a liostadh fo _Coltas > Thoir a' ghlas dheth_. B' fheàrr nam b' e png thrìd-shoilleir a bhiodh san `unlock.png` agad. Agus 's urrainn dhut dealbh an ro-sheallaidh a chruthachadh le `omarchy plymouth preview`.

### Ùrlaran airson aplacaidean nach eil Omarchy a' còmhdachadh

Ma chleachdas tu aplacaid nach eil air an liosta sin, 's urrainn dhut fhèin Omarchy a theagasg mar a chuireas e ùrlar oirre le teamplaid. Cuir faidhle ann an `~/.config/omarchy/themed/` air a bheil ainm an rèiteachaidh a ghinidh e agus leudachan `.tpl` ris, agus sgrìobh an rèiteachadh le `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` gu ruige `{{ color15 }}`, agus an còrr dhen phaileid mar ghlèidheadairean-àite. Gach turas a dh'atharraicheas tu an t-ùrlar, thèid am faidhle ath-ghintinn le dathan an ùrlair sin.

Tha `alacritty.toml.tpl.sample` sa phasgan sin le beachdan slàna ann as urrainn dhut lethbhreac a dhèanamh dheth — liostaichidh e gach caochladair as urrainn dhut cleachdadh, a bharrachd air na mion-atharraichearan `_strip` agus `_rgb` airson aplacaidean a tha ag iarraidh nan dathan aca gun `#` no mar RGB deicheach. Bidh prìomhachas aig na teamplaidean agad air an fheadhainn aig Omarchy fhèin, mar sin 's urrainn dhut seo a chleachdadh cuideachd gus mar a gheibh aplacaid thogte ùrlar a thar-àithneadh.

### An t-ùrlar agad a sgaoileadh

Ma tha thu airson an t-ùrlar agad a sgaoileadh ach an urrainn do chàch a chleachdadh, feumaidh tu a chur air frithealaiche git poblach, mar GitHub. An uairsin, 's urrainn do dhaoine a stàladh le _Stàlaich > Stoidhle > Ùrlar_ ann an clàr-taice Omarchy leis an URL sin. Mholamaid gun lean thu gnàths nan ainmean `omarchy-[themename]-theme`, oir nochdaidh an t-ùrlar gu ceart mar dìreach `[themename]` ann an clàr-taice taghadh nan ùrlaran an dèidh a stàladh.

Bidh an `[themename]` a tha air fhàgail na ainm air pasgan an ùrlair, mar sin feumaidh e a bhith na ainm as urrainn do dh'Omarchy a làimhseachadh gu sàbhailte: feumaidh e tòiseachadh le litir, àireamh no fo-loidhne, agus faodaidh litrichean, àireamhan, `.`, `_`, `+`, agus `-` a bhith sa chòrr dheth. Thèid litrichean mòra an dèanamh beag dhut, ach thèid rud sam bith eile — beàrn, comharra-labhairt, caractar nach eil sa Bheurla — a dhiùltadh aig àm an stàlaidh seach a thionndadh gu ainm pasgain. Mar sin, stàlaichidh `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, agus `omarchy-c++-theme` uile gun duilgheadas.

Cuimhnich, cho luath 's a bhios e air a stàladh o ionad-tasgaidh, gun tèid `.lua`, rèiteachadh tèirmineil no `vscode.json` sam bith a thig na lùib a leigeil seachad, mar sin na tog an t-ùrlar timcheall orra sin.

'S urrainn dhut an t-ùrlar agad a chur ri [duilleag nan ùrlaran a bharrachd](https://omarchy.org/themes/) le iarrtas tarraing a chur gu [ionad-tasgaidh omarchy-site](https://github.com/omacom-io/omarchy-site).
