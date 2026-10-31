# Zajem besedila in narekovanje

### Zajem besedila

Pritisnite `Super + Ctrl + PrtScr`, da izberete območje na zaslonu za zajem besedila. Odprtokodni model OCR tesseract bo nato ta izbor hitro pretvoril v besedilo in ga odložil v odložišče. Nato samo pritisnete `Super + V` za lepljenje.

To je zelo priročno za zajemanje naslovov iz nog slik ali telefonskih številk, vdelanih v naslove spletnih strani.

 ![text-extraction](images/text-extraction.webp)

### Narekovanje

Pri svežih namestitvah je [Superwhisper](https://superwhisper.com/) privzeti zaledni sistem za narekovanje, ki uporablja obdelavo v oblaku brez prenosov modelov za uporabo brez povezave. Superwhisper ali [Voxtype](https://voxtype.io/) izberete prek _Setup > Defaults > Dictation_ v meniju Omarchy. Izbira zalednega sistema ga po potrebi namesti in nastavi kot privzetega za narekovanje. Voxtype naloži osnovni angleški model, ki zasede 150MB; model zamenjate z `voxtype setup model`, druge nastavitve pa prek `~/.config/voxtype/config.toml`. Superwhisper odpre svoje nastavitve za izbiro obdelave v oblaku ali lokalne obdelave, OPR pa skrbi za posodabljanje aplikacije.

Narekujete tako, da držite `Right Alt` ali preklapljate z `Alt + Space`, narekovano besedilo pa se bo pojavilo v osredotočenem vnosnem polju. Te bližnjice uporabljajo izbrani zaledni sistem. Right Alt zažene narekovanje tudi, ko ga uporabite v kombinaciji modifikacijskih tipk; za te kombinacije uporabite Left Alt. Na razporeditvah tipkovnice, kjer je Right Alt hkrati AltGr, uporabite `Alt + Space`, da AltGr ostane na voljo za tipkanje. Namestitve iz časa, preden je Alt + Space postal privzet, ohranijo `F9` za pritisni-in-govori in `Super + Ctrl + X` za preklop, dodana v `~/.config/hypr/bindings.lua`; odstranite ju tam, da ti tipki vrnete aplikacijam.

Iste bližnjice delujejo z obema zalednima sistemoma. Zaledni sistem izberete prek Setup > Defaults > Dictation. Namestitveni program zalednega sistema ga konfigurira in shrani izbiro. Zaženite `omarchy default dictation`, da vidite, kateri je izbran. Izbira je shranjena v `~/.config/omarchy/defaults/dictation`. Sveže namestitve samodejno izberejo Superwhisper.

Omarchy samodejno naloži namizno integracijo izbranega zalednega sistema. V `~/.config/hypr/` ni potrebna nobena konfiguracija za Superwhisper.

Vezave po meri in skripti lahko uporabljajo `omarchy dictation start`, `omarchy dictation stop` in `omarchy dictation toggle`. Izbrani zaledni sistem poskrbi za snemanje in prepisovanje. Izbira Superwhisper onemogoči njegovo izvorno bližnjico za držanje in nastavi njegov izvorni preklop na `Ctrl + Alt + Space`, tako da ostane ločen od snemalnih tipk Omarchy. Superwhisper zahteva vsaj eno izvorno bližnjico za snemanje, njegova bližnjica za preklic pa ostane na voljo.

Dodatni zaledni sistemi se lahko integrirajo brez spreminjanja Omarchy. Zagotovite izvedljivo datoteko z imenom `omarchy-dictation-<backend>` v PATH, ki sprejme `start`, `stop` in `toggle` ter se takoj vrne, ob napaki pa s statusom, različnim od nič. Njen namestitveni program konfigurira ponudnika in po uspešni nastavitvi pokliče `omarchy-dictation-use <backend>`. To ustavi prejšnji zaledni sistem in atomarno shrani izbiro; `stop` mora uspeti, ko je ponudnik nedejaven ali nedosegljiv. Imena zalednih sistemov uporabljajo male črke, števke in vezaje. Za nastavitev zagotovite `omarchy-install-dictation-<backend>`; zažene ga `omarchy default dictation <backend>`. Vnos v meni Defaults za klic tega izbirnika dodajte prek razširitve menija Omarchy. Izbirna namizna integracija lahko živi v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
