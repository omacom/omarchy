# Vývojárske nástroje

## Alternatívne editory

Omarchy sa na nových inštaláciách dodáva s editorom Plain ako predvoleným editorom a s predinštalovaným editorom [Neovim](https://neovim.io/), ale ak by ste chceli niečo trochu mainstreamovejšie a známejšie, môžete spustiť Omarchy Menu (`Super + Space`) a pozrieť si možnosti v časti _Install > Editor_. Nájdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Ak nenájdete to, čo hľadáte, pozrite si _Install > Package_ a skontrolujte, či to nie je v niektorom Arch balíčku (a ak nie, skúste _Install > AUR_ a skontrolujte AUR).

Pôvodný editor `vi` je tiež k dispozícii hneď po inštalácii. Súbor v termináli upravíte spustením `vi filename`.

Zladenie s témou sa ponúka pre `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Predvolený editor pre celý systém môžete nastaviť v časti `Setup > Defaults > Editor`.

## Prostredia

Omarchy podporuje nastavenie celej škály vývojových prostredí prostredníctvom časti _Install > Development_ v Omarchy Menu (`Super + Space`). Samozrejme tam nájdete _Ruby on Rails_, ale aj všetky tri hlavné runtime prostredia pre JavaScript (Node.js, Bun, Deno), ako aj populárne PHP frameworky ako Laravel a Symfony. No a je tam aj Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to naozaj široký výber!

Väčšinu týchto prostredí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, ktorý vám umožňuje nainštalovať a spúšťať viacero verzií programovacieho jazyka na tom istom počítači. Je to ako rbenv alebo rvm pre Ruby alebo virtualenv pre Python, ale funguje pre množstvo rôznych prostredí.

Ak chcete nainštalovať napríklad Ruby, spustíte `mise use -g ruby`, čím sa Ruby zároveň nainštaluje aj nastaví ako globálna predvolená verzia. Alebo, ak má váš projekt súbor .ruby-version, môžete jednoducho spustiť `mise i` v koreňovom adresári daného projektu.

## Predinštalované CLI nástroje

`uv`, Node.js a `playwright-cli` (aby agenti mohli ovládať prehliadač pomocou nainštalovaného Chrome) prichádzajú nainštalované ako balíčky a `omarchy update` ich udržiava aktuálne spolu so zvyškom systému. [Hunk](https://github.com/modem-dev/hunk) a CLI pre GitHub, Basecamp, Cloudflare a HEY sú na dosah jedného výberu v časti _Install > CLI_ a [kódovací agenti](17-ai.md) v časti _Install > AI > CLI_.

mise spravuje iba runtime prostredia, ktoré si nastavíte v časti _Install > Development_; Omarchy cez neho sám od seba nič neinštaluje. Spustením `omarchy update` ich aktualizujete spolu so zvyškom Omarchy; alias `mup` aktualizuje iba nástroje spravované cez mise. Ak chcete do svojej vlastnej konfigurácie pridať ďalší nástroj, použite `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) takmer nepotrebuje žiadne predstavovanie. Umožňuje vám spúšťať izolované kontajnery a Omarchy nainštaluje všetko potrebné na to, aby dobre fungoval, vrátane samotného Docker a [Docker Compose](https://docs.docker.com/compose/).

Váš používateľ predvolene *nie* je členom skupiny `docker`. Táto skupina je v podstate root bez hesla — čokoľvek v nej môže spustiť `docker run -v /:/host` a prevziať kontrolu nad počítačom — takže jediný škodlivý skript alebo závislosť spustená pod vaším používateľom by inak bola len jeden príkaz od root. Preto na príkazovom riadku spúšťate Docker pomocou `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, ktoré komunikujú s démonom — Windows VM — si v prípade potreby vyžiadajú autorizáciu. Ak chcete späť pohodlie nastavenia bez skupiny a rozumiete kompromisu, povoľte ho v časti **Setup > Security > Sudoless Docker** (alebo spustite `omarchy-setup-security-sudoless-docker`), čím sa po varovaní pridáte do skupiny `docker`; potom obyčajné `docker` a alias `d` opäť fungujú bez `sudo`.

Bežné databázy pre lokálny vývoj v Docker si môžete nastaviť pomocou _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh`, nástroj na prácu s repozitármi, issues a pull requestmi z terminálu. _Setup > Git_ ho nainštaluje, keď sa tam rozhodnete prihlásiť do GitHub, alebo si ho nainštalujte samostatne v časti _Install > CLI > GitHub_. Potom príkaz `gh repo clone org/repo` naklonuje repozitár; spustite `gh --help` a preskúmajte jeho príkazy.

[Lazygit](https://github.com/jesseduffield/lazygit) je predinštalovaný na prácu so samotným Git.
