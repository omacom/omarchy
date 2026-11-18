# Namestitev z dvojnim zagonom

Omarchy lahko namestite na eno samo particijo poleg sistema Windows ali drugih namestitev.

Ta način namestitve privzeto še vedno vključuje šifriranje particije z LUKS, zato se dejansko ne razlikuje od namestitve na celoten pogon in preprosto zahteva, da je na disku na voljo prosti prostor.

## Sprostitev prostora v sistemu Windows

Za namestitev poleg sistema Windows v začetni meni vnesite `disk management` in izberite možnost **Ustvarjanje in formatiranje particij trdega diska**.

 ![dual-boot-1](images/dual-boot-1.webp)

Poiščite ustrezno particijo, z desno tipko kliknite nanjo in izberite **Skrči nosilec**.

![dual-boot-2](images/dual-boot-2.webp)

 Vnesite količino, za katero želite skrčiti nosilec. Upoštevajte, da bo to velikost vaše prihodnje namestitve Omarchy, vključno z zagonsko particijo.

 ![dual-boot-3](images/dual-boot-3.webp)

Ko končate, bi morali videti nekaj podobnega temu, kjer je razdelek s 50GB tisti, kamor bomo v tem primeru namestili Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Namestitev Omarchy

Postopek namestitve Omarchy je dejansko enak običajnemu. Ko izberete disk, boste dobili možnost **Namestitev v prosti prostor**. Izberite to možnost, da preprečite izbris celotnega diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potrdite, da je vse videti v redu, in počakajte, da se namestitev konča kot običajno. Tukaj se lahko tudi odločite za namestitev brez šifriranja (ni priporočljivo), tako kot pri namestitvi na celoten pogon.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodajanje drugih namestitev v zagonski nalagalnik

Ko končate namestitev Omarchy, boste opazili, da je zdaj privzeti zagonski nalagalnik Limine. Z njim lahko v Limine dodate tudi možnosti za druge namestitve, kot je Windows.

Če želite dodati druge operacijske sisteme, zaženite `limine-scan` in sledite pozivom, da želene vnose dodate v svojo konfiguracijo Limine. Zagonski meni privzeto ostane skrit in po eni sekundi zažene Omarchy. Če želite izbrati Windows ali drug vnos, pritisnite katero koli tipko takoj, ko se Limine zažene; ko se prikaže meni, s puščičnimi tipkami izberite vnos in pritisnite Enter. Če se Omarchy zažene, preden pritisnete tipko, znova zaženite računalnik in poskusite znova. Če ste vklopili _Setup > Direct Boot_, vdelana programska oprema Limine v celoti preskoči, zato Limine izberite v zagonskem meniju BIOS-a ali znova zaženite _Setup > Direct Boot_, da odstranite vnos.

## Bitlocker

Pomembno je vedeti, da ta način namestitve ni združljiv z Bitlocker, saj ta šifrira celoten pogon, ne le particije. Če naletite na napako, ki navaja, da je Bitlocker omogočen, zaženite Windows, pojdite v **Nastavitve -> Zasebnost in varnost -> Šifriranje naprave** in izklopite Bitlocker. Dešifriranje pogona lahko traja nekaj časa.

 ![dual-boot-7](images/dual-boot-7.webp)
