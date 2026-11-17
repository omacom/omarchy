# Zana za Shell

Mbali na zana za kawaida za Linux, Omarchy pia huja na zana nyingi za shell zilizoboreshwa. Hizi hapa ndizo muhimu zaidi.

## fzf

[fzf](https://junegunn.github.io/fzf/) inakupa utafutaji usio na ukamilifu (fuzzy finding) wa faili kupitia kifupisho cha `ff`. Nenda kwenye saraka yoyote, andika `ff`, na utaweza kutafuta kwa ukosefu wa ukamilifu njia yako hadi kwenye faili yoyote katika mti huo, huku ukiona hakikisho la faili unazobainisha upande wa kulia.

Unaweza kutumia `Ctrl + R` kutumia fzf kutafuta kwa ukosefu wa ukamilifu katika historia yako ya amri.

Zana hii pia hutumiwa na Neovim unapoandika `Space Space`.

Mwongozo kamili unaweza kupatikana kupitia `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) ni mbadala wa cd. Inakumbuka saraka ambazo umekuwamo, hivyo unaweza kuruka kwake kwa urahisi zaidi wakati mwingine. Tuseme unafanya `cd ~/.config/omarchy` mara moja. Wakati ujao, unaweza kufanya tu `cd omarchy` (au hata tu `cd oma`), na Zoxide itakupeleka huko moja kwa moja.

Mwongozo kamili unaweza kupatikana kupitia `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) hutafuta yaliyomo ndani ya faili kwa kutumia `rg <pattern> <path>`, kama `rg Controller app/` kupata kila kutajwa kwa `Controller` katika saraka app.

Zana hii pia hutumiwa na Neovim unapoandika `Space S G`.

Mwongozo kamili unaweza kupatikana kupitia `man rg`.

## eza

[eza](https://eza.rocks/) ni mbadala wa ls. Inakupa orodha za saraka zenye maelezo zaidi, rangi, na aikoni. Kwa chaguomsingi, eza imefupishwa kama ls. Unaweza pia kutumia `lt` kupata orodha ya viwango viwili vya ukingo. `lsa` inakupa orodha inayojumuisha faili zilizofichwa. Na `lta` orodha iliyokiwa yenye faili zilizofichwa.

Mwongozo kamili unaweza kupatikana kupitia `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) ni mbadala rahisi zaidi kutumia wa `find`. Tumia `fd person.rb` kupata faili inayoitwa `person.rb` ndani ya mti wa sasa. `fd person.rb /` itatafuta mfumo mzima wa faili. `fd person.rb / -H` hutafuta mfumo mzima wa faili, ikiwa ni pamoja na saraka zilizofichwa.

Mwongozo kamili unaweza kupatikana kupitia `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) ni `cat` yenye uanzishaji wa sarufi, nambari za mistari, na upangaji kurasa. Endesha `bat somefile.rb` na utaona ni kwa nini ni vigumu kurudi nyuma. Pia inafanya kazi kwa ajili yako kimya kimya mahali pengine: ndiyo inayochora kurasa zako za man, na ndiyo inayoonyesha hakikisho katika `ff`.

Mwongozo kamili unaweza kupatikana kupitia `man bat`.

## tldr

[tldr](https://tldr.sh/) ni dawa ya kurasa za man zinazofunguka na skrini tatu za historia kabla ya kukuonyesha mfano mmoja hata. `tldr tar` inakupa miito michache ambayo kwa kweli ulikuwa unataka.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) hupakua video kutoka YouTube na tovuti mamia nyingine. `yt-dlp <url>` hunyakua ubora bora zaidi unaopatikana kwenye saraka ya sasa.

Mwongozo kamili unaweza kupatikana kupitia `man yt-dlp`.

## try

[try](https://github.com/tobi/try) hufanya iwe rahisi kusimamia majaribio ya programu yenye saraka zenye muhuri wa tarehe. Majaribio yote hukaa katika `~/Work/tries` na unaweza kuyafikia kupitia `try`.

Omarchy haiongezi saraka ya `bin/` ya mradi kwenye `PATH` kiotomatiki. Endesha zana za ndani za mradi zinazoaminika kwa njia dhahiri ya uhusiano, kama `bin/rails` au `./bin/dev`.
