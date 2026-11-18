# Aktualizácie

Omarchy a vaše balíčky sa udržiavajú aktuálne cez _Update > Omarchy_ v ponuke Omarchy (`Super + Space`).

Samotný Omarchy je nainštalovaný ako bežné balíčky pacman z [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), takže aktualizácia nainštaluje [najnovšie vydanie Omarchy](https://github.com/omacom/omarchy/releases), spustí všetky čakajúce migrácie, aby váš systém zosúladila s najnovšou verziou, a aktualizuje všetky systémové balíčky z [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (ak máte nainštalované nejaké balíčky z AUR).

Keď sú vydané nové verzie, napravo od vašich hodín sa zobrazí ikona kruhovej šípky. Kliknite na ňu a proces aktualizácie sa spustí.

![update-available](images/update-available.webp)

### Štyri kanály

Omarchy sa aktualizuje cez štyri kanály: stable, RC, edge a dev. Nové inštalácie začínajú na kanáli stable, ktorý sleduje [oficiálne vydania](https://github.com/omacom/omarchy/releases/), ako aj [stabilné zrkadlo Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), ktoré beží o mesiac pozadu za najnovším, aby sme mohli zachytiť všetky nové nekompatibility, ktoré vyžadujú zmeny konfigurácie, skôr než ľuďom spôsobia problémy.

Ale ak chcete pomôcť odhaliť tieto potenciálne problémy, môžete bežať na kanáli edge. Ten udrží vaše balíčky Omarchy na najnovších vývojových zostaveniach a umožní vám aktualizovať na najnovšie balíčky Arch hneď, ako budú k dispozícii. Mali by ste to robiť len vtedy, ak máte skúsenosti s Linuxom a viete, ako obnoviť systém, ktorý má problémy.

Pred každým novým veľkým vydaním budeme vykonávať finálne overovanie pomocou kanála RC. Ak máte záujem pomôcť s finálnym dolaďovaním, príďte sa porozprávať na #omarchy-release-candidates na Discorde.

Nakoniec je tu kanál dev, ktorý prepája Omarchy priamo s git checkoutom zdrojového kódu v `~/omarchy`, v kombinácii s balíčkami edge. Tento kanál by ste mali používať len vtedy, ak ste skúsený používateľ Linuxu, pracujete priamo na Omarchy a ste ochotní tolerovať rozbitie systému.

Medzi kanálmi môžete prepínať pomocou _Update > Channel_ z ponuky Omarchy (alebo `omarchy-channel-set` v termináli).

### Prepínanie jadier

Omarchy zavádza svoj vlastný kernel `linux-omarchy`, ale popri ňom môžete mať nainštalované aj ďalšie, napríklad štandardný kernel Arch `linux` alebo experimentálnu verziu, ktorú testujete. Keď ich je viac ako jeden, _Update > Kernel_ v ponuke Omarchy ich zobrazí so začiarknutím vedľa toho, ktorý sa zavádza predvolene. Vyberte iný, raz zadajte heslo a po ďalšom reštarte sa zavedie ten. Ostatné jadrá zostávajú v zavádzacej ponuke, takže si stále môžete jedno vybrať ručne, ak vám nové predvolené jadro bude robiť problémy. V termináli je to `omarchy-kernel` na zobrazenie aktuálneho predvoleného jadra, `omarchy-kernel list` na zobrazenie nainštalovaných jadier a `omarchy-kernel set <kernel>` na prepnutie.

### Aktualizácie firmvéru

Vaše balíčky nie sú to jediné, čo zastaráva. Mnohé notebooky a periférie dodávajú firmvér BIOS, SSD a dokov cez Linux Vendor Firmware Service a _Update > Firmware_ v ponuke Omarchy stiahne a nainštaluje všetko, čo na váš hardvér čaká. Pri prvom spustení nainštaluje `fwupd`. Množstvo firmvéru je možné zapísať len počas reštartu, takže sa nečudujte, ak budete o jeden požiadaní.

Keď potrebujete zmeniť nastavenie v samotnom BIOSe, podržte `Alt` v systémovej ponuke (`Super + Escape`) a _Reboot_ sa zmení na _Reboot to BIOS_, čo reštartuje priamo do nastavenia firmvéru bez toho, aby ste museli pri zavádzaní stihnúť stlačiť správny kláves. V termináli je to `omarchy system firmware`.

### Varovanie pred priamymi aktualizáciami cez pacman/yay

Ak už Arch poznáte, možno vás bude lákať jednoducho spustiť `pacman -Syu` alebo `yay -Syu` sami, ale ak to urobíte, prídete o snímku, migrácie a aktualizácie konfigurácie, ktoré Omarchy spúšťa spolu s novými balíčkami. Preto Omarchy priamu aktualizáciu systému skutočne zastaví a namiesto toho vás odkáže na `omarchy update`. (Ak naozaj viete, čo robíte, ochrana vám povie, ako ju pre jednu transakciu obísť.)

### Vrátenie chybných aktualizácií

Ak budete mať po vykonaní aktualizácie niekedy problém, môžete svoj systém vrátiť späť na snímku vytvorenú pred aktualizáciou. Jednoducho reštartujte a v zavádzacej ponuke vyberte snímku z doby pred spustením aktualizácie.

![bootloader](images/bootloader.webp)

Ak sa vaše konfiguračné súbory nejakým spôsobom poškodili, môžete tiež vykonať preinštalovanie Omarchy pomocou `omarchy reinstall` v termináli. Tým sa preinštalujú všetky predvolené balíčky Omarchy, prepnete sa na stable, všetky príliš nové balíčky sa znížia na staršiu verziu a všetky konfiguračné súbory sa obnovia do pôvodného stavu. Upozorňujeme, že týmto sa prepíšu všetky vaše používateľské zmeny konfigurácie oproti predvoleným hodnotám Omarchy!
