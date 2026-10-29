# Zana za Uendelezaji

## Vihariri Mbadala

Omarchy huja na [Neovim](https://neovim.io/) kwa chaguo-msingi, lakini kama ungependa kitu kilichozoeleka zaidi na kinachofahamika sana, unaweza kufungua Menyu ya Omarchy (`Super + Space`) na kuona chaguo zilizo chini ya _Install > Editor_. Tuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim, na Emacs vilivyoorodheshwa hapo. Kama huoni unachokitafuta, angalia _Install > Package_, na uone kama hakiko katika kifurushi cha Arch (na kama hakiko, jaribu _Install > AUR_ kuangalia AUR).

Kihariri asili cha `vi` pia kinapatikana mara moja. Endesha `vi filename` kuhariri faili kwenye terminal.

Ulinganishaji wa mandhari hutolewa kwa `VSCode`, `Cursor`, `VSCodium`, na `Helix`.

Unaweza kuweka kihariri chaguo-msingi cha mfumo mzima chini ya `Setup > Defaults > Editor`.

## Mazingira

Omarchy inasaidia kusanidi mazingira mengi sana ya uendelezaji kupitia sehemu ya _Install > Development_ ya Menyu ya Omarchy (`Super + Space`). Bila shaka utapata _Ruby on Rails_, lakini pia runtimes zote tatu kuu za JavaScript (Node.js, Bun, Deno), pamoja na frameworks maarufu za PHP kama Laravel na Symfony. Oh, na pia kuna Go, Rust, Python, Java, Elixir (pamoja na Phoenix), .NET, OCaml, Zig, Clojure, na Scala pia. Ni uteuzi mpana sana!

Nyingi ya mazingira haya husimamiwa na [Mise](https://mise.jdx.dev/). Ni zana inayokuwezesha kusakinisha na kuendesha matoleo mengi ya lugha ya programu kwenye mashine moja. Ni kama rbenv au rvm kwa Ruby au virtualenv kwa Python, lakini inafanya kazi kwa mazingira mengi tofauti.

Kusakinisha, kwa mfano, Ruby, ungeendesha `mise use -g ruby`, ambayo itasakinisha Ruby na pia kuiweka kama chaguo-msingi cha kimataifa. Au, kama mradi wako una faili ya .ruby-version, unaweza tu kuendesha `mise i` katika mzizi wa mradi huo.

## Zana za CLI zilizosakinishwa awali

Omarchy hufanya zana kama vile `gh`, `uv`, na [mawakala](17-ai.md) wengi wa kuandika msimbo zipatikane kupitia [usakinishaji wa mise wa kusakinisha inapohitajika tu](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Mara ya kwanza unapoendesha mojawapo, mise huisakinisha. Uendeshaji wa baadaye hutumia tena toleo lililosakinishwa; hauangalia sasisho katika kila uzinduzi.

Unaweza pia kukagua chaguo-msingi au kuzisakinisha kabla ya wakati:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Endesha `omarchy update` kusasisha zana zilizosakinishwa pamoja na Omarchy yote. Lakabu ya `mup` husasisha zana zinazosimamiwa na mise pekee. Kuongeza zana nyingine kwenye usanidi wako mwenyewe, tumia `mise use -g <tool>`.

Usanidi wa Python pia husakinisha `uv` kupitia mise. Kuondoa mazingira ya uendelezaji wa Python huacha `uv` ipatikane kama zana huru.

### Kutumia usakinishaji wako mwenyewe

Amri za mise huja kabla ya `~/.local/bin` kwenye `PATH`, kwa hiyo zana uliyojisakinishia mwenyewe, kwa mfano kwa kisakinishi cha Claude Code au cha Cursor chenyewe, bado huendesha nakala ya mise. Programu zinazozinduliwa kutoka kwenye eneo-kazi pia hupata amri za mise kabla ya vifurushi vya mfumo, kwa hiyo programu inayoendesha `gh` hupata nakala ya mise hata kama ulisakinisha `github-cli` kwa pacman, na mise husakinisha nakala hiyo mara ya kwanza. Kutumia yako badala yake, zima nakala ya mise katika `~/.config/mise/config.toml`. Kwa mfano, kama ulijisakinishia Cursor CLI mwenyewe:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kama tayari una jedwali la `[settings]`, ongeza ingizo hapo; panua orodha iliyopo ya `disable_tools` badala ya kuibadilisha. Hakikisha usakinishaji wako uko kwenye `PATH`. Tumia jina la zana la mise, ambalo linaweza kutofautiana na amri yake: `oh-my-pi` hutoa `omp`, kwa mfano. Kizindua-wakala chaguo-msingi pia hupendelea Cursor au Muse iliyosakinishwa na mtumiaji katika `~/.local/bin`.

### Kuondoa na kurejesha chaguo-msingi

_Remove Preinstalls_ hufanya mise iruke matamko ya zana za Omarchy kwa mtumiaji wako, kwa kuyaongeza kwenye `ignored_config_paths` katika `~/.config/mise/miserc.toml`. _Restore Preinstalls_ huondoa mstari huo tena. Zana unazotamka mwenyewe, katika usanidi wako mwenyewe au katika `mise.toml` ya mradi, huendelea kufanya kazi kwa njia yoyote. Kama unachagua wakala chaguo-msingi au kusanidi Python baada ya kuondoa zilizosakinishwa awali, zana hiyo huongezwa kwenye usanidi wako mwenyewe. Zote mbili hutumika kwa mtumiaji wako pekee; watumiaji wengine kwenye mashine huhifadhi chaguo lao wenyewe.

## Docker

[Docker](https://www.docker.com/) haihitaji utangulizi wowote. Inakuwezesha kuendesha kontena zilizotengwa, na Omarchy husakinisha kila kitu kinachohitajika kuiendesha vizuri, ikiwa ni pamoja na Docker yenyewe na [Docker Compose](https://docs.docker.com/compose/).

Kwa chaguo-msingi mtumiaji wako *hayuko* katika kikundi cha `docker`. Kikundi hicho kwa vitendo ni root isiyohitaji nenosiri — chochote kilicho ndani yake kinaweza `docker run -v /:/host` na kuchukua udhibiti wa mashine — kwa hiyo hati moja mbaya au tegemezi moja inayoendeshwa kama wewe vinginevyo ingekuwa amri moja tu kutoka kuwa root. Kwa hiyo kwenye mstari wa amri unaendesha Docker kwa `sudo` (`sudo docker ps`, `sudo docker compose up`), na zana za kigraphiki zinazozungumza na daemon — Windows VM — huomba idhini zinapoihitaji. Kama unataka urahisi wa usanidi usio na kikundi urudi na unaelewa mabadilishano yake, uwashe kutoka **Setup > Security > Sudoless Docker** (au endesha `omarchy-setup-security-sudoless-docker`), ambayo inakuongeza kwenye kikundi cha `docker` baada ya onyo; kisha `docker` ya kawaida na lakabu ya `d` hufanya kazi bila `sudo` tena.

Unaweza kusanidi hifadhidata za kawaida za uendelezaji wa ndani katika Docker kwa kutumia _Install > Development > Docker DB_ katika menyu ya Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) inapatikana kama `gh` kwa kufanya kazi na hazina, masuala, na pull requests kutoka kwenye terminal. Endesha `gh auth login` kuisakinisha unapoitumia mara ya kwanza na kujithibitisha, kisha `gh repo clone org/repo` kuiga hazina. Endesha `gh --help` kuchunguza amri zake.

Kwa kiolesura cha terminal cha pull requests, endesha `ghui`; mise huisakinisha pia unapoitumia mara ya kwanza. [Lazygit](https://github.com/jesseduffield/lazygit) imesakinishwa awali kwa kufanya kazi na Git yenyewe.
