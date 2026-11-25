# Vývojárske nástroje

## Alternatívne editory

Omarchy sa dodáva s Plain ako predvoleným editorom v nových inštaláciách a s predinštalovaným [Neovim](https://neovim.io/), ale ak by ste chceli niečo o niečo bežnejšie a známejšie, môžete spustiť Omarchy Menu (`Super + Space`) a pozrieť si možnosti v časti _Install > Editor_. Nájdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Ak nenájdete to, čo hľadáte, pozrite sa do _Install > Package_ a skontrolujte, či to nie je v niektorom balíčku Arch (a ak nie, skúste _Install > AUR_ a skontrolujte AUR).

Pôvodný editor `vi` je tiež k dispozícii hneď po inštalácii. Súbor v termináli upravíte spustením `vi filename`.

Zosúladenie tém sa ponúka pre `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Celosystémový predvolený editor môžete nastaviť v časti `Setup > Defaults > Editor`.

## Prostredie

Omarchy podporuje nastavenie celého radu vývojových prostredí prostredníctvom časti _Install > Development_ v Omarchy Menu (`Super + Space`). Samozrejme tam nájdete _Ruby on Rails_, ale aj všetky tri hlavné behové prostredia pre JavaScript (Node.js, Bun, Deno), ako aj populárne PHP frameworky ako Laravel a Symfony. A je tam aj Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to naozaj široký výber!

Väčšinu týchto prostredí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, ktorý vám umožňuje nainštalovať a spúšťať viacero verzií programovacieho jazyka na tom istom počítači. Je to ako rbenv alebo rvm pre Ruby alebo virtualenv pre Python, ale funguje pre množstvo rôznych prostredí.

Ak chcete nainštalovať napríklad Ruby, spustíte `mise use -g ruby`, čím sa Ruby zároveň nainštaluje aj nastaví ako globálne predvolené. Alebo ak má váš projekt súbor .ruby-version, môžete jednoducho spustiť `mise i` v koreňovom adresári tohto projektu.

## Predinštalované CLI nástroje

`uv`, Node.js a `playwright-cli` (aby agenti mohli ovládať prehliadač pomocou nainštalovaného Chrome) sú nainštalované ako balíčky a `omarchy update` ich udržiava aktuálne spolu so zvyškom systému. `ghui`, [Hunk](https://github.com/modem-dev/hunk) a CLI pre Basecamp, Cloudflare a HEY sú na výber v časti _Install > CLI_ a [kódovací agenti](17-ai.md) v časti _Install > AI > CLI_.

mise spravuje len behové prostredia, ktoré si nastavíte v časti _Install > Development_; Omarchy prostredníctvom neho sám nič neinštaluje. Spustením `omarchy update` ich aktualizujete spolu so zvyškom Omarchy; alias `mup` aktualizuje len nástroje spravované cez mise. Ak chcete do vlastnej konfigurácie pridať ďalší nástroj, použite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) takmer nepotrebuje žiadne predstavenie. Umožňuje vám spúšťať izolované kontajnery a Omarchy nainštaluje všetko potrebné na jeho dobré fungovanie vrátane samotného Dockera a [Docker Compose](https://docs.docker.com/compose/).

Váš používateľ predvolene *nie je* v skupine `docker`. Táto skupina je v podstate root bez hesla — čokoľvek v nej môže spustiť `docker run -v /:/host` a prevziať kontrolu nad počítačom — takže jeden škodlivý skript alebo závislosť spustená pod vaším používateľom by inak bola len jeden príkaz od roota. Na príkazovom riadku preto Docker spúšťate pomocou `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, ktoré komunikujú s démonom — Windows VM — si vyžiadajú autorizáciu, keď ju potrebujú. Ak chcete späť pohodlie nastavenia bez skupiny a rozumiete tomuto kompromisu, zapnite ho v časti **Setup > Security > Sudoless Docker** (alebo spustite `omarchy-setup-security-sudoless-docker`), čo vás po varovaní pridá do skupiny `docker`; potom bude obyčajné `docker` a alias `d` opäť fungovať bez `sudo`.

Bežné databázy pre lokálny vývoj v Dockeri si môžete nastaviť pomocou _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh` na prácu s repozitármi, issues a pull requestmi z terminála. _Setup > Git_ ho nainštaluje, keď sa tam rozhodnete prihlásiť do GitHubu, a potom príkaz `gh repo clone org/repo` naklonuje repozitár. Jeho príkazy preskúmate spustením `gh --help`.

_Install > CLI > GitHub_ nainštaluje GitHub CLI, `gh`, spolu s `ghui`, terminálovým rozhraním pre pull requesty. [Lazygit](https://github.com/jesseduffield/lazygit) je predinštalovaný na prácu so samotným Gitom.
