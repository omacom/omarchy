# Skallverktøy

I tillegg til standard Linux-verktøyene leveres Omarchy også med en gjeng forbedrede skallverktøy. Her er de viktigste.

## fzf

[fzf](https://junegunn.github.io/fzf/) gir deg fuzzy-søk etter filer via `ff`-aliaset. Gå til en hvilken som helst mappe, skriv `ff`, så kan du fuzzy-finne deg frem til enhver fil i det treet, mens du ser en forhåndsvisning av filene du snevrer inn på høyre side.

Du kan bruke `Ctrl + R` for å bruke fzf til å fuzzy-søke gjennom kommandohistorikken din.

Dette verktøyet brukes også av Neovim når du skriver `Space Space`.

Hele manualen finner du via `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) er en erstatning for cd. Den husker mappene du har vært i, så du lettere kan hoppe til dem neste gang. Si du kjører `cd ~/.config/omarchy` én gang. Neste gang kan du bare kjøre `cd omarchy` (eller til og med bare `cd oma`), så tar Zoxide deg rett dit.

Hele manualen finner du via `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) søker i innholdet i filer med `rg <pattern> <path>`, som `rg Controller app/` for å finne alle omtaler av `Controller` i mappen app.

Dette verktøyet brukes også av Neovim når du skriver `Space S G`.

Hele manualen finner du via `man rg`.

## eza

[eza](https://eza.rocks/) er en erstatning for ls. Den gir deg mappeoppføringer med mer informasjon, farge og ikoner. Som standard er eza aliasset som ls. Du kan også bruke `lt` for å få en oppføring med to dype nestenivåer. `lsa` gir deg en oppføring inkludert skjulte filer. Og `lta` en nestet oppføring med skjulte filer.

Hele manualen finner du via `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) er en enklere erstatning for `find`. Bruk `fd person.rb` for å finne en fil kalt `person.rb` i gjeldende tre. `fd person.rb /` søker i hele filsystemet. `fd person.rb / -H` søker i hele filsystemet, inkludert skjulte mapper.

Hele manualen finner du via `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) er `cat` med syntaksfremhevning, linjenumre og sidevisning. Kjør `bat somefile.rb`, så skjønner du hvorfor det er vanskelig å gå tilbake. Den gjør også arbeid for deg i stillhet andre steder: den fargelegger man-sidene dine, og den gjengir forhåndsvisningene i `ff`.

Hele manualen finner du via `man bat`.

## tldr

[tldr](https://tldr.sh/) er motgiften mot man-sider som åpner med tre skjermer historikk før de viser deg ett eneste eksempel. `tldr tar` gir deg den håndfullen kall du faktisk ville ha.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) laster ned video fra YouTube og hundrevis av andre nettsteder. `yt-dlp <url>` henter den beste kvaliteten som er tilgjengelig til gjeldende mappe.

Hele manualen finner du via `man yt-dlp`.

## try

[try](https://github.com/tobi/try) gjør det enkelt å håndtere programmeringseksperimenter med datostemplede mapper. Alle eksperimenter bor i `~/Work/tries`, og du får tilgang til dem via `try`.

Omarchy legger ikke til et prosjekts `bin/`-mappe i `PATH` automatisk. Kjør klarerte prosjektlokale verktøy med en eksplisitt relativ sti, som `bin/rails` eller `./bin/dev`.
