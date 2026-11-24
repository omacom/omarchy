# Instalacija dvostrukog pokretanja

Omarchy možete instalirati na jednu particiju uz Windows ili druge instalacije.

Ova metoda instalacije i dalje prema zadanim postavkama dolazi s LUKS šifriranjem particije, pa se zapravo ne razlikuje od instalacije na cijeli disk i jednostavno zahtijeva slobodan prostor na disku.

## Oslobađanje prostora u Windowsu

Da biste instalirali uz Windows, u izborniku Start upišite `disk management` i odaberite opciju **Stvori i formatiraj particije tvrdog diska**.

 ![dual-boot-1](images/dual-boot-1.webp)

Pronađite odgovarajuću particiju, kliknite je desnom tipkom miša i odaberite **Smanji volumen**.

![dual-boot-2](images/dual-boot-2.webp)

 Unesite iznos za koji želite smanjiti volumen. Imajte na umu da će to biti veličina vaše buduće instalacije Omarchyja, uključujući particiju za pokretanje.

 ![dual-boot-3](images/dual-boot-3.webp)

Kada završite, trebali biste vidjeti nešto slično ovome, gdje je odjeljak od 50GB mjesto na koje ćemo u ovom primjeru instalirati Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacija Omarchyja

Postupak instalacije Omarchyja zapravo je isti kao i inače. Nakon što odaberete disk, dobit ćete opciju **Instalacija na slobodni prostor**. Odaberite tu opciju kako biste spriječili brisanje cijelog diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potvrdite da sve izgleda dobro i pričekajte da instalacija završi kao i inače. Ovdje također možete odabrati instalaciju bez šifriranja (ne preporučuje se), baš kao i kod instalacije na cijeli disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodavanje drugih instalacija u bootloader

Kada završite instalaciju Omarchyja, primijetit ćete da je Limine bootloader sada zadani. Uz njega u Limine možete dodati i opcije za druge instalacije, poput Windowsa.

Da biste dodali druge operacijske sustave, pokrenite `limine-scan` i slijedite upute kako biste željene unose dodali u svoju Limine konfiguraciju. Izbornik za pokretanje prema zadanim postavkama ostaje skriven i pokreće Omarchy nakon jedne sekunde. Da biste odabrali Windows ili drugi unos, pritisnite bilo koju tipku čim se Limine pokrene; kada se izbornik pojavi, tipkama sa strelicama odaberite unos i pritisnite Enter. Ako se Omarchy pokrene prije nego što pritisnete tipku, ponovno pokrenite računalo i pokušajte ponovno.

## Bitlocker

Važno je napomenuti da ova metoda instalacije nije kompatibilna s Bitlockerom jer on šifrira cijeli disk, a ne samo particiju. Ako naiđete na pogrešku koja navodi da je Bitlocker omogućen, pokrenite Windows, idite na **Postavke -> Privatnost i sigurnost -> Šifriranje uređaja** i isključite Bitlocker. Dešifriranje diska može potrajati.

 ![dual-boot-7](images/dual-boot-7.webp)

## Ponovna instalacija Windowsa

Ako je ovo računalo isporučeno s Windowsima, njegov ključ proizvoda pohranjen je u firmwareu. Pokrenite `omarchy windows key` da biste ga ispisali, kako biste mogli ponovno aktivirati Windowse ako ih ikada ponovno instalirate na ovom računalu.
