# Teksti eraldamine ja dikteerimine

### Teksti eraldamine

Vajuta `Super + Ctrl + PrtScr`, et valida ekraanil teksti eraldamiseks ala. Avatud lähtekoodiga tesseract OCR-mudel teisendab selle valiku seejärel kiiresti tekstiks ja paigutab selle lõikelauale. Seejärel vajuta kleepimiseks lihtsalt `Super + V`.

See on väga abiks aadresside haaramisel piltide jalustest või veebilehtede pealkirjadesse peidetud telefoninumbritest.

 ![text-extraction](images/text-extraction.webp)

### Dikteerimine

Uutel installidel on [Superwhisper](https://superwhisper.com/) vaikimisi dikteerimise taustaprogramm, mis kasutab pilvetöötlust ega nõua võrguühenduseta mudelite allalaadimist. Vali Omarchy menüüs _Seadistus > Vaikeseaded > Dikteerimine_ kaudu Superwhisper, [Voxtype](https://voxtype.io/) või [Hex](https://anoma.ly/hex/). Taustaprogrammi valimine installib selle vajadusel ja määrab selle dikteerimise vaikeseadeks. Voxtype laadib inglise keele baasmudeli, mis võtab 150MB; muuda mudelit käsuga `voxtype setup model` ja teisi seadeid faili `~/.config/voxtype/config.toml` kaudu. Superwhisper avab oma seaded, et valida pilve- või kohalik töötlus, ja OPR hoiab rakenduse ajakohasena. Hex laadib seadistamise ajal alla oma seadmesisese kõnemudeli ja töötab `hex.service` kasutajateenusena; ava selle aken riba salveikoonilt või käivitades `hex`, et muuta mudelit ja teisi seadeid.

Dikteerid hoides all `Right Alt` või lülitades `Alt + Space` abil, ja dikteeritud tekst ilmub fokuseeritud sisestusalale. Need otseteed kasutavad valitud taustaprogrammi. Right Alt käivitab dikteerimise ka siis, kui seda kasutatakse modifikaatoriklahviga kombinatsioonis; kasuta nende kombinatsioonide jaoks Left Alt. Klaviatuuripaigutustel, kus Right Alt on AltGr, kasuta `Alt + Space`, et AltGr jääks tippimiseks kättesaadavaks. Installid ajast enne, kui Alt + Space sai vaikeseadeks, säilitavad `F9` hoidmisega rääkimiseks ja `Super + Ctrl + X` lülitamiseks, lisatuna faili `~/.config/hypr/bindings.lua`, kus see `Super + Ctrl + X` asendab agentide paneeli; eemalda need sealt, et anda need klahvid rakendustele ja paneelile tagasi.

Samad otseteed töötavad iga taustaprogrammiga. Vali oma taustaprogramm Seadistus > Vaikeseaded > Dikteerimine kaudu. Taustaprogrammi installer seadistab selle ja salvestab valiku. Käivita `omarchy default dictation`, et näha, milline on valitud. Valik salvestatakse faili `~/.config/omarchy/defaults/dictation`. Uutel installidel on Superwhisper automaatselt valitud.

Omarchy laadib valitud taustaprogrammi töölauaintegratsiooni automaatselt. Kataloogis `~/.config/hypr/` pole Superwhisper jaoks seadistust vaja.

Kohandatud seosed ja skriptid saavad kasutada käske `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valitud taustaprogramm tegeleb salvestamise ja transkriptsiooniga. Superwhisper valimine keelab selle algse hoidmise otsetee ja määrab selle algseks lülituseks `Ctrl + Alt + Space`, hoides selle Omarchy salvestusklahvidest eraldi. Superwhisper nõuab vähemalt üht algset salvestamise otseteed ja selle tühistamise otsetee jääb kättesaadavaks.

Täiendavad taustaprogrammid saavad integreeruda ilma Omarchy muutmata. Paku PATH-is käivitatavat faili nimega `omarchy-dictation-<backend>`, mis aktsepteerib käske `start`, `stop` ja `toggle` ning naaseb viivitamatult, vea korral nullist erineva olekuga. Selle installer seadistab pakkuja ja kutsub pärast edukat seadistamist välja `omarchy-dictation-use <backend>`. See peatab eelmise taustaprogrammi ja salvestab valiku ühe aatomilise toiminguna; `stop` peab õnnestuma, kui pakkuja on jõude või kättesaamatu. Taustaprogrammide nimed kasutavad väiketähti, numbreid ja sidekriipse. Paku seadistamiseks `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käivitab selle. Lisa Omarchy menüü laienduse kaudu Vaikeseaded menüü kirje, et seda valijat välja kutsuda. Valikuline töölauaintegratsioon võib asuda failis `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
