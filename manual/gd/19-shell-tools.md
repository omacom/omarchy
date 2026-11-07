# Innealan na slige

A bharrachd air innealan àbhaisteach Linux, thig Omarchy le dòrlach de dh'innealan slige leasaichte. Seo an fheadhainn as cudromaiche.

## fzf

Bheir [fzf](https://junegunn.github.io/fzf/) lorg neo-shoilleir air faidhlichean dhut leis an alias `ff`. Rach do phasgan sam bith, sgrìobh `ff`, agus 's urrainn dhut do shlighe a lorg gu faidhle sam bith sa chraobh sin, fhad 's a chì thu ro-shealladh air na faidhlichean a tha thu a' cumhangachadh air an taobh deas.

'S urrainn dhut `Ctrl + R` a chleachdadh airson lorg neo-shoilleir le fzf a dhèanamh air eachdraidh nan àitheantan agad.

Cleachdaidh Neovim an t-inneal seo cuideachd nuair a sgrìobhas tu `Space Space`.

Gheibh thu an leabhar-mìneachaidh slàn le `man fzf`.

## Zoxide

Tha [Zoxide](https://github.com/ajeetdsouza/zoxide) na àite cd. Cuimhnichidh e na pasganan anns an robh thu, ach an urrainn dhut leum thuca nas fhasa an ath thuras. Abair gun dèan thu `cd ~/.config/omarchy` aon turas. An ath thuras, 's urrainn dhut dìreach `cd omarchy` a dhèanamh (no fiù 's dìreach `cd oma`), agus bheir Zoxide ann thu sa bhad.

Gheibh thu an leabhar-mìneachaidh slàn le `man zoxide`.

## ripgrep

Lorgaidh [ripgrep](https://github.com/BurntSushi/ripgrep) ann an susbaint fhaidhlichean le `rg <pattern> <path>`, mar `rg Controller app/` airson gach iomradh air `Controller` sa phasgan app a lorg.

Cleachdaidh Neovim an t-inneal seo cuideachd nuair a sgrìobhas tu `Space S G`.

Gheibh thu an leabhar-mìneachaidh slàn le `man rg`.

## eza

Tha [eza](https://eza.rocks/) na àite ls. Bheir e liostaichean phasgan dhut le barrachd fiosrachaidh, dath is ìomhaigheagan. Gu bunaiteach, chaidh eza a shuidheachadh mar alias airson ls. 'S urrainn dhut `lt` a chleachdadh cuideachd airson liosta le dà ìre de neadachadh. Bheir `lsa` liosta dhut a ghabhas a-steach faidhlichean falaichte. Agus `lta` liosta neadaichte le faidhlichean falaichte.

Gheibh thu an leabhar-mìneachaidh slàn le `man eza`.

## fd

Tha [fd](https://github.com/sharkdp/fd) na àite `find` a tha nas fhasa a chleachdadh. Cleachd `fd person.rb` airson faidhle air a bheil `person.rb` a lorg sa chraobh làithreach. Lorgaidh `fd person.rb /` air feadh an t-siostaim-fhaidhlichean gu lèir. Lorgaidh `fd person.rb / -H` air feadh an t-siostaim-fhaidhlichean gu lèir, a' gabhail a-steach pasganan falaichte.

Gheibh thu an leabhar-mìneachaidh slàn le `man fd`.

## bat

Tha [bat](https://github.com/sharkdp/bat) na `cat` le soillseachadh co-chàraidh, àireamhan loidhne is duilleagachadh. Ruith `bat somefile.rb` agus chì thu carson a tha e doirbh tilleadh. Tha e ag obair dhut gu sàmhach ann an àiteachan eile cuideachd: 's e seo a chuireas dath air na duilleagan man agad, agus a sheallas na ro-sheallaidhean ann an `ff`.

Gheibh thu an leabhar-mìneachaidh slàn le `man bat`.

## tldr

'S e [tldr](https://tldr.sh/) an leigheas air duilleagan man a thòisicheas le trì sgrìnichean de dh'eachdraidh mus seall iad aon eisimpleir dhut. Bheir `tldr tar` dhut an dòrlach de ghairmean a bha thu ag iarraidh dha-rìribh.

## yt-dlp

Luchdaichidh [yt-dlp](https://github.com/yt-dlp/yt-dlp) a-nuas videothan o YouTube is ceudan de làraichean eile. Glacaidh `yt-dlp <url>` a' chàileachd as fheàrr a tha ri fhaighinn dhan phasgan làithreach.

Gheibh thu an leabhar-mìneachaidh slàn le `man yt-dlp`.

## try

Nì [try](https://github.com/tobi/try) e furasta deuchainnean prògramachaidh a stiùireadh le pasganan air a bheil stampa-cinn-latha. Tha gach deuchainn a' fuireach ann an `~/Work/tries` agus gheibh thu thuca le `try`.

Cha chuir Omarchy pasgan `bin/` pròiseict ris a' `PATH` gu fèin-obrachail. Ruith innealan ionadail pròiseict sa bheil earbsa agad le slighe dhàimheach shoilleir, mar `bin/rails` no `./bin/dev`.
