# Trikčių šalinimas

### Sugadinau sistemą su atnaujinimu!

Pirmiausia pabandykite [atstatyti sistemą](47-system-snapshots.md) į versiją, buvusią prieš paskutinį atnaujinimą. Jei tai nepadeda, naudokite `omarchy-debug`, kad pasidalytumėte savo problema kanale #omarchy-help platformoje Discord. O jei ir tai nepadeda, naudodami `omarchy-reinstall` galite iš naujo įdiegti numatytąsias konfigūracijas ir paketus.

### Kodėl kai kurios programos mano ekrane tokios didelės?

Omarchy daro prielaidą, kad naudojamas 2x didelės raiškos ekranas, todėl nustato `GDK_SCALE` reikšmę 2, kol monitoriaus skydelyje nepasirinksite mastelio. Jei naudojate 1x ekraną, o GTK arba X11 programos rodomos per didelės, monitoriaus skydelyje jam pasirinkite 1x arba pridėkite `hl.env("GDK_SCALE", "1")` į `~/.config/hypr/monitors.lua` (o tada iš naujo paleiskite visas per dideles programas). Žr. [vadovą apie monitorius](33-monitors.md).

Programoje Spotify galite naudoti `Ctrl + Minus`, kad sumažintumėte sąsają (ir `Ctrl + Plus`, kad ją padidintumėte).

### Kodėl nustojo veikti visi mano Super klavišo susiejimai?

Kai kuriuose ASUS ROG ir TUF nešiojamuosiuose kompiuteriuose `Fn + Super` yra lengvai nepastebimas derinys, kuris perjungia aparatinės programinės įrangos Windows klavišo užraktą (skirtą žaidžiant, kad netyčia neišeitumėte iš žaidimo). Ekrane nieko nematyti, kad tai įvyko. Kol užraktas įjungtas, Super nieko nesiunčia — todėl kiekvienas Omarchy susiejimas, kuriame naudojamas Super, tiesiog nustoja veikti, ir atrodo, kad sugedo Hyprland.

Prieš kapstydamiesi po `~/.config/hypr/` vieną kartą paspauskite `Fn + Super`, o jei tai nesugrąžina Super, paspauskite dar kartą, kad nepaliktumėte įjungto užrakto. Tai nėra Fn-lock, kuris keičia tik tai, ką daro F klavišų eilutė.

### Mano Wi-Fi, Bluetooth, garsas arba jutiklinė plokštė tiesiog nustojo veikti

Prieš perkraudami pabandykite atskirai iš naujo paleisti sutrikusią posistemę. Omarchy meniu _Update > Hardware_ yra Wi-Fi, Bluetooth, Audio ir Trackpad, o vienos iš jų perkrovimas išsprendžia daugumą situacijų „prieš penkias minutes dar veikė“ — Bluetooth ausines, kurios nebesijungia iš naujo, jutiklinę plokštę, kuri nustojo veikti po užmigdymo, garsą, dingusį atjungus monitorių.

### Kodėl negroja mano išoriniai garsiakalbiai?

Tikriausiai todėl, kad jie nenustatyti kaip pagrindinė išvestis. Spustelėkite garsiakalbio piktogramą dešinėje juostos pusėje ir atsidarys garsumo iššokantis langas, kuriame galėsite pasirinkti išvesties įrenginį (ir taip pat reguliuoti atskirų programų garsumą).

### Mano nešiojamojo kompiuterio garsiakalbiai skamba keistai

Kai kuriuose nešiojamuosiuose kompiuteriuose Omarchy automatiškai pritaiko garsiakalbių derinimą, koreguojantį integruotų garsiakalbių dažnių atsaką. `omarchy audio tuning status` parodo, ar toks derinimas aktyvus jūsų kompiuteryje, o `omarchy audio tuning off` jį išjungia, jei verčiau norite girdėti neapdorotą garsiakalbių garsą.

### Kodėl negaliu prisijungti arba naudoti sudo su savo slaptažodžiu?

Tikriausiai per daug kartų neteisingai jį įvedėte ir buvote užblokuoti. Jei tai vyksta užrakto ekrane, galite paspausti `CTRL + ALT + F2`, kad paleistumėte naują TTY, kuriame galite prisijungti kaip root, tada paleiskite `faillock --reset --user [your-username]`. Tai atstatys užblokavimą ir galėsite tęsti.

### Kodėl nerodomi mano 1Password autorizacijos raginimai, skirti 1Password SSH Agent / CLI?

Tai gali nutikti dėl 2 priežasčių:

Kad būtų rodomas išsamus patvirtinimo raginimas, turi būti įjungta Settings > Advanced > Use Hardware Acceleration. _Pastaba: kad tai pradėtų veikti, reikia perkrauti kompiuterį._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Arba jei nuo įkrovos nepaleidote 1Password, raginimas nebus rodomas.
