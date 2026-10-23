# Vývojové nástroje

## Alternatívne editory

Omarchy sa predvolene dodáva s editorom [Neovim](https://neovim.io/), ale ak by si chcel niečo bežnejšie a známejšie, môžeš spustiť menu Omarchy (`Super + Space`) a pozrieť si možnosti v časti _Inštalovať > Editor_. Nájdeš tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Ak tam nenájdeš, čo hľadáš, pozri sa do _Inštalovať > Balíček_ a zisti, či to nie je v niektorom balíčku Archu (a ak nie, skús _Inštalovať > AUR_ a skontroluj AUR).

Hneď po inštalácii je k dispozícii aj pôvodný editor `vi`. Ak chceš upraviť súbor v termináli, spusti `vi filename`.

Zosúladenie témy sa ponúka pre `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Predvolený editor pre celý systém môžeš nastaviť v časti `Nastavenie > Predvolené > Editor`.

## Prostredie

Omarchy podporuje nastavenie celého radu vývojových prostredí prostredníctvom časti _Inštalovať > Vývoj_ v menu Omarchy (`Super + Space`). Samozrejme tam nájdeš _Ruby on Rails_, ale aj všetky tri hlavné runtime prostredia pre JavaScript (Node.js, Bun, Deno), ako aj populárne PHP frameworky ako Laravel a Symfony. A áno, nechýbajú ani Go, Rust, Python, Java, Elixir (s Phoenixom), .NET, OCaml, Zig, Clojure a Scala. Výber je naozaj široký!

Väčšinu týchto prostredí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, ktorý ti umožňuje nainštalovať a spúšťať viacero verzií programovacieho jazyka na tom istom počítači. Je to niečo ako rbenv alebo rvm pre Ruby či virtualenv pre Python, ale funguje pre celú kopu rôznych prostredí.

Ak chceš nainštalovať napríklad Ruby, spustíš `mise use -g ruby`, čím sa Ruby nainštaluje a zároveň nastaví ako globálna predvolená verzia. Alebo, ak má tvoj projekt súbor .ruby-version, stačí v koreňovom adresári projektu spustiť `mise i`.

## Docker

[Docker](https://www.docker.com/) takmer netreba predstavovať. Umožňuje spúšťať izolované kontajnery a Omarchy nainštaluje všetko potrebné na jeho dobré fungovanie vrátane samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Tvoj používateľ predvolene *nie je* v skupine `docker`. Táto skupina je v podstate root bez hesla — čokoľvek v nej môže spustiť `docker run -v /:/host` a prevziať kontrolu nad počítačom — takže jediný nekontrolovaný skript alebo závislosť spustená pod tvojím používateľom by inak bola len jeden príkaz od práv roota. V príkazovom riadku preto Docker spúšťaš so `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, ktoré komunikujú s démonom — virtuálny stroj s Windowsom — si v prípade potreby vyžiadajú autorizáciu. Ak chceš späť pohodlie nastavenia bez skupiny a rozumieš kompromisu, zapni ho v časti **Nastavenie > Bezpečnosť > Docker bez sudo** (alebo spusti `omarchy-setup-security-sudoless-docker`), čo ťa po upozornení pridá do skupiny `docker`; potom obyčajný príkaz `docker` aj alias `d` opäť fungujú bez `sudo`.

Bežné databázy pre lokálny vývoj v Dockeri môžeš nastaviť pomocou _Inštalovať > Vývoj > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) ti umožňuje prihlásiť sa do svojho účtu GitHub a klonovať pomocou neho súkromné repozitáre. Je zapojený ako jeden z lenivo načítaných stubov nástroja mise, takže pri prvom spustení `gh` sa sám nainštaluje. Na prihlásenie spusti `gh auth login`. Potom môžeš klonovať súkromné repozitáre pomocou `gh repo clone org/repo`.

Pomocou tohto príkazu môžeš vykonávať aj množstvo ďalších operácií na GitHube. Stačí spustiť `gh` a uvidíš všetko, čo je možné.

K dispozícii je aj lenivo inštalovaný stub `ghui` na správu pull requestov v TUI. A predinštalovaný je aj [lazygit](https://github.com/jesseduffield/lazygit), ak chceš ovládať samotný git tiež z TUI.
