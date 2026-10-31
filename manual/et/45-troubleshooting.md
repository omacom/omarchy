# Tõrkeotsing

### Rikkusin värskendusega oma süsteemi ära!

Proovi kõigepealt [oma süsteem taastada](47-system-snapshots.md) versioonile enne viimast värskendust. Kui see ei aita, kasuta oma probleemi jagamiseks Discordi kanalis #omarchy-help käsku `omarchy-debug`. Ja kui kõik muu ebaõnnestub, saad vaikekonfiguratsioonid ja paketid uuesti installida käsuga `omarchy-reinstall`.

### Miks on mõned rakendused minu ekraanil nii suured?

Omarchy eeldab 2x kõrge eraldusvõimega ekraani, nii et see seab `GDK_SCALE` väärtuseks 2, kuni valid monitoripaneelil mastaabi. Kui sul on 1x ekraan ja GTK või X11 rakendused tulevad välja liiga suurena, vali selle jaoks monitoripaneelil 1x või lisa `hl.env("GDK_SCALE", "1")` faili `~/.config/hypr/monitors.lua` (ja seejärel taaskäivita iga rakendus, mis on liiga suur). Vaata [monitoride kasutusjuhendit](33-monitors.md).

Spotify puhul saad kasutajaliidese väiksemaks teha klahvidega `Ctrl + Minus` (ja suuremaks klahvidega `Ctrl + Plus`).

### Miks kõik minu Super-klahvi otseteed lakkasid töötamast?

Osadel ASUS ROG ja TUF sülearvutitel on `Fn + Super` kergesti märkamata jääv klahvikombinatsioon, mis lülitab sisse või välja püsivara Windowsi klahvi lukustuse (mõeldud mängimiseks, et sa kogemata mängust välja ei läheks). Miski ekraanil ei anna sulle teada, et see juhtus. Kui lukustus on sisse lülitatud, ei väljasta Super üldse midagi — nii et iga Omarchy otsetee, mis kasutab Super-klahvi, lihtsalt lakkab töötamast ja tundub, et Hyprland läks katki.

Vajuta üks kord `Fn + Super`, enne kui hakkad failis `~/.config/hypr/` tuhnima, ja kui see Super-klahvi tagasi ei too, vajuta seda uuesti, et sa lukustust sisse ei jätaks. See ei ole Fn-lukk, mis muudab ainult seda, mida F-klahvide rida teeb.

### Minu Wi-Fi, Bluetooth, heli või puuteplaat lakkasid just töötamast

Enne taaskäivitamist proovi vigane alamsüsteem eraldi taaskäivitada. Omarchy menüüs oleval _Värskendus > Riistvara_ on Wi-Fi, Bluetooth, heli ja puuteplaat ning ühe neist uuesti laadimine lahendab enamiku olukordadest „see töötas viis minutit tagasi" — Bluetoothi peakomplekt, mis ei taha uuesti ühenduda, puuteplaat, mis pärast unerežiimi suri, heli, mis kadus, kui ühendasid monitori lahti.

### Miks minu välised kõlarid ei mängi?

Tõenäoliselt sellepärast, et need ei ole määratud peamiseks väljundiks. Klõpsa riba paremal küljel oleval kõlariikoonil ja see avab helitugevuse hüpikakna, kus saad valida väljundseadme (ja miksida ka iga rakenduse helitugevust eraldi).

### Minu sülearvuti kõlarid kõlavad imelikult

Osadel sülearvutitel rakendab Omarchy automaatselt kõlarite häälestust, mis korrigeerib sisseehitatud kõlarite sageduskarakteristikut. `omarchy audio tuning status` ütleb sulle, kas sinu masinal on mõni aktiivne, ja `omarchy audio tuning off` lülitab selle välja, kui eelistad kuulata kõlareid töötlemata kujul.

### Miks ma ei saa oma parooliga sisse logida ega sudo-t kasutada?

Tõenäoliselt sisestasid selle liiga mitu korda valesti ja sind lukustati välja. Kui see juhtub lukustuskuval, saad vajutada `CTRL + ALT + F2`, et käivitada uus TTY, kus saad root-kasutajana sisse logida, seejärel käivita `faillock --reset --user [your-username]`. See tühistab lukustuse ja võid jätkata.

### Miks minu 1Passwordi autoriseerimisviibad 1Password SSH Agent / CLI jaoks ei ilmu?

Sellel võib olla 2 põhjust:

Et rikkalik kinnitusviip ilmuks, peab Settings > Advanced > Use Hardware Acceleration olema sisse lülitatud. _Märkus: Selle toimima hakkamiseks on vaja taaskäivitust._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Või kui sa ei ole pärast käivitamist 1Passwordi avanud, viipa ei ilmu.
