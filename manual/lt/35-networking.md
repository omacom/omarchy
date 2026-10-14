# Tinklas

Tinklu Omarchy rūpinasi NetworkManager, o tu jį valdai iš tinklo piktogramos [viršutinėje juostoje](05-the-top-bar.md) arba su `Super + Ctrl + W`.

Tas skydelis ieško Wi-Fi tinklų, rodo signalo stiprumą ir prisijungia. Ethernet nereikia nieko — įkiši laidą ir veikia. Jei mieliau lieki terminale, `nmtui` duoda tuos pačius valdiklius, o dar yra ir `omarchy network` komandų grupė.

## Dalijimasis savo Wi-Fi

Užuot garsiai skaitęs ilgą slaptažodį, būdamas prisijungęs prie Wi-Fi paleisk _Nuostatos > Tinklas > QR Code_. Tai parodys ekrane QR kodą, kurį gali nuskenuoti bet kuri telefono kamera ir prisijungti. Tai vienas tų dalykų, kuriuos naudosi dažniau, nei tikėtumeisi, kai žinai, kad jis yra.

Jei tau iš tikrųjų reikia paties slaptažodžio, jį išspausdina `omarchy network password <interface>`.

## DNS

Omarchy naudoja tokį DNS, kokį tavo tinklas dalina per DHCP. Gali jį pakeisti visam kompiuteriui skiltyje _Nuostatos > Tinklas > DNS_, kur Cloudflare ir Google pasiekiami vienu spustelėjimu. Pasirink _Pasirinktinis_, jei nori įvesti savus serverius.

Terminale `omarchy dns` išspausdina dabartinį teikėją, o `omarchy dns Cloudflare` nustato vieną.

## Wi-Fi dažnių juostos prisegimas

Jei tavo maršrutizatorius 2.4GHz, 5GHz ir 6GHz deda po tuo pačiu tinklo pavadinimu, tavo nešiojamasis kartais įsikibs į lėtąją. `omarchy network band` parodo, kurioje juostoje esi, o `omarchy network band 5` ją prisega. Naudok `auto`, kad vėl leistum rinktis pačiam.

Tai prisega juostą, o ne konkretų prieigos tašką, todėl tarp prieigos taškų keliauji kaip įprastai.

## Kaip greitai?

_Veiksmai > Greitis > Tinklo greičio testas_ pamatuoja tavo tikrąjį atsisiuntimo ir įkėlimo greitį su dviem skalėmis. Terminale tai `omarchy network speedtest down` arba `up`. (Tame meniu šalia yra ir disko greičio testas, jei matuoji kitą siaurą vietą.)

## Ugniasienė

Ugniasienė pagal numatytuosius įjungta ir blokuoja visą įeinantį srautą su viena išimtimi: prievadu 53317, kad [LocalSend](22-guis.md) veiktų iškart.

SSH išjungtas, kol pats jo neįjungi per _Nuostatos > Sauga > SSHD_ — tai paleidžia demoną, atidaro 22 prievadą su apsauga nuo brutalios jėgos atakų ir autorizuoja raktą. Docker taip pat užrakintas, kad konteineriai atsitiktinai neatsivertų pasauliui. Visą istoriją žr. [sauga](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) yra tinklinis VPN, dėl kurio visus savo kompiuterius ir serverius internetu pasiekti paprasta ir saugu. Įdiek jį per _Įdiegti > Paslauga > Tailscale_.

Tai duoda tau Tailscale skydelį juostoje, kuris prisijungia prie tailnet ir atsijungia nuo jo, keičia paskyras ir parenka išėjimo mazgą — sąraše rodomi ir tavo kompiuteriai, ir Mullvad regionai. Jis taip pat naršo tavo kompiuterius, ir ten gyvena Taildrop: pasirink kompiuterį ir paspausk `s`, kad išsiųstum jam failus, arba `c`, `n` ir `d`, kad nukopijuotum jo IP, pavadinimą arba pilną DNS pavadinimą. Terminalo atitikmuo yra `omarchy tailscale send <machine> [file...]`, o tau atsiųsti failai automatiškai atsiduria `~/Downloads`. Pranešimas apie atvykimą laukia, kol jį atidarysi arba atmesi, todėl failas, atkeliavęs, kol buvai toliau nuo kompiuterio, vis tiek bus ten, kai grįši.

Įdiegus jį, pridedama ir žiniatinklio programa Tailscale administravimo konsolei.

## Kai nustoja veikti

Prieš perkraudamas, pabandyk iš naujo paleisti vien kaltąją dalį. _Atnaujinti > Aparatinė įranga_ turi Wi-Fi, Bluetooth, Garsą ir Jutiklinį kilimėlį, o vienos iš jų perkrovimas ištaiso daugumą situacijų „prieš penkias minutes veikė". Žr. [trikčių šalinimą](45-troubleshooting.md).
