# Oma teema loomine

Saad lisada oma teemad asukohta `~/.config/omarchy/themes`. Kopeeri lihtsalt üks olemasolevatest aluseks (vaata asukohta `/usr/share/omarchy/themes`) ja kohanda siis oma rõõmuks. Kuni sinu teema on selles kaustas, lisatakse see teemavaliku menüüsse.

Peamine fail, mida pead kohandama, on `colors.toml`. See määrab värvikomplekti, mida seejärel kasutatakse konfiguratsioonide loomiseks terminalile (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ja kogu Omarchy kesta (ülariba, menüü, teavitused, OSD ja lukustuskuva) jaoks.

Saad kasutada ka kaasasolevat rakendust Aether, et luua uus teema meeldiva GUI liidese abil, kus saad mängida värvidega ja otsida taustu. Käivita see lihtsalt rakenduste ruudustikus klahvidega `Super + Alt + Space`.

### Mida installitud teema võib sisaldada

Teema, mille kirjutad ise asukohta `~/.config/omarchy/themes`, võib sisaldada mida iganes soovid — see on sinu masin ja sinu fail ning Omarchy rakendab selle kõik.

Teema, mille installid kellegi teise repositooriumist käsuga `omarchy theme install`, säilitab kõik, mis on värv, ja kaotab need vähesed failid, mis käivitaksid sinu masinas koodi: kõik `.lua` failid, terminali konfiguratsioonid (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teema `hyprland.lua` on Lua, mille sinu komposiitor käivitab sisselogimisel, terminali konfiguratsioon nimetab programmi, mille sinu terminal käivitab, ja `vscode.json` nimetab installitava VSCode laienduse. Kellegi teema installimine peaks muutma seda, kuidas sinu töölaud välja näeb, mitte kunagi seda, mida see käivitab.

Kõik muu töötab endiselt täpselt nii, nagu teema autor selle kirjutas — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustad ja eelvaated säilivad kõik. Ainult see, mis ära visati, luuakse sinu masinas uuesti failist `colors.toml`.

Omarchy eristab neid kahte selle järgi, kas teemal on sees oma git repositoorium, mille `omarchy theme install` kloonimisel maha jätab. Nii jääb teema, mille ise kirjutasid, sinu omaks ja teema, mille internetist tõmbasid, ainult värvideks.

### Hele režiim

Kui teed heleda režiimi teemat, määra faili `colors.toml` ülaosas `mode = "light"`. Seejärel seotakse see kõigi rakenduste puhul automaatselt heleda režiimiga. (Vana viis — tühja faili nimega `light.mode` panemine teema juurkausta — töötab samuti endiselt.)

### Avamispilt

Teemad, millega on kaasas pildid `unlock.png` ja `preview-unlock.png`, loetletakse jaotuses _Välimus > Avamine_. Sinu `unlock.png` peaks eelistatavalt olema läbipaistev png. Ja eelvaatepildi saad luua käsuga `omarchy plymouth preview`.

### Rakenduste teemastamine, mida Omarchy ei kata

Kui kasutad rakendust, mida selles loendis ei ole, saad Omarchy õpetada seda malliga ise teemastama. Pane fail asukohta `~/.config/omarchy/themed/`, nimetades selle selle konfiguratsiooni järgi, mille see genereerib, lisades laiendi `.tpl`, ja kirjuta konfiguratsioon, kasutades kohahoidjatena `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kuni `{{ color15 }}` ja ülejäänud paletti. Iga kord, kui vahetad teemat, genereeritakse fail selle teema värvidega uuesti.

Selles kaustas on täielikult kommenteeritud `alacritty.toml.tpl.sample`, millest saad kopeerida — see loetleb kõik muutujad, mida saad kasutada, lisaks modifikaatorid `_strip` ja `_rgb` rakenduste jaoks, mis soovivad oma värve ilma `#`-ita või kümnendkujul RGB-na. Sinu mallid on Omarchy enda omadest tähtsamad, nii et saad seda kasutada ka selleks, et üle kirjutada, kuidas sisseehitatud rakendust teemastatakse.

### Oma teema levitamine

Kui soovid oma teemat levitada, et teised saaksid seda kasutada, pead panema selle avalikku git serverisse, näiteks GitHub. Seejärel saavad inimesed selle selle URL-i abil Omarchy menüüs _Paigalda > Stiil > Teema_ kaudu installida. Soovitatav on järgida nimetamistava `omarchy-[themename]-theme`, sest pärast installimist kuvatakse teema teemavaliku menüüs õigesti lihtsalt kujul `[themename]`.

See järelejääv `[themename]` muutub teema katalooginimeks, seega peab see olema selline, mida Omarchy saab turvaliselt edasi anda: see peab algama tähe, numbri või allkriipsuga ning ülejäänud osa võib sisaldada tähti, numbreid, `.`, `_`, `+` ja `-`. Suurtähed muudetakse sinu eest väiketähtedeks, kuid kõik muu — tühik, jutumärk, mitteinglise märk — lükatakse installimisel tagasi, selle asemel et see katalooginimeks muuta. Seega installivad `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` kõik probleemideta.

Pea meeles, et kui see on repositooriumist installitud, visatakse ära kõik sellega kaasas olevad `.lua`, terminali konfiguratsioon või `vscode.json`, seega ära ehita teemat nende ümber.

Saad lasta oma teema lisada [lisateemade lehele](https://omarchy.org/themes/), saates pull request'i [omarchy-site repositooriumile](https://github.com/omacom-io/omarchy-site).
