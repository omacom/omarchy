# Savo temos kūrimas

Savo temas galite pridėti į `~/.config/omarchy/themes`. Tiesiog nukopijuokite vieną iš esamų temų kaip pagrindą (jų ieškokite `/usr/share/omarchy/themes`), tada pritaikykite pagal savo skonį. Kol jūsų tema yra tame aplanke, ji bus įtraukta į temų pasirinkimo meniu.

Pagrindinis failas, kurį turite pritaikyti, yra `colors.toml`. Jis apibrėžia spalvų rinkinį, kuris vėliau naudojamas konfigūracijoms generuoti terminalui (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt programoms, klaviatūros apšvietimui, įvesties metodui, ekrano bendrinimo pasirinkimo langui, programų piktogramoms, keliems AI įrankiams (Claude, Pi, Hermes, T3 Code, Herdr) ir visai Omarchy aplinkai (viršutinei juostai, meniu, pranešimams, OSD ir užrakinimo ekranui).

Taip pat galite naudoti pridėtą Aether programą ir kurti naują temą per mielą GUI sąsają, kurioje galėsite žaisti su spalvomis ir ieškoti fonų. Tiesiog paleiskite ją iš programų tinklelio paspaudę `Super + Alt + Space`.

### Ką gali turėti įdiegta tema

Tema, kurią patys parašote `~/.config/omarchy/themes`, gali turėti viską, ko tik norite — tai jūsų kompiuteris ir jūsų failas, o Omarchy pritaiko viską.

Tema, kurią įdiegiate iš kieno nors kito saugyklos su `omarchy theme install`, išlaiko viską, kas susiję su spalvomis, ir praranda saujelę failų, kurie jūsų kompiuteryje vykdytų kodą: bet kurį `.lua` failą, terminalo konfigūracijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ir `vscode.json`. Temos `hyprland.lua` yra Lua, kurį jūsų kompozitorius vykdo prisijungus, terminalo konfigūracija nurodo programą, kurią jūsų terminalas paleidžia, o `vscode.json` nurodo VSCode plėtinį, kurį reikia įdiegti. Kieno nors temos įdiegimas turėtų pakeisti tai, kaip atrodo jūsų darbalaukis, o niekada — tai, ką jis vykdo.

Visa kita vis tiek veikia tiksliai taip, kaip temos autorius parašė — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fonai ir peržiūros išlieka visi. Tik tai, kas buvo atmesta, jūsų kompiuteryje iš naujo sugeneruojama iš `colors.toml`.

Omarchy atskiria šias dvi rūšis pagal tai, ar tema viduje turi savo git saugyklą, kurią `omarchy theme install` palieka klonuodama. Taigi jūsų parašyta tema lieka jūsų, o iš interneto atsisiųsta lieka vien spalvomis.

### Šviesusis režimas

Jei kuriate šviesiojo režimo temą, `colors.toml` viršuje nustatykite `mode = "light"`. Tada ji visoms programoms bus automatiškai suporuota su šviesiuoju režimu. (Senasis būdas — įmesti tuščią failą pavadinimu `light.mode` į temos šakninį katalogą — vis dar veikia.)

### Įkrovos ir prisijungimo ekranai

Ekranas, kuris įkrovos metu prašo disko slaptažodžio, ir prisijungimo ekranas piešia Omarchy logotipą jūsų temos `accent` spalva ant jos `background`, slaptažodžio lauką rodo `foreground` spalva, o neteisingą slaptažodį — `red`. Jiems nereikia nieko papildomai pateikti: Omarchy nebenaudoja temos `unlock.png` ar `preview-unlock.png`. Apple Silicon Mac kompiuteriuose disko slaptažodžio ekranas išlaiko numatytąją Omarchy išvaizdą, kad ir kokia būtų tema.

### Kaip pritaikyti temą programoms, kurių Omarchy neapima

Jei naudojate programą, kurios nėra tame sąraše, galite patys išmokyti Omarchy pritaikyti jai temą naudodami šabloną. Įmeskite failą į `~/.config/omarchy/themed/`, pavadintą pagal konfigūraciją, kurią jis generuoja, pridėdami `.tpl` plėtinį, ir rašykite konfigūraciją su `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` iki `{{ color15 }}` bei likusia palete kaip vietos žymekliais. Kiekvieną kartą, kai perjungiate temas, failas iš naujo sugeneruojamas su tos temos spalvomis.

Tame aplanke yra išsamiai pakomentuotas `alacritty.toml.tpl.sample`, nuo kurio galite kopijuoti — jame išvardyti visi kintamieji, kuriuos galite naudoti, taip pat `_strip` ir `_rgb` modifikatoriai programoms, kurios nori spalvų be `#` arba dešimtainiu RGB formatu. Jūsų šablonai turi pirmenybę prieš pačios Omarchy šablonus, todėl taip galite ir perrašyti, kaip pritaikoma tema integruotai programai.

### Temos platinimas

Jei norite platinti savo temą, kad kiti galėtų ją naudoti, turite ją įkelti į viešą git serverį, pavyzdžiui, GitHub. Tada žmonės galės ją įdiegti Omarchy meniu pasirinkę _Install > Style > Theme_ ir naudodami tą URL. Rekomenduojama laikytis pavadinimų konvencijos `omarchy-[themename]-theme`, nes po įdiegimo tema temų pasirinkimo meniu bus teisingai rodoma tik kaip `[themename]`.

Tas likęs `[themename]` tampa temos katalogo pavadinimu, todėl jis turi būti toks, kurį Omarchy gali saugiai perduoti iš rankų į rankas: jis turi prasidėti raide, skaitmeniu arba pabraukimo brūkšniu, o likusią dalį gali sudaryti raidės, skaitmenys, `.`, `_`, `+` ir `-`. Didžiosios raidės už jus paverčiamos mažosiomis, tačiau visa kita — tarpas, kabutė, neangliškas simbolis — įdiegimo metu atmetama, o ne paverčiama katalogo pavadinimu. Taigi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ir `omarchy-c++-theme` visos įsidiegia be problemų.

Atminkite, kad kai ji įdiegiama iš saugyklos, bet koks jos pateikiamas `.lua`, terminalo konfigūracija ar `vscode.json` atmetamas, todėl nekurkite temos aplink juos.

Galite pasiekti, kad jūsų tema būtų pridėta prie [papildomų temų puslapio](https://omarchy.org/themes/), pateikę pull request į [omarchy-site saugyklą](https://github.com/omacom-io/omarchy-site).
