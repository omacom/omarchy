# Zajem besedila in narekovanje

### Zajem besedila

Pritisnite `Super + Ctrl + PrtScr`, da izberete območje na zaslonu za zajem besedila. Odprtokodni OCR model tesseract bo nato to izbiro hitro pretvoril v besedilo in ga odložil v odložišče. Nato preprosto pritisnite `Super + V` za lepljenje.

To je zelo uporabno za zajemanje naslovov iz nog slik ali telefonskih številk, vdelanih v naslove spletnih strani.

 ![text-extraction](images/text-extraction.webp)

### Narekovanje

Pri svežih namestitvah je [Superwhisper](https://superwhisper.com/) privzeti zaledni sistem za narekovanje, ki uporablja obdelavo v oblaku brez prenosov modelov za uporabo brez povezave. Superwhisper, [Voxtype](https://voxtype.io/) ali [Hex](https://anoma.ly/hex/) izberete prek _Nastavitev > Privzete nastavitve > Narekovanje_ v meniju Omarchy. Izbira zalednega sistema ga po potrebi namesti in nastavi kot privzetega za narekovanje. Voxtype naloži osnovni angleški model, ki zasede 150MB; model spremenite z `voxtype setup model`, druge nastavitve pa prek `~/.config/voxtype/config.toml`. Superwhisper odpre svoje nastavitve za izbiro obdelave v oblaku ali lokalne obdelave, OPR pa skrbi za posodabljanje aplikacije. Hex med nastavitvijo prenese svoj model za govor na napravi in deluje kot uporabniška storitev `hex.service`; za spremembo modela in drugih nastavitev odprite njegovo okno z ikone v vrstici ali z zagonom ukaza `hex`.

Narekujete tako, da držite `Right Alt` ali preklapljate z `Alt + Space`, narekovano besedilo pa se bo prikazalo v fokusiranem vnosnem območju. Te bližnjice uporabljajo izbrani zaledni sistem. Right Alt zažene narekovanje tudi, ko je uporabljen v akordu modifikatorjev; za te akorde uporabite Left Alt. Na razporeditvah tipkovnice, kjer je Right Alt AltGr, uporabite `Alt + Space`, da AltGr ostane na voljo za tipkanje. Namestitve iz časa, preden je Alt + Space postal privzeta bližnjica, ohranijo `F9` za push-to-talk in `Super + Ctrl + X` za preklapljanje, dodani v `~/.config/hypr/bindings.lua`, kjer ta `Super + Ctrl + X` prevzame mesto plošče agentov; odstranite ju tam, da te tipke vrnete aplikacijam in plošči.

Iste bližnjice delujejo z vsakim zalednim sistemom. Svoj zaledni sistem izberite prek Nastavitev > Privzete nastavitve > Narekovanje. Namestitveni program zalednega sistema ga konfigurira in shrani izbiro. Zaženite `omarchy default dictation`, da vidite, kateri je izbran. Izbira je shranjena v `~/.config/omarchy/defaults/dictation`. Sveže namestitve samodejno izberejo Superwhisper.

Omarchy samodejno naloži namizno integracijo izbranega zalednega sistema. V `~/.config/hypr/` ni potrebna nobena konfiguracija za Superwhisper.

Bližnjice in skripti po meri lahko uporabljajo `omarchy dictation start`, `omarchy dictation stop` in `omarchy dictation toggle`. Izbrani zaledni sistem poskrbi za snemanje in prepis. Izbira Superwhisper onemogoči njegovo izvorno bližnjico za držanje in nastavi njegov izvorni preklop na `Ctrl + Alt + Space`, da ostane ločen od snemalnih tipk Omarchy. Superwhisper zahteva vsaj eno izvorno bližnjico za snemanje, njegova bližnjica za preklic pa ostane na voljo.

Dodatni zaledni sistemi se lahko integrirajo brez spreminjanja sistema Omarchy. Zagotovite izvedljivo datoteko z imenom `omarchy-dictation-<backend>` na PATH, ki sprejme `start`, `stop` in `toggle` ter se takoj vrne, ob napaki pa z statusom, različnim od nič. Njen namestitveni program konfigurira ponudnika in po uspešni namestitvi pokliče `omarchy-dictation-use <backend>`. To ustavi prejšnji zaledni sistem in atomarno shrani izbiro; `stop` mora uspeti, ko je ponudnik nedejaven ali nedosegljiv. Imena zalednih sistemov uporabljajo male črke, številke in vezaje. Za namestitev zagotovite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ga zažene. Dodajte vnos v meni Privzete nastavitve prek razširitve menija Omarchy, da pokličete ta izbirnik. Izbirna namizna integracija lahko živi v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
