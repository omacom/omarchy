# Neovim

[Neovim](https://neovim.io/) je moderna implementacija [uređivača vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) koji je Bill Joy stvorio još daleke 1976. godine. To je modalni uređivač u kojem su način umetanja i naredbeni način odvojeni i svojevrsna je supermoć kad naučite čak i samo dio nevjerojatno opsežnog skupa naredbi pomoću tipki. Ali krivulja učenja je također poprilična!

Ako ste potpuno novi u uređivanju u stilu vima, preporučujem da pogledate [ThePrimeagenovu seriju Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTubeu. Ona će vas naučiti osnovama. Samo znajte da će vam, za razliku od sličnijih uobičajenih uređivača, trebati više vremena da steknete osnovnu vještinu rada s vimom. Ali kad je steknete, i dobitak je veći.

Neovim je u biti beskonačno prilagodljiv. Ako baš želite pretjerati, možete izraditi vlastitu konfiguraciju Neovima od nule. Postoji sjajan tečaj autora [Typecraft o postavljanju Neovima od nule](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen ima jedan također](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ali Omarchy dolazi s cjelovitom postavkom Neovima — paketom `omarchy-nvim` — koja je s ljubavlju ugođena kako bi odmah po instalaciji pokazala najbolje što je moguće. A da ne morate napisati ni jedan jedini redak konfiguracije! Temelji se na [LazyVimu](https://www.lazyvim.org/), distribuciji dodataka i konfiguracija za Neovim. Odličan je.

## Osnove LazyVima

Kao što sam spomenuo, neću vas u ovom kratkom uvodu učiti vim, ali mogu vam pokazati nekoliko osnova LazyVima i kako se snaći.

Prvo, Neovim ima pojam vodeće tipke. To je u osnovi ulaz u sve naredbe. LazyVim ju je postavio na `Space`. Dakle samo je pritisnite, pričekajte sekundu i vidjet ćete hrpu opcija objašnjenih u retku ovako:

Evo nekoliko osnovnih naredbi koje stalno koristim:

- `Space Space` - Pomoću nejasnog pretraživanja pronađite bilo koju datoteku u trenutnom direktoriju.
- `Space S G` - Pretražite sve datoteke pomoću naredbe grep uz pregled.
- `Space E` - Uključite/isključite stablo datoteka.
- `Ctrl + W W` - Skačite sa stabla datoteka na uređivač i natrag.
- `Shift + H` - Pomaknite se ulijevo među otvorenim karticama (vim ih zove međuspremnici).
- `Shift + L` - Pomaknite se udesno među otvorenim karticama.
- `Space B D` - Zatvorite karticu.
- `Space B O` - Zatvorite sve ostale kartice osim trenutne.
- `Space G G` - Pokrenite LazyGit u plutajućem oknu iz trenutnog direktorija.
- `Space U W` - Uključite/isključite meko prelamanje teksta.

Dok ste u stablu datoteka (`Space E` za otkrivanje, `Ctrl + W W` za skok onamo), možete dodati novu datoteku pomoću `a` ili novi direktorij pomoću `A`. Pritisnite `?` dok ste u stablu da biste vidjeli sve naredbe.

Ako želite usvojiti osnovni jezik vima, pisao sam o [trodijelnoj sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) i o tome kako izvesti te lude kombinirane poteze!

Sve moguće naredbe možete vidjeti na [stranici LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Pokretanje Neovima

`Super + Shift + N` pokreće vaš zadani uređivač, što je na novim instalacijama Plain; odaberite Neovim pod _Setup > Defaults > Editor_ da se umjesto njega pokreće Neovim. Ali obično ga je lakše pokretati iz terminala tako da odete u direktorij u kojem želite raditi i upišete `n`. `n` je alias za `nvim`, koji će prema zadanim postavkama otvoriti trenutni direktorij. Pojedinačnu datoteku možete otvoriti pomoću `n myfile.txt`.

## Korištenje Neovima za uređivanje pomoću naredbe sudo

Ako trebate uređivati datoteke koje možete mijenjati samo kao superkorisnik, pokrenite `sudoedit /etc/sudoers.d/00-sudo-only-file`. Otvara vaš zadani uređivač, pa postavite Neovim pod _Setup > Defaults > Editor_ ako ga želite ondje sa svim svojim dodacima.
