# Pozadí

Každý motiv se dodává s vlastní sadou pozadí a další si můžete přidat do složky `~/.config/omarchy/backgrounds/[theme]`. Pokud chcete přidat další obrázek pozadí například k motivu nord, stačí umístit soubor do složky `~/.config/omarchy/backgrounds/nord`.

Nejsnadněji to uděláte v nabídce Omarchy v části _Instalovat > Styl > Pozadí_. Otevře se složka, v níž jsou pozadí daného motivu uložena. Stiskem `Super + Shift + F` spustíte další správce souborů, najdete svoje pozadí a překopírujete ho. Nyní bude zahrnuto mezi pozadími, mezi nimiž si můžete vybírat zkratkou `Super + Ctrl + Space`.

Pozadím mohou být vedle statických obrázků také videa. Vložte do stejné složky soubor `mp4`, `m4v`, `mov`, `webm`, `mkv` nebo `avi` a objeví se vedle obrázků. Videa přehrává jádro tapet OWE. Dekóduje video jednou pro všechny monitory a jeho zvuk přehrává přes výchozí zvukový výstup a přehrávání zastaví, kdykoli není vidět. Zamykací obrazovka vykresluje stejné dekódování, ztlumené, přes OWE. Videotapeta přitom stále spotřebovává mnohem více energie než statická tapeta.

Motivy mohou obsahovat krátký úvod ke statickému pozadí. Pro `backgrounds/road.webp` se odpovídající video nachází v `backgrounds/intros/road.mp4`. Přehraje se automaticky při spouštění a při přepnutí na motiv s vybraným pozadím, a poté se vrátí ke statickému obrázku. Úvodní videa se nezobrazují ve výběru pozadí a nikdy se neopakují ve smyčce.

Vypnutí volby _Akce > Vzhled > Animace_ vypne také úvody pozadí. Omarchy to ve výchozím nastavení dělá ve virtuálním počítači. Příkaz `omarchy theme bg intro toggle` může úvody přepínat samostatně. Obnovení motivu ani volba jiného pozadí v rámci téhož motivu úvod nepřehraje.

Obrovskou sbírku krásných vybraných pozadí najdete na adrese https://github.com/dharmx/walls.

Videopozadí si na zamykací obrazovce zachovávají uložený statický obrázek, pokud je přehrávání pozastaveno nebo není k dispozici. Animované obrázky GIF se přehrávají na ploše a na zamykací obrazovce zobrazují statický snímek.
