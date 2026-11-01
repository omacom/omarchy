# Textaútdráttur og talinnsláttur

### Textaútdráttur

Ýttu á `Super + Ctrl + PrtScr` til að velja svæði á skjánum fyrir textaútdrátt. Opna OCR-líkanið tesseract breytir því vali fljótt í texta og setur það á klippiborðið. Síðan ýtirðu bara á `Super + V` til að líma.

Þetta er mjög gagnlegt til að ná heimilisföngum úr myndafótum eða símanúmerum sem felld eru inn í fyrirsagnir á vefsíðum.

 ![text-extraction](images/text-extraction.webp)

### Talinnsláttur

Á nýjum uppsetningum er [Superwhisper](https://superwhisper.com/) sjálfgefinn bakendi fyrir talinnslátt og notar vinnslu í skýi án þess að sækja líkön til notkunar án nettengingar. Veldu Superwhisper, [Voxtype](https://voxtype.io/) eða [Hex](https://anoma.ly/hex/) í gegnum _Uppsetning > Sjálfgefið > Talinnsláttur_ í Omarchy-valmyndinni. Þegar bakendi er valinn er hann settur upp ef þörf krefur og gerður sjálfgefinn fyrir talinnslátt. Voxtype hleður inn grunnlíkani fyrir ensku sem tekur 150MB; breyttu líkaninu með `voxtype setup model` og öðrum stillingum í gegnum `~/.config/voxtype/config.toml`. Superwhisper opnar stillingar sínar til að velja vinnslu í skýi eða staðbundna vinnslu, og OPR heldur forritinu uppfærðu. Hex sækir tallíkan sitt á tækinu við uppsetningu og keyrir sem notandaþjónustan `hex.service`; opnaðu glugga þess frá tákninu í kerfisbakka stýristikunnar eða með því að keyra `hex` til að breyta líkaninu og öðrum stillingum.

Þú talar inn með því að halda inni `Right Alt`, eða með því að skipta með `Alt + Space`, og innlesni textinn birtist í virka innsláttarsvæðinu. Þessir flýtilyklar nota valda bakendann. Right Alt byrjar líka talinnslátt þegar það er notað í samsettum lyklaborðsskipunum; notaðu Left Alt fyrir slíkar samsetningar. Á lyklaborðsuppsetningum þar sem Right Alt er AltGr skaltu nota `Alt + Space` til að halda AltGr lausu til að skrifa. Uppsetningar frá því áður en Alt + Space varð sjálfgefið halda `F9` fyrir ýta-til-að-tala og `Super + Ctrl + X` til að skipta, sem bætt er við í `~/.config/hypr/bindings.lua`; fjarlægðu þá þar til að skila lyklunum aftur til forritanna.

Sömu flýtilyklar virka með öllum bakendum. Veldu bakendann þinn í gegnum Uppsetning > Sjálfgefið > Talinnsláttur. Uppsetningarforrit bakendans stillir hann og vistar valið. Keyrðu `omarchy default dictation` til að sjá hvaða bakendi er valinn. Valið er vistað í `~/.config/omarchy/defaults/dictation`. Nýjar uppsetningar velja Superwhisper sjálfkrafa.

Omarchy hleður sjálfkrafa inn skjáborðssamþættingu valda bakendans. Engrar stillingar fyrir Superwhisper er þörf í `~/.config/hypr/`.

Sérsniðnar lyklabindingar og forskriftir geta notað `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Valdi bakendinn sér um upptökuna og umritunina. Þegar Superwhisper er valið er slökkt á innbyggða halda-flýtilyklinum þess og innbyggði skiptilykillinn þess stilltur á `Ctrl + Alt + Space`, þannig að hann helst aðskilinn frá upptökulyklum Omarchy. Superwhisper þarf að minnsta kosti einn innbyggðan upptökuflýtilykil, og hætta við-flýtilykillinn þess helst tiltækur.

Aukabakendar geta samþæst án þess að breyta Omarchy. Leggðu til keyrsluskrá með nafninu `omarchy-dictation-<backend>` á PATH sem tekur við `start`, `stop` og `toggle` og skilar strax, með stöðukóða sem er ekki núll ef eitthvað mistekst. Uppsetningarforrit þess stillir veituna og kallar á `omarchy-dictation-use <backend>` eftir að uppsetningu lýkur með góðum árangri. Þetta stöðvar fyrri bakendann og vistar valið atómískt; `stop` verður að heppnast þegar veitan er aðgerðarlaus eða ekki tiltæk. Nöfn bakenda nota lágstafi, tölustafi og bandstrik. Leggðu til `omarchy-install-dictation-<backend>` fyrir uppsetningu; `omarchy default dictation <backend>` ræsir hana. Bættu við færslu í Sjálfgefið-valmyndina í gegnum Omarchy-valmyndarviðbót til að kalla á þann veljara. Valfrjáls skjáborðssamþætting getur verið í `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
