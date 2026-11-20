# Instalacija s dual bootom

Možete instalirati Omarchy na jednu particiju uz Windows ili druge instalacije.

Ova metoda instalacije i dalje prema zadanim postavkama uključuje LUKS šifriranje za particiju, pa se u praksi ne razlikuje od instalacije na cijeli disk i jednostavno zahtijeva slobodan prostor na disku.

## Oslobađanje prostora u Windowsu

Za instalaciju uz Windows upišite `disk management` u izborniku Start i odaberite opciju **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Pronađite odgovarajuću particiju, kliknite je desnom tipkom miša i odaberite **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Unesite količinu za koju želite smanjiti volumen. Imajte na umu da će to biti veličina vaše buduće Omarchy instalacije, uključujući particiju za pokretanje.

 ![dual-boot-3](images/dual-boot-3.webp)

Kada završite, trebali biste vidjeti nešto poput ovoga, gdje je odjeljak od 50GB mjesto na koje ćemo u ovom primjeru instalirati Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacija Omarchyja

Postupak instalacije Omarchyja u praksi je isti kao i inače. Nakon što odaberete disk, dobit ćete opciju **Free space install**. Odaberite tu opciju kako biste spriječili brisanje cijelog diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrdite da sve izgleda dobro i pričekajte da se instalacija završi kao i inače. Ovdje također možete odabrati nešifriranu instalaciju (ne preporučuje se), baš kao i kod instalacije na cijeli disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodavanje drugih instalacija u bootloader

Kada završite instalaciju Omarchyja, primijetit ćete da je Limine bootloader sada zadani. Uz njega u Limine možete dodati i opcije za svoje druge instalacije, kao što je Windows.

Za dodavanje drugih operativnih sustava pokrenite `limine-scan` i slijedite upute za dodavanje željenih unosa u svoju Limine konfiguraciju. Izbornik za pokretanje prema zadanim postavkama ostaje skriven i pokreće Omarchy nakon jedne sekunde. Za odabir Windowsa ili drugog unosa pritisnite bilo koju tipku čim se Limine pokrene; kada se izbornik pojavi, pomoću tipki sa strelicama odaberite unos i pritisnite Enter. Ako se Omarchy pokrene prije nego što pritisnete tipku, ponovno pokrenite računalo i pokušajte opet.

## Bitlocker

Važno je napomenuti da ova metoda instalacije nije kompatibilna s Bitlockerom jer on šifrira cijeli disk, a ne samo particiju. Ako naiđete na pogrešku koja navodi da je Bitlocker omogućen, pokrenite Windows, idite na **Settings -> Privacy & Security -> Device encryption** i isključite Bitlocker. Dešifriranje diska može potrajati.

 ![dual-boot-7](images/dual-boot-7.webp)
