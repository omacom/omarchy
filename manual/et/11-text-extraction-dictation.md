# Teksti eraldamine ja dikteerimine

### Teksti eraldamine

Teksti eraldamiseks ekraanil piirkonna valimiseks vajuta `Super + Ctrl + PrtScr`. Avatud lähtekoodiga OCR-mudel tesseract teisendab seejärel valiku kiiresti tekstiks ja paigutab selle lõikelauale. Seejärel vajuta kleepimiseks lihtsalt `Super + V`.

See on väga kasulik aadresside haaramiseks piltide jalustest või veebilehtede pealkirjadesse manustatud telefoninumbritest.

 ![text-extraction](images/text-extraction.webp)

### Dikteerimine

Värsketel installidel on [Superwhisper](https://superwhisper.com/) vaikimisi dikteerimise taustaprogramm, mis kasutab pilvetöötlust ilma ühenduseta mudelite allalaadimiseta. Vali Superwhisper, [Voxtype](https://voxtype.io/) või [Hex](https://anoma.ly/hex/) Omarchy menüüs _Setup > Defaults > Dictation_ kaudu. Taustaprogrammi valimine installib selle vajaduse korral ja muudab selle dikteerimise vaikesätteks. Voxtype laadib ingliskeelse baasmudeli, mis võtab 150MB; muuda mudelit käsuga `voxtype setup model` ja muid sätteid faili `~/.config/voxtype/config.toml` kaudu. Superwhisper avab selle sätted, et valida pilve- või kohalik töötlus, ja OPR hoiab rakenduse ajakohasena. Hex laadib seadistamise ajal alla oma seadmesisese kõnemudeli ja töötab kasutajateenusena `hex.service`; selle akna avamiseks mudeli ja muude sätete muutmiseks kasuta riba salveikooni või käivita `hex`.

Dikteerimiseks hoia all `Right Alt` või lülita `Alt + Space` abil, ja dikteeritud tekst ilmub fokuseeritud sisestusalale. Need otseteed kasutavad valitud taustaprogrammi. Right Alt käivitab dikteerimise ka modifikaatoriakordis kasutamisel; nende akordide puhul kasuta Left Alt. Klaviatuuripaigutustel, kus Right Alt on AltGr, sealhulgas siis, kui selline paigutus on üks neist, millele sa ümber lülitud, hoia seda dikteerimiseks hetke omaette all; AltGr koos mõne muu klahviga vajutatuna sisestab ikka oma märgi. Installid ajast, enne kui Alt + Space sai vaikesätteks, säilitavad `F9` vajuta-ja-räägi jaoks ja `Super + Ctrl + X` lülitamiseks, lisatuna faili `~/.config/hypr/bindings.lua`, kus see `Super + Ctrl + X` asendab agentide paneeli; eemalda need sealt, et anda need klahvid rakendustele ja paneelile tagasi.

Samad otseteed töötavad iga taustaprogrammiga. Vali oma taustaprogramm Setup > Defaults > Dictation kaudu. Taustaprogrammi installer konfigureerib selle ja salvestab valiku. Käivita `omarchy default dictation`, et näha, milline on valitud. Valik salvestatakse faili `~/.config/omarchy/defaults/dictation`. Värsked installid valivad Superwhisperi automaatselt.

Omarchy laadib valitud taustaprogrammi töölauaintegratsiooni automaatselt. Superwhisperi konfigureerimine kaustas `~/.config/hypr/` ei ole vajalik.

Kohandatud seosed ja skriptid saavad kasutada käske `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valitud taustaprogramm tegeleb salvestamise ja transkriptsiooniga. Superwhisperi valimine keelab selle loomuliku allhoidmise otsetee ja seab selle loomulikuks lülitiks `Ctrl + Alt + Space`, hoides selle Omarchy salvestusklahvidest eraldi. Superwhisper nõuab vähemalt ühte loomulikku salvestusotseteed ja selle tühistamisotsetee jääb saadaval.

Täiendavad taustaprogrammid saavad integreeruda Omarchyt muutmata. Pakku PATH-is käivitatavat faili nimega `omarchy-dictation-<backend>`, mis aktsepteerib käske `start`, `stop` ja `toggle`, tagastab kiiresti ja annab rikke korral nullist erineva oleku. Selle installer konfigureerib pakkuja ja kutsub pärast edukat seadistamist välja käsu `omarchy-dictation-use <backend>`. See peatab eelmise taustaprogrammi ja salvestab valiku aatomiliselt; `stop` peab õnnestuma, kui pakkuja on jõude või saadaval pole. Taustaprogrammide nimed kasutavad väiketähti, numbreid ja sidekriipse. Seadistamiseks pakku `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käivitab selle. Lisa selle valija kutsumiseks Omarchy menüülaienduse kaudu Defaults menüükirje. Valikuline töölauaintegratsioon võib asuda asukohas `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
