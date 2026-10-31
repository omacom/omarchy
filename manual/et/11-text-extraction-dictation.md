# Teksti eraldamine ja dikteerimine

### Teksti eraldamine

Vajuta `Super + Ctrl + PrtScr`, et valida ekraanil piirkond teksti eraldamiseks. Avatud lähtekoodiga OCR-mudel tesseract muudab selle valiku seejärel kiiresti tekstiks ja paigutab selle lõikelauale. Seejärel vajuta lihtsalt `Super + V`, et kleepida.

See on väga kasulik aadresside haaramiseks piltide jalustest või veebilehtede pealkirjadesse manustatud telefoninumbrite haaramiseks.

 ![text-extraction](images/text-extraction.webp)

### Dikteerimine

Värsketel installatsioonidel on [Superwhisper](https://superwhisper.com/) dikteerimise vaiketaustaprogramm, mis kasutab pilvetöötlust ilma võrguühenduseta mudelite allalaadimiseta. Vali Superwhisper või [Voxtype](https://voxtype.io/) Omarchy menüüs _Setup > Defaults > Dictation_ kaudu. Taustaprogrammi valimine installib selle vajadusel ja määrab selle dikteerimise vaikevalikuks. Voxtype laadib ingliskeelse baasmudeli, mis võtab 150MB; muuda mudelit käsuga `voxtype setup model` ja muid seadistusi faili `~/.config/voxtype/config.toml` kaudu. Superwhisper avab oma seadistused, et valida pilve- või kohalik töötlus, ja OPR hoiab rakendust ajakohasena.

Dikteerid, hoides all `Right Alt`, või lülitades `Alt + Space` abil, ja dikteeritud tekst ilmub fokuseeritud sisestusalasse. Need otseteed kasutavad valitud taustaprogrammi. Right Alt käivitab dikteerimise ka siis, kui seda kasutatakse modifikaatoriakordis; kasuta nende akordide jaoks Left Alt. Klaviatuuripaigutustel, kus Right Alt on AltGr, kasuta `Alt + Space`, et AltGr jääks trükkimiseks kättesaadavaks. Installatsioonid ajast enne seda, kui Alt + Space sai vaikevalikuks, säilitavad `F9` vajuta-ja-räägi jaoks ja `Super + Ctrl + X` lülitamiseks, mis on lisatud faili `~/.config/hypr/bindings.lua`; eemalda need sealt, et anda need klahvid rakendustele tagasi.

Samad otseteed töötavad mõlema taustaprogrammiga. Vali oma taustaprogramm Setup > Defaults > Dictation kaudu. Taustaprogrammi installija konfigureerib selle ja salvestab valiku. Käivita `omarchy default dictation`, et näha, milline on valitud. Valik salvestatakse faili `~/.config/omarchy/defaults/dictation`. Värsked installatsioonid valivad Superwhisperi automaatselt.

Omarchy laadib valitud taustaprogrammi töölauaintegratsiooni automaatselt. Superwhisperi konfigureerimine kaustas `~/.config/hypr/` pole vajalik.

Kohandatud seosed ja skriptid saavad kasutada käske `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valitud taustaprogramm tegeleb salvestamise ja transkriptsiooniga. Superwhisperi valimine keelab selle omase allhoidmise otsetee ja seab selle omase lüliti väärtuseks `Ctrl + Alt + Space`, hoides selle Omarchy salvestusklahvidest eraldi. Superwhisper nõuab vähemalt ühte omast salvestamise otseteed ja selle tühistamise otsetee jääb kättesaadavaks.

Täiendavad taustaprogrammid saavad integreeruda Omarchyt muutmata. Paku käivitatavat faili nimega `omarchy-dictation-<backend>` PATH-il, mis aktsepteerib käske `start`, `stop` ja `toggle` ning naaseb kiiresti, tõrke korral nullist erineva olekuga. Selle installija konfigureerib teenusepakkuja ja kutsub pärast edukat seadistamist välja käsu `omarchy-dictation-use <backend>`. See peatab eelmise taustaprogrammi ja salvestab valiku aatomiliselt; `stop` peab õnnestuma, kui teenusepakkuja on jõude või kättesaamatu. Taustaprogrammide nimed kasutavad väiketähti, numbreid ja sidekriipse. Paku seadistamiseks `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käivitab selle. Lisa Defaults menüükirje Omarchy menüülaienduse kaudu, et seda valijat välja kutsuda. Valikuline töölauaintegratsioon võib asuda failis `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
