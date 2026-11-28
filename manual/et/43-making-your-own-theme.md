# Oma teema loomine

Saad lisada oma teemad kausta `~/.config/omarchy/themes`. Kopeeri lihtsalt üks olemasolevatest aluseks (vaata kausta `/usr/share/omarchy/themes`) ja kohanda siis oma rõõmuks. Seni, kuni sinu teema on selles kaustas, lisatakse see teemavaliku menüüsse.

Peamine fail, mida pead kohandama, on `colors.toml`. See määrab värvikomplekti, mida kasutatakse seejärel konfiguratsioonide genereerimiseks järgmiste jaoks: terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt rakendused, klaviatuuri taustvalgustus, sisendmeetod, ekraanijagamise valija, rakenduste ikoonid, mitmed AI-tööriistad (Claude, Pi, Hermes, T3 Code, Herdr) ja kogu Omarchy kest (ülariba, menüü, teatised, OSD ja lukustuskuva).

Võid kasutada ka kaasasolevat rakendust Aether, et luua uus teema ilusa graafilise liidese abil, kus saad värvidega mängida ja taustu otsida. Käivita see lihtsalt rakenduste ruudustikust klahvikombinatsiooniga `Super + Alt + Space`.

### Mida installitud teema võib sisaldada

Teema, mille kirjutad ise kausta `~/.config/omarchy/themes`, võib sisaldada mida iganes soovid — see on sinu masin ja sinu fail ning Omarchy rakendab selle kõik.

Teema, mille installid kellegi teise repositooriumist käsuga `omarchy theme install`, säilitab kõik, mis on värv, ja kaotab need üksikud failid, mis käivitaksid sinu masinas koodi: kõik `.lua` failid, terminali konfiguratsioonid (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ja `vscode.json`. Teema `hyprland.lua` on Lua, mille sinu komposiitor käivitab sisselogimisel, terminali konfiguratsioon nimetab programmi, mille sinu terminal käivitab, ja `vscode.json` nimetab installitava VSCode laienduse. Kellegi teise teema installimine peaks muutma seda, kuidas sinu töölaud välja näeb, mitte kunagi seda, mida see käivitab.

Kõik muu töötab endiselt täpselt nii, nagu teema autor selle kirjutas — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, taustad ja eelvaated säilitatakse kõik. Ainult see, mis ära jäeti, genereeritakse sinu masinas uuesti failist `colors.toml`.

Omarchy eristab neid kahte selle järgi, kas teema sees on selle oma git-repositoorium, mille `omarchy theme install` kloonimisel sinna järele jätab. Nii jääb teema, mille ise kirjutasid, sinu omaks ja teema, mille internetist tõmbasid, jääb värvideks.

### Hele režiim

Kui teed heleda režiimi teemat, pane oma `colors.toml` algusse `mode = "light"`. Siis seotakse see automaatselt kõigi rakenduste heleda režiimiga. (Vana viis, kus teema juurkausta pannakse tühi fail nimega `light.mode`, töötab ka endiselt.)

### Alglaadimis- ja sisselogimisekraanid

Ekraan, mis küsib alglaadimisel ketta parooli, ja sisselogimisekraan joonistavad Omarchy logo sinu teema värviga `accent` selle värvil `background`, parooliväljaga värvis `foreground` ja värviga `red` vale parooli korral. Nende jaoks ei ole vaja midagi lisaks kaasa panna: Omarchy ei kasuta enam teema faile `unlock.png` ega `preview-unlock.png`. Apple Silicon Macidel säilitab ketta parooli ekraan olenemata teemast Omarchy vaikimisi välimuse.

### Nende rakenduste teemastamine, mida Omarchy ei kata

Kui kasutad rakendust, mida selles loendis ei ole, saad Omarchyle ise malli abil õpetada, kuidas seda teemastada. Pane kausta `~/.config/omarchy/themed/` fail, mille nimi on selle genereeritava konfiguratsiooni nimi pluss laiend `.tpl`, ja kirjuta konfiguratsioon, kasutades kohatäidetena `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` kuni `{{ color15 }}` ja ülejäänud värvipaletti. Iga kord, kui teemat vahetad, genereeritakse fail selle teema värvidega uuesti.

Selles kaustas on täielikult kommenteeritud fail `alacritty.toml.tpl.sample`, millelt kopeerida — see loetleb kõik muutujad, mida saad kasutada, pluss modifikaatorid `_strip` ja `_rgb` rakenduste jaoks, mis soovivad oma värve ilma `#`-märgita või kümnendsüsteemi RGB-väärtustena. Sinu mallid on Omarchy enda omadest tähtsamad, nii et saad seda kasutada ka selleks, et määrata ümber, kuidas sisseehitatud rakendust teemastatakse.

### Oma teema levitamine

Kui soovid oma teemat levitada, et teised saaksid seda kasutada, pead selle panema avalikku git-serverisse, näiteks GitHubi. Siis saavad inimesed selle selle URL-i abil Omarchy menüüs valiku _Install > Style > Theme_ kaudu installida. Soovitatav on järgida nimetamistava `omarchy-[themename]-theme`, sest pärast installimist kuvatakse teema teemavaliku menüüs õigesti lihtsalt kujul `[themename]`.

Sellest järelejäävast osast `[themename]` saab teema kausta nimi, seega peab see olema selline, mida Omarchy saab turvaliselt edasi anda: see peab algama tähe, numbri või allkriipsuga ning ülejäänud osa võib sisaldada tähti, numbreid, märke `.`, `_`, `+` ja `-`. Suurtähed muudetakse sinu eest väiketähtedeks, kuid kõigest muust — tühikust, jutumärgist, mitteingliskeelsest märgist — keeldutakse installimisel, selle asemel et see kausta nimeks muuta. Nii installivad `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ja `omarchy-c++-theme` kõik probleemideta.

Pea meeles, et kui see on repositooriumist installitud, jäetakse ära kõik sellega kaasas olevad `.lua` failid, terminali konfiguratsioon või `vscode.json`, nii et ära ehita teemat nende ümber.

Sa saad lasta oma teema lisada [lisateemade lehele](https://omarchy.org/themes/), saates pull requesti [omarchy-site repositooriumile](https://github.com/omacom-io/omarchy-site).
