# Shell-työkalut

Tavallisten Linux-työkalujen lisäksi Omarchyssa on mukana myös joukko paranneltuja shell-työkaluja. Tässä tärkeimmät.

## fzf

[fzf](https://junegunn.github.io/fzf/) antaa sinulle sumean tiedostojen haun aliaksella `ff`. Siirry mihin tahansa hakemistoon, kirjoita `ff`, ja voit sumeasti hakea tiesi mihin tahansa tiedostoon kyseisessä puussa ja samalla nähdä oikealla puolella esikatselun tiedostoista, joihin olet rajaamassa valikoimaa.

Voit käyttää yhdistelmää `Ctrl + R` hakeaksesi fzf:llä sumeasti komentohistoriastasi.

Neovim käyttää tätä työkalua myös, kun kirjoitat `Space Space`.

Koko ohjeen löydät komennolla `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) on korvaaja cd:lle. Se muistaa hakemistot, joissa olet käynyt, joten voit seuraavalla kerralla hypätä niihin helpommin. Sanotaan, että teet kerran `cd ~/.config/omarchy`. Seuraavalla kerralla voit vain tehdä `cd omarchy` (tai jopa vain `cd oma`), ja Zoxide vie sinut suoraan sinne.

Koko ohjeen löydät komennolla `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) hakee tiedostojen sisällöstä komennolla `rg <pattern> <path>`, kuten `rg Controller app/` löytääksesi kaikki maininnat sanasta `Controller` hakemistossa app.

Neovim käyttää tätä työkalua myös, kun kirjoitat `Space S G`.

Koko ohjeen löydät komennolla `man rg`.

## eza

[eza](https://eza.rocks/) on korvaaja ls:lle. Se antaa hakemistoluettelot, joissa on enemmän tietoa, värejä ja kuvakkeita. Oletuksena eza on aliaksena ls:lle. Voit myös käyttää komentoa `lt` saadaksesi luettelon kahden tason syvyydeltä. `lsa` antaa luettelon piilotiedostot mukaan lukien. Ja `lta` sisäkkäisen luettelon piilotiedostot mukaan lukien.

Koko ohjeen löydät komennolla `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) on helpommin käytettävä korvaaja komennolle `find`. Käytä `fd person.rb` löytääksesi tiedoston nimeltä `person.rb` nykyisestä puusta. `fd person.rb /` hakee koko tiedostojärjestelmästä. `fd person.rb / -H` hakee koko tiedostojärjestelmästä, piilotetut hakemistot mukaan lukien.

Koko ohjeen löydät komennolla `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) on `cat` syntaksikorostuksella, rivinumeroilla ja sivutuksella. Aja `bat somefile.rb`, niin näet, miksi takaisin on vaikea palata. Se tekee hiljaisesti töitä puolestasi muuallakin: se värjää man-sivusi ja hahmontaa esikatselut komennossa `ff`.

Koko ohjeen löydät komennolla `man bat`.

## tldr

[tldr](https://tldr.sh/) on vastalääke man-sivuille, jotka avautuvat kolmella näytöllisellä historiaa ennen kuin näyttävät yhtään esimerkkiä. `tldr tar` antaa sinulle ne muutamat kutsut, joita oikeasti halusit.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) lataa videoita YouTubesta ja sadoilta muilta sivustoilta. `yt-dlp <url>` nappaa parhaan saatavilla olevan laadun nykyiseen hakemistoon.

Koko ohjeen löydät komennolla `man yt-dlp`.

## try

[try](https://github.com/tobi/try) tekee ohjelmointikokeilujen hallinnasta helppoa päivämääräleimatuilla hakemistoilla. Kaikki kokeilut sijaitsevat hakemistossa `~/Work/tries`, ja pääset niihin käsiksi komennolla `try`.

Omarchy ei lisää projektin hakemistoa `bin/` muuttujaan `PATH` automaattisesti. Aja luotettavia projektin paikallisia työkaluja eksplisiittisellä suhteellisella polulla, kuten `bin/rails` tai `./bin/dev`.
