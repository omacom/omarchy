# Pozadí

Každé téma se dodává s vlastní sadou pozadí a vy si můžete přidat další vlastní v `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí například k tématu nord, prostě soubor vložíte do `~/.config/omarchy/backgrounds/nord`.

Nejsnáze to uděláte tak, že v Omarchy Menu přejdete na _Install > Style > Background_. Tím se otevře složka, kde jsou uložena pozadí pro dané téma. Stiskněte `Super + Shift + F` pro spuštění dalšího správce souborů, najděte své pozadí a zkopírujte ho tam. Nyní bude zahrnuto mezi pozadími, mezi kterými můžete vybírat pomocí `Super + Ctrl + W`.

Pozadí mohou být videa stejně jako statické obrázky. Vložte soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` do stejné složky a objeví se vedle obrázků. Videa přehrává engine pro tapety OWE. Dekóduje video jednou pro všechny monitory a přehrává jeho zvuk přes výchozí zvukový výstup a přehrávání zastaví, kdykoli ho nic nevidí. Video tapeta stále stojí mnohem více energie než statická.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění, při přepnutí na téma s vybraným daným pozadím a při výběru daného pozadí, poté se vrátí ke statickému obrázku. Intro videa zůstávají mimo výběr pozadí a nikdy se neopakují ve smyčce.

Vypnutí _Appearance > Animations_ také vypne intra pozadí. Omarchy to ve virtuálním počítači dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu intro nepřehrává.

Obrovskou sbírku skvělých vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek video pozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
