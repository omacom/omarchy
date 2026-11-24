# Zana za Ukuzaji

## Vihariri Mbadala

Omarchy huja na Plain kama kihariri chaguo-msingi kwenye usakinishaji mpya na [Neovim](https://neovim.io/) kimesakinishwa awali, lakini kama ungependa kitu cha kawaida na kilichozoeleka zaidi, unaweza kuendesha Menyu ya Omarchy (`Super + Space`) na kuona chaguo chini ya _Install > Editor_. Tuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim, na Emacs vilivyoorodheshwa hapo. Kama huoni unachokitafuta, angalia _Install > Package_, na uone kama hakiko katika kifurushi cha Arch (na kama hakiko, jaribu _Install > AUR_ kuangalia AUR).

Kihariri asilia cha `vi` pia kinapatikana moja kwa moja. Endesha `vi filename` kuhariri faili kwenye terminali.

Ulinganishaji wa mandhari unatolewa kwa `VSCode`, `Cursor`, `VSCodium`, na `Helix`.

Unaweza kuweka kihariri chaguo-msingi cha mfumo mzima chini ya `Setup > Defaults > Editor`.

## Mazingira

Omarchy inasaidia kuweka mazingira mengi kabisa ya ukuzaji kupitia sehemu ya _Install > Development_ ya Menyu ya Omarchy (`Super + Space`). Bila shaka utapata _Ruby on Rails_, lakini pia runtimes tatu kuu za JavaScript (Node.js, Bun, Deno), pamoja na mifumo maarufu ya PHP kama Laravel na Symfony. Naam, na pia kuna Go, Rust, Python, Java, Elixir (pamoja na Phoenix), .NET, OCaml, Zig, Clojure, na Scala pia. Ni uteuzi mpana sana!

Nyingi ya mazingira haya husimamiwa na [Mise](https://mise.jdx.dev/). Ni zana inayokuwezesha kusakinisha na kuendesha matoleo mengi ya lugha ya programu kwenye mashine moja. Ni kama rbenv au rvm kwa Ruby au virtualenv kwa Python, lakini inafanya kazi kwa mazingira mengi tofauti.

Kusakinisha, kwa mfano, Ruby, ungeendesha `mise use -g ruby`, ambayo itasakinisha Ruby na kuiweka kama chaguo-msingi cha kimataifa. Au, kama mradi wako una faili ya .ruby-version, unaweza tu kuendesha `mise i` katika mzizi wa mradi huo.

## Zana za CLI Zilizosakinishwa Awali

Omarchy hufanya zana kama `gh`, `uv`, na [maajenti wengi wa kuandika msimbo](17-ai.md) zipatikane kupitia [usakinishaji wa uvivu wa mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Mara ya kwanza unapoendesha moja, mise huisakinisha. Kisha maajenti wa kuandika msimbo huangalia sasisho kabla ya kuendeshwa, mara moja tu kila baada ya saa nne; zana nyingine, kama `gh` na `uv`, hutumia tena toleo lililosakinishwa hadi utakaposasisha.

Unaweza pia kukagua chaguo-msingi au kuzisakinisha mapema:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Endesha `omarchy update` kusasisha zana zilizosakinishwa pamoja na Omarchy yote. Jina mbadala la `mup` husasisha zana zinazosimamiwa na mise pekee. Kuongeza zana nyingine kwenye usanidi wako mwenyewe, tumia `mise use -g <tool>`.

Usanidi wa Python pia husakinisha `uv` kupitia mise. Kuondoa mazingira ya ukuzaji ya Python huacha `uv` ipatikane kama zana huru.

### Kutumia usakinishaji wako mwenyewe

Amri za mise huja kabla ya `~/.local/bin` kwenye `PATH`, kwa hivyo zana uliyosakinisha mwenyewe, kwa mfano kwa kisakinishi cha Claude Code au Cursor, bado itaendesha nakala ya mise. Programu zinazozinduliwa kutoka kwenye eneo-kazi pia hupata amri za mise kabla ya vifurushi vya mfumo, kwa hivyo programu inayoendesha `gh` hupata nakala ya mise hata kama ulisakinisha `github-cli` kwa pacman, na mise husakinisha nakala hiyo mara ya kwanza. Ili kutumia yako badala yake, zima nakala ya mise katika `~/.config/mise/config.toml`. Kwa mfano, kama ulisakinisha Cursor CLI mwenyewe:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kama tayari una jedwali la `[settings]`, ongeza kipengele hapo; panua orodha iliyopo ya `disable_tools` badala ya kuibadilisha. Hakikisha usakinishaji wako uko kwenye `PATH`. Tumia jina la zana la mise, ambalo linaweza kutofautiana na amri yake: `oh-my-pi` hutoa `omp`, kwa mfano. Kizinduzi cha ajenti chaguo-msingi pia hupendelea Cursor au Muse iliyosakinishwa na mtumiaji katika `~/.local/bin`.

### Kuondoa na kurejesha chaguo-msingi

_Remove > Preinstalls_ huondoa programu za wavuti, TUI na programu zilizosakinishwa awali za Omarchy, na hufanya mise iruke matamko ya zana za Omarchy kwa mtumiaji wako, kwa kuyaongeza kwenye `ignored_config_paths` katika `~/.config/mise/miserc.toml`. _Install > Preinstalls_ huzirejesha na kuondoa mstari huo tena. Zana unazotangaza mwenyewe, katika usanidi wako mwenyewe au katika `mise.toml` ya mradi, huendelea kufanya kazi kwa vyovyote vile. Kama utachagua ajenti chaguo-msingi au kuweka Python baada ya kuondoa vilivyosakinishwa awali, zana hiyo huongezwa kwenye usanidi wako mwenyewe. Mpangilio wa mise hutumika kwa mtumiaji wako pekee, na watumiaji wengine huhifadhi chaguo lao mwenyewe; hata hivyo programu hizo ni vifurushi, kwa hivyo kuziondoa au kuzirejesha hubadilisha kwa kila mtu kwenye mashine.

## Docker

[Docker](https://www.docker.com/) haihitaji utangulizi wowote. Inakuwezesha kuendesha kontena zilizotengwa, na Omarchy husakinisha kila kinachohitajika kuiendesha vizuri, ikiwa ni pamoja na Docker yenyewe na [Docker Compose](https://docs.docker.com/compose/).

Chaguo-msingi mtumiaji wako *hayuko* katika kikundi cha `docker`. Kikundi hicho ni sawa na root bila nenosiri — chochote kilicho ndani yake kinaweza `docker run -v /:/host` na kuteka mashine — kwa hivyo skripti moja mbovu au tegemezi inayoendeshwa kama wewe ingekuwa amri moja tu kutoka kwa root. Kwa hivyo kwenye mstari wa amri unaendesha Docker kwa `sudo` (`sudo docker ps`, `sudo docker compose up`), na zana za michoro zinazozungumza na daemon — VM ya Windows — huomba idhini zinapoihitaji. Kama unataka urahisi wa usanidi usio na kikundi tena na unaelewa mabadilishano hayo, uiwashe kutoka **Setup > Security > Sudoless Docker** (au endesha `omarchy-setup-security-sudoless-docker`), ambayo inakuongeza kwenye kikundi cha `docker` baada ya onyo; kisha `docker` ya kawaida na jina mbadala la `d` hufanya kazi bila `sudo` tena.

Unaweza kuweka hifadhidata za kawaida kwa ukuzaji wa ndani katika Docker kwa kutumia _Install > Development > Docker DB_ katika menyu ya Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) inapatikana kama `gh` kwa kufanya kazi na hazina, masuala, na pull requests kutoka kwenye terminali. Endesha `gh auth login` kuisakinisha unapotumia mara ya kwanza na kujithibitisha, kisha `gh repo clone org/repo` kunakili hazina. Endesha `gh --help` kuchunguza amri zake.

Kwa kiolesura cha terminali cha pull requests, endesha `ghui`; mise huisakinisha pia unapotumia mara ya kwanza. [Lazygit](https://github.com/jesseduffield/lazygit) imesakinishwa awali kwa kufanya kazi na Git yenyewe.
