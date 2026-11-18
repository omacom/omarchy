# Začíname

Omarchy sa inštaluje pomocou ISO. Môžete si vybrať medzi inštaláciou na celý disk, ktorá prevezme celý disk, alebo inštaláciou do voľného priestoru, ktorá umiestni Omarchy do neprideleného priestoru na disku — takto dual bootujete popri Windowse alebo inom OS (pozrite si [inštaláciu s dual bootom](50-dual-boot-install.md) — nezabudnite, že vo Windowse musíte najprv vypnúť BitLocker). Tak či onak, inštalácia má predvolene zapnuté úplné šifrovanie a možnosť inštalácie na celý disk vymaže vybraný disk, takže si pred použitím existujúceho disku určite urobte zálohu!

Najprv si stiahnite [Omarchy ISO](https://omarchy.org/), umiestnite ho na USB kľúč (vo Windowse použite [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/) alebo na Linuxe [caligula](https://github.com/ifd3f/caligula)) a nabootujte z kľúča.

_V BIOSe musíte vypnúť Secure Boot a/alebo TPM. Tieto musíte vypnúť, aby ste mohli nainštalovať Omarchy. Sú to bezpečnostné schémy Microsoftu určené pre Windows a Linuxové distribúcie pridružené k Microsoftu._

Potom odpovedzte na konfiguračné otázky a potvrďte ich takto:

 ![install-config](images/install-config.webp)

Potom vyberte disk pre svoju inštaláciu a pohodlne sa usaďte a sledujte predstavenie inštalácie. Na najrýchlejších moderných strojoch to zvládnete za menej než minútu, ale ani na staršom počítači by to nemalo trvať viac než 5 minút.

 ![install-done](images/install-done.webp)

Teraz ste pripravení na Omarchy!

### Použite káblovú alebo 2.4ghz klávesnicu!

Šifrovanie celého disku vám pri spustení neumožní zadať heslo z Bluetooth klávesnice. Rovnako ako nemôžete použiť Bluetooth klávesnicu na vstup do BIOSu na PC. Budete potrebovať klávesnicu, ktorá používa buď 2.4ghz dongle, alebo kábel (čo je aj tak oveľa lepšie kvôli latencii!). Ja osobne milujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Inštalácia pre iného vlastníka

Ak pripravujete stroj pre niekoho iného — člena rodiny, nového zamestnanca, kupujúceho — nemali by ste na osobné otázky odpovedať za neho. Na úplne prvej obrazovke inštalátora (výber klávesnice) stlačte `Ctrl + C` a Omarchy namiesto toho ponúkne prípravu stroja pre iného vlastníka. Systém sa nainštaluje okamžite, ale celé osobné nastavenie — rozloženie klávesnice, používateľské meno, heslo — sa odloží, kým sa stroj prvýkrát nespustí. Disk je stále predvolene šifrovaný a heslo, ktoré si nový vlastník vyberie pri tomto prvom spustení, sa stane aj šifrovacím heslom. (Stroj, ktorý ste už používali, môžete odovzdať aj bez preinštalovania — pozrite si [resetovanie počítača](48-security.md).)

### Bezobslužné inštalácie

ISO sa môže nainštalovať aj úplne samo — bez klávesnice, bez sprievodcu — keď dostane svoju konfiguráciu na druhom disku. Takto môžete s Omarchy zaobchádzať ako so základným obrazom pre VM a flotilové stroje. Pozrite si [bezobslužné inštalácie](51-unattended-installs.md).

### Inštalácie bez šifrovania

Omarchy sa predvolene inštaluje so šifrovaním. Je to bezpečná a zodpovedná voľba pre každý počítač, ktorý sa môže stratiť alebo byť ukradnutý. Nechcete, aby ktokoľvek s prístupom k vášmu hardvéru mohol získať vaše dáta!

Za osobitných okolností, ako sú vzdialené inštalácie Omarchy na chránených počítačoch alebo jednorazové inštalácie bez citlivých dát, však možno budete chcieť inštalovať bez šifrovania. Na potvrdení formátovania disku môžete stlačiť `Ctrl + C` a prepnúť na inštaláciu bez šifrovania.

### Jazyk

Omarchy hovorí 50 jazykmi — rovnakou sadou ako omarchy.org — a angličtina je predvolená. Ak ju chcete prepnúť, otvorte ponuku Omarchy a prejdite na _Setup > Language_ alebo spustite v termináli `omarchy language <code>` (`omarchy language list` zobrazí kódy). Ponuka, pracovná plocha a vlastné oznámenia Omarchy okamžite zmenia jazyk a každá aplikácia, ktorú potom otvoríte, ich bude nasledovať tiež. Aplikácie, ktoré už boli otvorené, sa prepnú, keď ich reštartujete.

### Pomoc, ak sa zaseknete

Ak sa zaseknete, zvyčajne nájdete niekoho ochotného pomôcť v kanáli _#omarchy-help_ na [komunitnom Discorde](https://omarchy.org/discord).
