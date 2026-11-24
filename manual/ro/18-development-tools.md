# Instrumente de dezvoltare

## Editoare alternative

Omarchy vine cu Plain ca editor implicit pe instalările noi și cu [Neovim](https://neovim.io/) preinstalat, dar dacă ai vrea ceva puțin mai mainstream și mai familiar, poți deschide Meniul Omarchy (`Super + Space`) și poți vedea opțiunile din _Instalare > Editor_. Acolo avem trecute VSCode, Cursor, Zed, Sublime Text, Helix, Vim și Emacs. Dacă nu găsești ce cauți, treci pe la _Instalare > Pachet_ și vezi dacă nu cumva se află într-un pachet Arch (iar dacă nu, încearcă _Instalare > AUR_ ca să verifici AUR-ul).

Editorul `vi` original este disponibil și el din start. Rulează `vi filename` ca să editezi un fișier în terminal.

Potrivirea cu tema este oferită pentru `VSCode`, `Cursor`, `VSCodium` și `Helix`.

Poți seta editorul implicit la nivelul întregului sistem din `Setup > Defaults > Editor`.

## Mediu

Omarchy acceptă configurarea unei întregi mulțimi de medii de dezvoltare prin secțiunea _Instalare > Dezvoltare_ din Meniul Omarchy (`Super + Space`). Vei găsi, bineînțeles, _Ruby on Rails_, dar și toate cele trei runtime-uri majore pentru JavaScript (Node.js, Bun, Deno), precum și framework-uri PHP populare, cum ar fi Laravel și Symfony. Ah, și mai există și Go, Rust, Python, Java, Elixir (cu Phoenix), .NET, OCaml, Zig, Clojure și Scala. Este o selecție foarte largă!

Majoritatea acestor medii sunt gestionate de [Mise](https://mise.jdx.dev/). Este un instrument care îți permite să instalezi și să rulezi mai multe versiuni ale unui limbaj de programare pe aceeași mașină. Este ca rbenv sau rvm pentru Ruby ori ca virtualenv pentru Python, dar funcționează pentru o mulțime de medii diferite.

Ca să instalezi, să zicem, Ruby, ai rula `mise use -g ruby`, ceea ce va instala Ruby și îl va seta totodată ca valoare implicită globală. Sau, dacă proiectul tău are un fișier .ruby-version, poți rula pur și simplu `mise i` în rădăcina acelui proiect.

## Instrumente CLI preinstalate

Omarchy pune la dispoziție instrumente precum `gh`, `uv` și majoritatea [agenților de codare](17-ai.md) prin [instalarea leneșă a mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Prima dată când rulezi unul dintre ele, mise îl instalează. Agenții de codare verifică apoi dacă există o actualizare înainte să ruleze, cel mult o dată la patru ore; alte instrumente, cum ar fi `gh` și `uv`, refolosesc versiunea instalată până când faci tu actualizarea.

De asemenea, poți inspecta valorile implicite sau le poți instala dinainte:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Rulează `omarchy update` ca să actualizezi instrumentele instalate odată cu restul Omarchy. Aliasul `mup` actualizează numai instrumentele gestionate de mise. Ca să adaugi alt instrument în propria configurație, folosește `mise use -g <tool>`.

Configurarea Python instalează și `uv` prin mise. Eliminarea mediului de dezvoltare Python lasă `uv` disponibil ca instrument independent.

### Folosirea propriei instalări

Comenzile mise vin înaintea `~/.local/bin` în `PATH`, așa că un instrument instalat de tine, de exemplu cu programul de instalare propriu al Claude Code sau al Cursor, rulează tot copia mise. Aplicațiile lansate de pe desktop găsesc și ele comenzile mise înaintea pachetelor de sistem, așa că o aplicație care rulează `gh` primește copia mise chiar dacă ai instalat `github-cli` cu pacman, iar mise instalează acea copie prima dată. Ca să o folosești pe a ta în schimb, dezactivează copia mise în `~/.config/mise/config.toml`. De exemplu, dacă ai instalat singur Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Dacă ai deja un tabel `[settings]`, adaugă intrarea acolo; extinde o listă `disable_tools` existentă, în loc să o înlocuiești. Asigură-te că instalarea ta se află în `PATH`. Folosește numele instrumentului mise, care poate fi diferit de comanda sa: `oh-my-pi` oferă `omp`, de exemplu. Programul de lansare al agentului implicit preferă, de asemenea, o versiune Cursor sau Muse instalată de utilizator în `~/.local/bin`.

### Eliminarea și restaurarea valorilor implicite

_Eliminare > Preinstalări_ elimină aplicațiile web, TUI-urile și aplicațiile preinstalate ale Omarchy și face ca mise să sară peste declarațiile de instrumente ale Omarchy pentru utilizatorul tău, adăugându-le în `ignored_config_paths` în `~/.config/mise/miserc.toml`. _Instalare > Preinstalări_ le aduce înapoi și elimină din nou acel rând. Instrumentele pe care le declari tu însuți, în propria configurație sau într-un `mise.toml` al unui proiect, continuă să funcționeze în ambele cazuri. Dacă alegi un agent implicit sau configurezi Python după ce ai eliminat preinstalările, acel instrument este adăugat în propria ta configurație. Setarea mise se aplică numai utilizatorului tău, iar ceilalți utilizatori își păstrează propria alegere; aplicațiile sunt însă pachete, așa că eliminarea sau restaurarea lor le modifică pentru toată lumea de pe mașină.

## Docker

[Docker](https://www.docker.com/) nu are aproape deloc nevoie de prezentare. Îți permite să rulezi containere izolate, iar Omarchy instalează tot ce este nevoie ca să ruleze bine, inclusiv Docker însuși și [Docker Compose](https://docs.docker.com/compose/).

În mod implicit, utilizatorul tău *nu* se află în grupul `docker`. Acel grup înseamnă, efectiv, root fără parolă — orice se află în el poate rula `docker run -v /:/host` și poate prelua controlul asupra mașinii — așa că un singur script sau o singură dependență rău intenționată care rulează ca tine ar fi, altfel, la o singură comandă distanță de root. Așadar, în linia de comandă rulezi Docker cu `sudo` (`sudo docker ps`, `sudo docker compose up`), iar instrumentele grafice care vorbesc cu daemonul — VM-ul Windows — cer autorizare atunci când au nevoie de ea. Dacă vrei înapoi comoditatea unei configurații fără grup și înțelegi compromisul, activeaz-o din **Configurare > Securitate > Docker fără sudo** (sau rulează `omarchy-setup-security-sudoless-docker`), ceea ce te adaugă în grupul `docker` după un avertisment; apoi `docker` simplu și aliasul `d` funcționează din nou fără `sudo`.

Poți configura cele mai comune baze de date pentru dezvoltarea locală în Docker folosind _Instalare > Dezvoltare > Docker DB_ din meniul Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) este disponibil ca `gh` pentru lucrul cu depozite, issue-uri și pull request-uri din terminal. Rulează `gh auth login` ca să îl instalezi la prima utilizare și să te autentifici, apoi `gh repo clone org/repo` ca să clonezi un depozit. Rulează `gh --help` ca să-i explorezi comenzile.

Pentru o interfață în terminal pentru pull request-uri, rulează `ghui`; și pe acesta mise îl instalează la prima utilizare. [Lazygit](https://github.com/jesseduffield/lazygit) este preinstalat pentru lucrul cu Git însuși.
