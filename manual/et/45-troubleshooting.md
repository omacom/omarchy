# Veaotsing

### Rikkusin värskendusega oma süsteemi ära!

Esmalt proovi [oma süsteem tagasi keerata](47-system-snapshots.md) versioonile enne hiljutist värskendust. Kui see ei toimi, kasuta käsku `omarchy-debug`, et jagada oma probleemi Discordis kanalis #omarchy-help. Ja kui kõik muu ebaõnnestub, saad vaikekonfiguratsioonid ja paketid uuesti installida käsuga `omarchy-reinstall`.

### Miks on mõned rakendused minu ekraanil nii suured?

Omarchy eeldab 2x kõrge eraldusvõimega ekraani, seega määrab see `GDK_SCALE` väärtuseks 2, kuni valid kuvari paneelil skaala. Kui kasutad 1x ekraani ja GTK või X11 rakendused tulevad liiga suured, vali selle jaoks kuvari paneelil 1x või lisa faili `~/.config/hypr/monitors.lua` `hl.env("GDK_SCALE", "1")` (ja seejärel taaskäivita iga liiga suur rakendus). Vaata [kuvarite kasutusjuhendit](33-monitors.md).

Spotify puhul saad kasutajaliidest vähendada klahvidega `Ctrl + Minus` (ja suurendada klahvidega `Ctrl + Plus`).

### Miks lakkasid kõik minu Super-klahvi otseteed töötamast?

Mõnel ASUS ROG ja TUF sülearvutil on `Fn + Super` kergesti märkamatu klahvikombinatsioon, mis lülitab sisse/välja püsivara Windowsi klahvi lukustuse (mõeldud mängimiseks, et sa kogemata mängust ei lahkuks). Ekraanil miski ei anna sulle teada, et see juhtus. Kui lukustus on sisse lülitatud, ei väljasta Super üldse midagi — seega iga Omarchy otsetee, mis kasutab Super-klahvi, lihtsalt lakkab töötamast ja tundub, et Hyprland läks katki.

Vajuta üks kord `Fn + Super`, enne kui hakkad kaustas `~/.config/hypr/` kaevama, ja kui see Super-klahvi tagasi ei too, vajuta seda uuesti, et sa lukustust sisse ei jätaks. See ei ole Fn-lock, mis muudab ainult seda, mida F-klahvide rida teeb.

### Minu Wi-Fi, Bluetooth, heli või puuteplaat lakkas lihtsalt töötamast

Enne taaskäivitamist proovi probleemne alamsüsteem eraldi taaskäivitada. Omarchy menüüs on _Update > Hardware_ all Wi-Fi, Bluetooth, Audio ja Trackpad ning ühe neist uuesti laadimine lahendab enamiku olukordadest „see töötas viis minutit tagasi“ — Bluetooth-peakomplekt, mis ei taha uuesti ühenduda, puuteplaat, mis lakkas pärast peatamist töötamast, heli, mis kadus, kui kuvari lahti ühendasid.

### Miks minu välised kõlarid ei mängi?

Tõenäoliselt seetõttu, et need ei ole määratud peamiseks väljundiks. Klõpsa riba paremal küljel kõlariikoonil ja see avab helitugevuse hüpikakna, kus saad valida väljundseadme (ja segada ka rakendusepõhiseid helitugevusi).

### Minu sülearvuti kõlarid kõlavad imelikult

Mõnel sülearvutil rakendab Omarchy automaatselt kõlarite häälestuse, mis korrigeerib sisseehitatud kõlarite sageduskarakteristikut. `omarchy audio tuning status` ütleb sulle, kas sinu masinal on üks aktiivne, ja `omarchy audio tuning off` lülitab selle välja, kui eelistad kõlareid kuulata töötlemata kujul.

### Miks ma ei saa oma parooliga sisse logida ega sudo't kasutada?

Tõenäoliselt sisestasid selle kümme korda valesti ja sind lukustati välja. Lukustus kaob iseenesest kahe minuti pärast. Kui sa ei saa oodata ja see juhtub lukustuskuval, saad vajutada `CTRL + ALT + F2`, et käivitada uus TTY, kus saad root-kasutajana sisse logida, seejärel käivita `faillock --reset --user [your-username]`. See lähtestab lukustuse ja võid jätkata.

### Minu parooli võetakse vastu, kuid mind suunatakse tagasi sisselogimisekraanile

Katkine seansi keskkonnafail võib takistada töölaua käivitumist isegi siis, kui parool on õige. Seda tasub eriti kontrollida pärast failide muutmist kaustas `~/.config/uwsm/env.d/`.

Vajuta `Ctrl + Alt + F2`, logi sisse oma tavalise kasutajanime ja parooliga ning vaata praeguse käivituse kasutajapäevikut:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Otsi viga, mis nimetab ühte sinu keskkonnafailidest, näiteks `bad substitution`, vahetult enne teadet, et env väljundi märki ei leitud. Teisalda see fail kaustast `env.d` välja, enne kui proovid uuesti sisse logida. Näiteks kui viga nimetab faili `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM jätab süntaksiveaga faili vahele, kuid saatuslik viga, mis ilmneb alles faili käivitamisel, nagu `bad substitution`, võib siiski takistada töölaua käivitumist. Süsteemi hetktõmmise tagasikeeramine neid faile ei paranda, sest `/home` ei keerata tagasi.

Kui saad sisse logida, paranda salvestatud koopia ära, enne kui selle tagasi teisaldad. `sh -n` püüab süntaksivead kinni faili käivitamata, kuid ei suuda kinni püüda iga viga, mis tekib selle sisselugemisel. Hoia muudatuste testimise ajal töötav terminal avatuna.

### Miks 1Password SSH Agent / CLI jaoks mõeldud 1Passwordi autoriseerimisviibad ei ilmu?

See võib juhtuda kahel põhjusel:

Selleks, et rikkalik heakskiiduviip ilmuks, peab Settings > Advanced > Use Hardware Acceleration olema sisse lülitatud. _Märkus: See hakkab tööle alles pärast taaskäivitamist._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Või kui sa ei ole pärast arvuti käivitamist 1Passwordi käivitanud, siis viip ei ilmu.
