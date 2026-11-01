# Uobičajene prilagodbe

Ovo je zbirka uobičajenih prilagodbi Omarchy postave. Znajte da će ponekad možda biti potrebno da ažuriranja sustava vrate određene konfiguracije u izvorno stanje. Ako se to dogodi, vaše promjene neće biti izgubljene, nego spremljene u `.bak` datoteku u istom direktoriju.

Ako nešto pokvarite, pojedinačne konfiguracije možete vratiti u izvornu postavu putem _Ažuriraj > Config_ u Omarchy izborniku. Ako _stvarno_ sve pokvarite, sve konfiguracije možete resetirati putem `omarchy-reinstall`.

### Uvijek otkrivanje svih ikona ladice

Prema zadanim postavkama ikone ladice, poput Dropboxa, 1passworda ili Steama, skrivene su iza strelice za proširenje ladice, koja ih otkriva kad prijeđete preko nje. Ako ih želite uvijek izložene, desnim gumbom kliknite strelicu za proširenje da biste otvorili upravitelj ikona ladice, a zatim pričvrstite ikone koje želite zadržati vidljivima (također možete sakriti one koje nikada ne želite vidjeti).

### Zaobljeni kutovi prozora

Zadani dizajn Omarchyja jest onaj četvrtastih kutova, ali ako ga želite malo omekšati, možete promijeniti `~/.config/hypr/looknfeel.lua` tako da zaobljivanje više nije komentirano:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Uklanjanje razmaka između prozora

Na zaslonima prijenosnih računala neki ljudi radije ne troše nijedan piksel na razmake između prozora (ili čak gornju traku, koju možete isključiti s `Super + Shift + Space`). Sve razmake i obrube možete isključiti s `Super + Shift + Backspace` ili ih trajno ukloniti uklanjanjem komentara u ovom odjeljku datoteke `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
