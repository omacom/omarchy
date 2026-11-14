# Savo temos kūrimas

Savo temas galite pridėti į `~/.config/omarchy/themes`. Tiesiog nukopijuokite vieną iš esamų kaip pagrindą (ieškokite `/usr/share/omarchy/themes`), tada pritaikykite pagal savo norus. Kol jūsų tema yra tame aplanke, ji bus įtraukta į temos pasirinkimo meniu.

Pagrindinis failas, kurį turite pritaikyti, yra `colors.toml`. Jis apibrėžia spalvų rinkinį, kuris tada naudojamas konfigūracijoms generuoti terminalui (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian ir visai Omarchy aplinkai (viršutinei juostai, meniu, pranešimams, OSD ir užrakinimo ekranui).

Taip pat galite naudoti pateiktą Aether programą, kad sukurtumėte naują temą naudodami puikią GUI sąsają spalvoms išbandyti ir fonams ieškoti. Tiesiog paleiskite ją iš programų tinklelio paspaudę `Super + Alt + Space`.

### Ką gali turėti įdiegta tema

Tema, kurią patys parašote `~/.config/omarchy/themes`, gali turėti bet ką — tai jūsų kompiuteris ir jūsų failas, o Omarchy pritaiko viską.

Tema, kurią įdiegiate iš kieno nors kito repozitorijos naudodami `omarchy theme install`, išsaugo viską, kas yra spalva, ir praranda saujelę failų, kurie paleistų kodą jūsų kompiuteryje: bet kurį `.lua` failą, terminalo konfigūracijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ir `vscode.json`. Temos `hyprland.lua` yra Lua, kurį jūsų kompozitorius paleidžia prisijungus, terminalo konfigūracija įvardija programą, kurią paleidžia jūsų terminalas, o `vscode.json` įvardija įdiegtiną VSCode plėtinį. Kieno nors temos įdiegimas turėtų pakeisti tai, kaip jūsų darbalaukis atrodo, bet niekada tai, ką jis paleidžia.

Visa kita ir toliau veikia lygiai taip, kaip temos autorius parašė — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fonai ir peržiūros išsaugomi. Tik tai, kas buvo pašalinta, jūsų kompiuteryje sugeneruojama iš naujo iš `colors.toml`.

Omarchy juos atskiria pagal tai, ar tema turi savo git repozitoriją viduje, o būtent tai `omarchy theme install` palieka po klonavimo. Taigi jūsų parašyta tema lieka jūsų, o parsisiųsta iš interneto lieka spalvomis.

### Šviesus režimas

Jei kuriate šviesaus režimo temą, `colors.toml` viršuje nustatykite `mode = "light"`. Tada ji bus automatiškai susieta su šviesiu režimu visoms programoms. (Senasis būdas — įmesti tuščią failą pavadinimu `light.mode` į temos šaknį — taip pat vis dar veikia.)

### Atrakinimo paveikslėlis

Temos, pateiktos su `unlock.png` ir `preview-unlock.png` paveikslėliais, bus išvardytos skiltyje _Appearance > Unlock_. Jūsų `unlock.png` pageidautina turėtų būti skaidrus png. O peržiūros paveikslėlį galite sukurti naudodami `omarchy plymouth preview`.

### Temų taikymas programoms, kurių Omarchy neapima

Jei naudojate programą, kurios nėra tame sąraše, galite išmokyti Omarchy ją teminti patys naudodami šabloną. Įmeskite failą į `~/.config/omarchy/themed/` pavadintą pagal konfigūraciją, kurią jis generuoja, pridėdami `.tpl` plėtinį, ir parašykite konfigūraciją naudodami `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` iki `{{ color15 }}` ir likusią paletę kaip vietos rezervavimo žymes. Kaskart perjungus temas, failas sugeneruojamas iš naujo su tos temos spalvomis.

Tame aplanke yra išsamiai pakomentuotas `alacritty.toml.tpl.sample`, nuo kurio galite kopijuoti — jame išvardyti visi kintamieji, kuriuos galite naudoti, taip pat `_strip` ir `_rgb` modifikatoriai programoms, kurioms spalvos reikalingos be `#` arba kaip dešimtainiai RGB. Jūsų šablonai turi pirmenybę prieš Omarchy savuosius, todėl tai taip pat galite naudoti norėdami pakeisti, kaip teminama integruota programa.

### Temos platinimas

Jei norite platinti savo temą, kad kiti galėtų ją naudoti, turite įkelti ją į viešą git serverį, pavyzdžiui, GitHub. Tada žmonės galės ją įdiegti per _Install > Style > Theme_ Omarchy meniu naudodami tą URL. Rekomenduojama laikytis pavadinimų konvencijos `omarchy-[themename]-theme`, nes po įdiegimo tema temos pasirinkimo meniu bus teisingai rodoma tiesiog kaip `[themename]`.

Likusi `[themename]` dalis tampa temos katalogo pavadinimu, todėl ji turi būti tokia, kurią Omarchy gali saugiai perduoti: ji turi prasidėti raide, skaitmeniu arba pabraukimo brūkšniu, o likusią dalį gali sudaryti raidės, skaitmenys, `.`, `_`, `+` ir `-`. Didžiosios raidės už jus paverčiamos mažosiomis, bet visa kita — tarpas, kabutė, ne angliškas simbolis — įdiegimo metu atmetama, o ne paverčiama katalogo pavadinimu. Taigi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ir `omarchy-c++-theme` visos įsidiegia be problemų.

Atminkite, kad įdiegus iš repozitorijos, bet koks jos pateikiamas `.lua`, terminalo konfigūracija ar `vscode.json` yra pašalinamas, todėl nekurkite temos aplink juos.

Savo temą į [papildomų temų puslapį](https://omarchy.org/themes/) galite pridėti nusiųsdami pull request į [omarchy-site repozitoriją](https://github.com/omacom-io/omarchy-site).
