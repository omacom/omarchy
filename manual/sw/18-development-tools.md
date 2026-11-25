# Zana za Uendelezaji

## Wahariri Mbadala

Omarchy huja na Plain kama kihariri chaguomsingi kwenye usakinishaji mpya na [Neovim](https://neovim.io/) kikiwa kimesakinishwa awali, lakini kama ungependa kitu kilichozoeleka zaidi na cha kawaida kidogo, unaweza kuendesha Omarchy Menu (`Super + Space`) na kuona chaguo zilizo chini ya _Install > Editor_. Tuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim, na Emacs vilivyoorodheshwa hapo. Kama huoni unachokitafuta, angalia _Install > Package_, na uone kama hakiko kwenye kifurushi cha Arch (na kama hakiko, jaribu _Install > AUR_ kuangalia AUR).

Kihariri asilia cha `vi` kinapatikana pia moja kwa moja. Endesha `vi filename` kuhariri faili kwenye terminal.

Ulinganishaji wa mandhari hutolewa kwa `VSCode`, `Cursor`, `VSCodium`, na `Helix`.

Unaweza kuweka kihariri chaguomsingi cha mfumo mzima chini ya `Setup > Defaults > Editor`.

## Mazingira

Omarchy inasaidia kuweka mazingira mengi sana ya uendelezaji kupitia sehemu ya _Install > Development_ ya Omarchy Menu (`Super + Space`). Bila shaka utapata _Ruby on Rails_, lakini pia mazingira yote matatu makuu ya utekelezaji wa JavaScript (Node.js, Bun, Deno), pamoja na mifumo maarufu ya PHP kama Laravel na Symfony. Ah, na kuna Go, Rust, Python, Java, Elixir (pamoja na Phoenix), .NET, OCaml, Zig, Clojure, na Scala pia. Ni uteuzi mpana sana!

Mengi kati ya mazingira haya yanasimamiwa na [Mise](https://mise.jdx.dev/). Ni zana inayokuwezesha kusakinisha na kuendesha matoleo mengi ya lugha ya programu kwenye mashine moja. Ni kama rbenv au rvm kwa Ruby au virtualenv kwa Python, lakini inafanya kazi kwa mazingira mengi tofauti.

Ili kusakinisha, tuseme, Ruby, ungeendesha `mise use -g ruby`, ambayo itasakinisha Ruby na kuiweka kama chaguomsingi ya jumla. Au, kama mradi wako una faili ya .ruby-version, unaweza kuendesha tu `mise i` kwenye mzizi wa mradi huo.

## Zana za CLI zilizosakinishwa awali

`uv`, Node.js, na `playwright-cli` (ili agents ziendeshe kivinjari, kwa kutumia Chrome iliyosakinishwa) huja vikiwa vimesakinishwa kama vifurushi, na `omarchy update` huviweka vya kisasa pamoja na mfumo mzima. [Hunk](https://github.com/modem-dev/hunk) na CLI za GitHub, Basecamp, Cloudflare na HEY ziko umbali wa chaguo moja chini ya _Install > CLI_, na [mawakala wa uandishi wa msimbo](17-ai.md) chini ya _Install > AI > CLI_.

mise husimamia tu mazingira ya utekelezaji unayoyaweka kutoka _Install > Development_; Omarchy yenyewe haisakinishi chochote kupitia hiyo. Endesha `omarchy update` kuzisasisha pamoja na Omarchy yote; lakabu `mup` husasisha zana zinazosimamiwa na mise tu. Kuongeza zana nyingine kwenye usanidi wako mwenyewe, tumia `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) haihitaji utambulisho wowote. Inakuwezesha kuendesha kontena zilizotenganishwa, na Omarchy husakinisha kila kinachohitajika kuiendesha vizuri, ikiwa ni pamoja na Docker yenyewe na [Docker Compose](https://docs.docker.com/compose/).

Kwa chaguomsingi mtumiaji wako *hayuko* kwenye kikundi cha `docker`. Kikundi hicho kwa vitendo ni root isiyohitaji nenosiri — chochote kilicho ndani yake kinaweza `docker run -v /:/host` na kuchukua udhibiti wa mashine — hivyo hati moja mbovu au tegemezi inayoendeshwa kama wewe vinginevyo ingekuwa amri moja tu kutoka kuwa root. Kwa hiyo kwenye mstari wa amri unaendesha Docker kwa `sudo` (`sudo docker ps`, `sudo docker compose up`), na zana za picha zinazowasiliana na daemon — Windows VM — huomba idhini zinapoihitaji. Kama unataka kurejesha urahisi wa usanidi usio na kikundi na unaelewa mabadilishano yake, uiwashe kutoka **Setup > Security > Sudoless Docker** (au endesha `omarchy-setup-security-sudoless-docker`), ambayo inakuongeza kwenye kikundi cha `docker` baada ya onyo; kisha `docker` ya kawaida na lakabu `d` hufanya kazi bila `sudo` tena.

Unaweza kuweka hifadhidata za kawaida za uendelezaji wa ndani kwenye Docker kwa kutumia _Install > Development > Docker DB_ kwenye menyu ya Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ni `gh`, kwa kufanya kazi na hazina, issues, na pull requests kutoka kwenye terminal. _Setup > Git_ huisanikisha unapochagua kuingia GitHub hapo, au isakinishe yenyewe kutoka _Install > CLI > GitHub_. Kisha `gh repo clone org/repo` hunakili hazina; endesha `gh --help` kuchunguza amri zake.

[Lazygit](https://github.com/jesseduffield/lazygit) imesakinishwa awali kwa kufanya kazi na Git yenyewe.
