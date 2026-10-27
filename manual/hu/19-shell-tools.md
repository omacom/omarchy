# Shell-eszközök

A szokásos Linux-eszközökön felül az Omarchy számos továbbfejlesztett shell-eszközzel is érkezik. Íme a legfontosabbak.

## fzf

Az [fzf](https://junegunn.github.io/fzf/) fuzzy fájlkeresést kínál az `ff` aliáson keresztül. Menj bármelyik könyvtárba, írd be, hogy `ff`, és fuzzy kereséssel eljuthatsz bármelyik fájlhoz abban a fában, miközben a jobb oldalon látod a szűkítés alatt álló fájlok előnézetét.

A `Ctrl + R` segítségével az fzf-fel fuzzy kereshetsz a parancselőzményeid között.

Ezt az eszközt a Neovim is használja, amikor a `Space Space` kombinációt leütöd.

A teljes kézikönyv a `man fzf` paranccsal érhető el.

## Zoxide

A [Zoxide](https://github.com/ajeetdsouza/zoxide) a cd helyettesítője. Megjegyzi a könyvtárakat, amelyekben jártál, így legközelebb könnyebben ugorhatsz vissza beléjük. Tegyük fel, hogy egyszer kiadod a `cd ~/.config/omarchy` parancsot. Legközelebb elég a `cd omarchy` (vagy akár csak a `cd oma`), és a Zoxide közvetlenül odavisz.

A teljes kézikönyv a `man zoxide` paranccsal érhető el.

## ripgrep

A [ripgrep](https://github.com/BurntSushi/ripgrep) az `rg <pattern> <path>` paranccsal keresi a fájlok tartalmát, például az `rg Controller app/` megtalálja a `Controller` összes előfordulását az app könyvtárban.

Ezt az eszközt a Neovim is használja, amikor a `Space S G` kombinációt leütöd.

A teljes kézikönyv a `man rg` paranccsal érhető el.

## eza

Az [eza](https://eza.rocks/) az ls helyettesítője. Könyvtárlistákat ad többlettartalommal, színekkel és ikonokkal. Alapértelmezetten az eza ls aliásként van beállítva. Az `lt` paranccsal kétszintű beágyazású listát kapsz. Az `lsa` a rejtett fájlokat is tartalmazó listát ad. Az `lta` pedig rejtett fájlokkal együtt beágyazott listát.

A teljes kézikönyv a `man eza` paranccsal érhető el.

## fd

Az [fd](https://github.com/sharkdp/fd) a `find` könnyebben használható helyettesítője. Az `fd person.rb` paranccsal megkeresheted a `person.rb` nevű fájlt az aktuális fában. Az `fd person.rb /` az egész fájlrendszeren keres. Az `fd person.rb / -H` az egész fájlrendszeren keres, beleértve a rejtett könyvtárakat is.

A teljes kézikönyv a `man fd` paranccsal érhető el.

## bat

A [bat](https://github.com/sharkdp/bat) a `cat` szintaktikai kiemeléssel, sorszámokkal és lapozással. Futtasd a `bat somefile.rb` parancsot, és látni fogod, miért nehéz visszatérni. Emellett csendben máshol is dolgozik helyetted: ő színesíti a man oldalaidat, és ő jeleníti meg az `ff`-ben látható előnézeteket.

A teljes kézikönyv a `man bat` paranccsal érhető el.

## tldr

A [tldr](https://tldr.sh/) ellenszere azoknak a man oldalaknak, amelyek három képernyőnyi történelemmel nyílnak, mielőtt egyetlen példát is megmutatnának. A `tldr tar` pont azt a néhány hívást adja, amelyre tényleg kíváncsi voltál.

## yt-dlp

A [yt-dlp](https://github.com/yt-dlp/yt-dlp) videókat tölt le a YouTube-ról és több száz más oldalról. A `yt-dlp <url>` az elérhető legjobb minőségben tölti le az aktuális könyvtárba.

A teljes kézikönyv a `man yt-dlp` paranccsal érhető el.

## try

A [try](https://github.com/tobi/try) megkönnyíti a programozási kísérletek kezelését dátumbélyeges könyvtárakkal. Minden kísérlet a `~/Work/tries` alatt él, és a `try` paranccsal érheted el őket.

Az Omarchy nem adja hozzá automatikusan egy projekt `bin/` könyvtárát a `PATH`-hez. A megbízható, projektbeli eszközöket futtasd explicit relatív útvonallal, például `bin/rails` vagy `./bin/dev` formában.
