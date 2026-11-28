# Cum să-ți faci propria temă

Poți adăuga propriile teme în `~/.config/omarchy/themes`. Copiază pur și simplu una dintre cele existente ca bază (le găsești în `/usr/share/omarchy/themes`), apoi modific-o după pofta inimii. Atâta timp cât tema ta se află în acel folder, va fi inclusă în meniul de selectare a temelor.

Fișierul principal pe care trebuie să-l modifici este `colors.toml`. Acesta definește setul de culori folosit apoi pentru a genera configurații pentru terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplicații Qt, iluminarea de fundal a tastaturii, metoda de introducere, selectorul de partajare a ecranului, pictogramele aplicațiilor, mai multe instrumente AI (Claude, Pi, Hermes, T3 Code, Herdr) și întregul shell Omarchy (bara superioară, meniu, notificări, OSD și ecranul de blocare).

Poți folosi și aplicația Aether inclusă pentru a crea o temă nouă folosind o interfață GUI plăcută, în care să te joci cu culorile și să cauți fundaluri. Pornește-o pur și simplu din grila de aplicații cu `Super + Alt + Space`.

### Ce poate conține o temă instalată

O temă pe care o scrii tu însuți în `~/.config/omarchy/themes` poate conține orice dorești — este mașina ta și fișierul tău, iar Omarchy aplică totul.

O temă pe care o instalezi din repo-ul altcuiva cu `omarchy theme install` păstrează tot ce ține de culoare și pierde puținele fișiere care ar rula cod pe mașina ta: orice fișier `.lua`, configurațiile de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) și `vscode.json`. `hyprland.lua` al unei teme este Lua pe care compositorul tău îl rulează la autentificare, o configurație de terminal numește programul pe care terminalul tău îl pornește, iar `vscode.json` numește o extensie VSCode de instalat. Instalarea temei cuiva ar trebui să schimbe cum arată desktopul tău, niciodată ce rulează pe el.

Tot restul funcționează în continuare exact cum l-a scris autorul temei — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fundalurile și previzualizările sunt păstrate toate. Doar ce a fost eliminat este regenerat din `colors.toml` pe mașina ta.

Omarchy le distinge după dacă tema are propriul repo git în interiorul ei, ceea ce `omarchy theme install` lasă în urmă atunci când clonează. Așa, o temă pe care ai scris-o rămâne a ta, iar una pe care ai luat-o de pe internet rămâne doar culori.

### Modul luminos

Dacă faci o temă cu mod luminos, setează `mode = "light"` la începutul fișierului tău `colors.toml`. Apoi va fi asociată automat cu modul luminos pentru toate aplicațiile. (Vechea metodă de a lăsa un fișier gol numit `light.mode` în rădăcina temei tale funcționează în continuare.)

### Imaginea de deblocare

Temele furnizate cu imaginile `unlock.png` și `preview-unlock.png` vor fi listate sub _Aspect > Deblocare_. `unlock.png`-ul tău ar trebui, de preferință, să fie un png transparent. Și poți crea imaginea de previzualizare folosind `omarchy plymouth preview`.

### Tematizarea aplicațiilor pe care Omarchy nu le acoperă

Dacă folosești o aplicație care nu este în lista aceea, poți învăța Omarchy să o tematizeze singur cu un șablon. Lasă un fișier în `~/.config/omarchy/themed/` numit după configurația pe care o generează plus extensia `.tpl` și scrie configurația cu `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` până la `{{ color15 }}` și restul paletei ca substituenți. De fiecare dată când schimbi temele, fișierul este regenerat cu culorile temei respective.

Există un `alacritty.toml.tpl.sample` complet comentat în acel folder din care poți copia — listează fiecare variabilă pe care o poți folosi, plus modificatorii `_strip` și `_rgb` pentru aplicațiile care își vor culorile fără `#` sau ca RGB zecimal. Șabloanele tale au prioritate față de cele proprii ale Omarchy, așa că poți folosi asta și pentru a suprascrie modul în care este tematizată o aplicație încorporată.

### Distribuirea temei tale

Dacă vrei să-ți distribui tema pentru ca alții să o poată folosi, trebuie să o pui pe un server git public, precum GitHub. Apoi oamenii o pot instala folosind _Instalare > Stil > Temă_ în meniul Omarchy, folosind acel URL. Este recomandat să urmezi convenția de denumire `omarchy-[themename]-theme`, deoarece tema va fi afișată corect ca doar `[themename]` în meniul de selectare a temelor după instalare.

Acel `[themename]` rămas devine numele directorului temei, așa că trebuie să fie unul pe care Omarchy îl poate plimba în siguranță: trebuie să înceapă cu o literă, o cifră sau un caracter de subliniere, iar restul poate conține litere, cifre, `.`, `_`, `+` și `-`. Majusculele sunt transformate în minuscule pentru tine, dar orice altceva — un spațiu, un ghilimeu, un caracter non-englez — este refuzat la momentul instalării, în loc să fie transformat într-un nume de director. Așa că `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` și `omarchy-c++-theme` se instalează toate fără probleme.

Reține că, odată instalată dintr-un repo, orice `.lua`, configurație de terminal sau `vscode.json` pe care o furnizează este eliminat, așa că nu construi tema în jurul acestora.

Poți avea tema ta adăugată pe [pagina de teme suplimentare](https://omarchy.org/themes/) trimițând un pull request către [repo-ul omarchy-site](https://github.com/omacom-io/omarchy-site).
