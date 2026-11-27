# Textaútdráttur og dikterun

### Textaútdráttur

Ýttu á `Super + Ctrl + PrtScr` til að velja svæði á skjánum fyrir textaútdrátt. Opna OCR-líkanið tesseract breytir þá valinu fljótt í texta og setur hann á klippiborðið. Síðan ýtir þú bara á `Super + V` til að líma.

Þetta er mjög gagnlegt til að ná heimilisföngum úr neðanmálstexta í myndum eða símanúmerum sem eru felld inn í fyrirsagnir á vefsíðum.

 ![text-extraction](images/text-extraction.webp)

### Dikterun

Í nýjum uppsetningum er [Superwhisper](https://superwhisper.com/) sjálfgefinn bakendi fyrir dikterun, með skýjavinnslu án þess að sækja þurfi líkön til notkunar án nettengingar. Veldu Superwhisper, [Voxtype](https://voxtype.io/) eða [Hex](https://anoma.ly/hex/) í gegnum _Uppsetning > Sjálfgefið > Dikterun_ í Omarchy-valmyndinni. Þegar bakendi er valinn er hann settur upp ef þörf krefur og gerður að sjálfgefnum bakenda fyrir dikterun. Voxtype hleður inn grunnlíkani fyrir ensku sem tekur 150MB; breyttu líkaninu með `voxtype setup model` og öðrum stillingum í gegnum `~/.config/voxtype/config.toml`. Superwhisper opnar stillingar sínar til að velja á milli skýjavinnslu og staðbundinnar vinnslu, og OPR heldur forritinu uppfærðu. Hex sækir talgreiningarlíkan sitt á tækinu meðan á uppsetningu stendur og keyrir sem `hex.service` notendaþjónustan; opnaðu glugga þess frá bakkatákninu á stikunni eða með því að keyra `hex` til að breyta líkaninu og öðrum stillingum.

Þú dikterar með því að halda inni `Right Alt`, eða með því að kveikja og slökkva með `Alt + Space`, og dikteraði textinn birtist í virka innsláttarsvæðinu. Þessir flýtilyklar nota valda bakendann. Right Alt ræsir einnig dikterun þegar það er notað í samsetningu með breytilykli; notaðu Left Alt fyrir slíkar samsetningar. Á lyklaborðsuppsetningum þar sem Right Alt er AltGr, þar á meðal þegar slík uppsetning er ein af þeim sem þú skiptir yfir í, haltu því inni einu og sér í smástund til að diktera; AltGr ýtt samtímis öðrum lykli skrifar enn stafinn sinn. Uppsetningar frá því áður en Alt + Space varð sjálfgefið halda `F9` fyrir ýttu-til-að-tala og `Super + Ctrl + X` til að kveikja og slökkva, bætt við `~/.config/hypr/bindings.lua`, þar sem þetta `Super + Ctrl + X` kemur í stað umboðsmannaborðsins; fjarlægðu þá þar til að skila þessum lyklum aftur til forrita og borðsins.

Sömu flýtilyklar virka með öllum bakendum. Veldu bakendann þinn í gegnum Uppsetning > Sjálfgefið > Dikterun. Uppsetningarforrit bakendans stillir hann og vistar valið. Keyrðu `omarchy default dictation` til að sjá hvaða bakendi er valinn. Valið er vistað í `~/.config/omarchy/defaults/dictation`. Nýjar uppsetningar velja Superwhisper sjálfkrafa.

Omarchy hleður sjálfkrafa inn skjáborðssamþættingu valda bakendans. Engin stilling fyrir Superwhisper er nauðsynleg í `~/.config/hypr/`.

Sérsniðnar lyklabindingar og forskriftir geta notað `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Valdi bakendinn sér um upptökuna og umritunina. Þegar Superwhisper er valið er innbyggður halda-flýtilykill þess gerður óvirkur og innbyggður kveikja-slökkva lykill þess settur á `Ctrl + Alt + Space`, þannig að hann helst aðskilinn frá upptökulyklum Omarchy. Superwhisper krefst að minnsta kosti eins innbyggðs upptökuflýtilykils, og hætta-við flýtilykill þess helst tiltækur.

Viðbótarbakendar geta samþæst án þess að breyta Omarchy. Gefðu upp keyrsluskrá með nafninu `omarchy-dictation-<backend>` á PATH sem tekur við `start`, `stop` og `toggle` og svarar strax, með stöðukóða sem er ekki núll ef aðgerð mistekst. Uppsetningarforrit hennar stillir veituna og kallar á `omarchy-dictation-use <backend>` eftir að uppsetningu lýkur með góðum árangri. Þetta stöðvar fyrri bakendann og vistar valið í einni óskiptanlegri aðgerð; `stop` verður að heppnast þegar veitan er aðgerðarlaus eða ekki tiltæk. Nöfn bakenda nota lágstafi, tölustafi og bandstrik. Gefðu upp `omarchy-install-dictation-<backend>` fyrir uppsetningu; `omarchy default dictation <backend>` ræsir hana. Bættu við færslu í Sjálfgefið-valmyndina í gegnum Omarchy-valmyndarviðbót til að kalla á þann veljara. Valfrjáls skjáborðssamþætting getur verið í `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
