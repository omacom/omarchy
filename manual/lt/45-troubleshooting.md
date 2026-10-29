# Trikčių šalinimas

### Sugadinau sistemą atnaujinimu!

Pirmiausia pabandykite [grąžinti ankstesnę sistemos versiją](47-system-snapshots.md) į tą, kuri buvo prieš pastarąjį atnaujinimą. Jei tai nepadeda, naudokite `omarchy-debug`, kad pasidalytumėte savo problema kanale #omarchy-help „Discord“ serveryje. O jei visa tai nepadeda, galite iš naujo įdiegti numatytąsias konfigūracijas ir paketus naudodami `omarchy-reinstall`.

### Kodėl kai kurios programos mano ekrane tokios didelės?

Omarchy numato 2x didelės raiškos ekraną, todėl reikia, kad `~/.config/hypr/monitors.lua` faile `GDK_SCALE` būtų nustatytas į 2. Bet jei naudojate 1x ekraną, galite pakeisti `local omarchy_gdk_scale = 2` į 1 (o tada iš naujo paleisti visas per dideles programas). Žr. [monitorių vadovą](33-monitors.md).

Programoje Spotify galite naudoti `Ctrl + Minus`, kad sumažintumėte sąsają (ir `Ctrl + Plus`, kad ją padidintumėte).

### Kodėl nustojo veikti visi mano Super klavišo deriniai?

Kai kuriuose ASUS ROG ir TUF nešiojamuosiuose kompiuteriuose `Fn + Super` yra lengvai nepastebimas derinys, kuris perjungia programinės aparatinės įrangos Windows klavišo užraktą (skirtą žaidimams, kad netyčia neišeitumėte iš žaidimo). Ekrane niekas nerodo, kad tai įvyko. Kai užraktas įjungtas, Super apskritai nieko nesiunčia — todėl kiekvienas Omarchy derinys, naudojantis Super, tiesiog nustoja veikti, ir atrodo, kad sugedo Hyprland.

Prieš lįsdami į `~/.config/hypr/`, vieną kartą paspauskite `Fn + Super`, o jei tai negrąžina Super, paspauskite jį dar kartą, kad nepaliktumėte įjungto užrakto. Tai nėra Fn užraktas, kuris keičia tik tai, ką daro F klavišų eilutė.

### Mano Wi-Fi, Bluetooth, garsas arba jutiklinis kilimėlis tiesiog nustojo veikti

Prieš perkraudami kompiuterį, pabandykite iš naujo paleisti tik sutrikusią posistemę. Omarchy meniu _Update > Hardware_ yra Wi-Fi, Bluetooth, Audio ir Trackpad, ir vienos iš jų paleidimas iš naujo išsprendžia daugumą situacijų „prieš penkias minutes veikė“ — Bluetooth ausines, kurios nenori prisijungti iš naujo, jutiklinį kilimėlį, kuris nustojo veikti po pristabdymo, garsą, kuris dingo atjungus monitorių.

### Kodėl mano išoriniai garsiakalbiai negroja?

Tikriausiai todėl, kad jie nenustatyti kaip pagrindinis išvesties įrenginys. Spustelėkite garsiakalbio piktogramą dešinėje juostos pusėje, ir atsidarys garsumo iššokantis langas, kuriame galėsite pasirinkti išvesties įrenginį (ir reguliuoti kiekvienos programos garsumą atskirai).

### Mano nešiojamojo kompiuterio garsiakalbiai skamba keistai

Kai kuriuose nešiojamuosiuose kompiuteriuose Omarchy automatiškai pritaiko garsiakalbių sureguliavimą, kuris pakoreguoja įmontuotų garsiakalbių dažnių atsaką. `omarchy audio tuning status` parodys, ar toks sureguliavimas aktyvus jūsų kompiuteryje, o `omarchy audio tuning off` jį išjungs, jei verčiau norite girdėti neapdorotą garsiakalbių garsą.

### Kodėl negaliu prisijungti ar naudoti sudo su savo slaptažodžiu?

Tikriausiai per daug kartų įvedėte jį neteisingai ir jūsų prieiga buvo užblokuota. Jei tai vyksta užrakto ekrane, galite paspausti `CTRL + ALT + F2`, kad paleistumėte naują TTY, kuriame galėsite prisijungti kaip root, tada paleiskite `faillock --reset --user [your-username]`. Tai atstatys blokavimą, ir galėsite tęsti.

### Kodėl nerodomi mano 1Password autorizacijos raginimai, skirti 1Password SSH Agent / CLI?

Tai gali nutikti dėl 2 priežasčių:

Kad būtų rodomas išsamus patvirtinimo raginimas, Settings > Advanced > Use Hardware Acceleration turi būti įjungta. _Pastaba: Kad tai pradėtų veikti, reikia perkrauti kompiuterį._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Arba jei po kompiuterio paleidimo dar nepaleidote 1Password, raginimas nepasirodys.
