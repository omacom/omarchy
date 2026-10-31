# Tõrkeotsing

### Ma ajasin süsteemi uuendamisega katki!

Proovi esmalt [taastada oma süsteem](47-system-snapshots.md) olekusse, kus see oli enne viimast uuendust. Kui see ei aita, kasuta `omarchy-debug` käsku, et jagada oma probleemi #omarchy-help kanalil Discordis. Ja kui kõik muu ebaõnnestub, saad `omarchy-reinstall` abil vaike konfiguratsioonid ja paketid uuesti installida.

### Miks on mõned rakendused minu ekraanil nii suured?

Omarchy eeldab 2x kõrge resolutsiooniga ekraani, mistõttu tuleb `~/.config/hypr/monitors.lua` failis seada `GDK_SCALE` väärtuseks 2. Kui kasutad aga 1x ekraani, võid muuta `local omarchy_gdk_scale = 2` väärtuse 1-ks (ja seejärel taaskäivitada iga liiga suureks jäänud rakenduse). Vaata [ekraanide juhendit](33-monitors.md).

Spotify puhul saad kasutajaliidese väiksemaks tegemiseks kasutada `Ctrl + Minus` (ja suuremaks tegemiseks `Ctrl + Plus`).

### Miks kõik minu Super klahvi seosed enam ei tööta?

Mõnel ASUS ROG ja TUF sülearvutil on `Fn + Super` kergesti märkamata jääv kombinatsioon, mis lülitab sisse või välja püsivara Windowsi klahvi luku (mõeldud mängimiseks, et sa kogemata mängust välja ei läheks). Ekraanil miski ei anna teada, et see juhtus. Kui lukk on peal, ei saada Super üldse midagi — nii lakkab iga Super klahvi kasutav Omarchy seos töötamast ja tundub, et Hyprland läks katki.

Vajuta üks kord `Fn + Super`, enne kui hakkad `~/.config/hypr/` kaustas tuhnima, ja kui see Super klahvi tagasi ei too, vajuta seda uuesti, et sa lukku peale ei jätaks. See ei ole Fn-lukk, mis muudab ainult seda, mida F-klahvide rida teeb.

### Minu Wi-Fi, Bluetooth, heli või puuteplaat lõpetas just töö

Enne taaskäivitamist proovi probleemne alamsüsteem eraldi taaskäivitada. Omarchy menüüs _Värskenda > Riistvara_ alt leiad Wi-Fi, Bluetoothi, Heli ja Puuteplaadi ning ühe neist uuesti laadimine lahendab enamiku olukordadest stiilis „see töötas viis minutit tagasi“ — Bluetoothi peakomplekt, mis ei taha uuesti ühenduda, puuteplaat, mis pärast peatamist enam ei tööta, heli, mis kadus, kui ühendasid monitori lahti.

### Miks minu välised kõlarid ei mängi?

Tõenäoliselt pole need määratud peamiseks väljundiks. Klõpsa riba paremal küljel asuval kõlari ikoonil ja see avab helitugevuse hüpikakna, kus saad valida väljundseadme (ja reguleerida ka iga rakenduse helitugevust eraldi).

### Minu sülearvuti kõlarid kõlavad imelikult

Mõnel sülearvutil rakendab Omarchy automaatselt kõlarite häälestuse, mis korrigeerib sisseehitatud kõlarite sagedusreaktsiooni. `omarchy audio tuning status` ütleb sulle, kas sinu masinal on selline häälestus aktiivne, ja `omarchy audio tuning off` lülitab selle välja, kui eelistad kõlareid kuulata töötlemata kujul.

### Miks ma ei saa oma parooliga sisse logida ega sudo käsku kasutada?

Tõenäoliselt kirjutasid selle liiga mitu korda valesti ja sind lukustati välja. Kui see juhtub lukustuskuval, saad vajutada `CTRL + ALT + F2`, et käivitada uus TTY, kus saad root-kasutajana sisse logida, seejärel käivita `faillock --reset --user [your-username]`. See lähtestab lukustuse ja võid jätkata.

### Miks minu 1Passwordi autoriseerimisküsimused 1Password SSH Agent / CLI jaoks ei ilmu?

Sellel võib olla 2 põhjust:

Et rikkalik kinnitusviip ilmuks, peab Sätted > Täpsemalt > Kasuta riistvaralist kiirendust olema sisse lülitatud. _Märkus: Selle toimima hakkamiseks on vaja taaskäivitamist._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Või kui sa pole pärast käivitamist 1Passwordi käivitanud, siis viipa ei ilmu.
