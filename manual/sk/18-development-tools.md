# Vývojárske nástroje

## Alternatívne editory

Omarchy sa na nových inštaláciách dodáva s Plain ako predvoleným editorom a s predinštalovaným [Neovim](https://neovim.io/), ale ak by ste chceli niečo trochu bežnejšie a známejšie, môžete spustiť Omarchy Menu (`Super + Space`) a pozrieť si možnosti v časti _Install > Editor_. Nájdete tam uvedené VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Ak nenájdete to, čo hľadáte, pozrite si _Install > Package_ a zistite, či to nie je v niektorom balíčku Archu (a ak nie, skúste _Install > AUR_ a skontrolujte AUR).

Pôvodný editor `vi` je tiež k dispozícii hneď po inštalácii. Súbor v termináli upravíte spustením `vi filename`.

Prispôsobenie témy sa ponúka pre `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Systémovo predvolený editor môžete nastaviť v časti `Setup > Defaults > Editor`.

## Prostredie

Omarchy podporuje nastavenie celej škály vývojárskych prostredí prostredníctvom časti _Install > Development_ v Omarchy Menu (`Super + Space`). Samozrejme tam nájdete _Ruby on Rails_, ale aj všetky tri hlavné runtime prostredia pre JavaScript (Node.js, Bun, Deno), ako aj populárne PHP frameworky ako Laravel a Symfony. Aha, a je tam aj Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure a Scala. Je to veľmi široký výber!

Väčšinu týchto prostredí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, ktorý vám umožňuje nainštalovať a spúšťať viacero verzií programovacieho jazyka na tom istom počítači. Je to ako rbenv alebo rvm pre Ruby alebo virtualenv pre Python, ale funguje pre množstvo rôznych prostredí.

Ak chcete nainštalovať napríklad Ruby, spustíte `mise use -g ruby`, čím sa Ruby nainštaluje a zároveň nastaví ako globálne predvolené. Alebo, ak má váš projekt súbor .ruby-version, môžete jednoducho spustiť `mise i` v koreňovom adresári daného projektu.

## Predinštalované nástroje CLI

Omarchy sprístupňuje nástroje ako `gh`, `uv` a väčšinu [kódovacích agentov](17-ai.md) prostredníctvom [lenivej inštalácie mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Pri prvom spustení niektorého z nich ho mise nainštaluje. Kódovací agenti potom pred spustením skontrolujú, či nie je k dispozícii aktualizácia, najviac raz za štyri hodiny; ostatné nástroje, ako `gh` a `uv`, používajú nainštalovanú verziu, kým ich neaktualizujete.

Predvolené nástroje si môžete aj skontrolovať alebo ich nainštalovať vopred:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Spustením `omarchy update` aktualizujete nainštalované nástroje spolu so zvyškom Omarchy. Alias `mup` aktualizuje iba nástroje spravované cez mise. Ak chcete do vlastnej konfigurácie pridať ďalší nástroj, použite `mise use -g <tool>`.

Nastavenie Pythonu nainštaluje cez mise aj `uv`. Odstránením vývojárskeho prostredia Pythonu zostane `uv` k dispozícii ako nezávislý nástroj.

### Používanie vlastnej inštalácie

Príkazy mise sú na `PATH` pred `~/.local/bin`, takže nástroj, ktorý ste si nainštalovali sami, napríklad vlastným inštalátorom Claude Code alebo Cursoru, napriek tomu spustí kópiu od mise. Aplikácie spustené z pracovnej plochy tiež nájdu príkazy mise pred systémovými balíčkami, takže aplikácia, ktorá spúšťa `gh`, dostane kópiu od mise, aj keď ste si `github-cli` nainštalovali pomocou pacman, a mise túto kópiu pri prvom spustení nainštaluje. Ak chcete namiesto toho používať svoju vlastnú, zakážte kópiu od mise v `~/.config/mise/config.toml`. Napríklad, ak ste si Cursor CLI nainštalovali sami:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ak už tabuľku `[settings]` máte, pridajte záznam tam; existujúci zoznam `disable_tools` rozšírte, namiesto toho, aby ste ho nahradili. Uistite sa, že vaša inštalácia je na `PATH`. Použite názov nástroja mise, ktorý sa môže líšiť od jeho príkazu: napríklad `oh-my-pi` poskytuje `omp`. Spúšťač predvoleného agenta tiež uprednostňuje Cursor alebo Muse nainštalované používateľom v `~/.local/bin`.

### Odstránenie a obnovenie predvolených položiek

_Remove > Preinstalls_ odstráni predinštalované webové aplikácie, TUI a aplikácie Omarchy a spôsobí, že mise pre vášho používateľa preskočí deklarácie nástrojov Omarchy, a to tak, že ich pridá do `ignored_config_paths` v `~/.config/mise/miserc.toml`. _Install > Preinstalls_ ich vráti späť a tento riadok znova odstráni. Nástroje, ktoré si deklarujete sami, vo vlastnej konfigurácii alebo v súbore `mise.toml` projektu, fungujú naďalej v oboch prípadoch. Ak si po odstránení predinštalovaných položiek vyberiete predvoleného agenta alebo nastavíte Python, daný nástroj sa pridá do vašej vlastnej konfigurácie. Nastavenie mise platí iba pre vášho používateľa a ostatní používatelia si ponechajú vlastnú voľbu; aplikácie sú však balíčky, takže ich odstránenie alebo obnovenie ich zmení pre všetkých na počítači.

## Docker

[Docker](https://www.docker.com/) takmer nepotrebuje žiadne predstavovanie. Umožňuje spúšťať izolované kontajnery a Omarchy nainštaluje všetko potrebné na jeho dobré fungovanie vrátane samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Váš používateľ predvolene *nie je* v skupine `docker`. Táto skupina je v podstate root bez hesla — čokoľvek v nej môže spustiť `docker run -v /:/host` a prevziať kontrolu nad počítačom — takže jediný škodlivý skript alebo závislosť spustená pod vašim používateľom by inak bola len jeden príkaz od rootu. V príkazovom riadku preto Docker spúšťate pomocou `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, ktoré komunikujú s démonom — Windows VM — si v prípade potreby vyžiadajú autorizáciu. Ak chcete späť pohodlie nastavenia bez skupiny a rozumiete kompromisu, povoľte ho v časti **Setup > Security > Sudoless Docker** (alebo spustite `omarchy-setup-security-sudoless-docker`), čím budete po varovaní pridaní do skupiny `docker`; potom bude obyčajné `docker` a alias `d` znova fungovať bez `sudo`.

Bežné databázy pre lokálny vývoj v Dockeri môžete nastaviť pomocou _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je k dispozícii ako `gh` na prácu s repozitármi, issues a pull requestmi z terminálu. Spustením `gh auth login` ho pri prvom použití nainštalujete a overíte sa, potom môžete repozitár naklonovať pomocou `gh repo clone org/repo`. Jeho príkazy preskúmate spustením `gh --help`.

Terminálové rozhranie pre pull requesty spustíte pomocou `ghui`; mise ho pri prvom použití tiež nainštaluje. [Lazygit](https://github.com/jesseduffield/lazygit) je predinštalovaný na prácu so samotným Gitom.
