# Textaútdráttur og talritun

### Textaútdráttur

Ýttu á `Super + Ctrl + PrtScr` til að velja svæði á skjánum fyrir textaútdrátt. Opna OCR-líkanið tesseract breytir þá valinu fljótt í texta og setur hann á klippiborðið. Þá ýtir þú bara á `Super + V` til að líma.

Þetta er mjög gagnlegt til að grípa heimilisföng úr myndfótum eða símanúmer sem eru felld inn í fyrirsagnir á vefsíðum.

 ![text-extraction](images/text-extraction.webp)

### Talritun

Á nýjum uppsetningum er [Superwhisper](https://superwhisper.com/) sjálfgefinn talritunarbakendi, sem notar skýjavinnslu án niðurhals á líkönum til notkunar án nettengingar. Veldu Superwhisper eða [Voxtype](https://voxtype.io/) í gegnum _Uppsetning > Sjálfgefið > Talritun_ í Omarchy-valmyndinni. Þegar bakendi er valinn er hann settur upp ef þörf krefur og gerður sjálfgefinn fyrir talritun. Voxtype hleður inn grunnlíkani fyrir ensku sem tekur 150MB; breyttu líkaninu með `voxtype setup model` og öðrum stillingum í gegnum `~/.config/voxtype/config.toml`. Superwhisper opnar stillingar sínar til að velja á milli skýjavinnslu og staðbundinnar vinnslu, og OPR heldur forritinu uppfærðu.

Þú talar inn texta með því að halda inni `Right Alt`, eða með því að kveikja og slökkva með `Alt + Space`, og inntalaði textinn birtist á virka innsláttarsvæðinu. Þessir flýtilyklar nota valda bakendann. Right Alt ræsir líka talritun þegar hann er notaður í samsetningu með breytilykli; notaðu Left Alt fyrir slíkar samsetningar. Á lyklaborðsuppsetningum þar sem Right Alt er AltGr skaltu nota `Alt + Space` til að halda AltGr tiltækum til innsláttar. Uppsetningar frá því áður en Alt + Space varð sjálfgefið halda `F9` fyrir ýttu-til-að-tala og `Super + Ctrl + X` til að kveikja og slökkva, sem bætt er við í `~/.config/hypr/bindings.lua`; fjarlægðu þá þar til að skila þeim lyklum aftur til forritanna.

Sömu flýtilyklar virka með báðum bakendum. Veldu bakendann þinn í gegnum Uppsetning > Sjálfgefið > Talritun. Uppsetningarforrit bakendans stillir hann og vistar valið. Keyrðu `omarchy default dictation` til að sjá hvor er valinn. Valið er vistað í `~/.config/omarchy/defaults/dictation`. Nýjar uppsetningar velja Superwhisper sjálfkrafa.

Omarchy hleður sjálfkrafa inn skjáborðssamþættingu valda bakendans. Engin stilling fyrir Superwhisper er nauðsynleg í `~/.config/hypr/`.

Sérsniðnar lyklaskipanir og forskriftir geta notað `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Valdi bakendinn sér um upptökuna og umritunina. Þegar Superwhisper er valið er innbyggður hald-flýtilykill þess gerður óvirkur og innbyggður kveikju- og slökkvilykill þess settur á `Ctrl + Alt + Space`, svo hann haldist aðskilinn frá upptökulyklum Omarchy. Superwhisper krefst að minnsta kosti eins innbyggðs upptökuflýtilykils, og flýtilykill þess til að hætta við er áfram tiltækur.

Aðrir bakendar geta samþæst án þess að breyta Omarchy. Útvegaðu keyrsluskrá með nafninu `omarchy-dictation-<backend>` á PATH sem tekur við `start`, `stop` og `toggle` og skilar strax, með stöðukóða sem er ekki núll ef villa kemur upp. Uppsetningarforrit hennar stillir veituna og kallar á `omarchy-dictation-use <backend>` eftir vel heppnaða uppsetningu. Þetta stöðvar fyrri bakendann og vistar valið í einni heildstæðri aðgerð; `stop` verður að heppnast þegar veitan er aðgerðalaus eða ekki tiltæk. Nöfn bakenda nota lágstafi, tölustafi og bandstrik. Útvegaðu `omarchy-install-dictation-<backend>` fyrir uppsetningu; `omarchy default dictation <backend>` ræsir hana. Bættu við færslu í Sjálfgefið-valmyndina í gegnum viðbót við Omarchy-valmyndina til að kalla á þann valbúnað. Valfrjáls skjáborðssamþætting getur verið í `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
