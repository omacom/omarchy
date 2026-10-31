# Dotfiles

Omarchy este configurat în principal prin așa-numitele dotfiles care se află în `~/.config`. Acelea sunt considerate fișierele tale, pentru modificările tale. Fișierele care se află în `/usr/share/omarchy` aparțin lui Omarchy însuși și nu ar trebui să te bagi prin ele. Dacă trebuie să schimbi ceva în `/usr/share/omarchy`, ar trebui să suprascrii valoarea în `~/.config` în schimb.

Configurațiile cheie pot fi editate direct din meniul Omarchy (`Super + Space`), cum ar fi _Setup > Keybindings_, _Setup > Input_ și _Setup > Config > [file]_. Când o faci în acest fel, orice proces care trebuie repornit după editarea configurațiilor va fi repornit automat după ce închizi editorul (Neovim în mod implicit — `:wq`, ține minte! — dar îl poți schimba prin _Setup > Defaults > Editor_).

Iată o listă cu fișierele cheie din `~/.config` și ce controlează fiecare:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Configurația principală Hyprland. Încarcă valorile implicite Omarchy, plus fișierele tale de suprascriere de mai jos. [Află mai multe despre configurațiile Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Legăturile tale de taste proprii și suprascrierile valorilor implicite. |
| `~/.config/hypr/monitors.lua` | Setări ale monitorului pe care panoul pentru monitoare nu le acoperă, cum ar fi rotația, moduri suplimentare sau menținerea unui monitor oprit. |
| `~/.config/hypr/input.lua` | Controlează dispunerea tastaturii, mouse-ul și setările pentru trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controlează spațierea, marginile, animațiile și restul aspectului. |
| `~/.config/hypr/autostart.lua` | Controlează procesele suplimentare pornite odată cu sesiunea. |
| `~/.config/omarchy/shell.json` | Controlează shell-ul Omarchy: poziția barei, dispunerea și widgeturile, plus economizorul de ecran, blocarea și timpii de inactivitate. |
| `~/.config/foot/foot.ini` | Controlează terminalul tău (foot este cel implicit). |
| `~/.XCompose` | Definește emoji-urile pentru acces rapid și autocompletarea numelui/e-mailului. Asigură-te că rulezi `omarchy-restart-xcompose` după ce faci modificări. |

Dacă ajungi să faci multe modificări ca să-ți personalizezi propria configurare, e o idee bună să faci backup la toate aceste dotfiles. [Stow este o modalitate grozavă de a face asta](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pornirea propriilor aplicații odată cu sesiunea

Dacă vrei ca ceva să ruleze de fiecare dată când te autentifici — un daemon de sincronizare, o aplicație de chat, propriul tău script — pune-l în `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Asta pornește comanda ca parte a sesiunii, așa că este curățată corect când te deconectezi din nou.

### Rularea scripturilor la evenimente de sistem

Omarchy declanșează hook-uri în câteva momente, iar tu îți poți agăța propriile scripturi de ele. Ele se află în `~/.config/omarchy/hooks/<event>.d/`, câte un director pentru fiecare eveniment, iar fiecare fișier executabil de acolo rulează când are loc evenimentul:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Imediat după ce a pornit desktopul |
| `post-update` | Spre sfârșitul lui `omarchy update`, după pachete, migrări și repornirea serviciilor, înainte ca instrumentele mise să fie actualizate |
| `pre-refresh-pacman` | După ce `omarchy refresh pacman` resincronizează configurația pachetelor, înainte să actualizeze pachetele; o schimbare a canalului îl rulează în timpul aceluiași pas de refresh |
| `theme-set` | După o schimbare de temă (numele temei în `$1`) |
| `font-set` | După o schimbare de font (numele fontului în `$1`) |
| `battery-low` | Când bateria ajunge la un nivel scăzut (procentul în `$1`) |

Hook-ul `pre-refresh-pacman` este locul unde își au locul depozitele personalizate sau liniile `IgnorePkg`, pentru că rulează înainte de tranzacția pachetelor. Ambele hook-uri legate de actualizare rulează ca utilizatorul tău după ce Omarchy își șterge autorizația sudo din cache, așa că un hook care folosește `sudo` are nevoie de propria autorizație și este posibil să-ți ceară parola.

Fiecare dintre acele directoare conține deja un fișier `.sample` care arată forma unui hook — renunță la `.sample` din nume ca să-l pui la treabă. Ca să instalezi un script scris de tine în altă parte, folosește `omarchy hook install post-boot ~/my-hook`, care îl copiază acolo și îl face executabil.

### Adăugarea propriilor intrări în meniu

Meniul Omarchy (`Super + Space`) poate fi extins cu propriile tale rânduri editând `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Intrările sunt indexate după un id cu puncte, iar id-ul este cel care le plasează în arbore, așa că `personal` apare în meniul rădăcină, iar `personal.notes` apare în interiorul lui:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilizează un id existent și suprascrii rândul respectiv în loc să adaugi unul nou. Fișierul vine cu toate câmpurile disponibile documentate sub formă de comentarii.

### Adăugarea propriilor exporturi de shell, funcții și aliasuri

Omarchy vine cu o grămadă de aliasuri ergonomice și funcții utile, dar este foarte frecvent să vrei să le adaugi pe ale tale. Ar trebui să adaugi aliasurile, funcțiile și exporturile în `~/.bashrc`. Acest fișier nu va fi suprascris la actualizări. Dacă vrei să schimbi oricare dintre valorile implicite Omarchy, le poți adăuga în siguranță și aici.

### Setarea variabilelor de mediu pentru desktop

Exporturile pentru sesiunea desktop își au locul în `~/.config/uwsm/env.d/`. Aceste fișiere rulează înainte să pornească desktopul, așa că o eroare de shell te poate trimite înapoi la ecranul de autentificare. Ține un terminal funcțional deschis în timp ce le editezi. Ca să dezactivezi o suprascriere, mut-o din `env.d`. Vezi [recuperarea autentificării](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) dacă o schimbare te împiedică să te autentifici.

### Modificarea fișierelor interne Omarchy

Uite, acesta este computerul tău. Poți face ce vrei cu el, dar te-aș sfătui să nu faci modificări direct în fișierele din `/usr/share/omarchy`. Ele aparțin pachetului pacman Omarchy, așa că modificările tale vor fi pur și simplu suprascrise la următoarea actualizare. Mai bine suprascrii pur și simplu orice valori implicite care nu-ți plac în folderul `~/.config/*` în schimb.

Poți schimba aproape totul în felul acesta, cum ar fi legăturile de taste implicite. Doar editează `~/.config/hypr/bindings.lua` ca să, să zicem, înlocuiești [Obsidian](https://obsidian.md/) cu [Joplin](https://joplinapp.org/) (instalează cu `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimină legătura existentă înainte să-i adauge înlocuirea. Primește aceleași argumente ca `o.bind`, inclusiv helperi de lansare și opțiuni pentru legături. Folosește `o.bind` ca să adaugi o legătură sau `hl.unbind` ca să elimini una fără să o înlocuiești.

Dacă insiști să umbli prin fișierele interne Omarchy, treci pe canalul dev prin _Update > Channel > Dev_. Asta leagă Omarchy de un checkout git al codului sursă în `~/omarchy`, pe care îl poți modifica după bunul plac. Nimeni de aici nu-ți spune ce să faci!

### Resetarea oricăror modificări

Dacă ajungi să faci harcea-parcea configurațiile, le poți oricând readuce la valorile implicite prin _Update > Config_ în meniul Omarchy. Sau rulând `omarchy reinstall configs` ca să resetezi totul.
