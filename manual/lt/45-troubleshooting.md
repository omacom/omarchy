# Trikčių šalinimas

### Atnaujinimu sugadinau sistemą!

Pirmiausia pabandykite [grąžinti ankstesnę sistemos versiją](47-system-snapshots.md) iš laikotarpio prieš naujausią atnaujinimą. Jei tai nepadeda, naudokite `omarchy-debug`, kad pasidalytumėte savo problema kanale #omarchy-help Discord platformoje. O jei nepavyks ir tai, galite iš naujo įdiegti numatytąsias konfigūracijas ir paketus naudodami `omarchy-reinstall`.

### Kodėl kai kurios programos mano ekrane tokios didelės?

Omarchy daro prielaidą, kad naudojate 2x didelės raiškos ekraną, todėl nustato `GDK_SCALE` reikšmę 2, kol monitoriaus skydelyje nepasirinksite mastelio. Jei naudojate 1x ekraną, o GTK arba X11 programos rodomos per didelės, monitoriaus skydelyje jam pasirinkite 1x arba į `~/.config/hypr/monitors.lua` įrašykite `hl.env("GDK_SCALE", "1")` (tada iš naujo paleiskite visas per dideles programas). Žr. [monitoriu vadovą](33-monitors.md).

Jei naudojate Spotify, galite paspausti `Ctrl + Minus`, kad sumažintumėte sąsają (ir `Ctrl + Plus`, kad ją padidintumėte).

### Kodėl nustojo veikti visi mano Super klavišo susiejimai?

Kai kuriuose ASUS ROG ir TUF nešiojamuosiuose kompiuteriuose `Fn + Super` yra lengvai nepastebimas derinys, kuris perjungia programinės aparatinės įrangos Windows klavišo užraktą (skirtą žaidimams, kad netyčia neišeitumėte iš žaidimo). Ekrane niekas apie tai nepraneša. Kol užraktas įjungtas, Super nieko nesiunčia — todėl kiekvienas Omarchy susiejimas, naudojantis Super, tiesiog nustoja veikti, ir atrodo, kad sugedo Hyprland.

Paspauskite `Fn + Super` vieną kartą, prieš pradėdami knistis `~/.config/hypr/`, o jei tai negrąžins Super, paspauskite dar kartą, kad nepaliktumėte įjungto užrakto. Tai nėra Fn-lock, kuris keičia tik F klavišų eilutės veikimą.

### Mano Wi-Fi, Bluetooth, garsas arba jutiklinis kilimėlis ką tik nustojo veikti

Prieš perkraudami, pabandykite iš naujo paleisti tik sugedusią posistemę. Omarchy meniu _Update > Hardware_ yra Wi-Fi, Bluetooth, Audio ir Trackpad, ir vienos iš jų perkrovimas išsprendžia daugumą situacijų „prieš penkias minutes veikė“ — Bluetooth ausines, kurios nenori vėl prisijungti, jutiklinį kilimėlį, kuris nustojo veikti po miego režimo, garsą, kuris dingo atjungus monitorių.

### Kodėl negroja mano išorinės garso kolonėlės?

Tikriausiai todėl, kad jos nenustatytos kaip pagrindinis išvesties įrenginys. Spustelėkite garsiakalbio piktogramą dešinėje juostos pusėje, ir atsidarys garsumo iššokantis langas, kuriame galėsite pasirinkti išvesties įrenginį (ir maišyti atskirų programų garsumą).

### Mano nešiojamojo kompiuterio garsiakalbiai skamba keistai

Kai kuriuose nešiojamuosiuose kompiuteriuose Omarchy automatiškai pritaiko garsiakalbių derinimą, kuris koreguoja įmontuotų garsiakalbių dažnių atsaką. `omarchy audio tuning status` pasakys, ar toks derinimas aktyvus jūsų kompiuteryje, o `omarchy audio tuning off` jį išjungs, jei verčiau klausytumėte neapdoroto garsiakalbių garso.

### Kodėl negaliu prisijungti arba naudoti sudo su savo slaptažodžiu?

Tikriausiai dešimt kartų neteisingai įvedėte slaptažodį ir buvote užblokuoti. Užraktas savaime išnyks po dviejų minučių. Jei negalite laukti ir tai vyksta užrakinimo ekrane, galite paspausti `CTRL + ALT + F2`, kad paleistumėte naują TTY, kuriame galėsite prisijungti kaip root, tada paleiskite `faillock --reset --user [your-username]`. Tai atstatys užraktą, ir galėsite tęsti.

### Slaptažodis priimamas, bet grįžtu į prisijungimo ekraną

Sugedęs seanso aplinkos failas gali sutrukdyti darbalaukiui paleisti net tada, kai slaptažodis teisingas. Tai ypač verta patikrinti po `~/.config/uwsm/env.d/` redagavimo.

Paspauskite `Ctrl + Alt + F2`, prisijunkite įprastu vartotojo vardu ir slaptažodžiu ir patikrinkite dabartinės įkrovos vartotojo žurnalą:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Ieškokite klaidos, kurioje minimas vienas iš jūsų aplinkos failų, pavyzdžiui, `bad substitution`, einančios prieš pranešimą, kad nerasta aplinkos išvesties žymės. Prieš bandydami prisijungti dar kartą, perkelkite tą failą iš `env.d`. Pavyzdžiui, jei klaidoje minimas `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM praleidžia failą su sintaksės klaida, bet lemtinga klaida, kuri pasirodo tik paleidus failą, pavyzdžiui, `bad substitution`, vis tiek gali sutrukdyti darbalaukiui paleisti. Sistemos momentinės kopijos atkūrimas šių failų nepataiso, nes `/home` nėra atkuriama.

Kai galėsite prisijungti, pataisykite išsaugotą kopiją prieš ją grąžindami. `sh -n` aptinka sintaksės klaidas nepaleisdamas failo, bet negali aptikti kiekvienos klaidos, atsirandančios jį įkėlus. Testuodami pakeitimus laikykite atidarytą veikiantį terminalą.

### Kodėl nepasirodo 1Password autorizacijos raginimai, skirti 1Password SSH Agent / CLI?

Tai gali nutikti dėl 2 priežasčių:

Kad pasirodytų išsamus patvirtinimo raginimas, turi būti įjungta nuostata Settings > Advanced > Use Hardware Acceleration. _Pastaba: kad tai pradėtų veikti, reikia perkrauti kompiuterį._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Arba, jei nuo kompiuterio įkrovos nepaleidėte 1Password, raginimas nepasirodys.
