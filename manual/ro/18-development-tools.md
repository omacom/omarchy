# Instrumente de dezvoltare

## Editori alternativi

Omarchy vine implicit cu [Neovim](https://neovim.io/), dar dacă vrei ceva mai mainstream și mai familiar, poți deschide Omarchy Menu (`Super + Space`) și poți vedea opțiunile din _Install > Editor_. Acolo avem VSCode, Cursor, Zed, Sublime Text, Helix, Vim și Emacs. Dacă nu găsești ce cauți, verifică _Install > Package_ și vezi dacă nu cumva se află într-un pachet Arch (iar dacă nu, încearcă _Install > AUR_ ca să verifici AUR).

Editorul `vi` original este, de asemenea, disponibil din cutie. Rulează `vi filename` ca să editezi un fișier în terminal.

Potrivirea temei este oferită pentru `VSCode`, `Cursor`, `VSCodium` și `Helix`.

Poți seta editorul implicit pentru întregul sistem din `Setup > Defaults > Editor`.

## Mediu

Omarchy acceptă configurarea unei mulțimi întregi de medii de dezvoltare prin secțiunea _Install > Development_ din Omarchy Menu (`Super + Space`). Vei găsi, bineînțeles, _Ruby on Rails_, dar și toate cele trei runtime-uri majore pentru JavaScript (Node.js, Bun, Deno), precum și framework-uri PHP populare, ca Laravel și Symfony. Oh, și mai sunt Go, Rust, Python, Java, Elixir (cu Phoenix), .NET, OCaml, Zig, Clojure și Scala. Este o selecție foarte largă!

Majoritatea acestor medii sunt gestionate de [Mise](https://mise.jdx.dev/). Este un instrument care îți permite să instalezi și să rulezi mai multe versiuni ale unui limbaj de programare pe același computer. Este ca rbenv sau rvm pentru Ruby sau virtualenv pentru Python, dar funcționează pentru o mulțime de medii diferite.

Ca să instalezi, să zicem, Ruby, ai rula `mise use -g ruby`, ceea ce va instala Ruby și îl va seta ca implicit global. Sau, dacă proiectul tău are un fișier .ruby-version, poți rula pur și simplu `mise i` în rădăcina acelui proiect.

## Instrumente CLI preinstalate

Omarchy pune la dispoziție instrumente precum `gh`, `uv` și majoritatea [agenților de programare](17-ai.md) prin [instalarea leneșă a mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Prima dată când rulezi unul, mise îl instalează. Rulările ulterioare refolosesc versiunea instalată; nu verifică dacă există o actualizare la fiecare lansare.

Poți, de asemenea, să inspectezi valorile implicite sau să le instalezi dinainte:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Rulează `omarchy update` ca să actualizezi instrumentele instalate odată cu restul Omarchy. Aliasul `mup` actualizează doar instrumentele gestionate de mise. Ca să adaugi alt instrument în propria configurație, folosește `mise use -g <tool>`.

Configurarea Python instalează și `uv` prin mise. Eliminarea mediului de dezvoltare Python lasă `uv` disponibil ca instrument independent.

### Folosirea propriei instalări

Comenzile mise vin înaintea `~/.local/bin` în `PATH`, așa că un instrument instalat de tine, de exemplu cu programul de instalare propriu al Claude Code sau Cursor, rulează tot copia mise. Aplicațiile lansate de pe desktop găsesc și ele comenzile mise înaintea pachetelor de sistem, așa că o aplicație care rulează `gh` primește copia mise chiar dacă ai instalat `github-cli` cu pacman, iar mise instalează copia aceea prima dată. Ca să o folosești pe a ta în schimb, dezactivează copia mise în `~/.config/mise/config.toml`. De exemplu, dacă ai instalat singur Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Dacă ai deja un tabel `[settings]`, adaugă intrarea acolo; extinde o listă `disable_tools` existentă, nu o înlocui. Asigură-te că instalarea ta se află în `PATH`. Folosește numele instrumentului mise, care poate diferi de comanda sa: `oh-my-pi` oferă `omp`, de exemplu. Lansatorul agentului implicit preferă și el un Cursor sau Muse instalat de utilizator în `~/.local/bin`.

### Eliminarea și restaurarea valorilor implicite

_Remove Preinstalls_ face ca mise să sară peste declarațiile de instrumente ale Omarchy pentru utilizatorul tău, adăugându-le la `ignored_config_paths` în `~/.config/mise/miserc.toml`. _Restore Preinstalls_ șterge din nou linia aceea. Instrumentele declarate de tine, în propria configurație sau în `mise.toml` al unui proiect, continuă să funcționeze în ambele cazuri. Dacă alegi un agent implicit sau configurezi Python după eliminarea preinstalărilor, instrumentul respectiv este adăugat în propria ta configurație. Ambele se aplică doar utilizatorului tău; ceilalți utilizatori de pe computer își păstrează propria alegere.

## Docker

[Docker](https://www.docker.com/) aproape că nu mai are nevoie de nicio prezentare. Îți permite să rulezi containere izolate, iar Omarchy instalează tot ce trebuie ca să ruleze bine, inclusiv Docker însuși și [Docker Compose](https://docs.docker.com/compose/).

În mod implicit, utilizatorul tău *nu* se află în grupul `docker`. Grupul acela înseamnă, practic, root fără parolă — orice se află în el poate rula `docker run -v /:/host` și poate prelua controlul computerului — așa că un singur script sau o singură dependență necinstite care rulează ca tine ar fi altfel la o singură comandă distanță de root. Așadar, în linia de comandă rulezi Docker cu `sudo` (`sudo docker ps`, `sudo docker compose up`), iar instrumentele grafice care vorbesc cu daemonul — VM-ul Windows — cer autorizare când au nevoie de ea. Dacă vrei înapoi comoditatea unei configurări fără grup și înțelegi compromisul, activeaz-o din **Setup > Security > Sudoless Docker** (sau rulează `omarchy-setup-security-sudoless-docker`), ceea ce te adaugă în grupul `docker` după un avertisment; apoi `docker` simplu și aliasul `d` funcționează din nou fără `sudo`.

Poți configura bazele de date obișnuite pentru dezvoltarea locală în Docker folosind _Install > Development > Docker DB_ în meniul Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) este disponibil ca `gh` pentru lucrul cu depozite, issue-uri și pull request-uri din terminal. Rulează `gh auth login` ca să îl instalezi la prima utilizare și să te autentifici, apoi `gh repo clone org/repo` ca să clonezi un depozit. Rulează `gh --help` ca să-i explorezi comenzile.

Pentru o interfață în terminal pentru pull request-uri, rulează `ghui`; și pe acesta mise îl instalează la prima utilizare. [Lazygit](https://github.com/jesseduffield/lazygit) este preinstalat pentru lucrul cu Git însuși.
