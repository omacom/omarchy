# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _Skutočnú Prácu_ v _Skutočnom Svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzovej situácii. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je predvolene zapnuté*: Toto je najdôležitejší krok k zabezpečeniu fyzickej ochrany vašich dát. Ak sa váš počítač stratí alebo ho ukradnú, dáta sú plne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup). Inštalátor vám umožní túto možnosť vypnúť pre stroje na jedno použitie (pozri [Začíname](02-getting-started.md)); inštalácia bez šifrovania nemá žiadnu z tejto ochrany a ktokoľvek, kto má disk v rukách, si ho môže prečítať.
2. *Firewall je predvolene povolený*: Všetka prichádzajúca prevádzka je predvolene blokovaná, s niekoľkými výnimkami: port 53317 pre [LocalSend](https://localsend.org/); DNS dotazy na vlastný resolver počítača na adrese Docker bridge (172.17.0.1), prijímané zo súkromných rozsahov adries, ktoré Docker prideľuje svojim kontajnerom; a multicast DNS (port 5353), ktoré umožňuje tlačiarňam a iným zariadeniam vo vašej sieti nájsť sa navzájom a zároveň tam oznamuje názov vášho počítača. Okrem toho si firewall zachováva štandardné povolenia UFW pre ping, získanie adresy z vášho routera (DHCP) a vyhľadávanie UPnP. Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Setup > Security > SSHD_, čo otvorí port 22 (s obmedzením frekvencie proti brute force) ako súčasť nastavenia. Dokonca uzamykame prístup Dockeru pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby sme zabránili náhodnému vystaveniu vašich kontajnerov svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavené, je rolling distribúcia. To znamená, že akákoľvek bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v akomkoľvek balíčku, je rýchlo k dispozícii na inštaláciu pomocou `omarchy-update`. Týmto spôsobom máte vždy najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy spravuje svoje vlastné balíčky a mirror*: Omarchy sa predvolene spolieha len na balíčky z vlastných repozitárov Arch core/extra/multilib a zo svojho vlastného Omarchy Package Repository. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — len niekoľko voliteľných inštalácií, ako sú prehliadače tretích strán, čerpá z AUR.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO, balíčky Omarchy, Arch mirror — je chránená za mohutným DDoS štítom Cloudflare a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena vašich hesiel

Pri zašifrovanej inštalácii máte dve heslá: jedno, ktoré odomyká disk pri spustení, a druhé, ktorým sa prihlasujete a používate `sudo`. Pri nastavení sa nastavia ako rovnaké. Obe je možné zmeniť v časti _Update > Password_ v menu Omarchy — _Drive Encryption_ pre prvé, _User_ pre druhé. Zmena hesla disku si najprv vyžiada aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Drive Encryption_ znova: vyžiada si heslo, ktoré teraz odomyká disk, a dokončí zmenu.

## Odovzdanie stroja, ktorý ste už používali

Ak svoj stroj odovzdávate niekomu inému, nemusíte ho preinštalovať. Spustite _Setup > Reset Computer_ v menu Omarchy, napíšte `reset` na potvrdenie a reštartujte. Tým sa vymažú všetky používateľské účty a všetko v `/home`, zahodia sa všetky balíčky a systémové zmeny, ktoré ste vykonali od inštalácie, a vymaže sa identita stroja — sieťové pripojenia, kľúče hostiteľa a všetko. Čo sa po spustení vráti, je sprievodca nastavením z prvého spustenia, pripravený pre nového majiteľa, aby zadal svoje vlastné meno, heslo a heslo na šifrovanie.

Funguje to obnovením základného snapshotu, ktorý inštalátor vytvorí, takže je k dispozícii len na strojoch nainštalovaných z Omarchy ISO. A na disku bez šifrovania je resetovanie vymazaním, nie bezpečným vymazaním, takže ak boli dáta citlivé, vykonajte namiesto toho čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby `sudo` prestalo pýtať heslo, najčastejšie vtedy, keď pre vás AI agent vykonáva dlhý úsek systémovej práce. _Setup > Security > Passwordless Sudo_ sa opýta, na ako dlho povoliť prístup: **15 minút**, **1 Hodina**, **1 Deň** alebo **Trvalo**. Kým je prístup aktívny, vedľa ostatných indikátorov na paneli ponuky sa zobrazí červená varovná ikona. Kliknite na ňu alebo znova spustite príkaz, aby ste prístup vypli. Môžete tiež odovzdať vlastný počet minút (od 1 do 1440) pomocou `omarchy-sudo-passwordless 30` alebo použiť `omarchy-sudo-passwordless permanent`.

Časovaný prístup automaticky vyprší, a to aj okamžite po obnovení z režimu uspania, ktorý prekročil termín. Reštartovanie počítača ho ukončí predčasne. Trvalý prístup prežije reštarty a zostane povolený, kým ho nezakážete.

Aktualizácia alebo odstránenie balíčka nastavení Omarchy ukončí akýkoľvek dočasný grant skôr, ako sa zmení podpora jeho exspirácie. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju pred pokusom o povolenie ďalšieho grantu; chyba neznamená, že prístup bez hesla je neaktívny.

Buďte v tejto veci triezvi: kým je to zapnuté, čokoľvek bežiace pod vaším používateľom môže robiť čokoľvek ako root bez toho, aby sa pýtalo. To je celý zmysel a zároveň celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balíčky repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho tiež obsahuje a bude sa používať na bezproblémové zavedenie všetkých potenciálnych aktualizácií.

Podpis pre ktorékoľvek vydanie ISO nájdete pridaním `.sig` k jeho URL, napríklad `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
