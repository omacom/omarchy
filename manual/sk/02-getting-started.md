# Začíname

Omarchy sa inštaluje pomocou ISO. Môžete si vybrať medzi inštaláciou na celý disk, ktorá zaberie celý disk, alebo inštaláciou do voľného miesta, ktorá umiestni Omarchy do neprideleného miesta na disku — takto môžete mať duálne zavádzanie popri Windowse alebo inom OS (pozrite si [inštalácia s duálnym zavádzaním](50-dual-boot-install.md) — všimnite si, že vo Windowse budete musieť najprv vypnúť BitLocker). Tak či onak, inštalácia predvolene používa úplné šifrovanie a možnosť inštalácie na celý disk vymaže vybraný disk, takže si pred použitím existujúceho disku určite urobte zálohu!

Najprv si [stiahnite ISO Omarchy](https://omarchy.org/), umiestnite ho na USB kľúč (použite [Rufus](https://rufus.ie/) vo Windowse, [balenaEtcher](https://etcher.balena.io/) na Macu alebo [caligula](https://github.com/ifd3f/caligula) na Linuxe) a zaveďte systém z kľúča.

_V BIOSe musíte vypnúť Secure Boot a/alebo TPM. Musíte ich vypnúť, aby ste mohli nainštalovať Omarchy. Sú to bezpečnostné schémy Microsoftu určené pre Windows a Linuxové distribúcie pridružené k Microsoftu._

Potom odpovedzte na konfiguračné otázky a potvrďte ich takto:

 ![install-config](images/install-config.webp)

Potom vyberte disk pre svoju inštaláciu a pohodlne sa usaďte a sledujte inštalačnú šou. Na najrýchlejších moderných počítačoch to môže byť hotové za menej než minútu, ale ani na staršom počítači by to nemalo trvať viac než 5 minút.

 ![install-done](images/install-done.webp)

Teraz ste pripravení na Omarchy!

### Použite káblovú klávesnicu alebo klávesnicu s 2.4ghz pripojením!

Šifrovanie celého disku vám neumožní zadať heslo pri spustení z Bluetooth klávesnice. Rovnako ako nemôžete použiť Bluetooth klávesnicu na vstup do BIOSu na PC. Budete potrebovať klávesnicu, ktorá používa buď 2.4ghz dongle, alebo kábel (čo je aj tak oveľa lepšie kvôli latencii!). Osobne milujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Inštalácia pre iného vlastníka

Ak nastavujete počítač pre niekoho iného — člena rodiny, nového zamestnanca, kupujúceho — nemali by ste za neho odpovedať na osobné otázky. Stlačte `Ctrl + C` na úplne prvej obrazovke inštalátora (výber klávesnice) a Omarchy namiesto toho ponúkne prípravu počítača pre iného vlastníka. Systém sa nainštaluje hneď, ale celé osobné nastavenie — rozloženie klávesnice, používateľské meno, heslo — sa odloží až do prvého spustenia počítača. Disk je stále predvolene šifrovaný a heslo, ktoré si nový vlastník zvolí pri tom prvom spustení, sa stane aj šifrovacím heslom. (Počítač, ktorý ste už používali, môžete odovzdať aj bez preinštalovania — pozrite si [resetovanie počítača](48-security.md).)

### Bezobslužné inštalácie

ISO sa dokáže nainštalovať aj úplne samo — bez klávesnice, bez sprievodcu — keď dostane svoju konfiguráciu na druhom disku. Takto môžete s Omarchy zaobchádzať ako so základným obrazom pre VM a flotily počítačov. Pozrite si [bezobslužné inštalácie](51-unattended-installs.md).

### Inštalácie bez šifrovania

Omarchy sa predvolene inštaluje so šifrovaním. Je to bezpečná a zodpovedná voľba pre každý počítač, ktorý sa môže stratiť alebo byť ukradnutý. Nechcete, aby ktokoľvek s prístupom k vášmu hardvéru mohol získať vaše údaje!

Ale za zvláštnych okolností, ako sú vzdialené inštalácie Omarchy na chránených počítačoch alebo jednorazové inštalácie bez citlivých údajov, môžete chcieť inštalovať bez šifrovania. Pri potvrdení formátovania disku môžete stlačiť `Ctrl + C` a prepnúť na inštaláciu bez šifrovania.

### Jazyk

Omarchy hovorí 50 jazykmi — rovnakou sadou ako omarchy.org — a predvoleným jazykom je angličtina. Ak chcete jazyk prepnúť, otvorte menu Omarchy a prejdite do _Nastavenie > Región > Jazyk_ alebo spustite v termináli `omarchy language <code>` (`omarchy language list` zobrazí kódy). Menu, pracovná plocha a vlastné oznámenia Omarchy zmenia jazyk okamžite a každá aplikácia, ktorú potom otvoríte, ich bude nasledovať tiež. Aplikácie, ktoré už boli otvorené, sa prepnú po ich reštartovaní.

Ak si chcete jazyk ponechať, ale dátumy, časy, čísla, peniaze, jednotky a veľkosti papiera písať tak, ako to robí iný región (napríklad angličtina s európskymi dátumami a 24-hodinovými hodinami), vyberte si región v _Nastavenie > Región > Formáty_, kde každá voľba zobrazuje ukážku, alebo spustite `omarchy region formats <code>` (`omarchy region formats list` zobrazí kódy). _Rovnaké ako jazyk_ vráti formáty vlastné danému jazyku. Rovnako ako prepnutie jazyka sa to týka aplikácií, ktoré otvoríte potom.

### Pomoc, ak sa zaseknete

Ak sa zaseknete, zvyčajne nájdete niekoho ochotného pomôcť v kanáli _#omarchy-help_ na [komunitnom Discorde](https://omarchy.org/discord).
