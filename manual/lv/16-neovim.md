# Neovim

[Neovim](https://neovim.io/) ir moderna [vi redaktora](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) īstenošana, ko Bills Džojs izveidoja jau 1976. gadā. Tas ir modāls redaktors, kurā ievietošanas režīms un komandu režīms ir atdalīti, un tas ir mazliet kā superspēja, kad tu iemācies kaut tikai daļu no neticami dziļās taustiņu komandu kopas. Bet tas ir arī diezgan liels mācīšanās līkne!

Ja esi pilnīgi jauns vim stila rediģēšanā, es iesaku tev apskatīt [ThePrimeagen sēriju Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTube. Tas iemācīs tev pamatus. Tikai zini, ka atšķirībā no līdzīgākiem galvenās plūsmas redaktoriem tev būs nepieciešams ilgāks laiks, lai iegūtu pamata prasmes ar vim. Bet, kad iegūsi, atdeve ir arī lielāka.

Tagad Neovim ir būtībā bezgalīgi konfigurējams. Ja tu patiešām vēlies aizrauties, tu vari izveidot savu Neovim konfigurāciju no nulles. Ir lielisks kurss no [Typecraft par Neovim iestatīšanu no nulles](https://www.youtube.com/watch?v=zHTeCSVAFNY). Un [ThePrimeagen arī ir viens](https://www.youtube.com/watch?v=w7i4amO_zaE).

Bet Omarchy nāk ar pilnīgu Neovim iestatīšanu — pakotni `omarchy-nvim` —, kas ir ar mīlestību noskaņota, lai parādītu labāko no tā, kas ir iespējams uzreiz. Tev nav jāraksta neviena konfigurācijas rinda! Tā ir veidota uz [LazyVim](https://www.lazyvim.org/), Neovim spraudņu un konfigurāciju izplatījuma. Tas ir lieliski.

## LazyVim pamati

Kā jau minēts, es šajā īsajā ievadā nemācīšu tev vim, bet es varu parādīt dažus LazyVim pamatus un to, kā tajā pārvietoties.

Pirmkārt, Neovim ir līdera taustiņa ideja. Tā būtībā ir vārti uz visām komandām. LazyVim to ir iestatījis uz `Space`. Tāpēc vienkārši nospied to, pagaidi sekundi, un tu redzēsi virkni opciju, kas izskaidrotas tieši šādi:

Šeit ir dažas pamata komandas, ko es visu laiku izmantoju:

- `Space Space` - Izplūduši atrast jebkuru failu pašreizējā direktorijā.
- `Space S G` - Meklēt visus failus, izmantojot grep ar priekšskatījumu.
- `Space E` - Pārslēgt failu koku ieslēgtu/izslēgtu.
- `Ctrl + W W` - Lēkt no failu koka uz redaktoru un atpakaļ.
- `Shift + H` - Pārvietoties pa kreisi starp atvērtajām cilnēm (vim tos sauc par buferiem).
- `Shift + L` - Pārvietoties pa labi starp atvērtajām cilnēm.
- `Space B D` - Aizvērt cilni.
- `Space B O` - Aizvērt visas pārējās cilnes, izņemot pašreizējo.
- `Space G G` - Palaist LazyGit peldošā rūtī no pašreizējās direktorijas.
- `Space U W` - Pārslēgt mīksto aplaušanu.

Kamēr tu esi failu kokā (`Space E`, lai atklātu, `Ctrl + W W`, lai pārlēktu turp), tu vari pievienot jaunu failu ar `a` vai jaunu direktoriju ar `A`. Nospied `?`, kamēr esi kokā, lai redzētu visas komandas.

Ja vēlies apgūt pamata vim valodu, esmu rakstījis par [trīsdaļīgu sintaksi](https://world.hey.com/dhh/wonderful-vi-a1d034d3) un to, kā izpildīt tos slimo kombinētos gājienus!

Visas iespējamās komandas vari redzēt [lapā LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Neovim startēšana

Neovim vari startēt, izmantojot `Super + Shift + N` (piesaiste palaiž tavu noklusējuma redaktoru, kas uzreiz ir Neovim), bet parasti to ir vieglāk vadīt no termināla, pārvietojoties uz direktoriju, kurā vēlies strādāt, un rakstot `n`. `n` ir aizstājējvārds `nvim`, kas pēc noklusējuma izmantos pašreizējo direktoriju, lai atvērtu. Tu vari atvērt vienu failu ar `n myfile.txt`.

## Neovim izmantošana sudo rediģēšanai

Ja tev ir jārediģē faili, kurus vari mainīt tikai kā superlietotājs, tu vari izmantot neovim ar visiem saviem spraudņiem, kas ir iestatīti, palaižot `sudoedit /etc/sudoers.d/00-sudo-only-file`.
