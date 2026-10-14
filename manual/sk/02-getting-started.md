# Začíname

Omarchy sa inštaluje pomocou ISO. Môžete si vybrať medzi inštaláciou na celý disk, ktorá zaberie celý disk, alebo inštaláciou do voľného miesta, ktorá Omarchy umiestni do neprideleného miesta na disku — takto môžete mať dual boot popri Windowse alebo inom OS (pozri [inštalácia s dual bootom](50-dual-boot-install.md) — všimnite si, že najprv budete musieť vo Windowse vypnúť BitLocker). Tak či onak, inštalácia predvolene používa úplné šifrovanie a možnosť celého disku vymaže vybraný disk, takže pred použitím existujúceho disku si určite urobte zálohu!

Najprv si [stiahnite Omarchy ISO](https://omarchy.org/), dajte ho na USB kľúč (na Macu/Windowse použite [balenaEtcher](https://etcher.balena.io/) alebo na Linuxe [caligula](https://github.com/ifd3f/caligula)) a nabootujte z kľúča.

_Secure Boot a/alebo TPM musíte v BIOSe vypnúť. Musíte ich vypnúť, aby ste mohli Omarchy nainštalovať. Sú to bezpečnostné schémy Microsoftu určené pre Windows a linuxové distribúcie spriaznené s Microsoftom._

Potom odpovedzte na konfiguračné otázky a potvrďte ich takto:

 ![install-config](images/install-config.webp)

Potom vyberte disk pre inštaláciu, usaďte sa a sledujte inštalačnú šou. Na najrýchlejších moderných strojoch to môže byť hotové za menej ako minútu, ale ani na staršom počítači by to nemalo trvať viac ako 5 minút.

 ![install-done](images/install-done.webp)

Teraz ste pripravení na Omarchy!

### Používajte káblovú alebo 2.4ghz klávesnicu!

Šifrovanie celého disku vám pri štarte nedovolí zadať heslo z Bluetooth klávesnice. Rovnako ako nemôžete použiť Bluetooth klávesnicu na vstup do BIOSu na PC. Budete potrebovať klávesnicu, ktorá používa buď 2.4ghz dongle, alebo kábel (čo je aj tak oveľa lepšie kvôli latencii!). Ja osobne milujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Inštalácia pre iného vlastníka

Ak nastavujete stroj pre niekoho iného — člena rodiny, nového zamestnanca, kupujúceho — nemali by ste v jeho mene odpovedať na osobné otázky. Stlačte `Ctrl + C` na úplne prvej obrazovke inštalátora (výber klávesnice) a Omarchy ponúkne, že namiesto toho pripraví stroj pre iného vlastníka. Systém sa nainštaluje hneď, ale všetko osobné nastavenie — rozloženie klávesnice, používateľské meno, heslo — sa odloží, kým stroj prvýkrát nenabootuje. Disk je stále predvolene šifrovaný a heslo, ktoré si nový vlastník vyberie pri tom prvom boote, sa stane aj šifrovacím heslom. (Stroj, ktorý ste už používali, môžete odovzdať aj bez preinštalovania — pozri [resetovanie počítača](48-security.md).)

### Bezobslužné inštalácie

ISO sa môže nainštalovať aj úplne samo — bez klávesnice, bez sprievodcu — keď mu odovzdáte konfiguráciu na druhom disku. Takto môžete Omarchy považovať za základný obraz pre VM a flotilové stroje. Pozri [bezobslužné inštalácie](51-unattended-installs.md).

### Inštalácie bez šifrovania

Omarchy sa predvolene inštaluje so šifrovaním. Je to bezpečná, zodpovedná voľba pre každý počítač, ktorý sa môže stratiť alebo ho môžu ukradnúť. Nechcete, aby ktokoľvek s prístupom k vášmu hardvéru mohol získať vaše dáta!

Ale za zvláštnych okolností, ako sú vzdialené inštalácie Omarchy na chránených počítačoch alebo jednorazové inštalácie bez citlivých dát, možno budete chcieť inštalovať bez šifrovania. Pri potvrdení formátovania disku môžete stlačiť `Ctrl + C` a prepnúť na inštaláciu bez šifrovania.

### Jazyk

Omarchy hovorí 50 jazykmi — rovnaká sada ako omarchy.org — a angličtina je predvolená. Ak chcete prepnúť, otvorte menu Omarchy a prejdite na _Nastavenie > Jazyk_, alebo spustite `omarchy language <code>` v termináli (`omarchy language list` zobrazí kódy). Menu, pracovná plocha a vlastné oznámenia Omarchy okamžite zmenia jazyk a každá aplikácia, ktorú potom otvoríte, nasleduje tiež. Aplikácie, ktoré už boli otvorené, sa prepnú, keď ich reštartujete.

### Pomoc, ak ste sa zasekli

Ak ste sa zasekli, zvyčajne nájdete niekoho ochotného pomôcť v kanáli _#omarchy-help_ na [komunitnom Discorde](https://omarchy.org/discord).
