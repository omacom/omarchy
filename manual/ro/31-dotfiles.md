# Dotfiles

Omarchy este configurat în principal prin așa-numitele dotfiles care trăiesc în `~/.config`. Acelea sunt considerate fișierele tale, pentru schimbările tale. Fișierele care trăiesc în `/usr/share/omarchy` aparțin Omarchy însuși și n-ar trebui să umbli la ele. Dacă trebuie să schimbi ceva în `/usr/share/omarchy`, ar trebui să suprascrii în schimb valoarea în `~/.config`.

Configurațiile cheie pot fi editate direct din meniul Omarchy (`Super + Space`), cum ar fi _Configurare > Monitoare_, _Configurare > Scurtături_, _Configurare > Input_ și _Configurare > Configurare > [file]_. Când o faci așa, orice proces care trebuie repornit după editările de configurare va fi repornit automat după ce ieși din editor (Neovim implicit — `:wq`, ține minte! — dar poți schimba asta prin _Configurare > Implicite > Editor_).

Iată o listă a fișierelor cheie din `~/.config` și ce controlează ele:

| Fișier                  | Scop              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Configurația principală Hyprland. Încarcă valorile implicite Omarchy plus fișierele tale de suprascriere de mai jos. [Află mai multe despre configurațiile Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Scurtăturile tale proprii și suprascrierile valorilor implicite. |
| `~/.config/hypr/monitors.lua` | Controlează monitoarele, rezoluția și poziția ta. |
| `~/.config/hypr/input.lua` | Controlează aranjarea tastaturii, mouse-ul și setările touchpadului. |
| `~/.config/hypr/looknfeel.lua` | Controlează spațiile, bordurile, animațiile și restul aspectului. |
| `~/.config/hypr/autostart.lua` | Controlează procesele suplimentare pornite cu sesiunea. |
| `~/.config/omarchy/shell.json` | Controlează shell-ul Omarchy: poziția barei, aranjarea și widgeturile, plus economizorul de ecran, blocarea și temporizările de inactivitate. |
| `~/.config/foot/foot.ini` | Controlează terminalul tău (foot este implicit). |
| `~/.XCompose` | Definește emoji-urile tale cu acces rapid și completarea automată de nume/e-mail. Asigură-te că rulezi `omarchy-restart-xcompose` după ce faci schimbări. |

Dacă ajungi să faci multe schimbări ca să-ți ajustezi propria configurație, este o idee bună să faci copii de rezervă ale tuturor acestor dotfiles. [Stow este o cale excelentă de a face asta](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Pornirea propriilor aplicații odată cu sesiunea

Dacă vrei ca ceva să ruleze de fiecare dată când te conectezi — un demon de sincronizare, o aplicație de chat, propriul tău script — pune-l în `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Asta pornește comanda ca parte a sesiunii, așa că este curățată corespunzător când te deconectezi din nou.

### Rularea scripturilor la evenimente de sistem

Omarchy declanșează cârlige în câteva momente, iar tu îți poți agața propriile scripturi de ele. Ele trăiesc în `~/.config/omarchy/hooks/<event>.d/`, un director per eveniment, și fiecare fișier executabil de acolo rulează când evenimentul se întâmplă:

| Eveniment | Când rulează |
| ----- | ------------ |
| `post-boot` | Imediat după ce desktopul a pornit |
| `post-update` | Aproape de sfârșitul lui `omarchy update`, după pachete, migrări și reporniri de servicii, înainte ca instrumentele mise să fie actualizate |
| `pre-refresh-pacman` | După ce `omarchy refresh pacman` resincronizează configurația pachetelor, înainte să actualizeze pachetele; o schimbare de canal îl rulează în timpul aceluiași pas de reîmprospătare |
| `theme-set` | După o schimbare de temă (numele temei în `$1`) |
| `font-set` | După o schimbare de font (numele fontului în `$1`) |
| `battery-low` | Când bateria ajunge scăzută (procentul în `$1`) |

Cârligul `pre-refresh-pacman` este locul unde aparțin depozitele personalizate sau liniile `IgnorePkg`, deoarece rulează înaintea tranzacției de pachete. Ambele cârlige legate de actualizare rulează ca utilizatorul tău, după ce Omarchy își șterge autorizarea sudo din cache, așa că un cârlig care folosește `sudo` are nevoie de propria lui autorizare și ți-ar putea cere parola.

Fiecare dintre acele directoare deține deja un fișier `.sample` care arată forma unui cârlig — scoate `.sample` din nume ca să-l pui la muncă. Ca să instalezi un script pe care l-ai scris în altă parte, folosește `omarchy hook install post-boot ~/my-hook`, ceea ce îl copiază și îl face executabil.

### Adăugarea propriilor intrări în meniu

Meniul Omarchy (`Super + Space`) poate fi extins cu propriile rânduri editând `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Intrările sunt identificate printr-un id cu puncte, iar id-ul este ce le plasează în arbore, așa că `personal` apare în meniul rădăcină, iar `personal.notes` apare în interiorul lui:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilizează un id existent și suprascrii acel rând, în loc să adaugi unul nou. Fișierul vine cu toate câmpurile disponibile documentate ca și comentarii.

### Adăugarea propriilor exporturi de shell, funcții și aliasuri

Omarchy vine cu o mulțime de aliasuri ergonomice și funcții utile, dar este foarte obișnuit să vrei să-ți adaugi propriile tale. Ar trebui să adaugi atât aliasuri, cât și funcții și exporturi în `~/.bashrc`. Acest fișier nu va fi suprascris la actualizări. Dacă vrei să schimbi oricare dintre valorile implicite Omarchy, le poți adăuga și aici în siguranță.

### Schimbarea fișierelor interne Omarchy

Uite, acesta este computerul tău. Poți face orice vrei cu el, dar te-aș sfătui să nu faci schimbări direct în fișierele din `/usr/share/omarchy`. Ele aparțin pachetului pacman Omarchy, așa că schimbările tale vor fi pur și simplu suprascrise la următoarea actualizare. Ești mai câștigat pur și simplu suprascriind orice valori implicite nu-ți plac în folderul `~/.config/*`.

Poți schimba cam totul în felul acesta, cum ar fi scurtăturile implicite. Editează pur și simplu `~/.config/hypr/bindings.lua` ca să, să zicem, înlocuiești [Obsidian](https://obsidian.md/) cu [Joplin](https://joplinapp.org/) (instalează cu `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimină legătura existentă înainte să-și adauge înlocuirea. Ia aceleași argumente ca `o.bind`, inclusiv ajutoare de lansare și opțiuni de legare. Folosește `o.bind` ca să adaugi o legătură sau `hl.unbind` ca să elimini una fără să o înlocuiești.

Dacă insiști să te joci cu fișierele interne Omarchy, treci pe canalul dev prin _Actualizează > Channel > Dev_. Asta leagă Omarchy de o copie git a codului sursă din `~/omarchy`, pe care ești liber să o schimbi după pofta inimii. Nu-i nimeni aici să-ți spună ce să faci!

### Resetarea oricăror schimbări

Dacă ajungi să faci o harababură din configurații, le poți reveni întotdeauna la valorile implicite prin _Actualizează > Config_ în meniul Omarchy. Sau rulând `omarchy reinstall configs` ca să resetezi totul.
