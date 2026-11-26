# Avtentikacija s strojno opremo

### Avtentikacija s prstnim odtisom

Številni prenosniki imajo senzor za prstni odtis za avtentikacijo. V sistemu Omarchy ga lahko uporabite tako, da v meniju Omarchy (`Super + Space`) zaženete _Setup > Security > Fingerprint_.

Odpre se celozaslonski prstni odtis, ki se izpolnjuje, ko se dotikate senzorja. V ozadju bo Omarchy namestil paket za prstne odtise, zabeležil vaš odtis in ga preveril, vi pa boste pripravljeni, da s prstnim odtisom odklenete zaklenjeni zaslon (ki ga lahko sprožite s `Super + Ctrl + L`), vstopite v način sudo in potrjujete sistemske pozive.

Ko zaklenjeni zaslon izklopi zaslon, senzor miruje, da varčuje z energijo, zato zaslon prebudite s katero koli tipko ali sledilno ploščico, preden se ga dotaknete.

Ko je pokrov prenosnika zaprt, se poziv za prstni odtis samodejno preskoči, tako da greste naravnost na poziv za geslo, namesto da čakate na senzor, ki ga ne morete doseči. Če sicer morate delati na zunanji tipkovnici, ki nima senzorja, med pozivom za prstni odtis pri `sudo` preprosto pritisnite `CTRL + C`.

Avtentikacijo s prstnim odtisom lahko odstranite pod _Remove > Security > Fingerprint_ v meniju Omarchy.

### Avtentikacija Fido2

Če uporabljate napravo Fido2, jo lahko nastavite za avtentikacijo `sudo` z _Setup > Security > Fido2_ v meniju Omarchy (`Super + Space`). Vendar pokriva `sudo` in sistemske pozive za avtorizacijo, ne pa odklepanja računalnika.

Avtentikacijo fido2 lahko odstranite pod _Remove > Security > Fido2_ v meniju Omarchy.
