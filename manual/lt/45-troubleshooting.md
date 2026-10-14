# Trikčių šalinimas

### Sugadinau sistemą naujinimu!

Pirmiausia pabandyk [atkurti savo sistemą](47-system-snapshots.md) į versiją prieš pastarąjį naujinimą. Jei tai neveikia, naudok `omarchy-debug`, kad pasidalytum savo problema #omarchy-help Discord. O jei visa tai nepavyksta, gali iš naujo įdiegti numatytąsias konfigūracijas ir paketus naudodamas `omarchy-reinstall`.

### Kodėl kai kurios programos mano ekrane tokios didelės?

Omarchy daro prielaidą, kad ekranas yra 2x didelės raiškos, todėl reikia `GDK_SCALE` nustatyti į 2 faile `~/.config/hypr/monitors.lua`. Bet jei esi 1x ekrane, gali `local omarchy_gdk_scale = 2` pakeisti į 1 (tada iš naujo paleisk bet kurią per didelę programą). Žr. [žinyną apie monitorius](33-monitors.md).

Spotify atveju gali naudoti `Ctrl + Minus`, kad sumažintum UI (ir `Ctrl + Plus`, kad ją padidintum).

### Mano Wi-Fi, Bluetooth, garsas ar jutiklinis kilimėlis tiesiog nustojo veikti

Prieš perkraudamas, pabandyk kaltąją posistemę iš naujo paleisti atskirai. _Atnaujinti > Aparatinė įranga_ Omarchy meniu turi Wi-Fi, Bluetooth, Garsą ir Jutiklinį kilimėlį, o vienos iš jų perkrovimas ištaiso daugumą situacijų „prieš penkias minutes veikė" — Bluetooth ausines, kurios neprisijungia iš naujo, jutiklinį kilimėlį, kuris po pristabdymo mirė, garsą, kuris dingo atjungus monitorių.

### Kodėl mano išoriniai garsiakalbiai negroja?

Tikriausiai todėl, kad jie nenustatyti kaip pagrindinė išvestis. Spustelėk garsiakalbio piktogramą dešinėje juostos pusėje ir ji atidarys garso iššokantį langą, kur gali pasirinkti išvesties įrenginį (ir taip pat maišyti kiekvienos programos garsus atskirai).

### Mano nešiojamojo garsiakalbiai skamba keistai

Kai kuriuose nešiojamuosiuose Omarchy automatiškai pritaiko garsiakalbių derinimą, kuris pataiso įmontuotų garsiakalbių dažnių atsaką. `omarchy audio tuning status` pasako, ar tavo kompiuteryje kuris nors aktyvus, o `omarchy audio tuning off` jį išjungia, jei mieliau garsiakalbius girdi neapdorotus.

### Kodėl negaliu prisijungti ar sudo su savo slaptažodžiu?

Tikriausiai jį per daug kartų įvedei neteisingai ir buvai užrakintas. Jei tai vyksta užrakinimo ekrane, gali paspausti `CTRL + ALT + F2`, kad paleistum naują TTY, kur gali prisijungti kaip root, tada paleisk `faillock --reset --user [your-username]`. Tai atstatys užrakinimą ir būsi pasiruošęs.

### Kodėl mano 1Password autorizavimo raginimai 1Password SSH Agent / CLI nepasirodo?

Tai gali atsitikti dėl 2 priežasčių:

Kad atsirastų išsamus patvirtinimo raginimas, Settings > Advanced > Use Hardware Acceleration turi būti įjungta. _Pastaba: kad pradėtų veikti, reikia perkrovimo._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Arba jei nuo įkrovos nepaleidai 1Password, raginimas nepasirodys.
