# Vývojárske nástroje

## Alternatívne editory

Omarchy sa štandardne dodáva s editorom [Neovim](https://neovim.io/), ale ak chcete niečo bežnejšie a známejšie, môžete spustiť Omarchy Menu (`Super + Space`) a pozrieť si možnosti v časti _Install > Editor_. Nájdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Ak nenájdete to, čo hľadáte, pozrite si _Install > Package_ a skontrolujte, či sa to nenachádza v niektorom balíku Archu (a ak nie, skúste _Install > AUR_ a skontrolujte AUR).

Pôvodný editor `vi` je tiež dostupný hneď po inštalácii. Spustením `vi filename` upravíte súbor v termináli.

Zosúladenie tém je ponúkané pre `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Predvolený editor pre celý systém môžete nastaviť v časti `Setup > Defaults > Editor`.

## Prostredie

Omarchy podporuje nastavenie celej škály vývojárskych prostredí prostredníctvom časti _Install > Development_ v Omarchy Menu (`Super + Space`). Samozrejme tam nájdete _Ruby on Rails_, ale aj všetky tri hlavné runtimy pre JavaScript (Node.js, Bun, Deno), ako aj populárne PHP frameworky ako Laravel a Symfony. Aha, a je tam aj Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to veľmi široký výber!

Väčšinu týchto prostredí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, ktorý vám umožňuje nainštalovať a spúšťať viacero verzií programovacieho jazyka na tom istom počítači. Je to ako rbenv alebo rvm pre Ruby alebo virtualenv pre Python, ale funguje pre množstvo rôznych prostredí.

Ak chcete nainštalovať napríklad Ruby, spustili by ste `mise use -g ruby`, čím sa Ruby nainštaluje a zároveň nastaví ako globálna predvolená verzia. Alebo, ak má váš projekt súbor .ruby-version, môžete jednoducho spustiť `mise i` v koreňovom adresári daného projektu.

## Predinštalované nástroje CLI

Omarchy sprístupňuje nástroje ako `gh`, `uv` a väčšinu [kódovacích agentov](17-ai.md) prostredníctvom [lenivej inštalácie mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pri prvom spustení niektorého z nich ho mise nainštaluje. Pri neskorších spusteniach sa použije nainštalovaná verzia; pri každom spustení sa nekontroluje aktualizácia.

Môžete si tiež pozrieť predvolené nastavenia alebo ich nainštalovať vopred:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Spustením `omarchy update` aktualizujete nainštalované nástroje spolu so zvyškom Omarchy. Alias `mup` aktualizuje iba nástroje spravované cez mise. Ak chcete do vlastnej konfigurácie pridať ďalší nástroj, použite `mise use -g <tool>`.

Nastavenie Pythonu tiež nainštaluje `uv` prostredníctvom mise. Odstránením vývojárskeho prostredia Pythonu zostane `uv` dostupný ako nezávislý nástroj.

### Použitie vlastnej inštalácie

Príkazy mise sú v `PATH` pred `~/.local/bin`, takže nástroj, ktorý ste si nainštalovali sami, napríklad vlastným inštalátorom Claude Code alebo Cursor, stále spúšťa kópiu od mise. Aplikácie spustené z pracovnej plochy tiež nájdu príkazy mise skôr ako systémové balíky, takže aplikácia, ktorá spúšťa `gh`, dostane kópiu od mise, aj keď ste si `github-cli` nainštalovali pomocou pacman, a mise túto kópiu pri prvom použití nainštaluje. Ak chcete namiesto toho používať svoju vlastnú, vypnite kópiu od mise v `~/.config/mise/config.toml`. Napríklad, ak ste si Cursor CLI nainštalovali sami:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ak už máte tabuľku `[settings]`, pridajte záznam tam; existujúci zoznam `disable_tools` rozšírte, namiesto toho, aby ste ho nahradili. Uistite sa, že vaša inštalácia je v `PATH`. Použite názov nástroja mise, ktorý sa môže líšiť od jeho príkazu: napríklad `oh-my-pi` poskytuje `omp`. Spúšťač predvoleného agenta tiež uprednostňuje Cursor alebo Muse nainštalovaný používateľom v `~/.local/bin`.

### Odstránenie a obnovenie predvolených nastavení

_Remove Preinstalls_ spôsobí, že mise preskočí deklarácie nástrojov Omarchy pre vášho používateľa tým, že ich pridá do `ignored_config_paths` v `~/.config/mise/miserc.toml`. _Restore Preinstalls_ tento riadok opäť odstráni. Nástroje, ktoré deklarujete sami, vo vlastnej konfigurácii alebo v projektovom `mise.toml`, fungujú aj naďalej v oboch prípadoch. Ak si po odstránení predinštalovaných nástrojov vyberiete predvoleného agenta alebo nastavíte Python, daný nástroj sa pridá do vašej vlastnej konfigurácie. Obidve možnosti platia iba pre vášho používateľa; ostatní používatelia na počítači si zachovajú vlastnú voľbu.

## Docker

[Docker](https://www.docker.com/) sotva potrebuje nejaké predstavovanie. Umožňuje vám spúšťať izolované kontajnery a Omarchy nainštaluje všetko potrebné na to, aby dobre fungoval, vrátane samotného Docker a [Docker Compose](https://docs.docker.com/compose/).

Váš používateľ štandardne *nie je* v skupine `docker`. Táto skupina je v podstate root bez hesla — čokoľvek v nej môže spustiť `docker run -v /:/host` a prevziať kontrolu nad počítačom — takže jediný podvodný skript alebo závislosť spustená pod vaším používateľom by inak bola len jeden príkaz od root. Takže na príkazovom riadku spúšťate Docker pomocou `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, ktoré komunikujú s démonom — Windows VM — požiadajú o autorizáciu, keď ju potrebujú. Ak chcete späť pohodlie nastavenia bez skupiny a rozumiete tomuto kompromisu, povoľte ho v časti **Setup > Security > Sudoless Docker** (alebo spustite `omarchy-setup-security-sudoless-docker`), čo vás po upozornení pridá do skupiny `docker`; potom bude obyčajné `docker` a alias `d` opäť fungovať bez `sudo`.

Bežné databázy pre lokálny vývoj v Docker môžete nastaviť pomocou _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je dostupný ako `gh` na prácu s repozitármi, issues a pull requests z terminálu. Spustite `gh auth login`, aby ste ho pri prvom použití nainštalovali a autentifikovali sa, potom `gh repo clone org/repo` na klonovanie repozitára. Spustite `gh --help` a preskúmajte jeho príkazy.

Pre terminálové rozhranie k pull requests spustite `ghui`; mise ho tiež nainštaluje pri prvom použití. [Lazygit](https://github.com/jesseduffield/lazygit) je predinštalovaný na prácu so samotným Git.
