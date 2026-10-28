# Tõrkeotsing

### Ma rikkusin oma süsteemi värskendusega ära!

Proovi esmalt [oma süsteemi tagasi pöörata](47-system-snapshots.md) versioonile enne hiljutist värskendust. Kui see ei tööta, kasuta käsku `omarchy-debug`, et oma probleemist Discordis kanalis #omarchy-help teada anda. Ja kui kõik see ebaõnnestub, saad vaikimisi seadistused ja paketid käsuga `omarchy-reinstall` uuesti paigaldada.

### Miks on mõned rakendused minu ekraanil nii suured?

Omarchy eeldab 2x kõrge eraldusvõimega ekraani, mis nõuab `GDK_SCALE` seadmist väärtusele 2 failis `~/.config/hypr/monitors.lua`. Aga kui oled 1x ekraanil, saad muuta `local omarchy_gdk_scale = 2` väärtuseks 1 (ja seejärel taaskäivitada iga ülegabariidilise rakenduse). Vaata [kuvarite juhendit](33-monitors.md).

Spotify puhul saad kasutajaliidese kahandamiseks kasutada klahvikombinatsiooni `Ctrl + Minus` (ja `Ctrl + Plus` selle suuremaks tegemiseks).

### Minu Wi-Fi, Bluetooth, heli või puuteplaat lakkas just töötamast

Enne taaskäivitamist proovi solvavat alamsüsteemi eraldi taaskäivitada. Omarchy menüüs jaotises _Uuenda > Riistvara_ on Wi-Fi, Bluetooth, Heli ja Puuteplaat ning ühe neist uuesti laadimine lahendab enamiku olukordadest, kus miski „viis minutit tagasi veel töötas“ — Bluetooth peakomplekt, mis ei ühendu uuesti, puuteplaat, mis suri pärast uinakut, heli, mis kadus, kui kuvari lahti ühendasid.

### Miks minu välised kõlarid ei mängi?

Tõenäoliselt sellepärast, et need pole esmaseks väljundiks seatud. Klõpsa riba paremas servas kõlariikoonil ja see avab helitugevuse hüpikakna, kus saad väljundseadme valida (ja ka iga rakenduse helitugevust eraldi miksida).

### Minu sülearvuti kõlarid kõlavad imelikult

Mõnel sülearvutil rakendab Omarchy automaatselt kõlarite häälestust, mis korrigeerib sisseehitatud kõlarite sagedusreaktsiooni. `omarchy audio tuning status` ütleb sulle, kas mõni on sinu masinal aktiivne, ja `omarchy audio tuning off` lülitab selle välja, kui eelistad kõlareid toorelt kuulda.

### Miks ma ei saa oma parooliga sisse logida ega sudo't kasutada?

Tõenäoliselt kirjutasid selle liiga palju kordi valesti ja sind lukustati välja. Kui see juhtub lukuekraanil, saad vajutada `CTRL + ALT + F2`, et käivitada uus TTY, kus saad root'ina sisse logida, ja käivitada seejärel `faillock --reset --user [sinu-kasutajanimi]`. See lähtestab lukustuse ja oledki valmis.

### Miks minu 1Password autoriseerimise päringud 1Password SSH Agenti / CLI jaoks ei ilmu?

See võib juhtuda kahel põhjusel:

Et rikkalik kinnituste päring ilmuks, peab Settings > Advanced > Use Hardware Acceleration olema sisse lülitatud. _Märkus: selle tööle hakkamiseks on vaja taaskäivitust._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Või kui sa pole pärast alglaadimist 1Passwordi käivitanud, päring ei ilmu.
