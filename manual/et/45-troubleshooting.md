# Tõrkeotsing

### Ma lõhkusin uuendusega oma süsteemi ära!

Esmalt proovi [oma süsteem tagasi pöörata](47-system-snapshots.md) versioonile, mis oli enne sinu viimast uuendust. Kui see ei tööta, kasuta käsku `omarchy-debug`, et jagada oma probleemi Discordi kanalil #omarchy-help. Ja kui kõik muu ebaõnnestub, saad vaike konfiguratsioonid ja paketid uuesti installida käsuga `omarchy-reinstall`.

### Miks on mõned rakendused minu ekraanil nii suured?

Omarchy eeldab 2x kõrge eraldusvõimega ekraani, seega määrab see `GDK_SCALE` väärtuseks 2, kuni valid monitori paneelil mastaabi. Kui kasutad 1x ekraani ja GTK või X11 rakendused tulevad liiga suured välja, vali selle jaoks monitori paneelil 1x või lisa `hl.env("GDK_SCALE", "1")` faili `~/.config/hypr/monitors.lua` (ja seejärel taaskäivita iga rakendus, mis on liiga suur). Vaata [monitoride käsiraamatut](33-monitors.md).

Spotify puhul saad kasutajaliidese kahandamiseks kasutada `Ctrl + Minus` (ja suurendamiseks `Ctrl + Plus`).

### Miks kõik minu Super klahvi seosed enam ei tööta?

Mõnel ASUS ROG ja TUF sülearvutil on `Fn + Super` kergesti märkamata jääv kombinatsioon, mis lülitab sisse või välja püsivara Windowsi klahvi luku (mõeldud mängimiseks, et sa kogemata mängust ei lahkuks). Miski ekraanil ei anna sulle teada, et see juhtus. Kuni lukk on peal, ei saada Super üldse midagi — seega iga Omarchy seos, mis kasutab Super klahvi, lihtsalt lakkab töötamast ja tundub, et Hyprland läks katki.

Vajuta üks kord `Fn + Super`, enne kui hakkad uurima kausta `~/.config/hypr/`, ja kui see Super klahvi tagasi ei too, vajuta seda uuesti, et sa lukku peale ei jätaks. See ei ole Fn-lock, mis muudab ainult seda, mida F-klahvide rida teeb.

### Minu Wi-Fi, Bluetooth, heli või puuteplaat lakkas lihtsalt töötamast

Enne taaskäivitamist proovi probleemne alamsüsteem eraldi taaskäivitada. Omarchy menüüs _Update > Hardware_ on Wi-Fi, Bluetooth, Audio ja Trackpad ning ühe neist uuesti laadimine lahendab enamiku olukordadest stiilis „see töötas viis minutit tagasi“ — Bluetooth kõrvaklapid, mis ei taha uuesti ühenduda, puuteplaat, mis lakkas pärast unerežiimi töötamast, heli, mis kadus monitori lahtiühendamisel.

### Miks minu välised kõlarid ei mängi?

Tõenäoliselt seetõttu, et need ei ole määratud peamiseks väljundiks. Klõpsa riba paremal küljel kõlariikoonil ja see avab helitugevuse hüpikakna, kus saad valida väljundseadme (ja reguleerida ka iga rakenduse helitugevust eraldi).

### Minu sülearvuti kõlarid kõlavad valesti

Mõnel sülearvutil rakendab Omarchy automaatselt kõlarite häälestuse, mis korrigeerib sisseehitatud kõlarite sageduskarakteristikut. `omarchy audio tuning status` ütleb sulle, kas sinu masinal on mõni aktiivne, ja `omarchy audio tuning off` lülitab selle välja, kui eelistad kuulata kõlareid töötlemata kujul.

### Miks ma ei saa oma parooliga sisse logida ega sudo't kasutada?

Tõenäoliselt sisestasid selle liiga mitu korda valesti ja sind lukustati välja. Kui see juhtub lukustuskuval, saad vajutada `CTRL + ALT + F2`, et käivitada uus TTY, kus saad root kasutajana sisse logida, seejärel käivita `faillock --reset --user [your-username]`. See lähtestab lukustuse ja võid jätkata.

### Minu parool võetakse vastu, kuid mind suunatakse tagasi sisselogimiskuvale

Katkine seansi keskkonnafail võib takistada töölaua käivitumist isegi siis, kui sinu parool on õige. Seda tasub eriti kontrollida pärast kausta `~/.config/uwsm/env.d/` muutmist.

Vajuta `Ctrl + Alt + F2`, logi oma tavalise kasutajanime ja parooliga sisse ning vaata praeguse käivituse kasutaja päevikut:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Otsi viga, mis nimetab ühte sinu keskkonnafailidest, näiteks `bad substitution`, vahetult enne teadet, et env väljundi märki ei leitud. Tõsta see fail enne uuesti sisselogimise proovimist kaustast `env.d` välja. Näiteks kui viga nimetab faili `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM jätab süntaksiveaga faili vahele, kuid saatuslik viga, mis ilmneb ainult faili töötamise ajal, näiteks `bad substitution`, võib endiselt takistada töölaua käivitumist. Süsteemi hetktõmmise tagasipööramine neid faile ei paranda, sest kausta `/home` ei pöörata tagasi.

Kui saad sisse logida, paranda salvestatud koopia enne selle tagasi tõstmist ära. `sh -n` püüab süntaksivead faili käivitamata kinni, kuid ei suuda püüda iga viga, mis selle sisse lugemisel tekib. Hoia muudatusi testides töötav terminal avatuna.

### Miks minu 1Password autoriseerimisviibad 1Password SSH Agent / CLI jaoks ei ilmu?

See võib juhtuda kahel põhjusel:

Et rikkalik kinnitusviip ilmuks, peab Settings > Advanced > Use Hardware Acceleration olema sisse lülitatud. _Märkus: See nõuab toimima hakkamiseks taaskäivitamist._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Või kui sa ei ole pärast käivitamist 1Passwordi avanud, viipa ei ilmu.
