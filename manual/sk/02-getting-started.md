# Začíname

Omarchy sa inštaluje pomocou ISO. Môžete si vybrať medzi inštaláciou na celý disk, ktorá zaberie celý disk, alebo inštaláciou do voľného priestoru, ktorá umiestni Omarchy do neprideleného priestoru na disku — takto dosiahnete duálne bootovanie popri Windowse alebo inom OS (pozrite si [inštaláciu s duálnym bootovaním](50-dual-boot-install.md) — majte na pamäti, že vo Windowse budete musieť najprv vypnúť BitLocker). Tak či onak, inštalácia predvolene používa úplné šifrovanie a možnosť inštalácie na celý disk vymaže vybraný disk, takže si pred použitím existujúceho disku určite urobte zálohu!

Na Macu s Apple Silicon inštalujete namiesto toho z macOS, bez ISO alebo USB kľúča. Pozrite si [Omarchy pre Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Najprv si [stiahnite ISO Omarchy](https://omarchy.org/), nahrajte ho na USB kľúč (použite [Rufus](https://rufus.ie/) vo Windowse, [balenaEtcher](https://etcher.balena.io/) na Macu alebo [caligula](https://github.com/ifd3f/caligula) v Linuxe) a nabootujte z kľúča.

_Musíte vypnúť Secure Boot a/alebo TPM v BIOSe. Tieto veci musíte vypnúť, aby ste mohli nainštalovať Omarchy. Sú to bezpečnostné schémy Microsoftu určené pre Windows a Linuxové distribúcie pridružené k Microsoftu._

Potom odpovedzte na konfiguračné otázky a potvrďte ich takto:

 ![install-config](images/install-config.webp)

Potom vyberte disk pre svoju inštaláciu, pohodlne sa usaďte a sledujte inštalačnú šou. Na najrýchlejších moderných počítačoch to zvládnete za menej než minútu, ale ani na staršom počítači by to nemalo trvať viac než 5 minút.

 ![install-done](images/install-done.webp)

Teraz ste pripravení na Omarchy!

### Používajte káblovú alebo 2.4ghz klávesnicu!

Úplné šifrovanie disku vám pri spustení nedovolí zadať heslo z Bluetooth klávesnice. Rovnako ako na PC nemôžete použiť Bluetooth klávesnicu na vstup do BIOSu. Budete potrebovať klávesnicu, ktorá používa buď 2.4ghz dongle, alebo kábel (čo je aj tak oveľa lepšie kvôli latencii!). Osobne milujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Inštalácia pre iného vlastníka

Ak nastavujete počítač pre niekoho iného — člena rodiny, nového zamestnanca, kupujúceho — nemali by ste osobné otázky zodpovedať za neho. Na úplne prvej obrazovke inštalátora (výber klávesnice) stlačte `Ctrl + C` a Omarchy namiesto toho ponúkne prípravu počítača pre iného vlastníka. Systém sa nainštaluje hneď, ale celé osobné nastavenie — rozloženie klávesnice, používateľské meno, heslo — sa odloží až do prvého spustenia počítača. Disk je stále predvolene šifrovaný a heslo, ktoré si nový vlastník zvolí pri tom prvom spustení, sa stane aj šifrovacím heslom. (Počítač, ktorý ste už používali, môžete odovzdať aj bez preinštalovania — pozrite si [resetovanie počítača](48-security.md).)

### Bezobslužné inštalácie

ISO sa dokáže nainštalovať aj úplne samo — bez klávesnice, bez sprievodcu — keď dostane svoju konfiguráciu na druhom disku. Takto môžete s Omarchy zaobchádzať ako so základným obrazom pre VM a flotily počítačov. Pozrite si [bezobslužné inštalácie](51-unattended-installs.md).

### Inštalácie bez šifrovania

Omarchy sa predvolene inštaluje so šifrovaním. Je to bezpečná, zodpovedná voľba pre každý počítač, ktorý sa môže stratiť alebo ho môžu ukradnúť. Nechcete, aby sa ktokoľvek s prístupom k vášmu hardvéru mohol dostať k vašim údajom!

Ale za osobitných okolností, ako sú vzdialené inštalácie Omarchy na chránených počítačoch alebo jednorazové inštalácie bez citlivých údajov, možno budete chcieť inštalovať bez šifrovania. Pri potvrdení formátovania disku môžete stlačením `Ctrl + C` prepnúť na inštaláciu bez šifrovania.

### Jazyk

Omarchy hovorí 50 jazykmi — rovnakou sadou ako omarchy.org — a predvolená je angličtina. Ak chcete jazyk prepnúť, otvorte menu Omarchy a prejdite do _Setup > Region > Language_ alebo spustite v termináli `omarchy language <code>` (`omarchy language list` zobrazí kódy). Menu, pracovná plocha a vlastné oznámenia Omarchy zmenia jazyk okamžite a každá aplikácia, ktorú otvoríte potom, ich bude nasledovať. Už otvorené aplikácie sa prepnú, keď ich reštartujete.

Ak si chcete jazyk ponechať, ale dátumy, časy, čísla, peniaze, jednotky a veľkosti papiera chcete zapisovať tak, ako to robí iný región (povedzme angličtina s európskymi dátumami a 24-hodinovým formátom času), vyberte si región v časti _Setup > Region > Formats_, kde každá voľba zobrazuje ukážku, alebo spustite `omarchy region formats <code>` (`omarchy region formats list` zobrazí kódy). Voľba _Same as language_ vás vráti k formátom vlastným danému jazyku. Rovnako ako prepnutie jazyka, aj toto sa prejaví v aplikáciách, ktoré otvoríte potom.

### Pomoc, ak sa zaseknete

Ak sa zaseknete, zvyčajne nájdete niekoho ochotného pomôcť v kanáli _#omarchy-help_ na [komunitnom Discorde](https://omarchy.org/discord).
