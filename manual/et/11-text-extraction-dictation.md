# Teksti eraldamine ja dikteerimine

### Teksti eraldamine

Vajuta `Super + Ctrl + PrtScr`, et valida ekraanil piirkond teksti eraldamiseks. Avatud lähtekoodiga OCR-mudel tesseract teisendab selle valiku seejärel kiiresti tekstiks ja paneb selle lõikelauale. Seejärel vajutad lihtsalt `Super + V`, et kleepida.

See on väga kasulik aadresside haaramiseks piltide jalustest või veebisaidi pealkirjadesse sisestatud telefoninumbritest.

 ![text-extraction](images/text-extraction.webp)

### Dikteerimine

Värsketel paigaldustel on [Superwhisper](https://superwhisper.com/) vaikimisi dikteerimistaust, kasutades pilvetöötlust ilma võrguta mudelite allalaadimisteta. Vali Superwhisper või [Voxtype](https://voxtype.io/) Omarchy menüüs _Seaded > Vaikimisi > Dikteerimine_ kaudu. Taustasüsteemi valimine paigaldab selle vajaduse korral ja muudab selle dikteerimise vaikimisi valikuks. Voxtype laadib baas-inglise mudeli, mis võtab 150MB; muuda mudelit `voxtype setup model` abil ja muid seadeid `~/.config/voxtype/config.toml` kaudu. Superwhisper avab oma seaded pilve- või kohaliku töötluse valimiseks ja OPR hoiab rakenduse ajakohasena.

Dikteerid `Right Alt` või `F9` all hoides või `Super + Ctrl + X` abil lülitades ja dikteeritud tekst ilmub fookuses olevasse sisestusalasse. Need otseteed kasutavad valitud taustasüsteemi. Right Alt alustab dikteerimist ka siis, kui seda kasutatakse modifikaatori kooskõlas; nende kooskõlade jaoks kasuta Left Altti. Klaviatuuripaigutustes, kus Right Alt on AltGr, kasuta `F9`, et hoida AltGr trükkimiseks saadaval.

Samad otseteed toimivad mõlema taustasüsteemiga. Vali oma taustasüsteem Seaded > Vaikimisi > Dikteerimine kaudu. Taustasüsteemi paigaldaja seadistab selle ja salvestab valiku. Käivita `omarchy default dictation`, et näha, milline on valitud. Valik salvestatakse `~/.config/omarchy/defaults/dictation`-isse. Värsked paigaldused valivad Superwhisperi automaatselt.

Omarchy laadib valitud taustasüsteemi töölaua integratsiooni automaatselt. Superwhisperi seadistust pole vaja `~/.config/hypr/`-is.

Kohandatud seosed ja skriptid saavad kasutada `omarchy dictation start`, `omarchy dictation stop` ja `omarchy dictation toggle`. Valitud taustasüsteem tegeleb salvestamise ja transkribeerimisega. Superwhisperi valimine keelab selle natiivse hoia-otsetee ja seab selle natiivse lüliti `Alt + Space` peale, hoides selle Omarchy salvestusklahvidest eraldi. Superwhisper nõuab vähemalt ühte natiivset salvestusotseteed ja selle tühistamise otsetee jääb kättesaadavaks.

Täiendavad taustasüsteemid saavad integreeruda Omarchyt muutmata. Paku PATH-il käivitatavat faili nimega `omarchy-dictation-<backend>`, mis võtab vastu `start`, `stop` ja `toggle` ning naaseb kiiresti, tõrke korral nullist erineva olekuga. Selle paigaldaja seadistab pakkuja ja kutsub pärast edukat seadistust `omarchy-dictation-use <backend>`. See peatab eelmise taustasüsteemi ja salvestab valiku aatomiliselt; `stop` peab õnnestuma, kui pakkuja on jõude või kättesaamatu. Taustasüsteemide nimed kasutavad väiketähti, numbreid ja sidekriipse. Paku seadistamiseks `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` käivitab selle. Lisa Vaikimisi menüü kirje Omarchy menüü laienduse kaudu, et seda valijat kutsuda. Valikuline töölaua integratsioon võib asuda `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`-is.
