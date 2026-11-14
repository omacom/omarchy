# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) on ihastuttava vaihtoehto esimerkiksi GitHub Desktop -sovellukselle, ja se toimii terminaalin sisällä.

Voit ajaa sen suoraan siirtymällä mihin tahansa gitin hallinnoimaan hakemistoon ja ajamalla `lazygit`. Tai voit ajaa sen Neovimin sisällä, jossa sen voi käynnistää näppäimillä `Space G G`.

Hyppäät eri ruutujen välillä näppäimellä `Tab`. Tiedostot-ruudussa valitset tiedostot valmisteluun näppäimellä `Space`, ja sen jälkeen voit luoda uuden commitin näppäimellä `c`. Näet kaikki käytettävissä olevat komennot näppäimellä `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) on kaunis resurssienhallinta, joka näyttää muistin, suorittimen, levyn ja verkon käytön. Se myös listaa kaikki aktiiviset prosessit ja antaa sinun hallita niitä.

Omarchy kutsuu sitä nimellä Activity, ja käynnistät sen painamalla `Super + Shift + T`. Se avautuu kelluvana ikkunana, jonka voit laatoittaa näppäimillä `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) on terminaalin työtilojen hallintaohjelma, joka antaa sinulle työtilat, välilehdet ja ruudut ja pitää ne kaikki käynnissä pysyvässä istunnossa, josta voit irrottautua ja johon voit palata myöhemmin.

Käynnistät sen (tai liityt takaisin olemassa olevaan istuntoosi) näppäimillä `Super + Ctrl + Return`. Omarchyn mukana tulee Herdr-kokoonpano, joka vastaa sen Tmux-kokoonpanoa, joten etuliitenäppäin on täälläkin `Ctrl + Space`. Voit selata kaikkia näppäinsidoksia näppäimillä `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) näyttää järjestelmätietoja, kuten ytimen version, käyttöajan, teeman, suorittimen, muistin ja paljon muuta. Se on suositun neofetch-työkalun seuraaja.

Omarchy on paketoinut tämän nimellä _About_ Omarchy-valikkoon (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) on retrotyylinen terminaalin musiikkisoitin, joka on saanut inspiraationsa Winamp 2.x:stä, mukanaan sisäänrakennetut radioasemat lo-fi-biittejä varten. Käynnistä se näppäimillä `Super + Shift + Alt + M` tai Omarchy-valikosta kohdasta _Apps_. Paina `?` nähdäksesi koko näppäinsidosluettelon.

## Entä Wi-Fi ja Bluetooth?

Wi-Fi:lle ja Bluetoothille ei löydy TUI-ohjelmia — ne työt kuuluvat Omarchy-kuorelle. Napsauta Wi-Fi-kuvaketta yläpalkissa (tai paina `Super + Ctrl + N`) nähdäksesi verkot ja muodostaaksesi yhteyden, ja napsauta Bluetooth-kuvaketta (tai paina `Super + Ctrl + B`) laitteiden parittamiseksi ja yhdistämiseksi. Katso koko tarina kohdasta [verkkoyhteydet](35-networking.md).

## Omien lisääminen

Mikä tahansa terminaaliohjelma voi saada täyden sovelluskohtelun. Siirry Omarchy-valikossa (`Super + Space`) kohtaan _Install > TUI_, anna sille nimi, käynnistyskomento, ikkunatyyli ja kuvake, ja se näkyy sovelluskäynnistimessä kuten mikä tahansa muu sovellus. Voit poistaa sen taas kohdasta _Remove > TUI_.
