# Uirlisí Blaoisce

Chomh maith leis na huirlisí caighdeánacha Linux, tagann Omarchy le go leor uirlisí blaoisce feabhsaithe freisin. Seo na príomhcinn.

## fzf

Tugann [fzf](https://junegunn.github.io/fzf/) duit cuardach doiléir comhaid tríd an ailias `ff`. Téigh chuig aon eolaire, clóscríobh `ff`, agus beidh tú in ann doiléirchuardach a dhéanamh ar do bhealach chuig aon chomhad sa chrann sin, agus tú ag féachaint ar réamhamharc ar na comhaid atá á gcaolú agat ar an taobh deas.

Is féidir leat `Ctrl + R` a úsáid chun fzf a úsáid chun doiléirchuardach a dhéanamh trí stair d'orduithe.

Úsáideann Neovim an uirlis seo freisin nuair a chlóscríobhaann tú `Space Space`.

Is féidir an lámhleabhar iomlán a fháil trí `man fzf`.

## Zoxide

Is ionadach do cd é [Zoxide](https://github.com/ajeetdsouza/zoxide). Cuimhníonn sé ar na heolairí a raibh tú iontu, ionas gur féidir leat léim chucu níos éasca an chéad uair eile. Abair go ndéanann tú `cd ~/.config/omarchy` uair amháin. An chéad uair eile, is féidir leat `cd omarchy` a dhéanamh (nó fiú `cd oma` amháin), agus tabharfaidh Zoxide tú díreach ann.

Is féidir an lámhleabhar iomlán a fháil trí `man zoxide`.

## ripgrep

Cuardachann [ripgrep](https://github.com/BurntSushi/ripgrep) ábhar comhaid trí `rg <pattern> <path>` a úsáid, mar `rg Controller app/` chun gach tagairt do `Controller` san eolaire app a aimsiú.

Úsáideann Neovim an uirlis seo freisin nuair a chlóscríobhaann tú `Space S G`.

Is féidir an lámhleabhar iomlán a fháil trí `man rg`.

## eza

Is ionadach do ls é [eza](https://eza.rocks/). Tugann sé duit liostaithe eolaire le tuilleadh faisnéise, datha, agus deilbhíní. De réir réamhshocraithe, tá eza ainmnithe mar ls. Is féidir leat `lt` a úsáid freisin chun liostaithe de dhá leibhéal doimhneachta a fháil. Tugann `lsa` duit liostaithe lena n-áirítear comhaid i bhfolach. Agus `lta` liostaithe neadaithe le comhaid i bhfolach.

Is féidir an lámhleabhar iomlán a fháil trí `man eza`.

## fd

Is ionadach níos éasca le húsáid do `find` é [fd](https://github.com/sharkdp/fd). Úsáid `fd person.rb` chun comhad darb ainm `person.rb` a aimsiú laistigh den chrann reatha. Cuardachoidh `fd person.rb /` an córas comhaid iomlán. Cuardachann `fd person.rb / -H` an córas comhaid iomlán, lena n-áirítear eolairí i bhfolach.

Is féidir an lámhleabhar iomlán a fháil trí `man fd`.

## bat

Is é [bat](https://github.com/sharkdp/bat) ná `cat` le aibhsiú comhréire, uimhreacha líne, agus leathanachú. Rith `bat somefile.rb` agus feicfidh tú cén fáth go bhfuil sé deacair dul ar ais. Tá sé ag déanamh oibre duit go ciúin in áiteanna eile freisin: is é atá ag dathú do leathanaigh man, agus atá ag rindreáil na réamhamharcanna in `ff`.

Is féidir an lámhleabhar iomlán a fháil trí `man bat`.

## tldr

Is é [tldr](https://tldr.sh/) an leigheas ar leathanaigh man a osclaíonn le trí scáileán staire sula dtaispeánann siad sampla amháin duit. Tugann `tldr tar` duit an dornán glaonna a bhí uait i ndáiríre.

## yt-dlp

Íoslódálann [yt-dlp](https://github.com/yt-dlp/yt-dlp) físeán ó YouTube agus na céadta suíomh eile. Grainníonn `yt-dlp <url>` an caighdeán is fearr atá ar fáil isteach san eolaire reatha.

Is féidir an lámhleabhar iomlán a fháil trí `man yt-dlp`.

## try

Éascaíonn [try](https://github.com/tobi/try) turgnaimh ríomhchlárúcháin a bhainistiú le heolairí le stampa dáta. Cónaíonn na turgnaimh go léir in `~/Work/tries` agus is féidir leat rochtain a fháil orthu trí `try`.

Ní chuireann Omarchy eolaire `bin/` tionscadail le `PATH` go huathoibríoch. Rith uirlisí áitiúla iontaofa tionscadail le conair choibhneasta shonrach, ar nós `bin/rails` nó `./bin/dev`.
