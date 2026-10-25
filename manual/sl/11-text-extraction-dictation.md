# Izvlečenje besedila in narekovanje

### Izvlečenje besedila

Pritisnite `Super + Ctrl + PrtScr`, da izberete območje na zaslonu za izvlečenje besedila. Odprtokodni model OCR tesseract bo nato izbor hitro pretvoril v besedilo in ga dal v odložišče. Nato samo pritisnete `Super + V` za lepljenje.

To je zelo koristno za pobiranje naslovov iz nog slik ali telefonskih številk, vdelanih v naslove spletnih strani.

 ![text-extraction](images/text-extraction.webp)

### Narekovanje

Pri novih namestitvah je [Superwhisper](https://superwhisper.com/) privzeti mehanizem za narekovanje, ki uporablja obdelavo v oblaku brez prenosov modelov za uporabo brez povezave. Superwhisper ali [Voxtype](https://voxtype.io/) izberete prek _Setup > Defaults > Dictation_ v meniju Omarchy. Izbira mehanizma ga namesti, če je potrebno, in ga nastavi kot privzetega za narekovanje. Voxtype naloži osnovni angleški model, velik 150 MB; model zamenjate z `voxtype setup model`, druge nastavitve pa prek `~/.config/voxtype/config.toml`. Superwhisper odpre svoje nastavitve za izbiro obdelave v oblaku ali lokalno, OPR pa aplikacijo ohranja posodobljeno.

Narekujete tako, da držite `Right Alt` ali `F9` ali preklapljate s `Super + Ctrl + X`, narekovano besedilo pa se bo pojavilo v osredotočenem vnosnem območju. Te bližnjice uporabljajo izbrani mehanizem. Right Alt začne narekovanje tudi, ko se uporabi v akordu z modifikatorjem; za te akorde uporabite Left Alt. Pri razporedih tipkovnice, kjer je Right Alt AltGr, uporabite `F9`, da ohranite AltGr na voljo za tipkanje.

Iste bližnjice delujejo s katerim koli mehanizmom. Mehanizem izberete prek Setup > Defaults > Dictation. Namestitveni program mehanizma ga konfigurira in shrani izbiro. Zaženite `omarchy default dictation`, da vidite, kateri je izbran. Izbira se shrani v `~/.config/omarchy/defaults/dictation`. Nove namestitve samodejno izberejo Superwhisper.

Omarchy samodejno naloži integracijo izbranega mehanizma za namizje. V `~/.config/hypr/` ni potrebna nobena konfiguracija Superwhispera.

Vezave po meri in skripti lahko uporabljajo `omarchy dictation start`, `omarchy dictation stop` in `omarchy dictation toggle`. Izbrani mehanizem poskrbi za snemanje in prepis. Izbira Superwhispera onemogoči njegovo izvorno bližnjico za držanje in izvorni preklop nastavi na `Alt + Space`, tako da je ločen od tipk za snemanje Omarchyja. Superwhisper zahteva vsaj eno izvorno bližnjico za snemanje, njegova bližnjica za preklic pa ostane na voljo.

Dodatni mehanizmi se lahko integrirajo brez spreminjanja Omarchyja. Na PATH zagotovite izvedljivo datoteko z imenom `omarchy-dictation-<backend>`, ki sprejema `start`, `stop` in `toggle` ter se takoj vrne, ob neuspehu pa vrne status, različen od nič. Njegov namestitveni program konfigurira ponudnika in po uspešni nastavitvi pokliče `omarchy-dictation-use <backend>`. To zaustavi prejšnji mehanizem in izbiro shrani atomarno; `stop` mora uspeti, ko je ponudnik nedejaven ali nedosegljiv. Imena mehanizmov uporabljajo male črke, številke in vezaje. Za nastavitev zagotovite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ga zažene. Vnos v meni Defaults dodajte prek razširitve menija Omarchy, da pokličete ta izbirnik. Neobvezna integracija za namizje je lahko v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
