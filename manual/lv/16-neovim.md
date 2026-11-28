# Neovim

[Neovim](https://neovim.io/) ir moderna [vi redaktora](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) versija, ko Bill Joy radīja jau tālajā 1976. gadā. Tas ir modāls redaktors, kurā ievades režīms un komandu režīms ir atdalīti, un tā ir gandrīz vai superspēja, tiklīdz apgūsti kaut tikai nelielu daļu no neticami plašā taustiņu komandu klāsta. Taču arī mācīšanās līkne ir visai stāva!

Ja vim stila rediģēšana tev ir pilnīgi sveša, iesaku noskatīties [ThePrimeagen sēriju Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) vietnē YouTube. Tā tev iemācīs pašus pamatus. Tikai rēķinies, ka atšķirībā no līdzīgākiem plaši izplatītajiem redaktoriem ar vim pamatprasmes apgūsi ilgāk. Taču, kad tas būs izdarīts, arī ieguvums būs lielāks.

Neovim ir praktiski bezgalīgi konfigurējams. Ja patiešām gribi trakot, vari izveidot savu Neovim konfigurāciju no nulles. Ir lielisks [Typecraft kurss par Neovim iestatīšanu no nulles](https://www.youtube.com/watch?v=zHTeCSVAFNY). Un [ThePrimeagen arī ir viens tāds](https://www.youtube.com/watch?v=w7i4amO_zaE).

Taču Omarchy komplektā ir pilnīga Neovim vide — pakotne `omarchy-nvim` —, kas ar mīlestību noslīpēta, lai parādītu labāko, kas iespējams jau uzreiz pēc instalēšanas. Bez nevienas pašam rakstītas konfigurācijas rindas! Tā ir balstīta uz [LazyVim](https://www.lazyvim.org/), Neovim spraudņu un konfigurāciju distributīvu. Tas ir lieliski.

## LazyVim pamati

Kā jau minēju, šajā īsajā ievadā es tev vim nemācīšu, bet varu parādīt dažus LazyVim pamatus un to, kā tajā orientēties.

Vispirms — Neovim ir tāds jēdziens kā līdertaustiņš. Tie būtībā ir vārti uz visām komandām. LazyVim tam ir iestatījis `Space`. Vienkārši nospied to, pagaidi sekundi, un redzēsi kaudzi iespēju, kas paskaidrotas tieši turpat, šādi:

Šeit ir dažas pamatkomandas, kuras lietoju visu laiku:

- `Space Space` - Atrast jebkuru failu pašreizējā direktorijā ar izplūdušo meklēšanu.
- `Space S G` - Meklēt visos failos ar grep un priekšskatījumu.
- `Space E` - Ieslēgt/izslēgt failu koku.
- `Ctrl + W W` - Pārlēkt no failu koka uz redaktoru un atpakaļ.
- `Shift + H` - Pārvietoties pa kreisi starp atvērtajām cilnēm (vim tās sauc par buferiem).
- `Shift + L` - Pārvietoties pa labi starp atvērtajām cilnēm.
- `Space B D` - Aizvērt cilni.
- `Space B O` - Aizvērt visas pārējās cilnes, izņemot pašreizējo.
- `Space G G` - Palaist LazyGit peldošā rūtī no pašreizējā direktorija.
- `Space U W` - Ieslēgt/izslēgt mīksto aplaušanu.

Kamēr esi failu kokā (`Space E`, lai to parādītu, `Ctrl + W W`, lai uz to pārlēktu), vari pievienot jaunu failu ar `a` vai jaunu direktoriju ar `A`. Nospied `?`, kamēr esi kokā, lai redzētu visas komandas.

Ja gribi apgūt vim valodas pamatus, esmu rakstījis par [trīsdaļīgo sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) un par to, kā izpildīt tos iespaidīgos kombinētos gājienus!

Visas iespējamās komandas vari redzēt [LazyVim taustiņu saīšņu lapā](https://www.lazyvim.org/keymaps).

## Neovim palaišana

`Super + Shift + N` palaiž tavu noklusējuma redaktoru, kas jaunās instalācijās ir Plain; izvēlies Neovim sadaļā _Setup > Defaults > Editor_, lai tā vietā tiktu palaists Neovim. Taču parasti to ir vieglāk darbināt no termināļa, pārejot uz direktoriju, kurā gribi strādāt, un ierakstot `n`. `n` ir `nvim` aizstājējvārds, kas pēc noklusējuma atvērs pašreizējo direktoriju. Vienu failu vari atvērt ar `n myfile.txt`.

## Neovim izmantošana sudo rediģēšanai

Ja jārediģē faili, kurus vari mainīt tikai kā superlietotājs, palaid `sudoedit /etc/sudoers.d/00-sudo-only-file`. Tas atver tavu noklusējuma redaktoru, tāpēc iestati Neovim sadaļā _Setup > Defaults > Editor_, ja gribi to tur ar visiem saviem spraudņiem.
