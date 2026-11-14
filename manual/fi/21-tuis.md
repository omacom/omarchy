# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) on ihastuttava vaihtoehto esimerkiksi GitHub Desktop -sovellukselle, ja se toimii terminaalin sisällä.

Voit ajaa sen suoraan siirtymällä mihin tahansa gitin hallinnoimaan hakemistoon ja ajamalla `lazygit`. Tai voit ajaa sen Neovimin sisällä, jossa sen voi käynnistää näppäimillä `Space G G`.

Siirryt eri paneelien välillä näppäimellä `Tab`. Files-paneelissa valitset tiedostoja staging-vaiheeseen näppäimellä `Space`, ja sen jälkeen voit luoda uuden commitin näppäimellä `c`. Näet kaikki käytettävissä olevat komennot näppäimellä `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) on kaunis resurssienhallinta, joka näyttää muistin, CPU:n, levyn ja verkon käytön. Se myös listaa kaikki aktiiviset prosessit ja antaa sinun hallita niitä.

Omarchy kutsuu sitä nimellä Activity Monitor, ja käynnistät sen sovelluskäynnistimestä tai painamalla `Super + Shift + T`. Se avautuu kelluvana ikkunana, jonka voit asettaa laatoitukseen näppäimillä `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) on terminaalin työtilojen hallinta, joka antaa sinulle työtilat, välilehdet ja paneelit ja pitää ne kaikki käynnissä pysyvässä istunnossa, josta voit irrottautua ja johon voit palata myöhemmin.

Käynnistät sen (tai palaat olemassa olevaan istuntoosi) näppäimillä `Super + Ctrl + Return`. Omarchy toimittaa Herdr-asetukset, jotka vastaavat sen Tmux-asetuksia, joten etuliitenäppäin on täälläkin `Ctrl + Space`. Voit selata kaikkia pikanäppäimiä näppäimillä `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) näyttää järjestelmätietoja, kuten kernelin version, käyttöajan, teeman, CPU:n, muistin ja paljon muuta. Se on suositun neofetch-työkalun seuraaja.

Omarchy on pakannut tämän nimellä _About_ Omarchy-valikkoon (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) on retroterminaalin musiikkisoitin, joka on saanut inspiraationsa Winamp 2.x:stä, mukanaan sisäänrakennetut radioasemat lo-fi-biittejä varten. Käynnistä se näppäimillä `Super + Shift + Alt + M` tai Omarchy-valikosta kohdasta _Apps_. Paina `?` nähdäksesi täydellisen pikanäppäinluettelon.

## Entä Wi-Fi ja Bluetooth?

Et löydä TUI:ta Wi-Fi:lle ja Bluetoothille — ne työt kuuluvat Omarchy-kuorelle. Napsauta Wi-Fi-kuvaketta yläpalkissa (tai paina `Super + Ctrl + N`) nähdäksesi verkot ja yhdistääksesi niihin, ja napsauta Bluetooth-kuvaketta (tai paina `Super + Ctrl + B`) laiteparien muodostamista ja laitteisiin yhdistämistä varten. Katso koko tarina kohdasta [verkkoasetukset](35-networking.md).

## Omien lisääminen

Mikä tahansa terminaaliohjelma voi saada täyden sovelluskäsittelyn. Siirry Omarchy-valikossa (`Super + Space`) kohtaan _Install > TUI_, anna sille nimi, käynnistyskomento, ikkunatyyli ja kuvake, ja se ilmestyy sovelluskäynnistimeen kuten mikä tahansa muukin sovellus. Voit poistaa sen taas kohdasta _Remove > TUI_.
