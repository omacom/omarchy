# Shellverktyg

Utöver de vanliga Linux-verktygen levereras Omarchy också med en massa förbättrade shellverktyg. Här är de viktigaste.

## fzf

[fzf](https://junegunn.github.io/fzf/) ger dig fuzzy finding av filer via aliaset `ff`. Gå till valfri katalog, skriv `ff`, så kan du fuzzy-söka dig fram till valfri fil i det trädet, samtidigt som du ser en förhandsvisning av filerna du avgränsar till på höger sida.

Du kan använda `Ctrl + R` för att använda fzf för att fuzzy-söka genom din kommandohistorik.

Det här verktyget används också av Neovim när du trycker `Space Space`.

Den fullständiga manualen finns via `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) är en ersättning för cd. Det kommer ihåg vilka kataloger du har varit i, så att du lättare kan hoppa till dem nästa gång. Säg att du kör `cd ~/.config/omarchy` en gång. Nästa gång kan du bara köra `cd omarchy` (eller till och med bara `cd oma`), så tar Zoxide dig direkt dit.

Den fullständiga manualen finns via `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) söker i filers innehåll med `rg <pattern> <path>`, som `rg Controller app/` för att hitta alla omnämnanden av `Controller` i katalogen app.

Det här verktyget används också av Neovim när du trycker `Space S G`.

Den fullständiga manualen finns via `man rg`.

## eza

[eza](https://eza.rocks/) är en ersättning för ls. Det ger dig kataloglistningar med mer information, färg och ikoner. Som standard har eza aliasats som ls. Du kan också använda `lt` för att få en listning med två nivåers nästling. `lsa` ger dig en listning inklusive dolda filer. Och `lta` en nästlad listning med dolda filer.

Den fullständiga manualen finns via `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) är en enklare ersättning för `find`. Använd `fd person.rb` för att hitta en fil som heter `person.rb` i det aktuella trädet. `fd person.rb /` söker genom hela filsystemet. `fd person.rb / -H` söker genom hela filsystemet, inklusive dolda kataloger.

Den fullständiga manualen finns via `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) är `cat` med syntaxmarkering, radnummer och sidvisning. Kör `bat somefile.rb` så förstår du varför det är svårt att gå tillbaka. Det gör också tyst nytta för dig på andra håll: det är det som färglägger dina man-sidor, och det som renderar förhandsvisningarna i `ff`.

Den fullständiga manualen finns via `man bat`.

## tldr

[tldr](https://tldr.sh/) är motgiftet mot man-sidor som öppnar med tre skärmar historia innan de visar ett enda exempel. `tldr tar` ger dig den handfull anrop som du faktiskt ville ha.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) laddar ner video från YouTube och hundratals andra webbplatser. `yt-dlp <url>` hämtar bästa tillgängliga kvalitet till den aktuella katalogen.

Den fullständiga manualen finns via `man yt-dlp`.

## try

[try](https://github.com/tobi/try) gör det enkelt att hantera programmeringsexperiment med datumstämplade kataloger. Alla experiment bor i `~/Work/tries` och du når dem via `try`.

Omarchy lägger inte till ett projekts `bin/`-katalog i `PATH` automatiskt. Kör betrodda projektlokala verktyg med en explicit relativ sökväg, som `bin/rails` eller `./bin/dev`.
