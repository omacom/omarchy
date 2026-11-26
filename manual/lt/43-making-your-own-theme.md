# Savo temos kūrimas

Galite pridėti savo temas į `~/.config/omarchy/themes`. Tiesiog nukopijuokite vieną iš esamų kaip pagrindą (žiūrėkite `/usr/share/omarchy/themes`), tada koreguokite pagal savo skonį. Kol jūsų tema yra tame aplanke, ji bus įtraukta į temos pasirinkimo meniu.

Pagrindinis failas, kurį turite koreguoti, yra `colors.toml`. Jis apibrėžia spalvų rinkinį, kuris tada naudojamas konfigūracijoms generuoti terminalui (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt programoms, klaviatūros apšvietimui, įvesties metodui, ekrano bendrinimo pasirinkikliui, programų piktogramoms, keliems AI įrankiams (Claude, Pi, Hermes, T3 Code, Herdr) ir visai Omarchy aplinkai (viršutinei juostai, meniu, pranešimams, OSD ir užrakto ekranui).

Taip pat galite naudoti pridedamą Aether programą, kad sukurtumėte naują temą naudodami puikią GUI sąsają, kurioje galite žaisti su spalvomis ir ieškoti fonų. Tiesiog paleiskite ją iš programų tinklelio paspaudę `Super + Alt + Space`.

### Ką gali turėti įdiegta tema

Tema, kurią patys parašote `~/.config/omarchy/themes`, gali turėti ką tik norite — tai jūsų kompiuteris ir jūsų failas, o Omarchy pritaiko viską.

Tema, kurią įdiegiate iš kažkieno kito saugyklos naudodami `omarchy theme install`, išlaiko viską, kas yra spalva, ir praranda tą saujelę failų, kurie vykdytų kodą jūsų kompiuteryje: bet kurį `.lua` failą, terminalo konfigūracijas (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) ir `vscode.json`. Temos `hyprland.lua` yra Lua, kurį jūsų kompozitorius vykdo prisijungimo metu, terminalo konfigūracija nurodo programą, kurią jūsų terminalas paleidžia, o `vscode.json` nurodo VSCode plėtinį, kurį reikia įdiegti. Kažkieno temos įdiegimas turėtų keisti tai, kaip jūsų darbalaukis atrodo, o niekada tai, ką jis vykdo.

Visa kita vis tiek veikia lygiai taip, kaip temos autorius parašė — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, fonai ir peržiūros yra išlaikomi. Tik tai, kas buvo pašalinta, jūsų kompiuteryje iš naujo sugeneruojama iš `colors.toml`.

Omarchy atskiria šiuos du atvejus pagal tai, ar tema turi savo git saugyklą viduje, o būtent tai `omarchy theme install` palieka po klonavimo. Taigi jūsų parašyta tema lieka jūsų, o iš interneto atsisiųsta tema lieka spalvomis.

### Šviesus režimas

Jei kuriate šviesaus režimo temą, nustatykite `mode = "light"` savo `colors.toml` viršuje. Tada ji bus automatiškai susieta su šviesiu režimu visoms programoms. (Senasis būdas, kai temos šakniniame aplanke paliekamas tuščias failas pavadinimu `light.mode`, taip pat vis dar veikia.)

### Atrakinimo vaizdas

Temos, pateiktos su `unlock.png` ir `preview-unlock.png` vaizdais, bus išvardytos skiltyje _Appearance > Unlock_. Jūsų `unlock.png` pageidautina turėtų būti skaidrus png. O peržiūros vaizdą galite sukurti naudodami `omarchy plymouth preview`.

### Kaip pritaikyti temą programoms, kurių Omarchy neapima

Jei naudojate programą, kurios nėra tame sąraše, galite patys išmokyti Omarchy pritaikyti jai temą naudodami šabloną. Įdėkite failą į `~/.config/omarchy/themed/`, pavadintą pagal konfigūraciją, kurią jis generuoja, pridėdami `.tpl` plėtinį, ir parašykite konfigūraciją naudodami `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` iki `{{ color15 }}` ir likusią paletę kaip vietos rezervavimo žymes. Kiekvieną kartą, kai perjungiate temas, failas iš naujo sugeneruojamas su tos temos spalvomis.

Tame aplanke yra išsamiai komentuotas `alacritty.toml.tpl.sample`, kurį galite kopijuoti — jis išvardija kiekvieną kintamąjį, kurį galite naudoti, taip pat `_strip` ir `_rgb` modifikatorius programoms, kurios nori savo spalvų be `#` arba kaip dešimtainio RGB. Jūsų šablonai turi pirmenybę prieš paties Omarchy šablonus, todėl tai taip pat galite naudoti norėdami perrašyti, kaip pritaikoma tema integruotai programai.

### Savo temos platinimas

Jei norite platinti savo temą, kad kiti galėtų ją naudoti, turite ją įkelti į viešą git serverį, pavyzdžiui, GitHub. Tada žmonės galės ją įdiegti naudodami _Install > Style > Theme_ Omarchy meniu, naudodami tą URL. Rekomenduojama laikytis pavadinimų konvencijos `omarchy-[themename]-theme`, nes tada po įdiegimo tema temos pasirinkimo meniu bus teisingai rodoma tik kaip `[themename]`.

Tas likęs `[themename]` tampa temos katalogo pavadinimu, todėl jis turi būti toks, kurį Omarchy gali saugiai perduoti: jis turi prasidėti raide, skaitmeniu arba pabraukimo brūkšniu, o likusią dalį gali sudaryti raidės, skaitmenys, `.`, `_`, `+` ir `-`. Didžiosios raidės jums paverčiamos mažosiomis, tačiau bet kas kita — tarpas, kabutė, ne angliškas simbolis — diegimo metu atmetama, o ne paverčiama katalogo pavadinimu. Taigi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` ir `omarchy-c++-theme` visos įdiegiamos be problemų.

Atminkite, kad kai ji įdiegiama iš saugyklos, bet koks `.lua`, terminalo konfigūracija ar `vscode.json`, kuriuos ji pateikia, pašalinami, todėl nestatykite temos ant jų.

Galite įtraukti savo temą į [papildomų temų puslapį](https://omarchy.org/themes/) išsiųsdami pull request į [omarchy-site saugyklą](https://github.com/omacom-io/omarchy-site).
