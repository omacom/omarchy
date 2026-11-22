# Terminālis

[Foot](https://codeberg.org/dnkl/foot) ir noklusējuma terminālis Omarchy. Tas ir ātrs, viegls un savietojams pat ar veciem datoriem. Tomēr tas neatbalsta vietējās cilnes vai dalījumus.

Ja tu izmanto Tmux, tev tas varbūt nerūp, bet, ja ne, mēs pilnībā atbalstām arī _Alacritty_, _Ghostty_ un _Kitty_ kā opcijas. Izvēlies savu priekšroku zem _Instalēt > Terminālis_ Omarchy izvēlnē.

Jaunu termināli startē, izmantojot `Super + Return`. (Šī piesaiste automātiski norādīs uz jebkuru termināli, ko esi instalējis, izmantojot _Instalēt > Terminālis_, un tu vari pārslēgties starp instalētajiem termināliem zem _Iestatīšana > Noklusējumi > Terminālis_.)

## Tmux

Tmux nodrošina konsekventu, programmējamu saskarni rūtīm, logiem (pazīstamiem arī kā cilnēm) un atsākamām sesijām neatkarīgi no tava termināla. Tas darbojas pat attālos saimniekos, tāpēc, kad tu veic SSH uz serveri, tu vari izmantot to pašu pieeju.

Jaunu Tmux sesiju svaigā terminālī startē, izmantojot `Super + Alt + Return`, un, tā kā Tmux ir pastāvīgs process, tu vari atsākt savu sesiju pat tad, ja aizver šo termināli. Vienkārši nospied `Ctrl + Space` (ko sauc par prefiksa taustiņu), pēc tam `s`, lai redzētu visas savas aktīvās sesijas.

Omarchy nāk ar ergonomiski optimizētu Tmux konfigurāciju, kurai ir daudz taustiņu piesaišu, kas jāiemācās, tāpēc turi [apkrāptu lapu pa rokai](07-hotkeys.md#tmux).

## Tmux izkārtojuma funkcijas

Tā kā Tmux ir programmējams, mēs varam izmantot funkcijas, lai izveidotu izkārtojumus. Omarchy nāk ar četrām dažādām funkcijām izplatītiem izstrādātāju izkārtojumiem.

`tdl [agent]` startē trīsdaļīgu IDE līdzīgu saskarni ar `$EDITOR` kreisajā pusē, tavu izvēlēto AI aģentu labajā pusē (piemēram, `c` opencode vai `cx` Claude vai `codex` OpenAI) un pēc tam termināli apakšā.

Tātad `tdl c` startētu šo (vai vienkārši `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Tu vari arī startēt otru aģentu ar `tdl c cx` (opencode + claude) (vai vienkārši `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Ir arī `tds`, kas startē četrdaļīgu kvadrātu ar redaktoru augšējā kreisajā stūrī, dzīvu diff vērotāju augšējā labajā stūrī, termināli apakšējā kreisajā stūrī un opencode apakšējā labajā stūrī.

Tu vari startēt šo izkārtojuma konfigurāciju arī katrai apakšdirektorijai pašreizējā direktorijā, izmantojot `tdlm [agent]`, pēc tam pārvietoties, izmantojot `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Visbeidzot, tu vari startēt aģentu spietu, izmantojot `tsl [panes] [command]`. Tātad `tsl 4 c` dos tev četrdaļīgu opencode aģentu režģi:

 ![tmux-tsl](images/tmux-tsl.webp)
