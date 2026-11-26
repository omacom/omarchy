# Instrumente de dezvoltare

## Editoare alternative

Omarchy vine cu Plain ca editor implicit pe instalările noi și cu [Neovim](https://neovim.io/) preinstalat, dar dacă vrei ceva puțin mai răspândit și mai familiar, poți deschide Meniul Omarchy (`Super + Space`) și poți vedea opțiunile din _Install > Editor_. Avem VSCode, Cursor, Zed, Sublime Text, Helix, Vim și Emacs listate acolo. Dacă nu găsești ce cauți, verifică _Install > Package_ și vezi dacă nu cumva se află într-un pachet Arch (iar dacă nu, încearcă _Install > AUR_ ca să verifici AUR).

Editorul original `vi` este și el disponibil din start. Rulează `vi filename` ca să editezi un fișier în terminal.

Potrivirea temei este oferită pentru `VSCode`, `Cursor`, `VSCodium` și `Helix`.

Poți seta editorul implicit la nivel de sistem din `Setup > Defaults > Editor`.

## Mediu

Omarchy îți permite să configurezi o mulțime întreagă de medii de dezvoltare prin secțiunea _Install > Development_ din Meniul Omarchy (`Super + Space`). Vei găsi, desigur, _Ruby on Rails_, dar și toate cele trei runtime-uri majore pentru JavaScript (Node.js, Bun, Deno), precum și framework-uri PHP populare precum Laravel și Symfony. Ah, și mai există și Go, Rust, Python, Java, Elixir (cu Phoenix), .NET, OCaml, Zig, Clojure și Scala. Este o selecție foarte largă!

Majoritatea acestor medii sunt gestionate de [Mise](https://mise.jdx.dev/). Este un instrument care îți permite să instalezi și să rulezi mai multe versiuni ale unui limbaj de programare pe aceeași mașină. Este ca rbenv sau rvm pentru Ruby sau virtualenv pentru Python, dar funcționează pentru o grămadă de medii diferite.

Ca să instalezi, să zicem, Ruby, ai rula `mise use -g ruby`, ceea ce va instala Ruby și îl va seta ca implicit global. Sau, dacă proiectul tău are un fișier .ruby-version, poți pur și simplu să rulezi `mise i` în rădăcina acelui proiect.

## Instrumente CLI preinstalate

`uv`, Node.js și `playwright-cli` (pentru ca agenții să controleze un browser, folosind Chrome-ul instalat) vin instalate ca pachete, iar `omarchy update` le menține actualizate împreună cu restul sistemului. [Hunk](https://github.com/modem-dev/hunk) și CLI-urile GitHub, Basecamp, Cloudflare și HEY sunt la un pas distanță în _Install > CLI_, iar [agenții de programare](17-ai.md) în _Install > AI > CLI_.

mise gestionează doar runtime-urile pe care le configurezi din _Install > Development_; Omarchy nu instalează nimic prin el pe cont propriu. Rulează `omarchy update` ca să le actualizezi împreună cu restul Omarchy; aliasul `mup` actualizează doar instrumentele gestionate de mise. Ca să adaugi alt instrument la configurația ta, folosește `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) nu prea are nevoie de nicio prezentare. Îți permite să rulezi containere izolate, iar Omarchy instalează tot ce este necesar ca să funcționeze bine, inclusiv Docker însuși și [Docker Compose](https://docs.docker.com/compose/).

În mod implicit, utilizatorul tău *nu* face parte din grupul `docker`. Acel grup este, practic, root fără parolă — orice se află în el poate rula `docker run -v /:/host` și poate prelua controlul mașinii — așa că un singur script sau o singură dependență rău intenționată care rulează ca tine ar fi, altfel, la o singură comandă distanță de root. Așadar, în linia de comandă rulezi Docker cu `sudo` (`sudo docker ps`, `sudo docker compose up`), iar instrumentele grafice care comunică cu daemonul — VM-ul Windows — cer autorizare atunci când au nevoie de ea. Dacă vrei înapoi comoditatea unei configurații fără grup și înțelegi compromisul, activeaz-o din **Setup > Security > Sudoless Docker** (sau rulează `omarchy-setup-security-sudoless-docker`), ceea ce te adaugă în grupul `docker` după un avertisment; apoi `docker` simplu și aliasul `d` funcționează din nou fără `sudo`.

Poți configura bazele de date uzuale pentru dezvoltare locală în Docker folosind _Install > Development > Docker DB_ în meniul Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) este `gh`, pentru a lucra cu depozite, issue-uri și pull request-uri din terminal. _Setup > Git_ îl instalează atunci când alegi să te autentifici la GitHub acolo, sau instalează-l separat din _Install > CLI > GitHub_. Apoi `gh repo clone org/repo` clonează un depozit; rulează `gh --help` ca să explorezi comenzile sale.

[Lazygit](https://github.com/jesseduffield/lazygit) este preinstalat pentru a lucra cu Git însuși.
