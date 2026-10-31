# Textaútdráttur og upplesning

### Textaútdráttur

Ýttu á `Super + Ctrl + PrtScr` til að velja svæði á skjánum fyrir textaútdrátt. Opna OCR-líkanið tesseract breytir því vali síðan fljótt í texta og setur hann á klippiborðið. Síðan ýtirðu bara á `Super + V` til að líma.

Þetta er mjög gagnlegt til að grípa heimilisföng út úr myndfótum eða símanúmer sem eru felld inn í fyrirsagnir vefsíðna.

 ![text-extraction](images/text-extraction.webp)

### Upplesning

Við nýjar uppsetningar er [Superwhisper](https://superwhisper.com/) sjálfgefið upplesningarbakendi, með skýjavinnslu án niðurhals á ótengdum líkönum. Veldu Superwhisper eða [Voxtype](https://voxtype.io/) í gegnum _Uppsetning > Sjálfgildi > Upplesning_ í Omarchy-valmyndinni. Að velja bakenda setur hann upp ef þarf og gerir hann að sjálfgefnum fyrir upplesningu. Voxtype hleður grunnensku líkani sem tekur 150 MB; breyttu líkaninu með `voxtype setup model` og öðrum stillingum í gegnum `~/.config/voxtype/config.toml`. Superwhisper opnar stillingar sínar til að velja skýja- eða staðbundna vinnslu, og OPR heldur forritinu uppfærðu.

Þú lesur upphátt með því að halda `Right Alt` eða `F9` inni, eða með því að víxla með `Super + Ctrl + X`, og upplesni textinn birtist í virka inntakssvæðinu. Þessar flýtivísanir nota valinn bakenda. Right Alt byrjar einnig upplesningu þegar það er notað í breytislyklasamsetningu; notaðu Left Alt fyrir þær samsetningar. Á lyklaborðsskipunum þar sem Right Alt er AltGr skaltu nota `F9` til að halda AltGr lausu fyrir innslátt.

Sömu flýtivísanir virka með hvorum bakenda sem er. Veldu bakendann þinn í gegnum Uppsetning > Sjálfgildi > Upplesning. Uppsetningarforrit bakendans stillir hann og vistar valið. Keyrðu `omarchy default dictation` til að sjá hvor er valinn. Valið er vistað í `~/.config/omarchy/defaults/dictation`. Nýjar uppsetningar velja Superwhisper sjálfkrafa.

Omarchy hleður skjáborðssamþættingu valdus bakenda sjálfkrafa. Engin Superwhisper-stilling er þörf í `~/.config/hypr/`.

Sérsniðnar tengingar og forskriftir geta notað `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Valdi bakendinn sér um upptökuna og umritunina. Að velja Superwhisper slekkur á innfæddu hald-flýtivísun hans og stillir innfæddan víxil hans á `Alt + Space`, sem heldur honum aðskildum frá upptökulykklum Omarchy. Superwhisper krefst að minnsta kosti einnar innfæddrar upptökuflýtivísunar, og aflýsingarflýtivísun hans helst tiltæk.

Viðbótarbakendar geta samþættst án þess að breyta Omarchy. Veittu keyrsluskrá sem heitir `omarchy-dictation-<backend>` á PATH sem tekur við `start`, `stop` og `toggle` og skilar strax, með stöðu sem er ekki núll við bilun. Uppsetningarforritið hans stillir veituna og kallar á `omarchy-dictation-use <backend>` eftir vel heppnaða uppsetningu. Þetta stöðvar fyrri bakenda og vistar valið atómískt; `stop` verður að takast þegar veitan er óvirk eða ekki tiltæk. Nöfn bakenda nota lágstafi, tölustafi og bandstrik. Veittu `omarchy-install-dictation-<backend>` fyrir uppsetningu; `omarchy default dictation <backend>` ræsir það. Bættu við Sjálfgildi-valmyndarfærslu í gegnum Omarchy-valmyndarviðbót til að kalla á þann veljara. Valfrjáls skjáborðssamþætting getur búið í `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
