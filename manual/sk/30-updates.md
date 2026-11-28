# Aktualizácie

Omarchy a svoje balíčky udržiavate aktuálne cez _Update > Omarchy_ v ponuke Omarchy (`Super + Space`).

Samotné Omarchy sa inštaluje ako bežné balíčky pacman z [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), takže aktualizácia nainštaluje [najnovšie vydanie Omarchy](https://github.com/omacom/omarchy/releases), spustí všetky čakajúce migrácie, aby bol váš systém zosúladený s najnovšou verziou, a aktualizuje všetky systémové balíčky z [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (ak máte nainštalované nejaké balíčky z AUR).

Keď vyjdú nové vydania, napravo od vašich hodín sa objaví ikona kruhovej šípky. Kliknite na ňu a proces aktualizácie sa spustí.

![update-available](images/update-available.webp)

### Štyri kanály

Omarchy sa aktualizuje v štyroch kanáloch: stable, RC, edge a dev. Nové inštalácie začínajú na kanáli stable, ktorý sleduje [oficiálne vydania](https://github.com/omacom/omarchy/releases/), ako aj [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror), ktorý beží s mesačným oneskorením za najnovším, aby sme mohli zachytiť všetky nové nekompatibility, ktoré si vyžadujú zmeny konfigurácie, skôr než ľuďom spôsobia problémy.

Ak by ste však chceli pomôcť odhaliť tieto potenciálne problémy, môžete bežať na kanáli edge. Vaše balíčky Omarchy tak budú sledovať najnovšie vývojové zostavy a budete môcť aktualizovať na najnovšie balíčky Arch hneď, ako budú k dispozícii. Mali by ste to robiť iba vtedy, ak máte skúsenosti s Linuxom a viete, ako obnoviť systém, ktorý má problémy.

Pred každým novým hlavným vydaním budeme vykonávať finálne overovanie pomocou kanála RC. Ak máte záujem pomôcť s finálnym dolaďovaním, príďte posedieť do #omarchy-release-candidates na Discorde.

Nakoniec je tu kanál dev, ktorý prepája Omarchy priamo s git checkoutom zdrojového kódu v `~/omarchy` v kombinácii s balíčkami edge. Tento kanál by ste mali používať iba vtedy, ak ste skúsený používateľ Linuxu, pracujete priamo na Omarchy a ste ochotní znášať rozbitie systému.

Medzi kanálmi môžete prepínať pomocou _Update > Channel_ v ponuke Omarchy (alebo `omarchy channel set <stable|rc|edge|dev>` v termináli, pričom pomocou `omarchy channel current` zistíte, kde sa nachádzate).

### Prepínanie kernelov

Omarchy bootuje svoj vlastný kernel `linux-omarchy`, ale popri ňom môžete mať nainštalované aj ďalšie, napríklad štandardný kernel Arch `linux` alebo experimentálnu zostavu, ktorú testujete. Keď ich je viac ako jeden, _Update > Kernel_ v ponuke Omarchy ich vypíše s fajkou vedľa toho, ktorý sa bootuje predvolene. Vyberte iný, raz zadajte svoje heslo a po ďalšom reštarte sa nabootuje ten. Ostatné kernely zostanú v ponuke bootovania, takže si stále môžete jeden vybrať ručne, ak vám nový predvolený robí problémy. V termináli slúži `omarchy kernel` na zobrazenie aktuálneho predvoleného, `omarchy kernel list` na to, čo je nainštalované, a `omarchy kernel set <kernel>` na prepnutie.

### Aktualizácie firmvéru

Nielen vaše balíčky zastarávajú. Mnoho notebookov a periférií dodáva firmvér BIOS, SSD a dokov cez Linux Vendor Firmware Service a _Update > Firmware_ v ponuke Omarchy stiahne a nainštaluje všetko, čo má váš hardvér pripravené. Pri prvom spustení nainštaluje `fwupd`. Veľa firmvéru sa dá zapísať iba počas reštartu, takže sa nečudujte, ak vás o jeden požiada.

Keď potrebujete zmeniť nastavenie v samotnom BIOSe, podržte `Alt` v systémovej ponuke (`Super + Escape`) a _Reboot_ sa zmení na _Reboot to BIOS_, čo reštartuje priamo do nastavenia firmvéru bez toho, aby ste museli pri bootovaní zachytiť ten správny kláves. Z terminálu je to `omarchy system firmware`.

### Varovanie pred priamymi aktualizáciami cez pacman/yay

Ak už Arch poznáte, možno vás bude lákať jednoducho si sami spustiť `pacman -Syu` alebo `yay -Syu`, ale ak to urobíte, prídete o snapshot, migrácie a aktualizácie konfigurácie, ktoré Omarchy spúšťa spolu s novými balíčkami. Preto Omarchy priamu aktualizáciu systému skutočne zastaví a namiesto toho vás nasmeruje na `omarchy update`. (Ak naozaj viete, čo robíte, táto ochrana vám povie, ako ju obísť pre jednu transakciu.)

### Vrátenie zlých aktualizácií

Ak budete mať po vykonaní aktualizácie niekedy problém, môžete svoj systém vrátiť späť na snapshot vytvorený pred aktualizáciou. Stačí reštartovať a v ponuke zavádzača vybrať snapshot spred spustenia aktualizácie.

![bootloader](images/bootloader.webp)

Ak sa vaše konfiguračné súbory nejakým spôsobom poškodili, môžete pomocou `omarchy reinstall` v termináli vykonať aj preinštalovanie Omarchy. Tým sa preinštalujú všetky predvolené balíčky Omarchy, prepne vás na stable (edge na Apple Silicon), downgradujú sa všetky balíčky, ktoré sú príliš nové, a obnovia sa všetky konfiguračné súbory. Upozorňujeme, že týmto sa prepíšu všetky vaše používateľské zmeny konfigurácie voči predvoleným nastaveniam Omarchy!
