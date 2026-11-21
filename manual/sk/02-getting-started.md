# Začíname

Omarchy sa inštaluje pomocou ISO. Môžete si vybrať medzi inštaláciou na celý disk, ktorá zaberie celý disk, alebo inštaláciou do voľného priestoru, ktorá umiestni Omarchy do neprideleného priestoru na disku — takto dual bootujete popri Windowse alebo inom OS (pozrite si [inštalácia dual bootu](50-dual-boot-install.md) — všimnite si, že najprv budete musieť vo Windowse vypnúť BitLocker). Tak či onak, inštalácia predvolene používa úplné šifrovanie a možnosť celého disku vymaže vybraný disk, takže si pred použitím existujúceho disku určite urobte zálohu!

Najprv si [stiahnite ISO Omarchy](https://omarchy.org/), umiestnite ho na USB kľúč (použite [Rufus](https://rufus.ie/) na Windowse, [balenaEtcher](https://etcher.balena.io/) na Macu alebo [caligula](https://github.com/ifd3f/caligula) na Linuxe) a bootujte z kľúča.

_Musíte vypnúť Secure Boot a/alebo TPM v BIOSe. Musíte ich vypnúť, aby ste mohli nainštalovať Omarchy. Sú to bezpečnostné schémy Microsoftu určené pre Windows a linuxové distribúcie pridružené k Microsoftu._

Potom odpovedzte na konfiguračné otázky a potvrďte ich takto:

 ![install-config](images/install-config.webp)

Potom vyberte disk pre vašu inštaláciu, pohodlne sa usaďte a sledujte inštalačnú show. Na najrýchlejších moderných strojoch to môže byť hotové za menej než minútu, ale ani na staršom počítači by to nemalo trvať viac než 5 minút.

 ![install-done](images/install-done.webp)

Teraz ste pripravení na Omarchy!

### Používajte káblovú klávesnicu alebo klávesnicu s 2.4ghz!

Šifrovanie celého disku vám pri spustení neumožní zadať heslo z Bluetooth klávesnice. Rovnako ako nemôžete použiť Bluetooth klávesnicu na vstup do BIOSu na PC. Budete potrebovať klávesnicu, ktorá buď používa 2.4ghz dongle, alebo kábel (čo je aj tak oveľa príjemnejšie kvôli latencii!). Osobne milujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Inštalácia pre iného vlastníka

Ak nastavujete stroj pre niekoho iného — člena rodiny, nového zamestnanca, kupujúceho — nemali by ste odpovedať na osobné otázky v jeho mene. Stlačte `Ctrl + C` na úplne prvej obrazovke inštalátora (výber klávesnice) a Omarchy namiesto toho ponúkne prípravu stroja pre iného vlastníka. Systém sa nainštaluje hneď, ale všetko osobné nastavenie — rozloženie klávesnice, používateľské meno, heslo — sa odloží, kým sa stroj prvýkrát nespustí. Disk je stále predvolene šifrovaný a heslo, ktoré si nový vlastník vyberie pri tom prvom spustení, sa stane aj šifrovacím heslom. (Stroj, ktorý ste už používali, môžete odovzdať aj bez preinštalovania — pozrite si [resetovanie počítača](48-security.md).)

### Bezobslužné inštalácie

ISO sa môže nainštalovať aj úplne samo — bez klávesnice, bez sprievodcu — keď mu odovzdáte jeho konfiguráciu na druhom disku. Takto sa k Omarchy pristupuje ako k základnému obrazu pre VM a flotily strojov. Pozrite si [bezobslužné inštalácie](51-unattended-installs.md).

### Inštalácie bez šifrovania

Omarchy sa predvolene inštaluje so šifrovaním. Je to bezpečná, zodpovedná voľba pre každý počítač, ktorý sa môže prípadne stratiť alebo môže byť ukradnutý. Nechcete, aby ktokoľvek s prístupom k vášmu hardvéru mohol získať vaše dáta!

Ale za zvláštnych okolností, ako sú vzdialené inštalácie Omarchy na chránených počítačoch alebo jednorazové inštalácie bez citlivých dát, možno budete chcieť inštalovať bez šifrovania. Pri potvrdení formátovania disku môžete stlačiť `Ctrl + C` a prepnúť na inštaláciu bez šifrovania.

### Jazyk

Omarchy hovorí 50 jazykmi — rovnakou sadou ako omarchy.org — a angličtina je predvolená. Ak chcete jazyk prepnúť, otvorte menu Omarchy a prejdite na _Setup > Region > Language_, alebo spustite v termináli `omarchy language <code>` (`omarchy language list` zobrazí kódy). Menu, pracovná plocha a vlastné oznámenia Omarchy okamžite zmenia jazyk a každá aplikácia, ktorú otvoríte potom, ich bude nasledovať tiež. Aplikácie, ktoré už boli otvorené, sa prepnú, keď ich reštartujete.

Ak chcete ponechať jazyk, ale písať dátumy, časy, čísla, peniaze, jednotky a veľkosti papiera tak, ako to robí iný región (napríklad angličtina s európskymi dátumami a 24-hodinovým formátom času), vyberte si región v _Setup > Region > Formats_, kde každá voľba zobrazuje ukážku, alebo spustite `omarchy region <code>` (`omarchy region list` zobrazí kódy). _Same as language_ sa vráti k vlastným formátom jazyka. Rovnako ako prepnutie jazyka, dosiahne aplikácie, ktoré otvoríte potom.

### Pomoc, ak sa zaseknete

Ak sa zaseknete, zvyčajne nájdete niekoho ochotného pomôcť v kanáli _#omarchy-help_ na [komunitnom Discorde](https://omarchy.org/discord).
