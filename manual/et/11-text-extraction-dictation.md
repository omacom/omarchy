# Teksti ekstraheerimine ja dikteerimine

### Teksti ekstraheerimine

Ekraanilt piirkonna valimiseks teksti ekstraheerimiseks vajuta `Super + Ctrl + PrtScr`. Avatud lähtekoodiga OCR-mudel tesseract teisendab seejärel valiku kiiresti tekstiks ja asetab selle lõikelauale. Seejärel vajuta lihtsalt kleepimiseks `Super + V`.

See on väga kasulik aadresside haaramiseks piltide jalustest või veebisaitide pealkirjadesse manustatud telefoninumbritest.

 ![text-extraction](images/text-extraction.webp)

### Dikteerimine

Värsketel installidel on [Superwhisper](https://superwhisper.com/) vaikimisi dikteerimise taustsüsteem, mis kasutab pilvetöötlust ilma võrguühenduseta mudelite allalaadimiseta. Vali Omarchy menüüs _Setup > Defaults > Dictation_ kaudu Superwhisper, [Voxtype](https://voxtype.io/) või [Hex](https://anoma.ly/hex/). Taustsüsteemi valimine installib selle vajadusel ja muudab selle dikteerimise vaikeseadeks. Voxtype laadib inglise keele baasmudeli, mis võtab 150MB; muuda mudelit käsuga `voxtype setup model` ja muid seadeid faili `~/.config/voxtype/config.toml` kaudu. Superwhisper avab oma seaded pilve- või kohaliku töötluse valimiseks ja OPR hoiab rakenduse ajakohasena. Hex laadib seadistamise ajal alla oma seadmesisese kõnemudeli ja töötab kasutajateenusena `hex.service`; mudeli ja muude seadete muutmiseks ava selle aken riba salveikoonilt või käivitades käsu `hex`.

Dikteerid hoides all `Right Alt` või lülitades klahvikombinatsiooniga `Alt + Space` ja dikteeritud tekst ilmub fokuseeritud sisestusalasse. Need otseteed kasutavad valitud taustsüsteemi. Right Alt käivitab dikteerimise ka modifikaatoriakordis kasutamisel; nende akordide puhul kasuta Left Alt. Klaviatuuripaigutustel, kus Right Alt on AltGr, kasuta `Alt + Space`, et AltGr jääks tippimiseks kättesaadavaks. Installid ajast, mil Alt + Space veel vaikeseade polnud, säilitavad kõneks allhoidmiseks klahvi `F9` ja lülitamiseks klahvikombinatsiooni `Super + Ctrl + X`, mis on lisatud faili `~/.config/hypr/bindings.lua`; eemalda need sealt, et anda need klahvid rakendustele tagasi.

Samad otseteed töötavad iga taustsüsteemiga. Vali oma taustsüsteem Setup > Defaults > Dictation kaudu. Taustsüsteemi installer konfigureerib selle ja salvestab valiku. Käivita `omarchy default dictation`, et näha, milline on valitud. Valik salvestatakse faili `~/.config/omarchy/defaults/dictation`. Värsked installid valivad automaatselt Superwhisperi.

Omarchy laadib valitud taustsüsteemi töölauaintegratsiooni automaatselt. Superwhisperi konfigureerimine kaustas `~/.config/hypr/` pole vajalik.

Kohandatud seosed ja skriptid saavad kasutada käske `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valitud taustsüsteem tegeleb salvestamise ja transkriptsiooniga. Superwhisperi valimine keelab selle loomuliku allhoidmise otsetee ja määrab selle loomulikuks lülitiks `Ctrl + Alt + Space`, hoides selle Omarchy salvestusklahvidest eraldi. Superwhisper nõuab vähemalt ühte loomulikku salvestamise otseteed ja selle tühistamise otsetee jääb kättesaadavaks.

Täiendavad taustsüsteemid saavad integreeruda Omarchyt muutmata. Paku PATH-is käivitatavat faili nimega `omarchy-dictation-<backend>`, mis aktsepteerib käske `start`, `stop` ja `toggle` ning naaseb kohe, rikke korral nullist erineva olekuga. Selle installer konfigureerib teenusepakkuja ja kutsub pärast edukat seadistamist välja `omarchy-dictation-use <backend>`. See peatab eelmise taustsüsteemi ja salvestab valiku aatomiliselt; `stop` peab õnnestuma, kui teenusepakkuja on jõude või kättesaamatu. Taustsüsteemide nimed kasutavad väiketähti, numbreid ja sidekriipse. Paku seadistamiseks `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käivitab selle. Lisa Defaults menüükirje Omarchy menüülaienduse kaudu selle valija kutsumiseks. Valikuline töölauaintegratsioon võib asuda asukohas `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
