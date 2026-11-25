# Instrumente de dezvoltare

## Editoare alternative

Omarchy vine cu Plain ca editor implicit pe instalările noi și cu [Neovim](https://neovim.io/) preinstalat, dar dacă vrei ceva puțin mai mainstream și mai familiar, poți deschide Omarchy Menu (`Super + Space`) și poți vedea opțiunile din _Install > Editor_. Acolo sunt listate VSCode, Cursor, Zed, Sublime Text, Helix, Vim și Emacs. Dacă nu găsești ce cauți, verifică _Install > Package_ și vezi dacă nu se află într-un pachet Arch (iar dacă nu, încearcă _Install > AUR_ ca să verifici AUR).

Editorul original `vi` este, de asemenea, disponibil din start. Rulează `vi filename` ca să editezi un fișier în terminal.

Potrivirea temei este oferită pentru `VSCode`, `Cursor`, `VSCodium` și `Helix`.

Poți seta editorul implicit la nivelul întregului sistem în `Setup > Defaults > Editor`.

## Mediu

Omarchy permite configurarea unei mulțimi întregi de medii de dezvoltare din secțiunea _Install > Development_ a Omarchy Menu (`Super + Space`). Vei găsi, bineînțeles, _Ruby on Rails_, dar și toate cele trei runtime-uri majore pentru JavaScript (Node.js, Bun, Deno), precum și framework-uri PHP populare, cum ar fi Laravel și Symfony. Ah, și mai sunt și Go, Rust, Python, Java, Elixir (cu Phoenix), .NET, OCaml, Zig, Clojure și Scala. Este o selecție foarte largă!

Majoritatea acestor medii sunt gestionate de [Mise](https://mise.jdx.dev/). Este un instrument care îți permite să instalezi și să rulezi mai multe versiuni ale unui limbaj de programare pe aceeași mașină. Este ca rbenv sau rvm pentru Ruby ori virtualenv pentru Python, dar funcționează pentru o mulțime de medii diferite.

Ca să instalezi, să zicem, Ruby, rulezi `mise use -g ruby`, ceea ce va instala Ruby și îl va seta totodată ca implicit global. Sau, dacă proiectul tău are un fișier .ruby-version, poți rula pur și simplu `mise i` în rădăcina acelui proiect.

## Instrumente CLI preinstalate

`uv`, Node.js și `playwright-cli` (pentru ca agenții să controleze un browser, folosind Chrome-ul instalat) vin instalate ca pachete, iar `omarchy update` le menține la zi alături de restul sistemului. `ghui`, [Hunk](https://github.com/modem-dev/hunk) și CLI-urile Basecamp, Cloudflare și HEY se află la o alegere distanță în _Install > CLI_, iar [agenții de programare](17-ai.md) în _Install > AI > CLI_.

mise gestionează doar runtime-urile pe care le configurezi din _Install > Development_; Omarchy nu instalează nimic prin el pe cont propriu. Rulează `omarchy update` ca să le actualizezi alături de restul Omarchy; aliasul `mup` actualizează doar instrumentele gestionate de mise. Ca să adaugi alt instrument la configurația ta, folosește `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) nu prea mai are nevoie de nicio prezentare. Îți permite să rulezi containere izolate, iar Omarchy instalează tot ce este necesar ca să funcționeze bine, inclusiv Docker însuși și [Docker Compose](https://docs.docker.com/compose/).

În mod implicit, utilizatorul tău *nu* se află în grupul `docker`. Acel grup înseamnă, practic, root fără parolă — orice se află în el poate rula `docker run -v /:/host` și poate prelua controlul asupra mașinii — așa că un singur script sau o singură dependență rău intenționată, care rulează ca tine, ar fi altfel la o singură comandă distanță de root. Prin urmare, în linia de comandă rulezi Docker cu `sudo` (`sudo docker ps`, `sudo docker compose up`), iar instrumentele grafice care comunică cu daemonul — VM-ul Windows — cer autorizare atunci când au nevoie de ea. Dacă vrei înapoi comoditatea configurării fără sudo și înțelegi compromisul, activeaz-o din **Setup > Security > Sudoless Docker** (sau rulează `omarchy-setup-security-sudoless-docker`), ceea ce te adaugă în grupul `docker` după un avertisment; apoi `docker` simplu și aliasul `d` funcționează din nou fără `sudo`.

Poți configura bazele de date uzuale pentru dezvoltarea locală în Docker folosind _Install > Development > Docker DB_ din meniul Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) este `gh`, pentru lucrul cu depozite, issue-uri și pull request-uri din terminal. _Setup > Git_ îl instalează atunci când alegi să te autentifici acolo în GitHub, apoi `gh repo clone org/repo` clonează un depozit. Rulează `gh --help` ca să explorezi comenzile sale.

_Install > CLI > GitHub_ instalează GitHub CLI, `gh`, împreună cu `ghui`, o interfață în terminal pentru pull request-uri. [Lazygit](https://github.com/jesseduffield/lazygit) este preinstalat pentru lucrul cu Git însuși.
