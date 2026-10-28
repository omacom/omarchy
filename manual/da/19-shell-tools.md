# Shellværktøjer

Ud over de standardmæssige Linux-værktøjer leveres Omarchy også med en række forbedrede shellværktøjer. Her er de vigtigste.

## fzf

[fzf](https://junegunn.github.io/fzf/) giver dig fuzzy-søgning efter filer via aliasset `ff`. Gå til en vilkårlig mappe, skriv `ff`, og du vil kunne fuzzy-finde vej til enhver fil i det træ, mens du ser en forhåndsvisning af de filer, du indsnævrer til, i højre side.

Du kan bruge `Ctrl + R` til at bruge fzf til at fuzzy-finde gennem din kommandohistorik.

Dette værktøj bruges også af Neovim, når du skriver `Space Space`.

Den fulde manual findes via `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) er en erstatning for cd. Det husker de mapper, du har været i, så du nemmere kan hoppe til dem næste gang. Lad os sige, at du laver `cd ~/.config/omarchy` én gang. Næste gang kan du bare lave `cd omarchy` (eller endda bare `cd oma`), og Zoxide tager dig direkte derhen.

Den fulde manual findes via `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) søger i indholdet af filer ved hjælp af `rg <pattern> <path>`, som `rg Controller app/` for at finde alle omtaler af `Controller` i mappen app.

Dette værktøj bruges også af Neovim, når du skriver `Space S G`.

Den fulde manual findes via `man rg`.

## eza

[eza](https://eza.rocks/) er en erstatning for ls. Det giver dig mappelister med mere information, farve og ikoner. Som standard er eza blevet aliaset som ls. Du kan også bruge `lt` til at få en liste med to niveauer af indlejring. `lsa` giver dig en liste inklusive skjulte filer. Og `lta` en indlejret liste med skjulte filer.

Den fulde manual findes via `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) er en nemmere at bruge erstatning for `find`. Brug `fd person.rb` til at finde en fil ved navn `person.rb` i det aktuelle træ. `fd person.rb /` vil søge i hele filsystemet. `fd person.rb / -H` søger i hele filsystemet, inklusive skjulte mapper.

Den fulde manual findes via `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) er `cat` med syntaksfremhævning, linjenumre og paging. Kør `bat somefile.rb`, og du vil se, hvorfor det er svært at gå tilbage. Det gør også stille og roligt arbejde for dig andre steder: det er det, der farver dine man-sider, og det, der gengiver forhåndsvisningerne i `ff`.

Den fulde manual findes via `man bat`.

## tldr

[tldr](https://tldr.sh/) er modgiften mod man-sider, der åbner med tre skærme fulde af historie, før de viser dig et eneste eksempel. `tldr tar` giver dig den håndfuld kald, du rent faktisk ville have.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) downloader video fra YouTube og hundredvis af andre sider. `yt-dlp <url>` henter den bedste tilgængelige kvalitet ned i den aktuelle mappe.

Den fulde manual findes via `man yt-dlp`.

## try

[try](https://github.com/tobi/try) gør det nemt at administrere programmeringseksperimenter med datostemplede mapper. Alle eksperimenter lever i `~/Work/tries`, og du kan få adgang til dem via `try`.

Omarchy tilføjer ikke automatisk et projekts `bin/`-mappe til `PATH`. Kør betroede projektlokale værktøjer med en eksplicit relativ sti, såsom `bin/rails` eller `./bin/dev`.
