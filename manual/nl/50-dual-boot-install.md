# Dualboot-installatie

Je kunt Omarchy installeren op een enkele partitie naast Windows of andere installaties.

Deze installatiemethode wordt standaard nog steeds geleverd met LUKS-encryptie voor de partitie, dus in feite verschilt ze niet van een installatie op de volledige schijf en vereist ze alleen dat er vrije ruimte beschikbaar is op de schijf.

## Ruimte maken op Windows

Om Omarchy naast Windows te installeren, typ je `disk management` in het startmenu en selecteer je de optie **Partities op harde schijf maken en formatteren**.

 ![dual-boot-1](images/dual-boot-1.webp)

Zoek de juiste partitie, klik er met de rechtermuisknop op en kies **Volume verkleinen**.

![dual-boot-2](images/dual-boot-2.webp)

 Voer in met hoeveel je het volume wilt verkleinen. Let op: dit wordt de grootte van je toekomstige Omarchy-installatie, inclusief de bootpartitie.

 ![dual-boot-3](images/dual-boot-3.webp)

Als je klaar bent, zou je iets als dit moeten zien, waarbij de sectie van 50GB in dit voorbeeld de plek is waar we Omarchy gaan installeren.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installeren

Het installatieproces voor Omarchy is in feite hetzelfde als normaal. Nadat je je schijf hebt geselecteerd, krijg je de optie **Free space install**. Selecteer die optie om te voorkomen dat de volledige schijf wordt gewist.

 ![dual-boot-5](images/dual-boot-5.webp)

Bevestig dat alles er goed uitziet en wacht zoals normaal tot de installatie is voltooid. Hier kun je er ook voor kiezen om zonder encryptie te installeren (niet aanbevolen), net als bij een installatie op de volledige schijf.
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere installaties toevoegen aan de bootloader

Als je klaar bent met je Omarchy-installatie, zul je merken dat de Limine-bootloader nu de standaard is. Hiermee kun je ook opties aan Limine toevoegen voor je andere installaties, zoals Windows.

Om andere besturingssystemen toe te voegen, voer je `limine-scan` uit en volg je de prompts om de gewenste items toe te voegen aan je Limine-configuratie. Het bootmenu blijft standaard verborgen en start Omarchy na één seconde. Om Windows of een ander item te kiezen, druk je op een willekeurige toets zodra Limine start; wanneer het menu verschijnt, gebruik je de pijltjestoetsen om een item te selecteren en druk je op Enter. Als Omarchy start voordat je op een toets drukt, herstart je en probeer je het opnieuw. Als je _Setup > Direct Boot_ hebt ingeschakeld, slaat de firmware Limine volledig over, dus kies je Limine uit het bootmenu van je BIOS of voer je _Setup > Direct Boot_ opnieuw uit om het item te verwijderen.

## Bitlocker

Het is belangrijk om te weten dat deze installatiemethode niet compatibel is met Bitlocker, omdat die de volledige schijf versleutelt en niet alleen de partitie. Als je een foutmelding krijgt waarin staat dat Bitlocker is ingeschakeld, start je op in Windows, ga je naar **Instellingen -> Privacy en beveiliging -> Apparaatversleuteling** en schakel je Bitlocker uit. Het kan enige tijd duren om de schijf te ontsleutelen.

 ![dual-boot-7](images/dual-boot-7.webp)
