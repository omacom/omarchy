# Pozadí

Každé téma se dodává s vlastní sadou pozadí a další vlastní si můžete přidat do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí třeba do tématu nord, stačí soubor umístit do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v Omarchy Menu přejdete na _Instalace > Styl > Pozadí_. Otevře se vám složka, ve které jsou uložena pozadí pro dané téma. Stisknutím `Super + Shift + F` spustíte další správce souborů, najdete své pozadí a zkopírujete ho sem. Nyní bude zahrnuto mezi pozadími, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Pozadí mohou být videa i statické obrázky. Vložte do stejné složky soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává engine tapet OWE. Video dekóduje jednou pro všechny monitory, jeho zvuk přehrává přes výchozí zvukový výstup a přehrávání zastaví vždy, když ho nic nemůže vidět. Video tapeta stále spotřebovává mnohem více energie než statická.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehraje se automaticky při spuštění systému, při přepnutí na téma s vybraným tímto pozadím a při výběru tohoto pozadí, poté se vrátí ke statickému obrázku. Intro videa se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Výběrem _Vzhled > Vypnout animace_ vypnete také intra pozadí. Omarchy to ve virtuálním stroji dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu intro nepřehraje.

Statický obrázek může mít také smyčku, tichou verzi téhož obrázku, která se neustále pohybuje, v `backgrounds/loops/road.mp4`. Přehrává se místo statického obrázku, po jeho intru, pokud nějaké má, a zastaví se, když jsou animace vypnuté. Při napájení z baterie se místo ní zobrazí statický obrázek a smyčka se vrátí, jakmile zařízení připojíte k napájení. Smyčky se nezobrazují ve výběru pozadí.

Obrovskou sbírku skvělých vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek video pozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
