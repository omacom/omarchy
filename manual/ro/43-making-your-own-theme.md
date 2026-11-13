# Crearea propriei teme

Poți adăuga propriile teme în `~/.config/omarchy/themes`. Copiază pur și simplu una dintre cele existente ca bază (uită-te în `/usr/share/omarchy/themes`), apoi ajusteaz-o după pofta inimii. Atât timp cât tema ta se află în acel director, va fi inclusă în meniul de selectare a temei.

Principalul fișier pe care trebuie să îl ajustezi este `colors.toml`. Acesta definește setul de culori folosit apoi pentru a genera configurații pentru terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian și întregul shell Omarchy (bara de sus, meniul, notificările, OSD-ul și ecranul de blocare).

Poți folosi și aplicația Aether inclusă pentru a crea o temă nouă folosind o interfață GUI plăcută, în care să te joci cu culorile și să cauți imagini de fundal. Pornește-o pur și simplu din grila de aplicații cu `Super + Alt + Space`.

### Ce poate conține o temă instalată

O temă pe care o scrii tu însuți în `~/.config/omarchy/themes` poate conține orice dorești — este computerul tău și fișierul tău, iar Omarchy aplică totul.

O temă pe care o instalezi din depozitul altcuiva cu `omarchy theme install` păstrează tot ce ține de culoare și pierde puținele fișiere care ar rula cod pe computerul tău: orice fișier `.lua`, configurațiile de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) și `vscode.json`. Fișierul `hyprland.lua` al unei teme este cod Lua pe care compozitorul tău îl rulează la autentificare, o configurație de terminal numește programul pe care îl pornește terminalul tău, iar `vscode.json` numește o extensie VSCode de instalat. Instalarea temei cuiva ar trebui să schimbe cum arată desktopul tău, niciodată ce rulează pe el.

Tot restul funcționează în continuare exact cum a scris autorul temei — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, imaginile de fundal și previzualizările sunt toate păstrate. Doar ce a fost eliminat este regenerat din `colors.toml` pe computerul tău.

Omarchy le deosebește după dacă tema are propriul depozit git în interiorul ei, ceea ce lasă în urmă `omarchy theme install` atunci când clonează. Așadar, o temă scrisă de tine rămâne a ta, iar una descărcată de pe internet rămâne doar culori.

### Modul luminos

Dacă faci o temă cu mod luminos, setează `mode = "light"` la începutul fișierului tău `colors.toml`. Apoi va fi asociată automat cu modul luminos pentru toate aplicațiile. (Vechea metodă de a lăsa un fișier gol numit `light.mode` în rădăcina temei tale funcționează în continuare.)

### Imaginea de deblocare

Temele furnizate cu imaginile `unlock.png` și `preview-unlock.png` vor fi listate sub _Aspect > Deblocare_. De preferință, fișierul tău `unlock.png` ar trebui să fie un png transparent. Iar imaginea de previzualizare o poți crea folosind `omarchy plymouth preview`.

### Aplicarea temelor la aplicații pe care Omarchy nu le acoperă

Dacă folosești o aplicație care nu se află în lista aceea, poți învăța singur Omarchy să îi aplice o temă cu ajutorul unui șablon. Lasă un fișier în `~/.config/omarchy/themed/` numit după configurația pe care o generează, plus o extensie `.tpl`, și scrie configurația cu `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` până la `{{ color15 }}` și restul paletei ca substituenți. De fiecare dată când schimbi tema, fișierul este regenerat cu culorile temei respective.

În acel director există un fișier `alacritty.toml.tpl.sample` complet comentat, din care poți copia — listează fiecare variabilă pe care o poți folosi, plus modificatorii `_strip` și `_rgb` pentru aplicațiile care își vor culorile fără `#` sau ca RGB zecimal. Șabloanele tale au prioritate față de cele proprii ale Omarchy, așa că poți folosi acest lucru și pentru a suprascrie modul în care o aplicație integrată primește o temă.

### Distribuirea temei tale

Dacă vrei să distribui tema ta pentru ca alții să o poată folosi, trebuie să o pui pe un server git public, cum ar fi GitHub. Apoi oamenii o pot instala folosind _Instalare > Stil > Temă_ în meniul Omarchy, folosind acel URL. Se recomandă să urmezi convenția de denumire `omarchy-[themename]-theme`, deoarece tema se va afișa corect ca doar `[themename]` în meniul de selectare a temei după instalare.

Acel `[themename]` rămas devine numele directorului temei, deci trebuie să fie unul pe care Omarchy îl poate transmite mai departe în siguranță: trebuie să înceapă cu o literă, o cifră sau un caracter de subliniere, iar restul poate conține litere, cifre, `.`, `_`, `+` și `-`. Majusculele sunt transformate pentru tine în litere mici, dar orice altceva — un spațiu, o ghilimea, un caracter non-englez — este refuzat în momentul instalării, nu transformat într-un nume de director. Așadar, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` și `omarchy-c++-theme` se instalează toate fără probleme.

Ține minte că, odată instalată dintr-un depozit, orice fișier `.lua`, configurație de terminal sau `vscode.json` pe care o include este eliminat, așa că nu construi tema în jurul acestora.

Poți face ca tema ta să fie adăugată pe [pagina cu teme suplimentare](https://omarchy.org/themes/) trimițând un pull request către [depozitul omarchy-site](https://github.com/omacom-io/omarchy-site).
