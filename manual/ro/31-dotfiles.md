# Dotfiles

Omarchy se configurează în principal prin așa-numitele dotfiles care se află în `~/.config`. Acestea sunt considerate fișierele tale, pentru modificările tale. Fișierele care se află în `/usr/share/omarchy` aparțin chiar Omarchy și n-ar trebui să te atingi de ele. Dacă trebuie să schimbi ceva în `/usr/share/omarchy`, ar trebui în schimb să suprascrii valoarea în `~/.config`.

Configurațiile principale pot fi editate direct din meniul Omarchy (`Super + Space`), cum ar fi _Setup > Keyboard > Keybindings_, _Setup > Input_ și _Setup > Config > [file]_. Când faci asta în acest fel, orice proces care trebuie repornit după modificarea configurațiilor va fi repornit automat după ce închizi editorul (Neovim în mod implicit — `:wq`, ține minte! — dar îl poți schimba din _Setup > Defaults > Editor_).

Iată o listă cu fișierele principale din `~/.config` și ce controlează fiecare:

| Fișier                  | Scop              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Configurația principală Hyprland. Încarcă setările implicite Omarchy plus fișierele tale de suprascriere de mai jos. [Află mai multe despre configurațiile Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Combinațiile tale de taste și suprascrierile celor implicite. |
| `~/.config/hypr/monitors.lua` | Setări pentru monitor pe care panoul pentru monitoare nu le acoperă, cum ar fi rotația, moduri suplimentare sau menținerea unui monitor oprit. |
| `~/.config/hypr/input.lua` | Controlează dispunerea tastaturii, mouse-ul și setările trackpadului. |
| `~/.config/hypr/looknfeel.lua` | Controlează spațiile, marginile, animațiile și restul aspectului. |
| `~/.config/hypr/autostart.lua` | Controlează procesele suplimentare pornite odată cu sesiunea. |
| `~/.config/omarchy/shell.json` | Controlează shell-ul Omarchy: poziția barei, dispunerea și widgeturile, plus timpii pentru screensaver, blocare și inactivitate. |
| `~/.config/foot/foot.ini` | Controlează terminalul tău (foot este cel implicit). |
| `~/.XCompose` | Definește emoji-urile tale cu acces rapid și completarea automată pentru nume/email. Asigură-te că rulezi `omarchy-restart-xcompose` după ce faci modificări. |

Dacă ajungi să faci multe modificări ca să-ți ajustezi propria configurație, e o idee bună să faci backup la toate aceste dotfiles. [Stow e o modalitate excelentă de a face asta](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pornirea propriilor aplicații odată cu sesiunea

Dacă vrei ca ceva să ruleze de fiecare dată când te autentifici — un daemon de sincronizare, o aplicație de chat, un script al tău — pune-l în `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Asta pornește comanda ca parte a sesiunii, așa că este curățată corect când te deconectezi din nou.

### Rularea scripturilor la evenimente de sistem

Omarchy declanșează hook-uri în câteva momente, iar tu îți poți agăța propriile scripturi de ele. Ele se află în `~/.config/omarchy/hooks/<event>.d/`, câte un director per eveniment, și fiecare fișier executabil de acolo rulează când are loc evenimentul:

| Eveniment | Când rulează |
| ----- | ------------ |
| `post-boot` | Imediat după ce a pornit desktopul |
| `post-update` | Spre sfârșitul lui `omarchy update`, după pachete, migrări și repornirea serviciilor, înainte ca instrumentele mise să fie actualizate |
| `pre-refresh-pacman` | După ce `omarchy refresh pacman` resincronizează configurația pachetelor, înainte să actualizeze pachetele; o schimbare de canal îl rulează în același pas de refresh |
| `theme-set` | După o schimbare de temă (numele temei în `$1`) |
| `font-set` | După o schimbare de font (numele fontului în `$1`) |
| `battery-low` | Când bateria este descărcată (procentajul în `$1`) |

Hook-ul `pre-refresh-pacman` este locul unde aparțin depozitele personalizate sau liniile `IgnorePkg`, fiindcă rulează înainte de tranzacția pachetelor. Ambele hook-uri legate de actualizare rulează ca utilizatorul tău după ce Omarchy își șterge autorizația sudo din cache, așa că un hook care folosește `sudo` are nevoie de propria autorizație și s-ar putea să-ți ceară parola.

Fiecare dintre aceste directoare conține deja un fișier `.sample` care arată forma unui hook — șterge `.sample` din nume ca să-l pui la treabă. Ca să instalezi un script pe care l-ai scris în altă parte, folosește `omarchy hook install post-boot ~/my-hook`, care îl copiază acolo și îl face executabil.

### Adăugarea propriilor intrări în meniu

Meniul Omarchy (`Super + Space`) poate fi extins cu propriile tale rânduri editând `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Intrările au ca cheie un id cu puncte, iar id-ul este cel care le plasează în arbore, așa că `personal` apare în meniul rădăcină și `personal.notes` apare în interiorul lui:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilizezi un id existent și suprascrii rândul respectiv în loc să adaugi unul nou. Fișierul vine cu toate câmpurile disponibile documentate sub formă de comentarii.

### Adăugarea propriilor exporturi, funcții și aliasuri de shell

Omarchy vine cu o mulțime de aliasuri ergonomice și funcții utile, dar este foarte frecvent să vrei să le adaugi pe ale tale. Ar trebui să adaugi atât aliasurile, funcțiile, cât și exporturile în `~/.bashrc`. Acest fișier nu va fi suprascris la actualizări. Dacă vrei să schimbi vreuna dintre setările implicite Omarchy, le poți adăuga în siguranță și aici.

### Setarea variabilelor de mediu pentru desktop

Exporturile pentru sesiunea desktop aparțin în `~/.config/uwsm/env.d/`. Aceste fișiere rulează înainte să pornească desktopul tău, așa că o eroare de shell te poate trimite înapoi la ecranul de autentificare. Ține un terminal funcțional deschis în timp ce le editezi. Ca să dezactivezi o suprascriere, mut-o afară din `env.d`. Vezi [recuperarea autentificării](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) dacă o modificare împiedică autentificarea.

### Modificarea fișierelor interne Omarchy

Uite, acesta este computerul tău. Poți face ce vrei cu el, dar te-aș sfătui să nu modifici direct fișierele din `/usr/share/omarchy`. Ele aparțin pachetului pacman Omarchy, așa că modificările tale vor fi pur și simplu suprascrise la următoarea actualizare. E mai bine să suprascrii pur și simplu în folderul `~/.config/*` orice valori implicite care nu-ți plac.

Poți schimba aproape totul în acest fel, cum ar fi combinațiile de taste implicite. Editează pur și simplu `~/.config/hypr/bindings.lua` ca să, să zicem, înlocuiești [Obsidian](https://obsidian.md/) cu [Joplin](https://joplinapp.org/) (instalează cu `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimină combinația existentă înainte să o adauge pe cea de înlocuire. Primește aceleași argumente ca `o.bind`, inclusiv funcțiile ajutătoare de lansare și opțiunile pentru combinații. Folosește `o.bind` ca să adaugi o combinație sau `hl.unbind` ca să elimini una fără să o înlocuiești.

Dacă insiști să umbli la fișierele interne Omarchy, treci pe canalul dev din _Update > Channel > Dev_. Asta leagă Omarchy de un checkout git al codului sursă din `~/omarchy`, pe care îl poți modifica după pofta inimii. Nu e nimeni aici să-ți spună ce să faci!

### Resetarea oricăror modificări

Dacă ajungi să faci harcea-parcea prin configurații, le poți readuce oricând la valorile implicite din _Update > Config_ în meniul Omarchy. Sau rulând `omarchy reinstall configs` ca să resetezi totul.
