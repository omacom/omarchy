# Namestitev z dvojnim zagonom

Omarchy lahko namestite na eno samo particijo ob Windows ali drugih namestitvah.

Ta način namestitve je še vedno privzeto opremljen s šifriranjem LUKS za particijo, tako da se dejansko ne razlikuje od celotnega pogona in preprosto zahteva prost prostor na disku.

## Ustvarjanje prostora na Windows

Za namestitev ob Windows v začetni meni vnesite `disk management` in izberite možnost **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Poiščite ustrezno particijo, z desno tipko miške kliknite nanjo in izberite **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Vnesite količino, za katero želite skrčiti volumen. Upoštevajte, da bo to velikost vaše prihodnje namestitve Omarchy skupaj z zagonsko particijo.

 ![dual-boot-3](images/dual-boot-3.webp)

Ko končate, bi morali videti nekaj takega, kjer je odsek 50 GB tisti, kamor bomo namestili Omarchy v tem primeru.

 ![dual-boot-4](images/dual-boot-4.webp)

## Namestitev Omarchyja

Postopek namestitve Omarchyja je dejansko enak kot običajno. Potem ko izberete svoj disk, boste dobili možnost **Free space install**. Izberite to možnost, da preprečite brisanje celotnega diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potrdite, da vse izgleda dobro, in počakajte, da se namestitev konča kot običajno. Tukaj se lahko tudi odločite za namestitev brez šifriranja (ni priporočljivo), tako kot pri namestitvi na celoten pogon.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodajanje drugih namestitev v zagonski nalagalnik

Ko končate namestitev Omarchyja, boste opazili, da je zdaj privzeti zagonski nalagalnik Limine. S tem lahko v Limine dodate tudi možnosti za svoje druge namestitve, kot je Windows.

Če želite to storiti, zaženite `limine-scan` in sledite pozivom, da v svojo konfiguracijo limine dodate poljubne elemente. Ko nato zaženete, boste videli svoje običajne možnosti za Omarchy ter Windows Boot Manager ali druge.

## Bitlocker

Pomembno je omeniti, da ta način namestitve ni združljiv z Bitlockerjem, saj šifrira celoten pogon, ne le particije. Če naletite na napako, ki pravi, da je Bitlocker omogočen, zaženite Windows, pojdite na **Settings -> Privacy & Security -> Device encryption** in izklopite Bitlocker. Dešifriranje pogona lahko traja nekaj časa.

 ![dual-boot-7](images/dual-boot-7.webp)
