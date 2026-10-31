# Pozadí

Každý motiv se dodává s vlastní sadou pozadí a další si můžete přidat do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí například k motivu nord, stačí soubor vložit do `~/.config/omarchy/backgrounds/nord`.

Nejsnazší cesta vede přes nabídku Omarchy _Instalovat > Vzhled > Pozadí_. Otevře složku s pozadími aktuálního motivu. Pomocí `Super + Shift + F` otevřete další okno správce souborů, najděte požadovaný obrázek a zkopírujte ho do této složky. Pak se objeví mezi pozadími, která přepínáte zkratkou `Super + Ctrl + W`.

Pozadím mohou být vedle statických obrázků také videa. Vložte do stejné složky soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává jádro tapet OWE. Dekóduje video jednou pro všechny monitory a jeho zvuk přehrává přes výchozí zvukový výstup a přehrávání zastaví, kdykoli není vidět. Videotapeta přitom stále spotřebovává mnohem více energie než statická tapeta.

Motivy mohou ke statickému pozadí obsahovat krátké úvodní video. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehraje se automaticky při spuštění, při přepnutí na motiv s tímto vybraným pozadím a při výběru tohoto pozadí, poté se vrátí ke statickému obrázku. Úvodní videa se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Vypnutí animací v nabídce _Vzhled_ vypne také úvodní videa pozadí. Omarchy to ve výchozím nastavení dělá ve virtuálním počítači. Příkaz `omarchy theme bg intro toggle` může úvodní videa zapínat a vypínat samostatně. Obnovení motivu úvodní video nepřehraje.

Obrovskou sbírku skvělých vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek video pozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
