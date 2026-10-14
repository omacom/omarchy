# Savo temos kūrimas

Gali pridėti savo temas į `~/.config/omarchy/themes`. Tiesiog nukopijuok vieną iš esamų kaip pagrindą (žiūrėk į `/usr/share/omarchy/themes`), tada tobulink iki soties. Kol tavo tema yra tame aplanke, ji bus įtraukta į temų pasirinkimo meniu.

Pagrindinis failas, kurį turi koreguoti, yra `colors.toml`. Jis apibrėžia spalvų rinkinį, iš kurio tada generuojamos konfigūracijos terminalui (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ir visam Omarchy apvalkalui (viršutinei juostai, meniu, pranešimams, OSD ir užrakinimo ekranui).

Taip pat gali naudoti pridėtą Aether programą, kad sukurtum naują temą naudodamas mielą GUI sąsają spalvoms žaisti ir fonams ieškoti. Tiesiog paleisk ją iš programų tinklelio su `Super + Alt + Space`.

### Ką gali turėti įdiegta tema

Tema, kurią pats parašai `~/.config/omarchy/themes`, gali turėti ką nori — tai tavo kompiuteris ir tavo failas, o Omarchy visa tai pritaiko.

Tema, kurią įdiegi iš svetimos saugyklos su `omarchy theme install`, pasilieka viską, kas yra spalva, ir praranda saujelę failų, kurie tavo kompiuteryje vykdytų kodą: bet kurį `.lua` failą, terminalo konfigūracijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ir `vscode.json`. Temos `hyprland.lua` yra Lua, kurį tavo kompozitorius paleidžia prisijungiant, terminalo konfigūracija įvardija programą, kurią tavo terminalas paleidžia, o `vscode.json` įvardija diegiamą VSCode plėtinį. Svetimos temos įdiegimas turėtų keisti tai, kaip tavo darbalaukis atrodo, niekad tai, ką jis paleidžia.

Visa kita vis tiek veikia tiksliai taip, kaip temos autorius parašė — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, fonai ir peržiūros visi išsaugomi. Tik tai, kas buvo išmesta, tavo kompiuteryje iš naujo generuojama iš `colors.toml`.

Omarchy jiedu atskiria pagal tai, ar tema viduje turi savą git saugyklą — tai yra tai, ką `omarchy theme install` palieka klonuodamas. Todėl tema, kurią parašei, lieka tavo, o ta, kurią atsisiuntei iš interneto, lieka spalvomis.

### Šviesus režimas

Jei kuri šviesaus režimo temą, `colors.toml` viršuje nustatyk `mode = "light"`. Tada ji visoms programoms automatiškai bus suporuota su šviesiu režimu. (Senasis būdas temos šaknyje numesti tuščią failą pavadinimu `light.mode` taip pat vis dar veikia.)

### Piktogramų spalvos

Jei norėtum failų tvarkyklės piktogramas spalvomis derinti prie savo temos, pridėk failą pavadinimu `icons.theme` su piktogramų rinkinio, kurį nori naudoti, pavadinimu. Pagal numatytuosius parinktys yra: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Atrakinimo paveikslėlis

Temos, pateikiamos su `unlock.png` ir `preview-unlock.png` paveikslėliais, bus išvardytos po _Stilius > Atrakinti_. Tavo `unlock.png` pageidautina turėtų būti skaidrus png. O peržiūros paveikslėlį gali sukurti naudodamas `omarchy plymouth preview`.

### Programų, kurių Omarchy neapima, teminimas

Jei naudoji programą, kurios tame sąraše nėra, gali Omarchy išmokyti ją teminti pats su šablonu. Numesk failą į `~/.config/omarchy/themed/`, pavadintą pagal konfigūraciją, kurią jis generuoja, plius `.tpl` plėtinį, ir parašyk konfigūraciją su `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` iki `{{ color15 }}` ir likusia palete kaip vietaženkliais. Kaskart pakeitus temą, failas sugeneruojamas iš naujo su tos temos spalvomis.

Tame aplanke yra pilnai pakomentuotas `alacritty.toml.tpl.sample`, nuo kurio gali kopijuoti — jis išvardija kiekvieną kintamąjį, kurį gali naudoti, plius `_strip` ir `_rgb` modifikatorius programoms, norinčioms savo spalvų be `#` arba dešimtainiu RGB. Tavo šablonai turi pirmenybę prieš pačios Omarchy, todėl gali tai naudoti ir tam, kad pakeistum, kaip teminama įmontuota programa.

### Savo temos platinimas

Jei nori platinti savo temą, kad kiti galėtų ją naudoti, turi ją įdėti į viešą git serverį, pavyzdžiui, GitHub. Tada žmonės gali ją įdiegti Omarchy meniu per _Įdiegti > Stilius > Tema_ naudodami tą URL. Rekomenduojama laikytis pavadinimų konvencijos `omarchy-[themename]-theme`, nes po įdiegimo tema temų pasirinkimo meniu teisingai rodysis tiesiog kaip `[themename]`.

Tas likęs `[themename]` tampa temos katalogo pavadinimu, todėl jis turi būti toks, kurį Omarchy gali saugiai perduoti: jis turi prasidėti raide, skaitmeniu arba pabraukimu, o likusi dalis gali turėti raides, skaitmenis, `.`, `_`, `+` ir `-`. Didžiosios raidės tau paverčiamos mažosiomis, bet visa kita — tarpas, kabutė, neangliškas simbolis — įdiegimo metu atmetama, užuot paversta katalogo pavadinimu. Todėl `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ir `omarchy-c++-theme` visos įsidiegia gerai.

Atmink, kad kai ji įdiegiama iš saugyklos, bet kuris jos pateikiamas `.lua`, terminalo konfigūracija ar `vscode.json` išmetamas, todėl temos aplink juos nestatyk.

Savo temą į [papildomų temų puslapį](https://omarchy.org/themes/) gali įtraukti atsiuntęs pull requestą į [omarchy-site saugyklą](https://github.com/omacom-io/omarchy-site).
