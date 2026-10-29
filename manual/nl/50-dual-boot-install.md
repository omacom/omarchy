# Dual Boot-installatie

Je kunt Omarchy installeren op een enkele partitie naast Windows of andere installaties.

Deze installatiemethode wordt standaard nog steeds geleverd met LUKS-versleuteling voor de partitie, dus hij verschilt in feite niet van een volledige schijf en vereist simpelweg dat er vrije ruimte beschikbaar is op de schijf.

## Ruimte maken op Windows

Om naast Windows te installeren, typ je `disk management` in het startmenu en selecteer je de optie voor **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Zoek de juiste partitie, klik met de rechtermuisknop en kies **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Voer de hoeveelheid in waarmee je het volume wilt verkleinen. Merk op dat dit de grootte zal zijn van je toekomstige Omarchy-installatie inclusief de opstartpartitie.

 ![dual-boot-3](images/dual-boot-3.webp)

Als je klaar bent, zou je zoiets moeten zien, waarbij het gedeelte van 50 GB is waar we Omarchy in dit voorbeeld gaan installeren.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installeren

Het installatieproces voor Omarchy is in feite hetzelfde als normaal. Nadat je je schijf hebt geselecteerd, krijg je de optie **Free space install**. Selecteer die optie om te voorkomen dat de volledige schijf wordt gewist.

 ![dual-boot-5](images/dual-boot-5.webp)

Bevestig dat alles er goed uitziet en wacht tot de installatie zoals normaal is voltooid. Hier kun je er ook voor kiezen om onversleuteld te installeren (niet aanbevolen), net als bij een installatie op de volledige schijf.
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere installaties toevoegen aan de bootloader

Als je je Omarchy-installatie hebt voltooid, zul je merken dat de Limine-bootloader nu de standaard is. Hiermee kun je ook opties aan Limine toevoegen voor je andere installaties, zoals Windows.

Voer daarvoor `limine-scan` uit en volg de prompts om de gewenste items toe te voegen aan je limine-config. Als je dan opstart, zie je je normale opties voor Omarchy, evenals Windows Boot Manager of andere.

## Bitlocker

Het is belangrijk om op te merken dat deze installatiemethode niet compatibel is met Bitlocker, omdat die de hele schijf versleutelt, niet alleen de partitie. Als je een fout tegenkomt die stelt dat Bitlocker is ingeschakeld, start dan Windows op, ga naar **Settings -> Privacy & Security -> Device encryption** en schakel Bitlocker uit. Het kan even duren om de schijf te ontsleutelen.

 ![dual-boot-7](images/dual-boot-7.webp)
