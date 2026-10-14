# Overjanje s strojno opremo

### Overjanje s prstnim odtisom

Veliko prenosnikov ima senzor za prstne odtise za overjanje. Z Omarchy ga lahko uporabite tako, da v meniju Omarchy (`Super + Space`) zaženete _Setup > Security > Fingerprint_.

To bo namestilo paket za prstne odtise, zbralo vaš odtis, ga preverilo in pripravljeni boste na uporabo prstnega odtisa za odklepanje na zaklenjenem zaslonu (ki ga lahko sprožite z `Super + Ctrl + L`), vstop v način sudo in odobritev sistemskih pozivov.

Ko zaklenjeni zaslon izklopi zaslon, senzor počiva, da prihrani energijo, zato zaslon pred dotikom senzorja zbudite s katero koli tipko ali sledilno ploščico.

Ko je pokrov prenosnika zaprt, se poziv za prstni odtis samodejno preskoči, tako da greste naravnost na poziv za geslo, namesto da čakate na senzor, ki ga ne morete doseči. Če morate sicer delati na zunanji tipkovnici brez senzorja, med pozivom za prstni odtis pri `sudo` preprosto pritisnite `CTRL + C`.

Overjanje s prstnim odtisom lahko odstranite v meniju Omarchy pod _Remove > Security > Fingerprint_.

### Overjanje s Fido2

Če uporabljate napravo Fido2, jo lahko nastavite za overjanje pri `sudo` z _Setup > Security > Fido2_ v meniju Omarchy (`Super + Space`). Pokriva pozive za `sudo` in sistemsko pooblastitev, ne pa tudi odklepanja računalnika.

Overjanje s Fido2 lahko odstranite v meniju Omarchy pod _Remove > Security > Fido2_.
