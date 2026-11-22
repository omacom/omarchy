# Tinklas

Omarchy tinklą tvarko NetworkManager, o jūs jį valdote iš tinklo piktogramos [viršutinėje juostoje](05-the-top-bar.md) arba su `Super + Ctrl + N`.

Tas skydelis ieško Wi-Fi tinklų, rodo signalo stiprumą ir prisijungia. Ethernetui visai nieko nereikia — prijunkite ir veikia. Jei labiau norite likti terminale, `nmtui` suteikia tokius pačius valdiklius, be to, yra komandų grupė `omarchy network`.

## Kaip dalytis Wi-Fi

Užuot garsiai skaitę ilgą slaptažodį, būdami prisijungę prie Wi-Fi paleiskite _Setup > Network > QR Code_. Tada ekrane atsiras QR kodas, kurį gali nuskaityti bet kuri telefono kamera ir prisijungti. Tai vienas tų dalykų, kuriais naudositės dažniau, nei tikitės, kai sužinosite, kad jis čia yra.

Jei iš tikrųjų reikia paties slaptažodžio, jį išspausdina `omarchy network password <interface>`.

## DNS

Omarchy naudoja tokį DNS, kokį jūsų tinklas pateikia per DHCP. Galite tai pakeisti visam kompiuteriui skiltyje _Setup > Network > DNS_, kur Cloudflare ir Google pasiekiami vienu spustelėjimu. Pasirinkite _Custom_, kad įvestumėte savo serverius.

Iš terminalo `omarchy dns` išspausdina dabartinį teikėją, o `omarchy dns Cloudflare` jį nustato.

## Wi-Fi juostos fiksavimas

Jei jūsų maršruto parinktuvas 2.4GHz, 5GHz ir 6GHz rodo tuo pačiu tinklo pavadinimu, jūsų nešiojamasis kompiuteris kartais įsikibs į lėtąją juostą. `omarchy network band` parodo, kurioje juostoje esate, o `omarchy network band 5` ją fiksuoja. Naudokite `auto`, kad vėl leistumėte rinktis automatiškai.

Tai fiksuoja juostą, o ne konkretų prieigos tašką, todėl tarp AP ir toliau įprastai persijungsite.

## Kaip greitai veikia?

_Trigger > Speed Test > Network Speed Test_ išmatuoja tikrąjį siuntimo ir atsisiuntimo greitį su dviem skalėmis. Iš terminalo tai yra `omarchy network speedtest down` arba `up`. Matuojama naudojant pačios Omarchy paslaugą ir skaičiuojami tik jos bandomieji perdavimai. Kiti atsisiuntimai gali konkuruoti dėl pralaidumo, bet jie neįtraukiami į greičio testo rezultatą. (Tame pačiame meniu šalia yra disko greičio testas, jei tikrinate kitą siaurą vietą.)

## Ugniasienė

Ugnasienė įjungta pagal numatytuosius nustatymus ir blokuoja visą įeinantį srautą su viena išimtimi: prievadas 53317, kad [LocalSend](22-guis.md) veiktų iš karto.

SSH išjungtas, kol jo neįjungsite su _Setup > Security > SSHD_, o tai paleidžia demoną, atidaro 22 prievadą su apribotu greičiu nuo brutalios jėgos atakų ir autorizuoja raktą. Docker taip pat apribotas, kad konteineriai netyčia neatsivertų pasauliui. Visą istoriją žr. [saugumo](48-security.md) skyriuje.

## Tailscale

[Tailscale](https://tailscale.com/) yra mesh VPN, dėl kurio pasiekti visus savo kompiuterius ir serverius internetu yra paprasta ir saugu. Įdiekite jį su _Install > Service > Tailscale_.

Tada juostoje atsiras Tailscale skydelis, kuris prisijungia prie tailnet ir nuo jo atsijungia, perjungia paskyras ir parenka išėjimo mazgą — sąraše matysite tiek savo kompiuterius, tiek Mullvad regionus. Jis taip pat naršo jūsų kompiuterius, ir čia gyvena Taildrop: pasirinkite kompiuterį ir paspauskite `s`, kad nusiųstumėte jam failų, arba `c`, `n` ir `d`, kad nukopijuotumėte jo IP, pavadinimą arba visą DNS pavadinimą. Atitikmuo terminale yra `omarchy tailscale send <machine> [file...]`, o jums atsiųsti failai automatiškai atsiduria `~/Downloads`. Pranešimas apie atvykimą laukia, kol jį spustelėsite atidaryti arba atmestumėte, todėl failas, atsiradęs jums nesant prie kompiuterio, vis dar lauks jūsų atsakymo, kai grįšite.

Įdiegus taip pat pridedama žiniatinklio programėlė, skirta Tailscale administravimo konsolei.

## Kai nustoja veikti

Prieš perkraudami, pabandykite iš naujo paleisti tik tą dalį, kuri kelia problemų. _Update > Hardware_ yra Wi-Fi, Bluetooth, Audio ir Trackpad, ir vieno iš jų perkrovimas išsprendžia daugumą „prieš penkias minutes veikė“ situacijų. Žr. [trikčių šalinimą](45-troubleshooting.md).
