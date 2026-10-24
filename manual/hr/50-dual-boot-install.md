# Instalacija dvostrukog pokretanja

Omarchy možete instalirati na jednu particiju pored Windowsa ili drugih instalacija.

Ova metoda instalacije i dalje prema zadanim postavkama dolazi s LUKS šifriranjem za particiju, pa se zapravo ne razlikuje od cijelog pogona i jednostavno zahtijeva slobodan prostor dostupan na disku.

## Stvaranje prostora na Windowsu

Za instalaciju pored Windowsa upišite `disk management` u izbornik Start i odaberite opciju **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Pronađite odgovarajuću particiju, kliknite desnim gumbom i odaberite **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Unesite iznos za koji želite smanjiti volumen. Imajte na umu da će to biti veličina vaše buduće Omarchy instalacije uključujući particiju za pokretanje.

 ![dual-boot-3](images/dual-boot-3.webp)

Kad završite, trebali biste vidjeti nešto poput ovoga, gdje je odjeljak od 50GB mjesto na koje ćemo u ovom primjeru instalirati Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacija Omarchyja

Postupak instalacije Omarchyja zapravo je isti kao i obično. Nakon što odaberete svoj disk, dobit ćete opciju **Free space install**. Odaberite tu opciju kako biste spriječili brisanje cijelog diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrdite da sve izgleda dobro i pričekajte da instalacija završi kao i obično. Ovdje također možete odabrati instalaciju bez šifriranja (nije preporučeno), baš kao na instalaciji cijelog pogona.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodavanje drugih instalacija u bootloader

Kad završite svoju Omarchy instalaciju, primijetit ćete da je Limine bootloader sada zadani. S njime u Limine također možete dodati opcije za svoje druge instalacije poput Windowsa.

Da biste to učinili, pokrenite `limine-scan` i slijedite upite za dodavanje stavki koje želite u svoju limine konfiguraciju. Zatim ćete pri pokretanju vidjeti svoje uobičajene opcije za Omarchy, kao i Windows Boot Manager ili druge.

## Bitlocker

Važno je napomenuti da ova metoda instalacije nije kompatibilna s Bitlockerom jer šifrira cijeli pogon, a ne samo particiju. Ako naiđete na pogrešku koja navodi da je Bitlocker omogućen, pokrenite Windows, idite na **Settings -> Privacy & Security -> Device encryption** i isključite Bitlocker. Dešifriranje pogona može potrajati.

 ![dual-boot-7](images/dual-boot-7.webp)
