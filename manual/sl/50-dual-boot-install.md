# Namestitev z dvojnim zagonom

Omarchy lahko namestite na eno samo particijo ob sistemu Windows ali drugih namestitvah.

Ta način namestitve privzeto še vedno vključuje šifriranje LUKS za particijo, zato se dejansko ne razlikuje od namestitve na celoten disk in preprosto zahteva, da je na disku na voljo prosti prostor.

## Sprostitev prostora v sistemu Windows

Za namestitev ob sistemu Windows v začetni meni vnesite `disk management` in izberite možnost **Ustvarjanje in formatiranje particij trdega diska**.

 ![dual-boot-1](images/dual-boot-1.webp)

Poiščite ustrezno particijo, jo kliknite z desno tipko miške in izberite **Skrči nosilec**.

![dual-boot-2](images/dual-boot-2.webp)

 Vnesite količino, za katero želite skrčiti nosilec. Upoštevajte, da bo to velikost vaše prihodnje namestitve Omarchy, vključno z zagonsko particijo.

 ![dual-boot-3](images/dual-boot-3.webp)

Ko končate, bi morali videti nekaj podobnega, kjer je razdelek s 50GB v tem primeru tisti, kamor bomo namestili Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Namestitev Omarchy

Postopek namestitve Omarchy je dejansko enak običajnemu. Ko izberete disk, boste dobili možnost **Namestitev v prosti prostor**. Izberite to možnost, da preprečite izbris celotnega diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potrdite, da je vse videti v redu, in počakajte, da se namestitev konča kot običajno. Tukaj se lahko tudi odločite za namestitev brez šifriranja (ni priporočljivo), tako kot pri namestitvi na celoten disk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodajanje drugih namestitev v zagonski nalagalnik

Ko končate namestitev Omarchy, boste opazili, da je zdaj privzeti zagonski nalagalnik Limine. Z njim lahko v Limine dodate tudi možnosti za druge namestitve, na primer Windows.

Za dodajanje drugih operacijskih sistemov zaženite `limine-scan` in sledite pozivom, da dodate želene vnose v svojo konfiguracijo Limine. Zagonski meni privzeto ostane skrit in po eni sekundi zažene Omarchy. Če želite izbrati Windows ali drug vnos, pritisnite katero koli tipko, takoj ko se Limine zažene; ko se prikaže meni, s puščičnimi tipkami izberite vnos in pritisnite Enter. Če se Omarchy zažene, preden pritisnete tipko, znova zaženite računalnik in poskusite znova.

## Bitlocker

Pomembno je vedeti, da ta način namestitve ni združljiv z orodjem Bitlocker, saj šifrira celoten disk, ne le particije. Če naletite na napako, da je Bitlocker omogočen, zaženite Windows, pojdite v **Nastavitve -> Zasebnost in varnost -> Šifriranje naprave** in izklopite Bitlocker. Dešifriranje diska lahko traja nekaj časa.

 ![dual-boot-7](images/dual-boot-7.webp)
