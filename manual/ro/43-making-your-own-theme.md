# Fă-ți propria temă

Poți adăuga propriile teme în `~/.config/omarchy/themes`. Pur și simplu copiază una dintre cele existente ca bază (le găsești în `/usr/share/omarchy/themes`), apoi ajusteaz-o după bunul plac. Atâta timp cât tema ta se află în acel folder, va fi inclusă în meniul de selectare a temelor.

Principalul fișier pe care trebuie să-l ajustezi este `colors.toml`. Acesta definește setul de culori folosit apoi pentru a genera configurațiile pentru terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian și întregul shell Omarchy (bara de sus, meniul, notificările, OSD și ecranul de blocare).

Poți folosi și aplicația inclusă Aether pentru a crea o temă nouă, folosind o interfață GUI plăcută pentru a te juca cu culorile și a căuta fundaluri. Pur și simplu pornește-o din grila de aplicații cu `Super + Alt + Space`.

### Ce poate conține o temă instalată

O temă pe care o scrii tu în `~/.config/omarchy/themes` poate conține orice dorești — este mașina ta și fișierul tău, iar Omarchy aplică totul.

O temă pe care o instalezi din repo-ul altcuiva cu `omarchy theme install` păstrează tot ce ține de culori și pierde puținele fișiere care ar rula cod pe mașina ta: orice fișier `.lua`, configurațiile de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) și `vscode.json`. `hyprland.lua` al unei teme este cod Lua pe care compositor-ul tău îl rulează la autentificare, o configurație de terminal numește programul pe care îl pornește terminalul tău, iar `vscode.json` numește o extensie VSCode de instalat. Instalarea temei altcuiva ar trebui să schimbe cum arată desktopul tău, niciodată ce rulează pe el.

Tot restul funcționează în continuare exact cum a scris autorul temei — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, fundalurile și previzualizările sunt toate păstrate. Doar ce a fost eliminat este regenerat din `colors.toml` pe mașina ta.

Omarchy le deosebește pe cele două după dacă tema are propriul repo git în interiorul ei, ceea ce lasă în urmă `omarchy theme install` atunci când clonează. Așa că o temă scrisă de tine rămâne a ta, iar una luată de pe internet rămâne doar culori.

### Modul luminos

Dacă faci o temă cu mod luminos, setează `mode = "light"` la începutul fișierului tău `colors.toml`. Apoi va fi asociată automat cu modul luminos pentru toate aplicațiile. (Vechea metodă de a plasa un fișier gol numit `light.mode` în rădăcina temei tale funcționează în continuare.)

### Culorile pictogramelor

Dacă dorești să potrivești cromatic pictogramele managerului de fișiere cu tema ta, adaugă un fișier numit `icons.theme` cu numele setului de pictograme pe care vrei să-l folosești. În mod implicit, opțiunile sunt: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imaginea de deblocare

Temele furnizate cu imaginile `unlock.png` și `preview-unlock.png` vor fi listate sub _Aspect > Deblocare_. `unlock.png` ar trebui să fie, de preferință, un png transparent. Iar imaginea de previzualizare o poți crea folosind `omarchy plymouth preview`.

### Tematizarea aplicațiilor pe care Omarchy nu le acoperă

Dacă folosești o aplicație care nu se află în acea listă, poți învăța singur Omarchy să o tematizeze cu un șablon. Plasează un fișier în `~/.config/omarchy/themed/` numit după configurația pe care o generează plus extensia `.tpl` și scrie configurația cu `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` până la `{{ color15 }}` și restul paletei ca substituenți. De fiecare dată când schimbi temele, fișierul este regenerat cu culorile acelei teme.

Există un `alacritty.toml.tpl.sample` complet comentat în acel folder, din care poți copia — listează fiecare variabilă pe care o poți folosi, plus modificatorii `_strip` și `_rgb` pentru aplicațiile care își vor culorile fără `#` sau ca RGB zecimal. Șabloanele tale au prioritate față de cele ale Omarchy, așa că poți folosi asta și pentru a suprascrie modul în care este tematizată o aplicație încorporată.

### Distribuirea temei tale

Dacă vrei să-ți distribui tema pentru a o putea folosi și alții, trebuie să o pui pe un server git public, precum GitHub. Apoi oamenii o pot instala folosind _Instalare > Stil > Temă_ în meniul Omarchy, folosind acel URL. Se recomandă să urmezi convenția de denumire `omarchy-[themename]-theme`, deoarece tema va apărea corect ca doar `[themename]` în meniul de selectare a temelor după instalare.

Acel `[themename]` rămas devine numele directorului temei, așa că trebuie să fie unul pe care Omarchy să-l poată transmite în siguranță: trebuie să înceapă cu o literă, o cifră sau un caracter de subliniere, iar restul poate conține litere, cifre, `.`, `_`, `+` și `-`. Majusculele sunt convertite în minuscule pentru tine, dar orice altceva — un spațiu, o ghilimea, un caracter non-englez — este refuzat la instalare, în loc să fie transformat într-un nume de director. Așa că `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` și `omarchy-c++-theme` se instalează toate fără probleme.

Ține minte că, odată instalată dintr-un repo, orice `.lua`, configurație de terminal sau `vscode.json` pe care o livrează este eliminat, așa că nu-ți construi tema în jurul acestora.

Poți face ca tema ta să fie adăugată la [pagina cu teme suplimentare](https://omarchy.org/themes/) trimițând un pull request către [repo-ul omarchy-site](https://github.com/omacom-io/omarchy-site).
