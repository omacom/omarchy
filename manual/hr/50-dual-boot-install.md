# Instalacija s dvostrukim pokretanjem

Omarchy možete instalirati na jednu particiju uz Windows ili druge instalacije.

Ovaj način instalacije i dalje prema zadanim postavkama dolazi s LUKS enkripcijom za particiju, pa se zapravo ne razlikuje od instalacije na cijeli disk i jednostavno zahtijeva slobodan prostor dostupan na disku.

## Oslobađanje prostora u Windowsima

Za instalaciju uz Windows upišite `disk management` u izborniku Start i odaberite opciju **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Pronađite odgovarajuću particiju, kliknite je desnom tipkom miša i odaberite **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Unesite iznos za koji želite smanjiti volumen. Imajte na umu da će to biti veličina vaše buduće instalacije Omarchyja, uključujući particiju za pokretanje.

 ![dual-boot-3](images/dual-boot-3.webp)

Kada završite, trebali biste vidjeti nešto ovako, gdje je odjeljak od 50GB onaj na koji ćemo u ovom primjeru instalirati Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacija Omarchyja

Postupak instalacije Omarchyja zapravo je isti kao i inače. Nakon što odaberete disk, dobit ćete opciju **Free space install**. Odaberite tu opciju kako biste spriječili brisanje cijelog diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrdite da sve izgleda dobro i pričekajte da instalacija završi kao i inače. Ovdje također možete odabrati instalaciju bez enkripcije (ne preporučuje se), baš kao i kod instalacije na cijeli disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodavanje drugih instalacija u pokretački program

Kada završite instalaciju Omarchyja, primijetit ćete da je pokretački program Limine sada zadani. Pomoću njega u Limine možete dodati i opcije za svoje druge instalacije, poput Windowsa.

Za dodavanje drugih operativnih sustava pokrenite `limine-scan` i slijedite upute za dodavanje željenih unosa u svoju konfiguraciju Liminea. Izbornik za pokretanje prema zadanim postavkama ostaje skriven i pokreće Omarchy nakon jedne sekunde. Za odabir Windowsa ili drugog unosa pritisnite bilo koju tipku čim se Limine pokrene; kada se izbornik pojavi, pomoću tipki sa strelicama odaberite unos i pritisnite Enter. Ako se Omarchy pokrene prije nego što pritisnete tipku, ponovno pokrenite računalo i pokušajte ponovno. Ako ste uključili _Setup > Direct Boot_, firmver u potpunosti preskače Limine, pa odaberite Limine iz izbornika za pokretanje BIOS-a ili ponovno pokrenite _Setup > Direct Boot_ kako biste uklonili unos.

## Bitlocker

Važno je napomenuti da ovaj način instalacije nije kompatibilan s Bitlockerom jer on šifrira cijeli disk, a ne samo particiju. Ako naiđete na pogrešku koja navodi da je Bitlocker omogućen, pokrenite Windows, idite na **Settings -> Privacy & Security -> Device encryption** i isključite Bitlocker. Dešifriranje diska može potrajati neko vrijeme.

 ![dual-boot-7](images/dual-boot-7.webp)
