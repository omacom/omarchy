# Oma teema loomine

Saad lisada oma teemad kausta `~/.config/omarchy/themes`. Kopeeri lihtsalt üks olemasolevatest aluseks (vaata kausta `/usr/share/omarchy/themes`) ja kohanda siis oma rõõmuks. Niikaua kui su teema on selles kaustas, lisatakse see teemavaliku menüüsse.

Peamine fail, mida pead kohandama, on `colors.toml`. See määrab värvikomplekti, mida kasutatakse seejärel konfiguratsioonide genereerimiseks terminalile (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ja kogu Omarchy kestale (ülemine riba, menüü, teavitused, OSD ja lukustuskuva).

Uue teema loomiseks saad kasutada ka kaasas olevat rakendust Aether, millel on kena GUI-liides värvidega mängimiseks ja taustade otsimiseks. Käivita see lihtsalt rakenduste ruudustikust klahvidega `Super + Alt + Space`.

### Mida installitud teema võib sisaldada

Teema, mille kirjutad ise kausta `~/.config/omarchy/themes`, võib sisaldada mida iganes soovid — see on sinu masin ja sinu fail ning Omarchy rakendab selle kõik.

Teema, mille installid kellegi teise repositooriumist käsuga `omarchy theme install`, säilitab kõik, mis on värv, ja kaotab need vähesed failid, mis käivitaksid sinu masinas koodi: kõik `.lua` failid, terminali konfiguratsioonid (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teema `hyprland.lua` on Lua, mida su komposiitor käivitab sisselogimisel, terminali konfiguratsioon nimetab programmi, mille su terminal käivitab, ja `vscode.json` nimetab installitava VSCode laienduse. Kellegi teema installimine peaks muutma seda, kuidas su töölaud välja näeb, mitte kunagi seda, mida see käivitab.

Kõik muu töötab endiselt täpselt nii, nagu teema autor selle kirjutas — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, taustad ja eelvaated säilivad kõik. Ainult see, mis maha jäeti, genereeritakse sinu masinas uuesti failist `colors.toml`.

Omarchy eristab neid kahte selle järgi, kas teemal on selle sees oma git repositoorium, mille `omarchy theme install` kloonimisel maha jätab. Nii jääb sinu kirjutatud teema sinu omaks ja internetist tõmmatud teema piirdub värvidega.

### Hele režiim

Kui teed heleda režiimi teemat, pane oma `colors.toml` faili algusesse `mode = "light"`. Siis seotakse see automaatselt kõigi rakenduste heleda režiimiga. (Vana viis, kus teema juurkausta jäetakse tühi fail nimega `light.mode`, töötab samuti edasi.)

### Ikoonide värvid

Kui soovid failihalduri ikoone oma teemaga värvilt sobitada, lisa fail nimega `icons.theme`, milles on selle ikoonikomplekti nimi, mida soovid kasutada. Vaikimisi on valikud: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Avamispilt

Teemad, millega on kaasas pildid `unlock.png` ja `preview-unlock.png`, loetletakse jaotises _Appearance > Unlock_. Sinu `unlock.png` peaks eelistatult olema läbipaistev png. Ja eelvaatepildi saad luua käsuga `omarchy plymouth preview`.

### Rakenduste teemastamine, mida Omarchy ei kata

Kui kasutad rakendust, mida selles loendis ei ole, saad Omarchyle õpetada, kuidas seda malliga ise teemastada. Pane kausta `~/.config/omarchy/themed/` fail, mille nimi on selle konfiguratsiooni järgi, mille see genereerib, pluss laiend `.tpl`, ja kirjuta konfiguratsioon kohahoidjatega `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kuni `{{ color15 }}` ja ülejäänud paletiga. Iga kord, kui teemat vahetad, genereeritakse fail uuesti selle teema värvidega.

Selles kaustas on täielikult kommenteeritud `alacritty.toml.tpl.sample`, millelt kopeerida — see loetleb kõik muutujad, mida saad kasutada, pluss modifikaatorid `_strip` ja `_rgb` rakendustele, mis soovivad oma värve ilma `#`-märgita või kümnendvormingus RGB-na. Sinu mallid on Omarchy enda omadest tähtsamad, nii et saad seda kasutada ka selle ümberkirjutamiseks, kuidas sisseehitatud rakendust teemastatakse.

### Oma teema levitamine

Kui soovid oma teemat levitada, et teised saaksid seda kasutada, pead selle panema avalikku git serverisse, näiteks GitHubi. Siis saavad inimesed selle installida Omarchy menüüs _Install > Style > Theme_ kaudu, kasutades seda URL-i. Soovitatav on järgida nimetamiskonventsiooni `omarchy-[themename]-theme`, sest pärast installimist kuvatakse teema teemavaliku menüüs õigesti lihtsalt kujul `[themename]`.

See järelejääv `[themename]` saab teema kataloogi nimeks, nii et see peab olema selline, mida Omarchy saab turvaliselt edasi anda: see peab algama tähe, numbri või alakriipsuga ning ülejäänu võib sisaldada tähti, numbreid, `.`, `_`, `+` ja `-`. Suurtähed muudetakse sinu eest väiketähtedeks, kuid kõik muu — tühik, jutumärk, mitte-inglise täht — lükatakse installimisel tagasi, selle asemel et see kataloogi nimeks muuta. Nii et `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` installivad kõik probleemideta.

Pea meeles, et kui see on repositooriumist installitud, jäetakse maha iga `.lua`, terminali konfiguratsioon või `vscode.json`, mille see kaasa toob, nii et ära ehita teemat nende ümber.

Saad lasta oma teema lisada [lisa teemade lehele](https://omarchy.org/themes/), saates pull requesti [omarchy-site repositooriumile](https://github.com/omacom-io/omarchy-site).
