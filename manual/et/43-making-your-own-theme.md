# Oma teema loomine

Oma teemasid saad lisada kausta `~/.config/omarchy/themes`. Kopeeri lihtsalt aluseks üks olemasolevatest (vaata kausta `/usr/share/omarchy/themes`) ja kohanda seda siis oma rõõmuks. Seni, kuni sinu teema on selles kaustas, lisatakse see teemavaliku menüüsse.

Peamine fail, mida pead kohandama, on `colors.toml`. See määrab värvikomplekti, mille põhjal luuakse seejärel konfiguratsioonid järgmisele: terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt rakendused, klaviatuuri taustvalgustus, sisestusmeetod, ekraanijagamise valija, rakenduste ikoonid, mitu AI tööriista (Claude, Pi, Hermes, T3 Code, Herdr) ja kogu Omarchy kest (ülemine riba, menüü, teavitused, OSD ja lukustusekraan).

Uue teema loomiseks saad kasutada ka kaasas olevat rakendust Aether, millel on armas GUI liides värvidega mängimiseks ja taustade otsimiseks. Käivita see lihtsalt rakenduste ruudustikust klahvidega `Super + Alt + Space`.

### Mida installitud teema võib sisaldada

Teema, mille kirjutad ise kausta `~/.config/omarchy/themes`, võib sisaldada mida iganes soovid — see on sinu masin ja sinu fail ning Omarchy rakendab selle kõik.

Teema, mille installid kellegi teise repositooriumist käsuga `omarchy theme install`, säilitab kõik, mis on värv, ja kaotab need üksikud failid, mis käivitaksid sinu masinas koodi: kõik `.lua` failid, terminali konfiguratsioonid (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teema `hyprland.lua` on Lua, mida sinu komposiitor käivitab sisselogimisel, terminali konfiguratsioon nimetab programmi, mille sinu terminal käivitab, ja `vscode.json` nimetab installitava VSCode laienduse. Kellegi teema installimine peaks muutma seda, kuidas sinu töölaud välja näeb, mitte kunagi seda, mida see käivitab.

Kõik muu töötab endiselt täpselt nii, nagu teema autor selle kirjutas — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustad ja eelvaated säilivad kõik. Ainult see, mis välja jäeti, luuakse sinu masinas uuesti faili `colors.toml` põhjal.

Omarchy eristab neid kahte selle järgi, kas teemal on selle sees oma git repositoorium, mille `omarchy theme install` kloonimisel maha jätab. Nii jääb sinu kirjutatud teema sinu omaks ja internetist tõmmatud teema jääb värvideks.

### Hele režiim

Kui teed heleda režiimi teemat, määra faili `colors.toml` ülaosas `mode = "light"`. Seejärel seotakse see automaatselt kõigi rakenduste heleda režiimiga. (Vana viis, kus teema juurkausta jäeti tühi fail nimega `light.mode`, töötab samuti edasi.)

### Lukustuse avamise pilt

Teemad, millega on kaasas pildid `unlock.png` ja `preview-unlock.png`, loetletakse jaotuses _Välimus > Lukustuse avamine_. Sinu `unlock.png` peaks eelistatavalt olema läbipaistev png. Ja eelvaatepildi saad luua käsuga `omarchy plymouth preview`.

### Nende rakenduste teemastamine, mida Omarchy ei kata

Kui kasutad rakendust, mida selles loendis ei ole, saad Omarchy seda malliga ise teemastama õpetada. Pane kausta `~/.config/omarchy/themed/` fail, mille nimi on selle konfiguratsiooni järgi, mida see loob, koos laiendiga `.tpl`, ja kirjuta konfiguratsioon, kasutades kohahoidjatena `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kuni `{{ color15 }}` ja ülejäänud paletti. Iga kord, kui teemat vahetad, luuakse fail selle teema värvidega uuesti.

Selles kaustas on täielikult kommenteeritud `alacritty.toml.tpl.sample`, millest kopeerida — seal on loetletud kõik muutujad, mida saad kasutada, ning lisaks modifikaatorid `_strip` ja `_rgb` rakendustele, mis soovivad oma värve ilma `#`-märgita või kümnendkujul RGB-na. Sinu mallid on Omarchy enda omadest tähtsamad, nii et saad seda kasutada ka selle ülekirjutamiseks, kuidas sisseehitatud rakendust teemastatakse.

### Oma teema levitamine

Kui soovid oma teemat levitada, et teised saaksid seda kasutada, pead selle panema avalikku git serverisse, näiteks GitHub. Seejärel saavad inimesed selle selle URL-i abil installida Omarchy menüü jaotuse _Installi > Stiil > Teema_ kaudu. Soovitatav on järgida nimetamistava `omarchy-[themename]-theme`, sest pärast installimist kuvatakse teema teemavaliku menüüs õigesti lihtsalt kujul `[themename]`.

See järelejäänud `[themename]` saab teema kataloogi nimeks, nii et see peab olema nimi, mida Omarchy saab turvaliselt ringi anda: see peab algama tähe, numbri või alakriipsuga ning ülejäänud osa võib sisaldada tähti, numbreid, `.`, `_`, `+` ja `-`. Suurtähed muudetakse sinu eest väiketähtedeks, kuid kõigest muust — tühikust, jutumärgist, mitteinglise tähemärgist — keeldutakse installimisel, selle asemel et see katalooginimeks muuta. Nii installivad `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` kõik probleemideta.

Pea meeles, et kui see on repositooriumist installitud, jäetakse kõik selle kaasa pandud `.lua`, terminali konfiguratsioon või `vscode.json` välja, nii et ära ehita teemat nende ümber.

Saad lasta oma teema lisada [lisateemade lehele](https://omarchy.org/themes/), saates pull requesti [omarchy-site repositooriumile](https://github.com/omacom-io/omarchy-site).
