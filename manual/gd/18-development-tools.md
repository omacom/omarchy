# Innealan leasachaidh

## Deasaichean eile

Thig Omarchy le [Neovim](https://neovim.io/) a thaobh bun-roghainn, ach nam b' fheàrr leat rudeigin a tha beagan nas prìomh-shruthaiche is nas eòlaiche, 's urrainn dhut clàr-taice Omarchy a ruith (`Super + Space`) agus sùil a thoirt air na roghainnean fo _Stàlaich > Deasaiche_. Tha VSCode, Cursor, Zed, Sublime Text, Helix, Vim agus Emacs air an liosta an sin. Mura lorg thu na tha thu a' sireadh, thoir sùil air _Stàlaich > Pacaid_, agus faic a bheil e ann am pacaid Arch (agus mur eil, feuch _Stàlaich > AUR_ airson sùil a thoirt air an AUR).

Tha an deasaiche `vi` tùsail ri fhaighinn às a' bhogsa cuideachd. Ruith `vi filename` airson faidhle a dheasachadh san tèirmineal.

Tha maidseadh ùrlair ri fhaighinn airson `VSCode`, `Cursor`, `VSCodium` agus `Helix`.

'S urrainn dhut an deasaiche bunaiteach airson an t-siostaim gu lèir a shuidheachadh fo `Suidheachadh > Bun-roghainnean > Deasaiche`.

## Àrainneachd

Cuiridh Omarchy taic ri suidheachadh pailteas àrainneachdan leasachaidh tro earrann _Stàlaich > Leasachadh_ de chlàr-taice Omarchy (`Super + Space`). Lorgaidh tu _Ruby on Rails_ ann, gun teagamh, ach cuideachd na trì prìomh àrainneachdan ruith airson JavaScript (Node.js, Bun, Deno), a bharrachd air frèamaichean PHP fèillmhor mar Laravel agus Symfony. Ò, agus tha Go, Rust, Python, Java, Elixir (le Phoenix), .NET, OCaml, Zig, Clojure agus Scala ann cuideachd. 'S e taghadh glè leathann a th' ann!

Tha a' mhòr-chuid dhe na h-àrainneachdan seo fo stiùireadh [Mise](https://mise.jdx.dev/). 'S e inneal a th' ann a leigeas leat iomadh tionndadh de chànan prògramachaidh a stàladh is a ruith air an aon inneal. Tha e coltach ri rbenv no rvm airson Ruby no virtualenv airson Python, ach obraichidh e airson dòrlach àrainneachdan eadar-dhealaichte.

Airson Ruby, can, a stàladh, ruitheadh tu `mise use -g ruby`, a stàlaicheas Ruby agus a shuidhicheas e mar a' bhun-roghainn uile-choitcheann. No, ma tha faidhle .ruby-version sa phròiseact agad, 's urrainn dhut dìreach `mise i` a ruith ann am bun a' phròiseict sin.

## Innealan CLI ro-stàlaichte

Bheir Omarchy innealan mar `gh`, `uv` agus a' mhòr-chuid de [dh'àidseantan còdaidh](17-ai.md) dhut tro [stàladh leisg mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). A' chiad turas a ruitheas tu fear, stàlaichidh mise e. Cleachdaidh ruith às dèidh sin an tionndadh stàlaichte; cha toir iad sùil airson ùrachadh gach turas a thèid an cur gu dol.

'S urrainn dhut sùil a thoirt air na bun-roghainnean no an stàladh ro làimh cuideachd:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Ruith `omarchy update` airson na h-innealan stàlaichte ùrachadh cuide ris a' chòrr de dh'Omarchy. Cha ùraich an t-alias `mup` ach na h-innealan fo stiùireadh mise. Airson inneal eile a chur ris an rèiteachadh agad fhèin, cleachd `mise use -g <tool>`.

Stàlaichidh suidheachadh Python `uv` tro mhise cuideachd. Ma bheir thu air falbh àrainneachd leasachaidh Python, bidh `uv` ri fhaighinn fhathast mar inneal neo-eisimeileach.

### A' cleachdadh an stàlaidh agad fhèin

