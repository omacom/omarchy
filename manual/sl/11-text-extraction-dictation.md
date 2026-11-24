# Pridobivanje besedila in narekovanje

### Pridobivanje besedila

Pritisnite `Super + Ctrl + PrtScr`, da izberete območje na zaslonu za pridobivanje besedila. Odprtokodni OCR-model tesseract bo to izbiro nato hitro pretvoril v besedilo in ga odložil v odložišče. Nato samo pritisnite `Super + V`, da prilepite.

To je zelo priročno za zajemanje naslovov iz nog slik ali telefonskih številk, vdelanih v naslove spletnih strani.

 ![text-extraction](images/text-extraction.webp)

### Narekovanje

Pri novih namestitvah je [Superwhisper](https://superwhisper.com/) privzeti vmesnik za narekovanje, ki uporablja obdelavo v oblaku brez prenosov modelov za uporabo brez povezave. Superwhisper, [Voxtype](https://voxtype.io/) ali [Hex](https://anoma.ly/hex/) izberete prek _Setup > Defaults > Dictation_ v meniju Omarchy. Izbira vmesnika ga po potrebi namesti in nastavi kot privzetega za narekovanje. Voxtype naloži osnovni angleški model, ki zasede 150MB; model zamenjate z `voxtype setup model`, druge nastavitve pa prek `~/.config/voxtype/config.toml`. Superwhisper odpre svoje nastavitve za izbiro obdelave v oblaku ali lokalne obdelave, OPR pa skrbi za posodabljanje aplikacije. Hex med namestitvijo prenese svoj model za prepoznavanje govora na napravi in se izvaja kot uporabniška storitev `hex.service`; njegovo okno odprete prek ikone v sistemski vrstici ali z ukazom `hex`, če želite zamenjati model in druge nastavitve.

Narekujete tako, da držite `Right Alt`, ali pa z `Alt + Space` preklopite narekovanje, in narekovano besedilo se prikaže v fokusiranem vnosnem polju. Te bližnjice uporabljajo izbrani vmesnik. Right Alt zažene narekovanje tudi, ko ga uporabite v kombinaciji z modifikacijskimi tipkami; za te kombinacije uporabite Left Alt. Pri razporeditvah tipkovnice, kjer je Right Alt AltGr, tudi kadar je takšna razporeditev ena od tistih, med katerimi preklapljate, ga kratek čas držite samega, če želite narekovati; AltGr, pritisnjen skupaj z drugo tipko, še vedno vtipka svoj znak. Namestitve iz časa, preden je Alt + Space postal privzet, ohranijo `F9` za push-to-talk in `Super + Ctrl + X` za preklop, dodana v `~/.config/hypr/bindings.lua`, kjer ta `Super + Ctrl + X` prevzame mesto plošče z agenti; odstranite ju tam, da te tipke vrnete aplikacijam in plošči.

Iste bližnjice delujejo z vsakim vmesnikom. Vmesnik izberete prek Setup > Defaults > Dictation. Namestitveni program vmesnika ga konfigurira in shrani izbiro. Zaženite `omarchy default dictation`, da vidite, kateri je izbran. Izbira je shranjena v `~/.config/omarchy/defaults/dictation`. Nove namestitve samodejno izberejo Superwhisper.

Omarchy samodejno naloži namizno integracijo izbranega vmesnika. V `~/.config/hypr/` ni potrebna nobena konfiguracija za Superwhisper.

Bližnjice in skripti po meri lahko uporabljajo `omarchy dictation start`, `omarchy dictation stop` in `omarchy dictation toggle`. Izbrani vmesnik poskrbi za snemanje in prepis. Izbira Superwhisperja onemogoči njegovo izvorno bližnjico za držanje in njegov izvorni preklop nastavi na `Ctrl + Alt + Space`, tako da ostane ločen od snemalnih tipk v Omarchy. Superwhisper zahteva vsaj eno izvorno bližnjico za snemanje, njegova bližnjica za preklic pa ostane na voljo.

Dodatni vmesniki se lahko integrirajo brez spreminjanja sistema Omarchy. Zagotovite izvedljivo datoteko z imenom `omarchy-dictation-<backend>` v PATH, ki sprejme `start`, `stop` in `toggle`, se takoj vrne ter ob napaki vrne neničelni status. Njen namestitveni program konfigurira ponudnika in po uspešni nastavitvi pokliče `omarchy-dictation-use <backend>`. To ustavi prejšnji vmesnik in izbiro shrani atomarno; `stop` mora uspeti, tudi ko ponudnik miruje ali ni na voljo. Imena vmesnikov uporabljajo male črke, številke in vezaje. Za namestitev zagotovite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ga zažene. Prek razširitve menija Omarchy dodajte vnos v meni Defaults, ki kliče ta izbirnik. Izbirna namizna integracija je lahko v `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
