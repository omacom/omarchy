# Pridobivanje besedila in narekovanje

### Pridobivanje besedila

Pritisnite `Super + Ctrl + PrtScr`, da izberete območje na zaslonu za pridobivanje besedila. Odprtokodni model OCR tesseract bo nato to izbiro hitro pretvoril v besedilo in ga odložil v odložišče. Nato samo pritisnete `Super + V`, da ga prilepite.

To je zelo priročno za zajemanje naslovov iz nog slik ali telefonskih številk, vdelanih v naslove spletnih strani.

 ![text-extraction](images/text-extraction.webp)

### Narekovanje

Pri svežih namestitvah je [Superwhisper](https://superwhisper.com/) privzeti zaledni sistem za narekovanje, ki uporablja obdelavo v oblaku brez prenosov modelov za uporabo brez povezave. Superwhisper, [Voxtype](https://voxtype.io/) ali [Hex](https://anoma.ly/hex/) izberete prek _Nastavitve > Privzete nastavitve > Narekovanje_ v meniju Omarchy. Izbira zalednega sistema ga po potrebi namesti in nastavi kot privzetega za narekovanje. Voxtype naloži osnovni angleški model, ki zavzame 150MB; model zamenjate z `voxtype setup model`, druge nastavitve pa prek `~/.config/voxtype/config.toml`. Superwhisper odpre svoje nastavitve, da izberete obdelavo v oblaku ali lokalno obdelavo, OPR pa skrbi, da je aplikacija posodobljena. Hex med namestitvijo prenese svoj model govora v napravi in se izvaja kot uporabniška storitev `hex.service`; njegovo okno odprete z ikone v sistemski vrstici v vrstici ali tako, da zaženete `hex`, če želite zamenjati model in druge nastavitve.

Narekujete tako, da držite `Right Alt`, ali pa s preklopom z `Alt + Space`, in narekovano besedilo se bo pojavilo v osredotočenem območju za vnos. Te bližnjice uporabljajo izbrani zaledni sistem. Right Alt sproži narekovanje tudi, kadar ga uporabite v kombinaciji modifikatorjev; za te kombinacije uporabite Left Alt. Pri razporeditvah tipkovnice, pri katerih je Right Alt AltGr, uporabite `Alt + Space`, da AltGr ostane na voljo za tipkanje. Namestitve iz časa, preden je Alt + Space postal privzet, ohranijo `F9` za pritisni-in-govori in `Super + Ctrl + X` za preklop, dodana v `~/.config/hypr/bindings.lua`; odstranite ju tam, da te tipke vrnete aplikacijam.

Iste bližnjice delujejo z vsakim zalednim sistemom. Zaledni sistem izberete prek Nastavitve > Privzete nastavitve > Narekovanje. Namestitveni program zalednega sistema ga konfigurira in shrani izbiro. Zaženite `omarchy default dictation`, da vidite, kateri je izbran. Izbira je shranjena v `~/.config/omarchy/defaults/dictation`. Sveže namestitve samodejno izberejo Superwhisper.

Omarchy samodejno naloži integracijo z namizjem za izbrani zaledni sistem. V `~/.config/hypr/` ni potrebna nobena konfiguracija za Superwhisper.

Vezave po meri in skripti lahko uporabljajo `omarchy dictation start`, `omarchy dictation stop` in `omarchy dictation toggle`. Izbrani zaledni sistem poskrbi za snemanje in prepis. Izbira Superwhisperja onemogoči njegovo izvorno bližnjico za držanje in njegov izvorni preklop nastavi na `Ctrl + Alt + Space`, da ostane ločen od tipk za snemanje v Omarchy. Superwhisper zahteva vsaj eno izvorno bližnjico za snemanje, njegova bližnjica za preklic pa ostane na voljo.

Dodatni zaledni sistemi se lahko integrirajo brez spreminjanja Omarchy. Poskrbite za izvedljivo datoteko z imenom `omarchy-dictation-<backend>` v PATH, ki sprejme `start`, `stop` in `toggle` ter se takoj vrne, ob napaki pa s statusom, ki ni ničeln. Njegov namestitveni program konfigurira ponudnika in po uspešni namestitvi pokliče `omarchy-dictation-use <backend>`. To ustavi prejšnji zaledni sistem in izbiro shrani atomarno; `stop` mora uspeti, kadar je ponudnik nedejaven ali nedosegljiv. Imena zalednih sistemov uporabljajo male črke, števke in vezaje. Za namestitev poskrbite za `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ga zažene. Vnos v meni Privzete nastavitve za klic tega izbirnika dodajte prek razširitve menija Omarchy. Izbirna integracija z namizjem lahko živi v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
