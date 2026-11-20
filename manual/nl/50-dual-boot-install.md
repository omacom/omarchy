# Installatie met dual boot

Je kunt Omarchy installeren op een enkele partitie naast Windows of andere installaties.

Deze installatiemethode wordt standaard nog steeds geleverd met LUKS-versleuteling voor de partitie, dus het is in feite niet anders dan een volledige schijf en vereist simpelweg dat er vrije ruimte beschikbaar is op de schijf.

## Ruimte maken op Windows

Om naast Windows te installeren, typ je `disk management` in het startmenu en selecteer je de optie **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Zoek de juiste partitie, klik met de rechtermuisknop en kies **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Voer in met hoeveel je het volume wilt verkleinen. Let op dat dit de grootte wordt van je toekomstige Omarchy-installatie, inclusief de bootpartitie.

 ![dual-boot-3](images/dual-boot-3.webp)

Als je klaar bent, zou je iets als dit moeten zien, waarbij de sectie van 50GB in dit voorbeeld de plek is waar we Omarchy installeren.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installeren

Het installatieproces voor Omarchy is in feite hetzelfde als normaal. Nadat je je schijf hebt geselecteerd, krijg je de optie **Free space install**. Selecteer die optie om te voorkomen dat de volledige schijf wordt gewist.

 ![dual-boot-5](images/dual-boot-5.webp)

Bevestig dat alles er goed uitziet en wacht tot de installatie normaal is voltooid. Hier kun je er ook voor kiezen om zonder versleuteling te installeren (niet aanbevolen), net als bij een installatie op een volledige schijf.
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere installaties toevoegen aan de bootloader

Wanneer je je Omarchy-installatie hebt voltooid, zul je merken dat de Limine-bootloader nu de standaard is. Hiermee kun je ook opties toevoegen aan Limine voor je andere installaties, zoals Windows.

Om andere besturingssystemen toe te voegen, voer je `limine-scan` uit en volg je de aanwijzingen om de gewenste items toe te voegen aan je Limine-configuratie. Het bootmenu blijft standaard verborgen en start Omarchy na één seconde. Om Windows of een ander item te kiezen, druk je op een willekeurige toets zodra Limine start; wanneer het menu verschijnt, gebruik je de pijltjestoetsen om een item te selecteren en druk je op Enter. Als Omarchy start voordat je op een toets drukt, herstart je en probeer je het opnieuw.

## Bitlocker

Het is belangrijk om op te merken dat deze installatiemethode niet compatibel is met Bitlocker, omdat dat de volledige schijf versleutelt, niet alleen de partitie. Als je een foutmelding krijgt waarin staat dat Bitlocker is ingeschakeld, start je Windows op, ga je naar **Settings -> Privacy & Security -> Device encryption** en schakel je Bitlocker uit. Het kan enige tijd duren om de schijf te ontsleutelen.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows opnieuw installeren

Als deze computer met Windows werd geleverd, is de productcode opgeslagen in de firmware. Voer `omarchy windows key` uit om deze af te drukken, zodat je Windows opnieuw kunt activeren als je het ooit opnieuw installeert op deze machine.
