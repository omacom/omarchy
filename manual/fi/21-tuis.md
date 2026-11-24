# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) on ihastuttava vaihtoehto jollekin GitHub Desktop -sovelluksen kaltaiselle, ja se toimii terminaalin sisällä.

Voit käynnistää sen suoraan menemällä mihin tahansa gitin hallinnoimaan hakemistoon ja suorittamalla `lazygit`. Tai voit käynnistää sen Neovimin sisällä, jossa sen voi käynnistää näppäimillä `Space G G`.

Hyppäät eri ruutujen välillä käyttämällä `Tab`. Files-ruudussa valitset tiedostoja valmisteltavaksi käyttämällä `Space`, ja sitten voit luoda uuden commitin käyttämällä `c`. Näet kaikki käytettävissä olevat komennot käyttämällä `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) on kaunis resurssienhallinta, joka näyttää muistin, CPU:n, levyn ja verkon käytön. Se myös listaa kaikki aktiiviset prosessit ja antaa sinun hallita niitä.

Omarchy kutsuu sitä nimellä Activity Monitor, ja käynnistät sen sovelluskäynnistimestä tai painamalla `Super + Shift + T`. Se avautuu kelluvana ikkunana, jonka voit laatoittaa näppäimillä `Super + T`.

## Herdr

[Herdr](https://herdr.dev) on terminaalin työtilojen hallinta, joka antaa sinulle työtiloja, välilehtiä ja ruutuja, ja pitää ne kaikki käynnissä pysyvässä istunnossa, josta voit irrottautua ja johon voit palata myöhemmin.

Käynnistät sen (tai liityt takaisin olemassa olevaan istuntoosi) sovelluskäynnistimestä tai näppäimillä `Super + Ctrl + Return`. Omarchy toimittaa Herdr-kokoonpanon, joka vastaa sen Tmux-kokoonpanoa, joten etuliitenäppäin on täälläkin `Ctrl + Space`. Voit selata kaikkia näppäinsidoksia näppäimillä `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) näyttää järjestelmätietoja, kuten ytimen version, käyttöajan, teeman, CPU:n, muistin ja paljon muuta. Se on suositun neofetch-työkalun seuraaja.

Omarchy on pakannut tämän nimellä _System > About_ Omarchy-valikossa (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) on retro terminaalimusiikkisoitin, jonka innoittajana on Winamp 2.x, mukanaan sisäänrakennettuja radioasemia lo-fi-biittejä varten. Käynnistä se näppäimillä `Super + Shift + Alt + M` tai Omarchy-valikosta kohdasta _Apps_. Paina `?` nähdäksesi koko näppäinsidontaluettelon.

## Entä Wi-Fi ja Bluetooth?

Et löydä TUI:ta Wi-Fiä ja Bluetoothia varten — ne työt kuuluvat Omarchy-kuorelle. Napsauta Wi-Fi-kuvaketta yläpalkissa (tai paina `Super + Ctrl + N`) nähdäksesi verkot ja muodostaaksesi yhteyden, ja napsauta Bluetooth-kuvaketta (tai paina `Super + Ctrl + B`) pariuttaaksesi ja yhdistääksesi laitteita. Katso koko tarina kohdasta [verkkoyhteydet](35-networking.md).

## Omien lisääminen

Mikä tahansa terminaaliohjelma voi saada täyden sovelluskohtelun. Mene Omarchy-valikossa (`Super + Space`) kohtaan _Install > TUI_, anna sille nimi, käynnistyskomento, ikkunatyyli ja kuvake, ja se näkyy sovelluskäynnistimessä kuten mikä tahansa muu sovellus. Voit poistaa sen uudelleen kohdasta _Remove > TUI_.
