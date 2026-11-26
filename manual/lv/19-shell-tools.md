# Čaulas rīki

Papildus standarta Linux rīkiem Omarchy tiek piegādāts arī ar veselām daudzām uzlabotām čaulas rīkām. Šeit ir svarīgākie.

## fzf

[fzf](https://junegunn.github.io/fzf/) nodrošina failu aptuvenu meklēšanu ar `ff` aizstājvārdu. Dodieties uz jebkuru direktoriju, ierakstiet `ff`, un varēsiet aptuvenā meklēšanā atrast ceļu uz jebkuru failu šajā kokā, labajā pusē redzot to failu priekšskatījumu, uz kuriem sašaurināt meklēšanu.

Ar `Ctrl + R` var izmantot fzf, lai aptuveni meklētu savā komandu vēsturē.

Šo rīku izmanto arī Neovim, kad nospiežat `Space Space`.

Pilno rokasgrāmatu var atrast ar `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) ir komandas cd aizstājums. Tas atceras direktorijas, kurās esat bijis, tāpēc nākamreiz varat uz tām vieglāk pārlēkt. Pieņemsim, ka vienreiz izpildāt `cd ~/.config/omarchy`. Nākamreiz varat vienkārši izpildīt `cd omarchy` (vai pat tikai `cd oma`), un Zoxide jūs aizvedīs uzreiz turp.

Pilno rokasgrāmatu var atrast ar `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) meklē failu saturā ar `rg <pattern> <path>`, piemēram, `rg Controller app/` atrod visas vārda `Controller` pieminēšanas direktorijā app.

Šo rīku izmanto arī Neovim, kad nospiežat `Space S G`.

Pilno rokasgrāmatu var atrast ar `man rg`.

## eza

[eza](https://eza.rocks/) ir komandas ls aizstājums. Tas sniedz direktoriju sarakstus ar vairāk informācijas, krāsām un ikonām. Pēc noklusējuma eza ir iestatīts kā ls aizstājvārds. Varat arī izmantot `lt`, lai iegūtu sarakstu ar divu līmeņu ligzdojumu. `lsa` sniedz sarakstu, ieskaitot slēptos failus. Bet `lta` — ligzdotu sarakstu ar slēptajiem failiem.

Pilno rokasgrāmatu var atrast ar `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) ir vieglāk lietojams komandas `find` aizstājums. Izmantojiet `fd person.rb`, lai pašreizējā kokā atrastu failu ar nosaukumu `person.rb`. `fd person.rb /` meklēs visā failu sistēmā. `fd person.rb / -H` meklē visā failu sistēmā, ieskaitot slēptās direktorijas.

Pilno rokasgrāmatu var atrast ar `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) ir `cat` ar sintakses izcelšanu, rindu numuriem un lapošanu. Palaidiet `bat somefile.rb`, un sapratīsiet, kāpēc ir grūti atgriezties atpakaļ. Tas klusi strādā jums arī citviet: tas iekrāso jūsu man lapas un atveido priekšskatījumus `ff` komandā.

Pilno rokasgrāmatu var atrast ar `man bat`.

## tldr

[tldr](https://tldr.sh/) ir pretlīdzeklis pret man lapām, kas sākas ar trīs ekrāniem vēstures, lai tikai pēc tam parādītu vienu piemēru. `tldr tar` sniedz tās pāris izsaukuma formas, kuras patiesībā gribējāt.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) lejupielādē video no YouTube un simtiem citu vietņu. `yt-dlp <url>` pašreizējā direktorijā lejupielādē labāko pieejamo kvalitāti.

Pilno rokasgrāmatu var atrast ar `man yt-dlp`.

## try

[try](https://github.com/tobi/try) atvieglo programmēšanas eksperimentu pārvaldību, izmantojot ar datumu marķētas direktorijas. Visi eksperimenti dzīvo mapē `~/Work/tries`, un tiem var piekļūt ar `try`.

Omarchy automātiski nepievieno projekta `bin/` direktoriju mainīgajam `PATH`. Palaidiet uzticamus projekta lokālos rīkus, norādot skaidru relatīvo ceļu, piemēram, `bin/rails` vai `./bin/dev`.
