# Instrumente de dezvoltare

## Editori alternativi

Omarchy vine implicit cu [Neovim](https://neovim.io/), dar dacă vrei ceva un pic mai mainstream și mai familiar, poți deschide meniul Omarchy (`Super + Space`) și poți vedea opțiunile sub _Instalează > Editor_. Acolo am listat VSCode, Cursor, Zed, Sublime Text, Helix, Vim și Emacs. Dacă nu găsești ce cauți, uită-te la _Instalează > Pachet_ și vezi dacă nu se află într-un pachet Arch (iar dacă nu, încearcă _Instalează > AUR_ ca să verifici AUR-ul).

Editorul original `vi` este și el disponibil din start. Rulează `vi filename` ca să editezi un fișier în terminal.

Potrivirea temei este oferită pentru `VSCode`, `Cursor`, `VSCodium` și `Helix`.

Poți seta editorul implicit pentru tot sistemul sub `Configurare > Implicite > Editor`.

## Mediu

Omarchy acceptă configurarea unei întregi mulțimi de medii de dezvoltare prin secțiunea _Instalează > Dezvoltare_ din meniul Omarchy (`Super + Space`). Vei găsi, desigur, _Ruby on Rails_, dar și toate cele trei medii de rulare majore pentru JavaScript (Node.js, Bun, Deno), precum și frameworkuri PHP populare precum Laravel și Symfony. Ah, și mai sunt Go, Rust, Python, Java, Elixir (cu Phoenix), .NET, OCaml, Zig, Clojure și Scala. Este o selecție foarte largă!

Majoritatea acestor medii sunt gestionate de [Mise](https://mise.jdx.dev/). Este un instrument care îți permite să instalezi și să rulezi mai multe versiuni ale unui limbaj de programare pe aceeași mașină. Este ca rbenv sau rvm pentru Ruby sau virtualenv pentru Python, dar funcționează pentru o mulțime de medii diferite.

Ca să instalezi, să zicem, Ruby, ai rula `mise use -g ruby`, ceea ce va instala Ruby și îl va seta ca implicit global. Sau, dacă proiectul tău are un fișier .ruby-version, poți rula pur și simplu `mise i` în rădăcina acelui proiect.

## Docker

[Docker](https://www.docker.com/) aproape că nu are nevoie de prezentare. Îți permite să rulezi containere izolate, iar Omarchy instalează tot ce e nevoie ca să ruleze bine, inclusiv Docker în sine și [Docker Compose](https://docs.docker.com/compose/).

Implicit, utilizatorul tău *nu* face parte din grupul `docker`. Acel grup este practic root fără parolă — orice din el poate face `docker run -v /:/host` și poate prelua mașina — așa că un singur script sau o singură dependență răuvoitoare care rulează ca tine ar fi altfel la o comandă distanță de root. Prin urmare, din linia de comandă rulezi Docker cu `sudo` (`sudo docker ps`, `sudo docker compose up`), iar instrumentele grafice care vorbesc cu daemonul — mașina virtuală Windows — cer autorizare când au nevoie de ea. Dacă vrei înapoi comoditatea unei configurații fără grup și înțelegi compromisul, activeaz-o din **Configurare > Securitate > Docker fără sudo** (sau rulează `omarchy-setup-security-sudoless-docker`), ceea ce te adaugă în grupul `docker` după un avertisment; apoi `docker` simplu și aliasul `d` funcționează din nou fără `sudo`.

Poți configura bazele de date obișnuite pentru dezvoltarea locală în Docker folosind _Instalează > Dezvoltare > Docker DB_ din meniul Omarchy.

## CLI-ul GitHub

[CLI-ul GitHub](https://cli.github.com/) îți permite să te autentifici cu contul tău GitHub și să clonezi depozite private folosindu-l. Este conectat ca unul dintre stub-urile mise cu încărcare lentă, așa că prima dată când rulezi `gh`, se instalează singur. Ca să te autentifici, rulează `gh auth login`. Apoi poți descărca depozite private folosind `gh repo clone org/repo`.

Poți efectua și o mulțime de alte operațiuni GitHub folosind această comandă. Rulează pur și simplu `gh` ca să vezi tot ce este posibil.

Există și un stub cu instalare lentă pentru `ghui`, ca să-ți gestionezi pull request-urile într-o TUI. Iar [lazygit](https://github.com/jesseduffield/lazygit) este preinstalat, dacă vrei să conduci git însuși tot dintr-o TUI.
