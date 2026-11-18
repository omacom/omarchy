# Neovim

[Neovim](https://neovim.io/) suvremena je implementacija [uređivača vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) koji je Bill Joy stvorio još 1976. godine. To je modalni uređivač u kojemu su način umetanja i način naredbi odvojeni, a to je svojevrsna supermoć kada naučite čak i samo podskup nevjerojatno dubokoga skupa tipkovnih naredbi. Ali krivulja učenja poprilična je!

Ako ste posve novi u uređivanju u vim stilu, preporučujem da pogledate [ThePrimeagenov serijal Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTubeu. To će vas naučiti osnovama. Samo znajte da će vam, za razliku od sličnijih mainstream uređivača, trebati dulje da steknete osnovnu vještinu s vimom. Ali kada to učinite, dobitak je također veći.

Sada je Neovim u osnovi beskonačno podesiv. Ako doista želite poludjeti, možete izraditi vlastitu konfiguraciju Neovima od nule. Postoji sjajan tečaj od [Typecrafta o postavljanju Neovima od nule](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen također ima jedan](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ali Omarchy dolazi s cjelovitim postavkama Neovima — paketom `omarchy-nvim` — pomno podešenim da pokaže najbolje od onoga što je moguće odmah iz kutije. Bez da morate napisati ijedan redak konfiguracije! Izgrađen je na [LazyVimu](https://www.lazyvim.org/), distribuciji dodataka i konfiguracija za Neovim. Sjajan je.

## Osnove LazyVima

Kao što je spomenuto, neću vas učiti vim u ovome kratkome uvodu, ali mogu vam pokazati nekoliko osnova LazyVima i kako se snaći.

Prvo, Neovim ima ideju vodeće tipke. To je u osnovi prolaz do svih naredbi. LazyVim ju je postavio na `Space`. Dakle samo je pritisnite, pričekajte sekundu i vidjet ćete hrpu opcija objašnjenih u retku poput ovoga:

Evo nekoliko osnovnih naredbi koje stalno koristim:

- `Space Space` - Fuzzy pronađite bilo koju datoteku u trenutačnome direktoriju.
- `Space S G` - Pretražite sve datoteke pomoću grepa s pregledom.
- `Space E` - Uključite/isključite stablo datoteka.
- `Ctrl + W W` - Skačite sa stabla datoteka na uređivač i natrag.
- `Shift + H` - Pomaknite se ulijevo između otvorenih kartica (vim ih naziva međuspremnicima).
- `Shift + L` - Pomaknite se udesno između otvorenih kartica.
- `Space B D` - Zatvorite karticu.
- `Space B O` - Zatvorite sve ostale kartice osim trenutačne.
- `Space G G` - Pokrenite LazyGit u plutajućem oknu iz trenutačnoga direktorija.
- `Space U W` - Prebacite meko prelamanje.

Dok ste u stablu datoteka (`Space E` za otkrivanje, `Ctrl + W W` za skok tamo), novu datoteku možete dodati s `a` ili novi direktorij s `A`. Pritisnite `?` dok ste u stablu da vidite sve naredbe.

Ako želite savladati osnovni vim jezik, pisao sam o [trodijelnoj sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) i kako izvesti one sjajne kombinirane poteze!

Sve moguće naredbe možete vidjeti na [stranici LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pokretanje Neovima

Neovim možete pokrenuti pomoću `Super + Shift + N` (poveznica pokreće vaš zadani uređivač, što je odmah iz kutije Neovim), ali obično ga je lakše pokretati iz terminala tako da odete u direktorij u kojemu želite raditi i upišete `n`. `n` je alias za `nvim`, koji će prema zadanim postavkama otvoriti trenutačni direktorij. Jednu datoteku možete otvoriti s `n myfile.txt`.

## Korištenje Neovima za sudo uređivanja

Ako trebate uređivati datoteke koje možete mijenjati samo kao superkorisnik, možete koristiti Neovim sa svim svojim postavljenim dodacima pokretanjem `sudoedit /etc/sudoers.d/00-sudo-only-file`.
