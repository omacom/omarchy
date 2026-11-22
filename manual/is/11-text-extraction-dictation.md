# Textaútdráttur og raddinnsláttur

### Textaútdráttur

Ýttu á `Super + Ctrl + PrtScr` til að velja svæði á skjánum til að draga út texta. OCR-líkanið tesseract, sem er með opnum frumkóða, breytir því valda svæði síðan fljótt í texta og setur hann á klippiborðið. Þá ýtirðu bara á `Super + V` til að líma hann inn.

Þetta er mjög handhægt til að grípa heimilisföng úr síðurfótum mynda eða símanúmer sem eru felld inn í fyrirsagnir á vefsíðum.

 ![text-extraction](images/text-extraction.webp)

### Raddinnsláttur

Í nýjum uppsetningum er [Superwhisper](https://superwhisper.com/) sjálfgefið bakendi fyrir raddinnslátt og notar skýjavinnslu án niðurhals á líkönum til notkunar án nettengingar. Veldu Superwhisper, [Voxtype](https://voxtype.io/) eða [Hex](https://anoma.ly/hex/) í gegnum _Setup > Defaults > Dictation_ í Omarchy-valmyndinni. Þegar bakendi er valinn er hann settur upp ef þess þarf og gerður að sjálfgefnum bakenda fyrir raddinnslátt. Voxtype hleður niður grunnlíkani fyrir ensku sem tekur 150MB; breyttu líkaninu með `voxtype setup model` og öðrum stillingum í gegnum `~/.config/voxtype/config.toml`. Superwhisper opnar stillingar sínar til að velja á milli skýjavinnslu og vinnslu á tækinu, og OPR heldur forritinu uppfærðu. Hex hleður niður tallíkani sínu á tækinu meðan á uppsetningu stendur og keyrir sem notendaþjónustan `hex.service`; opnaðu glugga þess frá bakkatákninu á stikunni eða með því að keyra `hex` til að breyta líkaninu og öðrum stillingum.

Þú talar inn texta með því að halda inni `Right Alt`, eða með því að kveikja og slökkva með `Alt + Space`, og talaði textinn birtist í innsláttarsvæðinu sem er í fókus. Þessir flýtilyklar nota valda bakendann. Right Alt ræsir einnig raddinnslátt þegar hann er notaður í lyklasamsetningu með breytilykli; notaðu Left Alt fyrir slíkar lyklasamsetningar. Á lyklaborðsuppsetningum þar sem Right Alt er AltGr skaltu nota `Alt + Space` til að halda AltGr tiltæku til að skrifa. Uppsetningar frá því áður en Alt + Space varð sjálfgefið halda `F9` fyrir ýttu-til-að-tala og `Super + Ctrl + X` til að kveikja og slökkva, sem bætt er við í `~/.config/hypr/bindings.lua`, þar sem þessi `Super + Ctrl + X` kemur í stað agents-spjaldsins; fjarlægðu þá þar til að skila lyklunum aftur til forritanna og spjaldsins.

Sömu flýtilyklar virka með hverjum bakenda. Veldu bakendann þinn í gegnum Setup > Defaults > Dictation. Uppsetningarforrit bakendans stillir hann og vistar valið. Keyrðu `omarchy default dictation` til að sjá hvor er valinn. Valið er vistað í `~/.config/omarchy/defaults/dictation`. Nýjar uppsetningar velja Superwhisper sjálfkrafa.

Omarchy hleður sjálfkrafa inn skjáborðssamþættingu valda bakendans. Engrar Superwhisper-stillingar er þörf í `~/.config/hypr/`.

Sérsniðnar lyklabindingar og forskriftir geta notað `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Valdi bakendinn sér um upptökuna og umritunina. Þegar Superwhisper er valið er innbyggður halda-flýtilykill þess gerður óvirkur og innbyggða kveikja/slökkva-aðgerð þess sett á `Ctrl + Alt + Space`, þannig að hún helst aðskilin frá upptökulyklum Omarchy. Superwhisper krefst að minnsta kosti eins innbyggðs upptökuflýtilykils, og hætta við-flýtilykill þess helst tiltækur.

Hægt er að samþætta viðbótarbakenda án þess að breyta Omarchy. Leggðu til keyrsluskrá með nafninu `omarchy-dictation-<backend>` á PATH sem tekur við `start`, `stop` og `toggle` og snýr aftur þegar í stað, með stöðukóða sem er ekki núll ef þetta mistekst. Uppsetningarforrit þess stillir veituna og kallar á `omarchy-dictation-use <backend>` eftir vel heppnaða uppsetningu. Þetta stöðvar fyrri bakendann og vistar valið atómískt; `stop` verður að heppnast þegar veitan er aðgerðarlaus eða ótiltæk. Bakendanöfn nota lágstafi, tölustafi og bandstrik. Leggðu til `omarchy-install-dictation-<backend>` fyrir uppsetningu; `omarchy default dictation <backend>` ræsir það. Bættu við færslu í Defaults-valmyndinni í gegnum Omarchy-valmyndarviðbót til að kalla á þann veljara. Valfrjáls skjáborðssamþætting getur verið í `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
