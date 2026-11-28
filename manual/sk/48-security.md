# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _Skutočnú prácu_ v _Skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzovej situácii. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je predvolene zapnuté*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich údajov. Ak sa váš počítač stratí alebo vám ho ukradnú, údaje sú úplne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup). Inštalátor vám umožňuje túto možnosť vypnúť pri počítačoch na jedno použitie (pozri [Začíname](02-getting-started.md)); inštalácia bez šifrovania nemá žiadnu z tejto ochrany a ktokoľvek, kto drží disk, si ho môže prečítať.
2. *Firewall je predvolene povolený*: Všetka prichádzajúca prevádzka je predvolene blokovaná, s niekoľkými výnimkami: port 53317 pre [LocalSend](https://localsend.org/); dopyty DNS na vlastný resolver počítača na adrese mosta Docker (172.17.0.1), prijímané z rozsahov súkromných adries, ktoré Docker prideľuje svojim kontajnerom; a multicast DNS (port 5353), ktorý umožňuje tlačiarňam a iným zariadeniam vo vašej sieti navzájom sa nájsť a zároveň tam ohlasuje názov vášho počítača. Okrem toho si firewall zachováva štandardné povolenia UFW pre ping, získanie adresy z vášho routera (DHCP) a vyhľadávanie UPnP. Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Nastavenie > Bezpečnosť > SSHD_, čo autorizuje váš kľúč SSH, vypne prihlasovanie heslom a až potom otvorí port 22 (s obmedzením rýchlosti proti útoku hrubou silou). Pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker) dokonca obmedzujeme prístup Docker, aby vaše kontajnery neboli náhodou vystavené svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavené, je priebežne aktualizovaná distribúcia. To znamená, že každá bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v ktoromkoľvek balíčku, je rýchlo k dispozícii na inštaláciu pomocou `omarchy-update`. Takto máte vždy spustené najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy si udržiava vlastné balíčky a zrkadlo*: Omarchy sa predvolene spolieha len na balíčky z vlastných repozitárov Arch core/extra/multilib (na počítačoch ARM z Arch Linux ARM, plus Asahi ALARM na Apple Silicon) a z vlastného Omarchy Package Repository. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — len niekoľko voliteľných inštalácií, napríklad prehliadače tretích strán, čerpá z AUR.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO, balíčky Omarchy, zrkadlo Arch — je chránená za impozantným štítom Cloudflare proti DDoS a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena vašich hesiel

Pri šifrovanej inštalácii máte dve heslá: jedno, ktoré odomyká disk pri zavádzaní, a druhé, ktorým sa prihlasujete a používate `sudo`. Inštalácia ich nastaví rovnaké. _Aktualizácia > Heslo_ v menu Omarchy zmení obe naraz, takže zostanú rovnaké: vyžiada si aktuálne heslo disku, potom nové, zmení heslo disku a následne nastaví vaše prihlasovacie heslo tak, aby sa s ním zhodovalo. Bez šifrovania disku zmení len vaše prihlasovacie heslo. Ak sa zmena preruší, spustite _Aktualizácia > Heslo_ znova: vyžiada si heslo, ktoré teraz odomyká disk, dokončí zmenu a nastaví naň vaše prihlasovacie heslo. Ak chcete zmeniť heslo iného šifrovaného disku, spustite v termináli `omarchy-drive-password`.

## Odovzdanie počítača, ktorý ste už používali

Ak svoj počítač odovzdávate niekomu inému, nemusíte ho preinštalovať. Spustite _Odstrániť > Obnovenie do továrenských nastavení_ v menu Omarchy, na potvrdenie napíšte `reset`, zadajte heslo šifrovania disku, ak vás o to požiada, a reštartujte počítač. Tým sa vymažú všetky používateľské účty a všetko v `/home`, zahodia všetky balíčky a systémové zmeny, ktoré ste urobili od inštalácie, a vymaže sa identita počítača — sieťové pripojenia, hostiteľské kľúče a všetko. Po spustení sa vráti sprievodca nastavením z prvého zavedenia, pripravený na to, aby nový vlastník zadal svoje vlastné meno, heslo a heslo šifrovania.

Funguje to obnovením základnej snímky, ktorú inštalátor vytvorí, takže je dostupné len na počítačoch nainštalovaných z ISO Omarchy. A na disku bez šifrovania je obnovenie skôr vymazaním než bezpečným prepísaním, takže ak boli údaje citlivé, namiesto toho urobte čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby `sudo` prestalo pýtať heslo, najčastejšie vtedy, keď za vás AI agent robí dlhý úsek systémovej práce. _Nastavenie > Bezpečnosť > Sudo bez hesla_ sa opýta, ako dlho má byť prístup povolený: **15 minút**, **1 hodina**, **1 deň** alebo **Natrvalo**. Kým je prístup aktívny, vedľa ostatných indikátorov na paneli menu sa zobrazí červená varovná ikona. Kliknite na ňu alebo znova spustite príkaz, ak chcete prístup vypnúť. Vlastný počet minút (od 1 do 1440) môžete zadať aj pomocou `omarchy-sudo-passwordless 30`, alebo použite `omarchy-sudo-passwordless permanent`.

Časovaný prístup automaticky vyprší, a to aj okamžite po obnovení z režimu spánku, ktorý prekročil termín. Reštartovanie počítača ho ukončí predčasne. Trvalý prístup pretrvá aj po reštartoch a zostane povolený, kým ho nevypnete.

Aktualizácia alebo odstránenie balíčka s nastaveniami Omarchy ukončí každé dočasné povolenie skôr, ako sa zmení jeho podpora vypršania. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju skôr, ako sa pokúsite povoliť ďalšie povolenie; chyba neznamená, že prístup bez hesla je neaktívny.

Majte v tom jasno: kým je to zapnuté, čokoľvek spustené pod vaším používateľom môže ako root urobiť čokoľvek bez opýtania. To je celý zmysel a zároveň celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balíčky repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho obsahuje tiež a bude sa používať na bezproblémové zavedenie prípadných aktualizácií.

Podpis pre ktorékoľvek vydanie ISO nájdete pridaním `.sig` k jeho URL, napríklad `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
