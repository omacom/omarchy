# Pozadí

Každé téma se dodává s vlastní sadou pozadí a svá další si můžete přidat do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek na pozadí třeba k tématu nord, stačí soubor vložit do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v Omarchy Menu přejdete do _Instalace > Styl > Pozadí_. Otevře se vám složka, kde jsou uložena pozadí daného tématu. Stiskněte `Super + Shift + F` a spusťte další správce souborů, najděte své pozadí a zkopírujte ho tam. Teď bude součástí nabídky pozadí, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Pozadím mohou být i videa, nejen statické obrázky. Do stejné složky vložte soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává tapetový engine OWE. Video dekóduje jednou pro všechny monitory a jeho zvuk přehrává přes výchozí zvukový výstup, a kdykoli ho nic nevidí, přehrávání zastaví. Videotapeta pořád stojí mnohem víc energie než statická.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění a při přepnutí na téma s vybraným daným pozadím, poté se vrátí ke statickému obrázku. Introvidea se nezobrazují ve výběru pozadí a nikdy se nepřehrávají ve smyčce.

Vypnutí _Vzhled > Animace_ vypne i intra pozadí. Omarchy to ve virtuálním počítači dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu ani výběr jiného pozadí v rámci téhož tématu intro nespustí.

Obrovskou sbírku skvělých, pečlivě vybraných pozadí najdete na https://github.com/dharmx/walls.

Zamykací obrazovka zobrazuje statický snímek videopozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
