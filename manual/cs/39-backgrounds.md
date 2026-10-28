# Pozadí

Každé téma se dodává s vlastní sadou pozadí a můžete si přidat další vlastní do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí například k tématu nord, stačí soubor umístit do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v nabídce Omarchy Menu přejdete do _Install > Style > Background_. Otevře se tím složka, kde jsou uložena pozadí pro dané téma. Stiskněte `Super + Shift + F` pro spuštění dalšího správce souborů, najděte své pozadí a zkopírujte ho tam. Nyní bude zahrnuto mezi pozadí, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Pozadí mohou být videa i statické obrázky. Vložte soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` do stejné složky a objeví se vedle obrázků. Videa přehrává wallpaper engine OWE. Dekóduje video jednou pro všechny monitory a přehrává jeho zvuk přes výchozí zvukový výstup a zastaví přehrávání vždy, když ho nic nemůže vidět. Video pozadí stále spotřebovává mnohem více energie než statické.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění a při přepnutí na téma s vybraným tímto pozadím, poté se vrátí ke statickému obrázku. Intro videa se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Vypnutí _Appearance > Animations_ vypne také intra pozadí. Omarchy to ve virtuálním počítači dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu nebo výběr jiného pozadí v rámci stejného tématu intro nespustí.

Obrovskou sbírku skvělých vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek video pozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
