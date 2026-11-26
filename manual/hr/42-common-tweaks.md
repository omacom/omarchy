# Uobičajene prilagodbe

Ovo je zbirka uobičajenih prilagodbi postavke Omarchyja. Imajte na umu da će ažuriranja sustava povremeno možda morati vratiti određene konfiguracije u izvorno stanje. Ako se to dogodi, vaše promjene neće biti izgubljene, nego će biti pohranjene u datoteku `.bak.<timestamp>` pokraj izvorne.

Ako nešto zeznete, pojedinačne konfiguracije možete vratiti na izvornu postavku putem _Update > Config_ u izborniku Omarchyja. Ako _stvarno_ sve zeznete, sve konfiguracije možete resetirati putem `omarchy reinstall configs` ili ponovno instalirati svaki zadani paket i konfiguraciju naredbom `omarchy reinstall`.

### Stalno prikazuj sve ikone palete

Ikone palete, poput Dropbox, 1password ili Steam, prema zadanim su postavkama skrivene iza strelice za proširivanje palete, koja ih otkriva kada zadržite pokazivač iznad nje. Ako želite da budu stalno izložene, desnom tipkom miša kliknite strelicu za proširivanje kako biste otvorili upravitelj ikona palete, a zatim prikvačite ikone koje želite zadržati vidljivima (možete sakriti i one koje nikada ne želite vidjeti).

### Zaobljeni kutovi prozora

Zadani dizajn Omarchyja ima četvrtaste kutove, ali ako to želite malo ublažiti, odaberite _Appearance > Windows > Window Corners > Rounded Corners_ u izborniku Omarchyja ili pokrenite `omarchy hyprland corners rounded`. _Theme Corners_ vraća ono što tema koristi. Kako biste odabrali vlastiti polumjer, ostanite na _Theme Corners_ (`omarchy hyprland corners theme`), jer se Rounded i Sharp učitavaju nakon vaše konfiguracije i nadjačavaju je, te uklonite komentar za zaobljenje u `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Ukloni razmake među prozorima

Na zaslonima prijenosnih računala neki ljudi radije ne troše nijedan piksel na razmake među prozorima (pa čak ni na gornju traku, koju možete isključiti kombinacijom `Super + Shift + Space`). Sve razmake i obrube možete isključiti kombinacijom `Super + Shift + Backspace` ili ih trajno ukloniti uklanjanjem komentara u ovom odjeljku datoteke `~/.config/hypr/looknfeel.lua`:

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
