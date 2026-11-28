# Cum să-ți faci propria temă

Poți adăuga propriile tale teme în `~/.config/omarchy/themes`. Copiază pur și simplu una dintre cele existente ca bază (le găsești în `/usr/share/omarchy/themes`), apoi ajusteaz-o după bunul plac. Atât timp cât tema ta se află în acel dosar, va fi inclusă în meniul de selectare a temelor.

Fișierul principal pe care trebuie să-l ajustezi este `colors.toml`. Acesta definește setul de culori folosit apoi pentru a genera configurații pentru terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplicațiile Qt, iluminarea de fundal a tastaturii, metoda de introducere, selectorul pentru partajarea ecranului, pictogramele aplicațiilor, câteva instrumente AI (Claude, Pi, Hermes, T3 Code, Herdr) și întregul shell Omarchy (bara de sus, meniul, notificările, OSD și ecranul de blocare).

Poți folosi și aplicația Aether inclusă pentru a crea o temă nouă folosind o interfață GUI plăcută, în care să te joci cu culorile și să cauți imagini de fundal. Pornește-o pur și simplu din grila de aplicații cu `Super + Alt + Space`.

### Ce poate conține o temă instalată

O temă pe care o scrii tu însuți în `~/.config/omarchy/themes` poate conține orice dorești — este mașina ta și fișierul tău, iar Omarchy aplică tot.

O temă pe care o instalezi din depozitul altcuiva cu `omarchy theme install` păstrează tot ce ține de culoare și pierde câteva fișiere care ar rula cod pe mașina ta: orice fișier `.lua`, configurațiile de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) și `vscode.json`. Fișierul `hyprland.lua` al unei teme este Lua pe care compositorul tău îl rulează la autentificare, o configurație de terminal numește programul pe care îl pornește terminalul tău, iar `vscode.json` numește o extensie VSCode de instalat. Instalarea temei cuiva ar trebui să schimbe cum arată desktopul tău, niciodată ce rulează pe el.

Tot restul funcționează în continuare exact așa cum l-a scris autorul temei — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, imaginile de fundal și previzualizările sunt toate păstrate. Doar ce a fost eliminat este regenerat din `colors.toml` pe mașina ta.

Omarchy le deosebește după dacă tema are propriul său depozit git în interior, ceea ce `omarchy theme install` lasă în urmă atunci când clonează. Așa că o temă scrisă de tine rămâne a ta, iar una luată de pe internet rămâne doar culori.

### Modul luminos

Dacă faci o temă cu mod luminos, setează `mode = "light"` în partea de sus a fișierului tău `colors.toml`. Apoi va fi asociată automat cu modul luminos pentru toate aplicațiile. (Merge în continuare și vechea metodă de a plasa un fișier gol numit `light.mode` în rădăcina temei tale.)

### Ecranele de pornire și de autentificare

Ecranul care îți cere parola unității la pornire și ecranul de autentificare desenează logo-ul Omarchy în culoarea `accent` a temei tale pe `background`-ul ei, cu câmpul pentru parolă în `foreground` și `red` pentru o parolă greșită. Nu trebuie să incluzi nimic în plus pentru ele: Omarchy nu mai folosește fișierele `unlock.png` sau `preview-unlock.png` ale unei teme. Pe Mac-urile cu Apple Silicon, ecranul pentru parola unității păstrează aspectul implicit Omarchy, indiferent de temă.

### Tematizarea aplicațiilor pe care Omarchy nu le acoperă

Dacă folosești o aplicație care nu este în lista aceea, poți învăța singur Omarchy să o tematizeze cu un șablon. Plasează un fișier în `~/.config/omarchy/themed/` numit după configurația pe care o generează, plus extensia `.tpl`, și scrie configurația folosind `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` până la `{{ color15 }}` și restul paletei ca substituenți. De fiecare dată când schimbi tema, fișierul este regenerat cu culorile temei respective.

Există în acel dosar un fișier `alacritty.toml.tpl.sample` complet comentat, din care poți copia — el enumeră fiecare variabilă pe care o poți folosi, plus modificatorii `_strip` și `_rgb` pentru aplicațiile care își vor culorile fără `#` sau ca RGB zecimal. Șabloanele tale au prioritate față de cele proprii ale Omarchy, așa că poți folosi asta și pentru a suprascrie modul în care este tematizată o aplicație integrată.

### Distribuirea temei tale

Dacă vrei să-ți distribui tema astfel încât alții să o poată folosi, trebuie să o pui pe un server git public, cum ar fi GitHub. Apoi oamenii o pot instala folosind _Install > Style > Theme_ în meniul Omarchy, folosind acel URL. Se recomandă să urmezi convenția de denumire `omarchy-[themename]-theme`, deoarece tema va fi afișată corect doar ca `[themename]` în meniul de selectare a temelor după instalare.

Restul de `[themename]` devine numele directorului temei, așa că trebuie să fie unul pe care Omarchy îl poate vehicula în siguranță: trebuie să înceapă cu o literă, o cifră sau un underscore, iar restul poate conține litere, cifre, `.`, `_`, `+` și `-`. Majusculele sunt transformate în minuscule pentru tine, dar orice altceva — un spațiu, un ghilimeu, un caracter non-englez — este refuzat la instalare, în loc să fie transformat într-un nume de director. Așa că `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` și `omarchy-c++-theme` se instalează toate fără probleme.

Reține că, odată instalată dintr-un depozit, orice fișier `.lua`, configurație de terminal sau `vscode.json` pe care îl include este eliminat, așa că nu construi tema în jurul acestora.

Poți avea tema ta adăugată pe [pagina cu teme suplimentare](https://omarchy.org/themes/) trimițând un pull request către [depozitul omarchy-site](https://github.com/omacom-io/omarchy-site).
