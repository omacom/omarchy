# Crearea propriei teme

Îți poți adăuga propriile teme în `~/.config/omarchy/themes`. Copiază pur și simplu una dintre cele existente ca bază (uită-te în `/usr/share/omarchy/themes`), apoi ajustează după bunul plac. Atâta timp cât tema ta este în acel dosar, va fi inclusă în meniul de selectare a temelor.

Fișierul principal pe care trebuie să îl ajustezi este `colors.toml`. Acesta definește setul de culori care este apoi folosit ca să genereze configurații pentru terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian și întregul shell Omarchy (bara de sus, meniul, notificările, OSD-ul și ecranul de blocare).

Poți folosi și aplicația inclusă Aether ca să creezi o temă nouă folosind o interfață GUI încântătoare ca să te joci cu culorile și să cauți fundaluri. Pornește-o pur și simplu din grila de aplicații de pe `Super + Alt + Space`.

### Ce poate conține o temă instalată

O temă pe care o scrii singur în `~/.config/omarchy/themes` poate conține orice vrei — este mașina ta și fișierul tău, iar Omarchy aplică totul.

O temă pe care o instalezi din depozitul altcuiva cu `omarchy theme install` păstrează tot ce ține de culoare și pierde puținele fișiere care ar rula cod pe mașina ta: orice fișier `.lua`, configurațiile de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) și `vscode.json`. `hyprland.lua` al unei teme este Lua pe care compozitorul tău îl rulează la autentificare, o configurație de terminal numește programul pe care îl pornește terminalul tău, iar `vscode.json` numește o extensie VSCode de instalat. Instalarea temei cuiva ar trebui să schimbe cum arată desktopul tău, niciodată ce rulează.

Tot restul funcționează în continuare exact cum l-a scris autorul temei — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, fundalurile și previzualizările sunt toate păstrate. Doar ce a fost aruncat este regenerat din `colors.toml` pe mașina ta.

Omarchy le deosebește pe cele două după dacă tema are propriul depozit git în interiorul ei, ceea ce `omarchy theme install` lasă în urmă când clonează. Așa că o temă pe care ai scris-o rămâne a ta, iar una pe care ai tras-o de pe internet rămâne culori.

### Mod luminos

Dacă faci o temă cu mod luminos, setează `mode = "light"` în partea de sus a `colors.toml`. Apoi va fi asociată automat cu modul luminos pentru toate aplicațiile. (Vechea metodă de a pune un fișier gol numit `light.mode` în rădăcina temei tale funcționează încă.)

### Culorile pictogramelor

Dacă ai vrea să asortezi culoarea pictogramelor managerului de fișiere cu tema ta, adaugă un fișier numit `icons.theme` cu numele setului de pictograme pe care vrei să îl folosești. Implicit, opțiunile sunt: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagine de deblocare

Temele furnizate cu imaginile `unlock.png` și `preview-unlock.png` vor fi listate sub _Stil > Deblochează_. `unlock.png` al tău ar trebui să fie de preferință un png transparent. Și poți crea imaginea de previzualizare folosind `omarchy plymouth preview`.

### Tematizarea aplicațiilor pe care Omarchy nu le acoperă

Dacă folosești o aplicație care nu este în acea listă, poți învăța Omarchy să o tematizeze singur cu un șablon. Pune un fișier în `~/.config/omarchy/themed/` numit după configurația pe care o generează plus o extensie `.tpl` și scrie configurația cu `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` până la `{{ color15 }}` și restul paletei ca substituenți. De fiecare dată când schimbi temele, fișierul este regenerat cu culorile acelei teme.

Există un `alacritty.toml.tpl.sample` complet comentat în acel dosar din care să copiezi — listează fiecare variabilă pe care o poți folosi, plus modificatorii `_strip` și `_rgb` pentru aplicațiile care își vor culorile fără `#` sau ca RGB zecimal. Șabloanele tale au prioritate față de cele ale Omarchy, așa că poți folosi asta și ca să suprascrii cum este tematizată o aplicație integrată.

### Distribuirea temei tale

Dacă vrei să-ți distribui tema astfel încât alții să o poată folosi, trebuie să o pui pe un server git public, precum GitHub. Apoi oamenii o pot instala folosind _Instalează > Stil > Temă_ în meniul Omarchy, folosind acel URL. Este recomandat să urmezi convenția de denumire `omarchy-[themename]-theme`, deoarece tema se va afișa corect ca doar `[themename]` în meniul de selectare a temelor după instalare.

Acel `[themename]` rămas devine numele directorului temei, așa că trebuie să fie unul pe care Omarchy îl poate transmite în siguranță: trebuie să înceapă cu o literă, o cifră sau un caracter de subliniere, iar restul poate conține litere, cifre, `.`, `_`, `+` și `-`. Majusculele sunt transformate în minuscule pentru tine, dar orice altceva — un spațiu, un ghilimea, un caracter non-englez — este refuzat la momentul instalării, în loc să fie transformat într-un nume de director. Așa că `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` și `omarchy-c++-theme` se instalează toate bine.

Amintește-ți că, odată ce este instalată dintr-un depozit, orice `.lua`, configurație de terminal sau `vscode.json` pe care le livrează este aruncat, așa că nu construi tema în jurul acestora.

Poți avea tema adăugată la [pagina cu teme suplimentare](https://omarchy.org/themes/) trimițând un pull request la [depozitul omarchy-site](https://github.com/omacom-io/omarchy-site).
