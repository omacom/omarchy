# Pozadí

Každé téma se dodává s vlastní sadou pozadí a můžete si přidat další vlastní v `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí například k tématu nord, stačí soubor vložit do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v nabídce Omarchy Menu přejdete do _Install > Style > Background_. Otevře se vám složka, kde jsou uložena pozadí pro dané téma. Stiskněte `Super + Shift + F` pro spuštění dalšího správce souborů, najděte své pozadí a zkopírujte ho tam. Nyní bude zahrnuto mezi pozadími, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Téma, které nemá žádná vlastní pozadí, dostane jedno vykreslené ze svých barev: logo Omarchy v akcentové barvě tématu na jeho barvě pozadí. Přidejte si vlastní a nahraďte ho.

Pozadí mohou být i videa, nejen statické obrázky. Vložte do stejné složky soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává wallpaper engine OWE. Video dekóduje jednou pro všechny monitory a jeho zvuk přehrává přes výchozí zvukový výstup a přehrávání zastaví, kdykoli ho nic nemůže vidět. Video jako pozadí stále spotřebovává mnohem více energie než statické pozadí.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění, při přepnutí na téma s vybraným daným pozadím a při výběru daného pozadí, poté se vrátí ke statickému obrázku. Introvidea se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Výběr _Appearance > Animations Off_ také vypne intra pozadí. Omarchy to ve virtuálním stroji dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu intro nepřehrává.

Statický obrázek může mít také smyčku, tichou verzi téhož obrázku, která se stále pohybuje, v `backgrounds/loops/road.mp4`. Přehrává se místo statického obrázku, po jeho intru, pokud nějaké má, a zastaví se, když jsou animace vypnuté. Na baterii se místo toho zobrazuje statický obrázek a smyčka se vrátí, jakmile zařízení připojíte k napájení. Smyčky se nezobrazují ve výběru pozadí.

Obrovskou sbírku skvělých vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek videopozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
