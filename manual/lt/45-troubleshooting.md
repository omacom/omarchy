# Trikčių šalinimas

### Atnaujinimas sugadino mano sistemą!

Pirmiausia pabandykite [atstatyti sistemą](47-system-snapshots.md) į versiją, buvusią prieš neseniai atliktą atnaujinimą. Jei tai nepadeda, naudokite `omarchy-debug`, kad pasidalintumėte problema #omarchy-help kanale Discord serveryje. O jei visa tai nepadės, galite iš naujo įdiegti numatytąsias konfigūracijas ir paketus naudodami `omarchy-reinstall`.

### Kodėl kai kurios programos mano ekrane tokios didelės?

Omarchy pagal numatytuosius nustatymus naudoja 2x didelės raiškos ekraną, todėl `GDK_SCALE` nustato į 2, kol monitoriaus skydelyje nepasirinksite mastelio. Jei naudojate 1x ekraną ir GTK arba X11 programos rodomos per didelės, monitoriaus skydelyje jam pasirinkite 1x arba pridėkite `hl.env("GDK_SCALE", "1")` į `~/.config/hypr/monitors.lua` (o tada iš naujo paleiskite visas per dideles programas). Žr. [vadovą apie monitorius](33-monitors.md).

Spotify programoje sąsają galite sumažinti paspaudę `Ctrl + Minus` (o padidinti – `Ctrl + Plus`).

### Kodėl nustojo veikti visi mano Super klavišo susiejimai?

Kai kuriuose ASUS ROG ir TUF nešiojamuosiuose kompiuteriuose `Fn + Super` yra lengvai nepastebimas derinys, kuris perjungia aparatinės įrangos Windows klavišo užraktą (skirtą žaidimams, kad netyčia neišeitumėte iš žaidimo). Ekrane apie tai niekas nepraneša. Kol užraktas įjungtas, Super nieko neišveda – todėl visi Omarchy susiejimai, kuriuose naudojamas Super, tiesiog nustoja veikti, ir atrodo, kad sugedo Hyprland.

Prieš lįsdami į `~/.config/hypr/`, vieną kartą paspauskite `Fn + Super`, o jei Super neatsiranda, paspauskite dar kartą, kad nepaliktumėte įjungto užrakto. Tai nėra Fn-lock, kuris keičia tik tai, kaip veikia F klavišų eilutė.

### Nustojo veikti mano Wi-Fi, Bluetooth, garsas ar jutiklinė plokštė

Prieš perkraudami, pabandykite iš naujo paleisti tik sugedusį posistemį atskirai. _Update > Hardware_ Omarchy meniu yra Wi-Fi, Bluetooth, Audio ir Trackpad, ir kurio nors iš jų paleidimas iš naujo išsprendžia didžiąją dalį „prieš penkias minutes viskas veikė“ situacijų – Bluetooth ausinių, kurios neprisijungia iš naujo, jutiklinės plokštės, kuri nustojo veikti po pristabdymo, garso, kuris dingo atjungus monitorių.

### Kodėl neveikia mano išoriniai garsiakalbiai?

Tikriausiai todėl, kad jie nenustatyti kaip pagrindinis išvesties įrenginys. Dešinėje juostos pusėje spustelėkite garsiakalbio piktogramą, ir atsivers garsumo iššokantis langas, kuriame galėsite pasirinkti išvesties įrenginį (ir maišyti garsumą atskiroms programoms).

### Mano nešiojamojo kompiuterio garsiakalbiai skamba keistai

Kai kuriuose nešiojamuosiuose kompiuteriuose Omarchy automatiškai pritaiko garsiakalbių derinimą, kuris pakoreguoja įmontuotų garsiakalbių dažninę charakteristiką. `omarchy audio tuning status` parodys, ar toks derinimas aktyvus jūsų kompiuteryje, o `omarchy audio tuning off` jį išjungs, jei verčiau norite klausytis neapdoroto garsiakalbių skambesio.

### Kodėl negaliu prisijungti ar naudoti sudo su slaptažodžiu?

Tikriausiai per daug kartų neteisingai jį įvedėte ir buvote užrakinti. Jei tai nutinka užrakinimo ekrane, galite paspausti `CTRL + ALT + F2`, kad paleistumėte naują TTY, kuriame galėsite prisijungti kaip root, o tada paleisti `faillock --reset --user [your-username]`. Tai atstatys užraktą, ir galėsite tęsti.

### Slaptažodis priimamas, bet grįžtu į prisijungimo ekraną

Sugadintas sesijos aplinkos failas gali sutrukdyti darbalaukiui paleisti net tada, kai slaptažodis teisingas. Ypač verta tai patikrinti po `~/.config/uwsm/env.d/` redagavimo.

Paspauskite `Ctrl + Alt + F2`, prisijunkite įprastu vartotojo vardu ir slaptažodžiu ir patikrinkite dabartinio įkrovimo vartotojo žurnalą:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Ieškokite klaidos, kurioje minimas vienas iš jūsų aplinkos failų, pavyzdžiui, `bad substitution`, iškart prieš pranešimą, kad env išvesties žymė nerasta. Prieš bandydami prisijungti iš naujo, perkelkite tą failą iš `env.d`. Pavyzdžiui, jei klaida mini `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM praleidžia failą su sintaksės klaida, bet kritinė klaida, kuri pasirodo tik failui veikiant, pavyzdžiui, `bad substitution`, vis tiek gali sutrukdyti darbalaukiui paleisti. Sistemos momentinis atstatymas šių failų nesutaiso, nes `/home` negrąžinama.

Kai galėsite prisijungti, pataisykite išsaugotą kopiją prieš grąžindami ją atgal. `sh -n` sugauna sintaksės klaidas nepaleisdamas failo, bet negali pagauti kiekvienos klaidos, atsirandančios jį įkeliant kaip šaltinį. Bandydami pakeitimus laikykite atidarytą veikiantį terminalą.

### Kodėl nerodomi mano 1Password autorizacijos raginimai 1Password SSH Agent / CLI?

Taip gali nutikti dėl 2 priežasčių:

Kad būtų rodomas išsamus patvirtinimo raginimas, turi būti įjungta Settings > Advanced > Use Hardware Acceleration. _Pastaba: kad tai pradėtų veikti, reikia perkrauti kompiuterį._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Arba, jei nuo kompiuterio įkrovimo nepaleidote 1Password, raginimas taip pat nebus rodomas.
