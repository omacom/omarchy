# Pozadí

Každé téma se dodává s vlastní sadou pozadí a další vlastní si můžete přidat do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek na pozadí například k tématu nord, prostě soubor vložíte do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v Omarchy Menu přejdete na _Install > Style > Background_. Otevře se tím složka, kde jsou uložena pozadí pro dané téma. Stiskněte `Super + Shift + F` pro spuštění dalšího správce souborů, najděte své pozadí a zkopírujte ho tam. Nyní bude zahrnuto mezi pozadími, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Pozadí mohou být stejně tak videa jako statické obrázky. Vložte do stejné složky soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává engine tapet OWE. Video dekóduje jednou pro všechny monitory, jeho zvuk přehrává přes výchozí zvukový výstup a přehrávání zastaví, kdykoli ho nic nevidí. Videotapeta stále spotřebuje mnohem více energie než statická.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází na `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění, při přepnutí na téma s vybraným tímto pozadím a při výběru tohoto pozadí, a poté se vrátí ke statickému obrázku. Videa intr se nezobrazují ve výběru pozadí a nikdy se nepřehrávají ve smyčce.

Vypnutí _Appearance > Animations_ také vypne intra pozadí. Omarchy to ve virtuálním počítači dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu intro nepřehraje.

Statický obrázek může mít také smyčku, klidnou verzi stejného obrázku, která se dál pohybuje, na `backgrounds/loops/road.mp4`. Přehrává se místo statického obrázku, po jeho intru, pokud ho má, a zastaví se, když jsou animace vypnuté. Smyčky se nezobrazují ve výběru pozadí a stejně jako každé videopozadí spotřebují více energie než statický obrázek.

Obrovskou sbírku skvělých pečlivě vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek videopozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
