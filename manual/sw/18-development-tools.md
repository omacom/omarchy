# Zana za Uendelezaji

## Wahariri Mbadala

Omarchy huja na Plain kama kihariri chaguo-msingi kwenye usakinishaji mpya na [Neovim](https://neovim.io/) iliyosakinishwa awali, lakini kama ungependa kitu kilichozoeleka zaidi na kinachojulikana sana, unaweza kufungua Menyu ya Omarchy (`Super + Space`) na kuona chaguo zilizo chini ya _Sakinisha > Kihariri_. Tuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim, na Emacs vilivyoorodheshwa hapo. Kama huoni unachokitafuta, angalia _Sakinisha > Kifurushi_, na uone kama hakiko kwenye kifurushi cha Arch (na kama hakiko, jaribu _Sakinisha > AUR_ kuangalia AUR).

Kihariri asilia cha `vi` pia kinapatikana moja kwa moja. Endesha `vi filename` kuhariri faili kwenye terminali.

Ulinganishaji wa mandhari hutolewa kwa `VSCode`, `Cursor`, `VSCodium`, na `Helix`.

Unaweza kuweka kihariri chaguo-msingi cha mfumo mzima chini ya `Setup > Defaults > Editor`.

## Mazingira

Omarchy inasaidia kuandaa mazingira mengi sana ya uendelezaji kupitia sehemu ya _Sakinisha > Uendelezaji_ ya Menyu ya Omarchy (`Super + Space`). Bila shaka utapata _Ruby on Rails_, lakini pia runtimes tatu kuu za JavaScript (Node.js, Bun, Deno), pamoja na frameworks maarufu za PHP kama Laravel na Symfony. Oh, na kuna Go, Rust, Python, Java, Elixir (pamoja na Phoenix), .NET, OCaml, Zig, Clojure, na Scala pia. Ni uteuzi mpana sana!

Mengi ya mazingira haya yanasimamiwa na [Mise](https://mise.jdx.dev/). Ni zana inayokuwezesha kusakinisha na kuendesha matoleo mengi ya lugha ya programu kwenye mashine moja. Ni kama rbenv au rvm kwa Ruby au virtualenv kwa Python, lakini inafanya kazi kwa mazingira mengi tofauti.

Kusakinisha, tuseme, Ruby, ungeendesha `mise use -g ruby`, ambayo itasakinisha Ruby na kuiweka kama chaguo-msingi cha kimataifa. Au, kama mradi wako una faili ya .ruby-version, unaweza tu kuendesha `mise i` kwenye mzizi wa mradi huo.

## Zana za CLI zilizosakinishwa awali

`uv`, Node.js, na `playwright-cli` (kwa maajenti kuendesha kivinjari, kwa kutumia Chrome iliyosakinishwa) huja vikiwa vimesakinishwa kama vifurushi, na `omarchy update` huviweka vya kisasa pamoja na mfumo mzima. `ghui`, [Hunk](https://github.com/modem-dev/hunk), na CLI za Basecamp, Cloudflare na HEY ziko umbali wa chaguo moja chini ya _Sakinisha > CLI_, na [maajenti wa kuandika msimbo](17-ai.md) chini ya _Sakinisha > AI > CLI_.

mise inasimamia tu runtimes unazoziandaa kutoka _Sakinisha > Uendelezaji_; Omarchy haisakinishi chochote kupitia hiyo yenyewe. Endesha `omarchy update` kuzisasisha pamoja na Omarchy yote; lakabu ya `mup` husasisha zana zinazosimamiwa na mise tu. Kuongeza zana nyingine kwenye usanidi wako mwenyewe, tumia `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) haihitaji utangulizi wowote. Inakuwezesha kuendesha kontena zilizotengwa, na Omarchy husakinisha kila kinachohitajika kuiendesha vizuri, ikiwa ni pamoja na Docker yenyewe na [Docker Compose](https://docs.docker.com/compose/).

Kwa chaguo-msingi mtumiaji wako *hayuko* kwenye kundi la `docker`. Kundi hilo kwa ufanisi ni root isiyo na nenosiri — chochote kilicho ndani yake kinaweza `docker run -v /:/host` na kuteka mashine — kwa hiyo script moja mbaya au tegemezi inayoendeshwa kama wewe ingekuwa amri moja tu kutoka kuwa root. Kwa hiyo kwenye mstari wa amri unaendesha Docker kwa `sudo` (`sudo docker ps`, `sudo docker compose up`), na zana za picha zinazozungumza na daemon — VM ya Windows — huomba idhini zinapoihitaji. Kama unataka urahisi wa usanidi usio na kundi urudi na unaelewa mabadilishano yake, uiwashe kutoka **Usanidi > Usalama > Docker Bila Sudo** (au endesha `omarchy-setup-security-sudoless-docker`), ambayo inakuongeza kwenye kundi la `docker` baada ya onyo; kisha `docker` tupu na lakabu ya `d` hufanya kazi bila `sudo` tena.

Unaweza kuandaa hifadhidata za kawaida kwa uendelezaji wa ndani kwenye Docker kwa kutumia _Sakinisha > Uendelezaji > Docker DB_ kwenye menyu ya Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ni `gh`, kwa kufanya kazi na hazina, issues, na pull requests kutoka kwenye terminali. _Usanidi > Git_ huisakinisha unapochagua kuingia kwenye GitHub hapo, kisha `gh repo clone org/repo` hupakua hazina. Endesha `gh --help` kuchunguza amri zake.

_Sakinisha > CLI > GitHub_ husakinisha GitHub CLI, `gh`, pamoja na `ghui`, kiolesura cha terminali cha pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) imesakinishwa awali kwa kufanya kazi na Git yenyewe.
