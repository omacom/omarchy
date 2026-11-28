# Namestitev z dvojnim zagonom

Omarchy lahko namestite na eno samo particijo poleg Windows ali drugih namestitev.

Ta način namestitve privzeto še vedno vključuje šifriranje particije z LUKS, zato se dejansko ne razlikuje od namestitve na celoten pogon in preprosto zahteva, da je na disku na voljo prosti prostor.

## Ustvarjanje prostora v Windows

Za namestitev poleg Windows v začetni meni vnesite `disk management` in izberite možnost **Ustvari in formatiraj particije trdega diska**.

 ![dual-boot-1](images/dual-boot-1.webp)

Poiščite ustrezno particijo, kliknite jo z desno tipko in izberite **Skrči nosilec**.

![dual-boot-2](images/dual-boot-2.webp)

 Vnesite velikost, za katero želite skrčiti nosilec. Upoštevajte, da bo to velikost vaše prihodnje namestitve Omarchy, vključno z zagonsko particijo.

 ![dual-boot-3](images/dual-boot-3.webp)

Ko končate, bi morali videti nekaj takega, kjer je razdelek s 50 GB tisti, kamor bomo v tem primeru namestili Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Namestitev Omarchy

Postopek namestitve Omarchy je dejansko enak kot običajno. Ko izberete disk, boste dobili možnost **Namestitev na prosti prostor**. Izberite to možnost, da preprečite brisanje celotnega diska.

 ![dual-boot-5](images/dual-boot-5.webp)

Potrdite, da je vse videti v redu, in počakajte, da se namestitev konča kot običajno. Tukaj lahko izberete tudi namestitev brez šifriranja (ni priporočljivo), tako kot pri namestitvi na celoten pogon.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodajanje drugih namestitev v zagonski nalagalnik

Ko končate namestitev Omarchy, boste opazili, da je zdaj privzeti zagonski nalagalnik Limine. Z njim lahko v Limine dodate tudi možnosti za druge namestitve, kot je Windows.

Za dodajanje drugih operacijskih sistemov zaženite `limine-scan` in sledite pozivom, da dodate želene vnose v svojo konfiguracijo Limine. Zagonski meni ostane privzeto skrit in Omarchy zažene po eni sekundi. Za izbiro Windows ali drugega vnosa pritisnite katero koli tipko, takoj ko se Limine zažene; ko se meni prikaže, s puščičnimi tipkami izberite vnos in pritisnite Enter. Če se Omarchy zažene, preden pritisnete tipko, znova zaženite računalnik in poskusite znova.

## Bitlocker

Pomembno je vedeti, da ta način namestitve ni združljiv z Bitlocker, saj šifrira celoten pogon, ne le particije. Če naletite na napako, da je Bitlocker omogočen, zaženite Windows, pojdite v **Nastavitve -> Zasebnost in varnost -> Šifriranje naprave** in izklopite Bitlocker. Dešifriranje pogona lahko traja nekaj časa.

 ![dual-boot-7](images/dual-boot-7.webp)

## Ponovna namestitev Windows

Če je bil ta računalnik dobavljen z Windows, je njegov ključ izdelka shranjen v vdelani programski opremi. Zaženite `omarchy windows key`, da ga izpišete, tako da lahko Windows znova aktivirate, če ga boste kdaj znova namestili na ta računalnik.
