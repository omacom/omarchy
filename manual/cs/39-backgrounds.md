# Pozadí

Každé téma se dodává s vlastní sadou pozadí a další vlastní si můžete přidat do `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek na pozadí třeba k tématu nord, prostě soubor vložíte do `~/.config/omarchy/backgrounds/nord`.

Nejjednodušeji to uděláte tak, že v nabídce Omarchy Menu přejdete do _Instalace > Styl > Pozadí_. Otevře se složka, kde jsou uložena pozadí pro dané téma. Stisknutím `Super + Shift + F` spustíte další správce souborů, najdete své pozadí a zkopírujete ho tam. Nyní bude zahrnuto mezi pozadími, mezi kterými můžete přepínat pomocí `Super + Ctrl + W`.

Pozadí mohou být videa stejně jako statické obrázky. Vložte soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` do stejné složky a objeví se vedle obrázků. Videa přehrává engine pro tapety OWE. Dekóduje video jednou pro všechny monitory, přehrává jeho zvuk přes výchozí zvukový výstup a zastaví přehrávání, kdykoli ho nic nevidí. Video pozadí pořád spotřebuje mnohem více energie než statické.

Témata mohou obsahovat krátké intro pro statické pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehrává se automaticky při spuštění, při přepnutí na téma s vybraným daným pozadím a při výběru daného pozadí, poté se vrátí ke statickému obrázku. Úvodní videa se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Vypnutí _Vzhled > Animace_ také vypne intra pozadí. Omarchy to ve virtuálním počítači dělá ve výchozím nastavení. Příkaz `omarchy theme bg intro toggle` může intra přepínat samostatně. Obnovení tématu intro nepřehrává.

Statický obrázek může mít také smyčku, klidnou verzi téhož obrázku, která se stále pohybuje, v `backgrounds/loops/road.mp4`. Přehrává se místo statického obrázku, po jeho intru, pokud ho má, a zastaví se, když jsou animace vypnuté. Na baterii se místo ní zobrazuje statický obrázek a smyčka se vrátí, jakmile zařízení připojíte k napájení. Smyčky se nezobrazují ve výběru pozadí.

Obrovskou sbírku skvělých pečlivě vybraných pozadí najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zamykací obrazovka zobrazuje statický snímek video pozadí, stejně jako zobrazuje statický snímek animovaného GIFu.