Thig àitheantan mise ro `~/.local/bin` air `PATH`, mar sin ruithidh inneal a stàlaich thu fhèin, mar eisimpleir le stàlaichear Claude Code no Cursor fhèin, lethbhreac mise fhathast. Lorgaidh aplacaidean a thèid a chur gu dol on deasg àitheantan mise ro phacaidean an t-siostaim cuideachd, mar sin gheibh aplacaid a ruitheas `gh` lethbhreac mise fiù 's ma stàlaich thu `github-cli` le pacman, agus stàlaichidh mise an lethbhreac sin a' chiad turas. Airson an tè agad fhèin a chleachdadh na àite, cuir lethbhreac mise à comas ann an `~/.config/mise/config.toml`. Mar eisimpleir, ma stàlaich thu Cursor CLI thu fhèin:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ma tha clàr `[settings]` agad mu thràth, cuir an nì ris an sin; leudaich liosta `disable_tools` a tha ann seach a cur na h-àite. Dèan cinnteach gu bheil an stàladh agad air `PATH`. Cleachd ainm an inneil ann am mise, a dh'fhaodadh a bhith eadar-dhealaichte on àithne aige: bheir `oh-my-pi` seachad `omp`, mar eisimpleir. B' fheàrr le lòinsear an àidseint bhunaitich cuideachd Cursor no Muse a stàlaich an cleachdaiche ann an `~/.local/bin`.

### A' toirt air falbh is ag aiseag nam bun-roghainnean

Bheir _Thoir air falbh > Ro-stàlaidhean_ air mise leum thar foillseachaidhean innealan Omarchy airson a' chleachdaiche agad, le bhith gan cur ri `ignored_config_paths` ann an `~/.config/mise/miserc.toml`. Bheir _Stàlaich > Ro-stàlaidhean_ an loidhne sin air falbh a-rithist. Cumaidh na h-innealan a dh'fhoillsicheas tu fhèin, san rèiteachadh agad fhèin no ann am `mise.toml` pròiseict, ag obair co-dhiù. Ma thaghas tu àidseant bunaiteach no ma shuidhicheas tu Python às dèidh dhut na ro-stàlaidhean a thoirt air falbh, thèid an inneal sin a chur ris an rèiteachadh agad fhèin. Cha bhuin an dà chuid ach ris a' chleachdaiche agad; cumaidh cleachdaichean eile air an inneal an roghainn fhèin.

## Docker

Cha mhòr nach fheum [Docker](https://www.docker.com/) ro-ràdh sam bith. Leigidh e leat soithichean dealaichte a ruith, agus stàlaichidh Omarchy a h-uile rud a tha a dhìth airson a ruith gu math, a' gabhail a-steach Docker fhèin agus [Docker Compose](https://docs.docker.com/compose/).

A thaobh bun-roghainn, *chan eil* an cleachdaiche agad sa bhuidheann `docker`. Gu h-èifeachdach, 's e root gun fhacal-faire a th' anns a' bhuidheann sin — 's urrainn do rud sam bith a th' ann `docker run -v /:/host` a dhèanamh agus an t-inneal a ghabhail thairis — mar sin bhiodh aon sgriobt no eisimeileachd bhradach a' ruith mar thusa dìreach aon àithne air falbh o root. Mar sin air an loidhne-àithne, ruithidh tu Docker le `sudo` (`sudo docker ps`, `sudo docker compose up`), agus iarraidh na h-innealan grafaigeach a bhruidhneas ris an daemon — an VM Windows — cead nuair a bhios feum aca air. Ma tha thu ag iarraidh goireasachd suidheachaidh gun bhuidheann air ais agus ma thuigeas tu a' mhalairt, cuir an comas e o **Suidheachadh > Tèarainteachd > Docker gun sudo** (no ruith `omarchy-setup-security-sudoless-docker`), a chuireas sa bhuidheann `docker` thu às dèidh rabhaidh; an uairsin obraichidh `docker` lom agus an t-alias `d` gun `sudo` a-rithist.

'S urrainn dhut na stòran-dàta cumanta airson leasachadh ionadail a shuidheachadh ann an Docker le _Stàlaich > Leasachadh > Stòr-dàta Docker_ ann an clàr-taice Omarchy.

## GitHub CLI

Tha [GitHub CLI](https://cli.github.com/) ri fhaighinn mar `gh` airson obrachadh le ionadan-tasgaidh, duilgheadasan agus iarrtasan tarraing on tèirmineal. Ruith `gh auth login` airson a stàladh a' chiad turas a chleachdas tu e agus dearbhadh, an uairsin `gh repo clone org/repo` airson ionad-tasgaidh a chlonadh. Ruith `gh --help` airson na h-àitheantan aige a rannsachadh.

Airson eadar-aghaidh tèirmineil do dh'iarrtasan tarraing, ruith `ghui`; stàlaichidh mise e a' chiad turas a chleachdas tu e cuideachd. Tha [Lazygit](https://github.com/jesseduffield/lazygit) ro-stàlaichte airson obrachadh le Git fhèin.
