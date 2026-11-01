# Orodja lupine

Poleg standardnih orodij Linuxa Omarchy dobavlja tudi kup izboljšanih orodij lupine. Tu so ključna.

## fzf

[fzf](https://junegunn.github.io/fzf/) omogoča mehko iskanje datotek prek vzdevka `ff`. Pojdite v katero koli mapo, vpišite `ff` in se boste lahko z mehkim iskanjem prebili do katere koli datoteke v tem drevesu, pri čemer boste na desni strani videli predogled datotek, ki jih zožujete.

S `Ctrl + R` lahko fzf uporabite za mehko iskanje po zgodovini ukazov.

To orodje uporablja tudi Neovim, ko pritisnete `Space Space`.

Celoten priročnik najdete prek `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) je zamenjava za cd. Zapomni si mape, v katerih ste bili, da lahko naslednjič lažje skočite vanje. Recimo, da enkrat izvedete `cd ~/.config/omarchy`. Naslednjič lahko preprosto izvedete `cd omarchy` (ali celo samo `cd oma`) in Zoxide vas bo odpeljal neposredno tja.

Celoten priročnik najdete prek `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) preiskuje vsebino datotek z `rg <pattern> <path>`, na primer `rg Controller app/` najde vse omembe `Controller` v mapi app.

To orodje uporablja tudi Neovim, ko pritisnete `Space S G`.

Celoten priročnik najdete prek `man rg`.

## eza

[eza](https://eza.rocks/) je zamenjava za ls. Ponuja sezname map z več informacijami, barvami in ikonami. Privzeto je eza nastavljen kot vzdevek za ls. Uporabite lahko tudi `lt`, da dobite seznam z dvema nivojema gnezdenja. `lsa` poda seznam vključno s skritimi datotekami. `lta` pa gnezdeni seznam s skritimi datotekami.

Celoten priročnik najdete prek `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) je lažje uporabna zamenjava za `find`. Z `fd person.rb` poiščete datoteko z imenom `person.rb` znotraj trenutnega drevesa. `fd person.rb /` preišče celoten datotečni sistem. `fd person.rb / -H` preišče celoten datotečni sistem, vključno s skritimi mapami.

Celoten priročnik najdete prek `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) je `cat` s poudarjanjem sintakse, številkami vrstic in straniškim prikazom. Zaženite `bat somefile.rb` in videli boste, zakaj se je težko vrniti. Tiho opravlja delo tudi drugje: on barva vaše man strani in upodablja predoglede v `ff`.

Celoten priročnik najdete prek `man bat`.

## tldr

[tldr](https://tldr.sh/) je protistrup za man strani, ki se odprejo s tremi zasloni zgodovine, preden pokažejo en sam primer. `tldr tar` vam poda peščico klicev, ki ste jih dejansko želeli.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) prenaša videoposnetke z YouTuba in stotin drugih spletnih mest. `yt-dlp <url>` zgrabi najboljšo razpoložljivo kakovost v trenutno mapo.

Celoten priročnik najdete prek `man yt-dlp`.

## try

[try](https://github.com/tobi/try) olajša upravljanje programskih poskusov z mapami z datumskimi žigi. Vsi poskusi živijo v `~/Work/tries` in do njih dostopate prek `try`.

Omarchy ne doda mape `bin/` projekta v `PATH` samodejno. Zaupanja vredna projektno lokalna orodja zaganjajte z eksplicitno relativno potjo, na primer `bin/rails` ali `./bin/dev`.
