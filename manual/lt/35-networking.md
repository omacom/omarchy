# Tinklas

Tinklo ryšiu Omarchy sistemoje rūpinasi NetworkManager, o jį valdote iš tinklo piktogramos [viršutinėje juostoje](05-the-top-bar.md) arba paspaudę `Super + Ctrl + N`.

Tas skydelis ieško Wi-Fi tinklų, rodo signalo stiprumą ir prisijungia. Ethernet nieko nereikia — tiesiog įjunkite laidą ir viskas veikia. Jei labiau mėgstate likti terminale, `nmtui` suteikia tuos pačius valdiklius, be to, yra ir `omarchy network` komandų grupė.

## Wi-Fi bendrinimas

Užuot garsiai skaitę ilgą slaptažodį, būdami prisijungę prie Wi-Fi paleiskite _Setup > Network > QR Code_. Ekrane atsiras QR kodas, kurį nuskenavęs bet kurio telefono fotoaparatas prisijungs prie tinklo. Tai vienas tų dalykų, kurį, sužinoję, kad jis yra, naudosite dažniau, nei tikėtumėtės.

Jei jums iš tikrųjų reikia paties slaptažodžio, jį išspausdina `omarchy network password <interface>`.

## DNS

Omarchy naudoja tokį DNS, kokį jūsų tinklas pateikia per DHCP. Galite jį pakeisti visam kompiuteriui skiltyje _Setup > Network > DNS_, kur Cloudflare ir Google pasiekiami vienu spustelėjimu. Pasirinkite _Custom_, kad įvestumėte savo serverius.

Terminale `omarchy dns` išspausdina dabartinį teikėją, o `omarchy dns Cloudflare` jį nustato.

## Wi-Fi dažnių juostos fiksavimas

Jei jūsų maršrutizatorius 2.4GHz, 5GHz ir 6GHz pateikia tuo pačiu tinklo pavadinimu, jūsų nešiojamasis kompiuteris kartais įsikibs į lėtąją juostą. `omarchy network band` parodo, kurioje juostoje esate, o `omarchy network band 5` ją užfiksuoja. Naudokite `auto`, kad vėl leistumėte rinktis automatiškai.

Taip užfiksuojama dažnių juosta, o ne konkretus prieigos taškas, todėl ir toliau įprastai keliaujate tarp AP.

## Koks greitis?

_Trigger > Speed Test > Network Speed Test_ išmatuoja tikrąjį atsisiuntimo ir įkėlimo greitį dviem ciferblatais. Terminale tai yra `omarchy network speedtest down` arba `up`. (Šalia tame meniu yra ir disko greičio testas, jei matuojate kitą siaurąją vietą.)

## Užkarda

Užkarda įjungta pagal numatytuosius nustatymus ir blokuoja visą įeinantį srautą su viena išimtimi: 53317 prievadu, kad [LocalSend](22-guis.md) veiktų iš karto.

SSH išjungtas, kol jo neįjungsite per _Setup > Security > SSHD_ — tai paleidžia tarnybą, atidaro 22 prievadą su greičio ribojimu nuo brute force atakų ir autorizuoja raktą. Docker taip pat apribotas, kad konteineriai netyčia neatsivertų pasauliui. Visą istoriją žr. [saugumas](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) yra mesh VPN, dėl kurio pasiekti visus savo kompiuterius ir serverius internetu tampa paprasta ir saugu. Įdiekite jį per _Install > Service > Tailscale_.

Taip juostoje atsiras Tailscale skydelis, kuris prijungia prie tailnet ir nuo jo atjungia, perjungia paskyras ir parenka exit node — sąraše matysite ir savo įrenginius, ir Mullvad regionus. Jame taip pat galite naršyti savo įrenginius, o ten gyvena ir Taildrop: pasirinkite įrenginį ir paspauskite `s`, kad nusiųstumėte jam failų, arba `c`, `n` ir `d`, kad nukopijuotumėte jo IP, pavadinimą arba visą DNS pavadinimą. Atitikmuo terminale yra `omarchy tailscale send <machine> [file...]`, o jums atsiųsti failai automatiškai patenka į `~/Downloads`. Pranešimas apie atvykusį failą laukia, kol jį spustelėję atidarysite arba atmessite, todėl failas, atsiradęs jums nesant prie kompiuterio, vis dar lauks jūsų atsakymo, kai grįšite.

Įdiegus taip pat atsiranda Tailscale administravimo konsolės žiniatinklio programėlė.

## Kai nustoja veikti

Prieš perkraudami kompiuterį, pabandykite iš naujo paleisti tik tą dalį, kuri kelia problemų. _Update > Hardware_ turi Wi-Fi, Bluetooth, Audio ir Trackpad, o vieno iš jų įkėlimas iš naujo išsprendžia daugumą situacijų „prieš penkias minutes veikė“. Žr. [trikčių šalinimas](45-troubleshooting.md).
