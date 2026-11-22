# Shell-tól

Til viðbótar við stöðluðu Linux-tólin kemur Omarchy líka með fullt af endurbættum shell-tólum. Hér eru þau helstu.

## fzf

[fzf](https://junegunn.github.io/fzf/) gefur þér óskýra leit að skrám í gegnum aliasinn `ff`. Farðu í hvaða möppu sem er, skrifaðu `ff`, og þú munt geta fundið þér leið með óskýrri leit að hvaða skrá sem er í því tré, á meðan þú sérð forskoðun á skránum sem þú ert að þrengja að hægra megin.

Þú getur notað `Ctrl + R` til að nota fzf til að leita með óskýrri leit í gegnum skipanasöguna þína.

Þetta tól er líka notað af Neovim þegar þú skrifar `Space Space`.

Heildarhandbókina er að finna með `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) er staðgengill fyrir cd. Það man möppurnar sem þú hefur verið í, þannig að þú getur auðveldlega stokkið í þær næst. Segjum að þú gerir `cd ~/.config/omarchy` einu sinni. Næst geturðu bara gert `cd omarchy` (eða jafnvel bara `cd oma`), og Zoxide fer með þig beint þangað.

Heildarhandbókina er að finna með `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) leitar í innihaldi skráa með því að nota `rg <pattern> <path>`, eins og `rg Controller app/` til að finna allar minningar á `Controller` í möppunni app.

Þetta tól er líka notað af Neovim þegar þú skrifar `Space S G`.

Heildarhandbókina er að finna með `man rg`.

## eza

[eza](https://eza.rocks/) er staðgengill fyrir ls. Það gefur þér möppulista með meiri upplýsingum, litum og táknum. Sjálfgefið hefur eza verið aliassett sem ls. Þú getur líka notað `lt` til að fá lista með tveggja stiga innfellingu. `lsa` gefur þér lista þar á meðal falin skrár. Og `lta` innfeldan lista með földum skrám.

Heildarhandbókina er að finna með `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) er auðveldari staðgengill fyrir `find`. Notaðu `fd person.rb` til að finna skrá sem heitir `person.rb` í núverandi tré. `fd person.rb /` leitar í öllu skráakerfinu. `fd person.rb / -H` leitar í öllu skráakerfinu, þar á meðal földum möppum.

Heildarhandbókina er að finna með `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) er `cat` með setningarfræðilitun, línunúmerum og blaðsíðuflettingu. Keyrðu `bat somefile.rb` og þú munt sjá af hverju erfitt er að fara til baka. Það vinnur líka hljóðlega fyrir þig annars staðar: það er það sem litar man-síðurnar þínar, og það sem teiknar forskoðanirnar í `ff`.

Heildarhandbókina er að finna með `man bat`.

## tldr

[tldr](https://tldr.sh/) er móteitrið gegn man-síðum sem opnast með þremur skjáum af sögu áður en þær sýna þér eitt einasta dæmi. `tldr tar` gefur þér þær fáu keyrslur sem þú raunverulega vildir.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) hleður niður myndböndum frá YouTube og hundruðum annarra vefsvæða. `yt-dlp <url>` sækir bestu gæðin sem völ er á í núverandi möppu.

Heildarhandbókina er að finna með `man yt-dlp`.

## try

[try](https://github.com/tobi/try) gerir það auðvelt að stjórna forritunartilraunum með dagsetningarstimpluðum möppum. Allar tilraunir búa í `~/Work/tries` og þú getur nálgast þær með `try`.

Omarchy bætir `bin/`-möppu verkefnis ekki sjálfkrafa við `PATH`. Keyrðu traust verkefnatól með skýrri afstæðri slóð, svo sem `bin/rails` eða `./bin/dev`.
