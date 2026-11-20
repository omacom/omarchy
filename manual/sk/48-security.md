# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _Skutočnú prácu_ v _Skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzovej situácii. Robíme preto toto:

1. *Úplné šifrovanie disku je predvolene zapnuté*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich dát. Ak sa váš počítač stratí alebo vám ho ukradnú, dáta sú úplne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup). Inštalátor vám pri strojoch na vyhodenie umožní túto možnosť vypnúť (pozri [Začíname](02-getting-started.md)); inštalácia bez šifrovania nemá žiadnu z tejto ochrany a ktokoľvek, kto má disk v rukách, si ho môže prečítať.
2. *Firewall je predvolene zapnutý*: Všetka prichádzajúca prevádzka je predvolene blokovaná, s niekoľkými výnimkami: port 53317 pre [LocalSend](https://localsend.org/); DNS dotazy na vlastný resolver počítača na adrese Docker bridge (172.17.0.1), prijímané z rozsahov súkromných adries, ktoré Docker prideľuje svojim kontajnerom; a multicast DNS (port 5353), ktorý umožňuje tlačiarňam a iným zariadeniam vo vašej sieti nájsť sa navzájom a zároveň tam oznamuje názov vášho počítača. Okrem toho firewall zachováva štandardné povolenia UFW pre ping, získanie adresy z vášho routera (DHCP) a vyhľadávanie UPnP. Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Nastavenie > Bezpečnosť > SSHD_, čo autorizuje váš SSH kľúč, vypne prihlasovanie heslom a až potom otvorí port 22 (s obmedzením rýchlosti proti útokom hrubou silou). Prístup Dockeru dokonca uzamykáme pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby sme zabránili náhodnému vystaveniu vašich kontajnerov svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavený, je rolling distribúcia. To znamená, že akákoľvek bezpečnostná zraniteľnosť, ktorá je objavená a opravená v akomkoľvek balíku, je rýchlo k dispozícii na inštaláciu pomocou `omarchy-update`. Týmto spôsobom vždy používate najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy spravuje vlastné balíky a zrkadlo*: Omarchy sa predvolene spolieha iba na balíky z vlastných repozitárov Archu core/extra/multilib (na ARM strojoch z Arch Linux ARM, plus Asahi ALARM na Apple Silicon) a svojho vlastného Omarchy Package Repository. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — z AUR čerpá len niekoľko voliteľných inštalácií, ako sú prehliadače tretích strán.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO súbory, balíky Omarchy, Arch mirror — je chránená za mohutným DDoS štítom Cloudflare a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena hesiel

Pri šifrovanej inštalácii máte dve heslá: jedno, ktoré pri spustení odomyká disk, a druhé, ktorým sa prihlasujete a používate `sudo`. Pri nastavení sú obe rovnaké. Obe môžete zmeniť v menu Omarchy pod _Aktualizácia > Heslo_ — _Šifrovanie disku_ pre prvé, _Používateľ_ pre druhé. Pri zmene hesla disku sa najprv opýta na aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Šifrovanie disku_ znova: opýta sa na heslo, ktoré teraz odomyká disk, a zmenu dokončí.

## Odovzdanie stroja, ktorý ste už používali

Ak odovzdávate svoj stroj niekomu inému, nemusíte ho preinštalovať. Spustite _Odstrániť > Obnovenie do továrenských nastavení_ v menu Omarchy, na potvrdenie napíšte `reset`, zadajte heslo šifrovania disku, ak vás o to požiada, a reštartujte. Tým sa vymažú všetky používateľské účty a všetko v `/home`, zahodia sa všetky balíky a systémové zmeny, ktoré ste vykonali od inštalácie, a vymaže sa identita stroja — sieťové pripojenia, kľúče hostiteľa a všetko. Čo sa vráti, je sprievodca nastavením z prvého spustenia, pripravený pre nového majiteľa, aby zadal svoje vlastné meno, heslo a heslo šifrovania.

Funguje to obnovením základnej snímky, ktorú inštalátor vytvorí, takže je k dispozícii len na strojoch nainštalovaných z Omarchy ISO. A na disku bez šifrovania je reset skôr vymazaním než bezpečným vymazaním, takže ak boli dáta citlivé, namiesto toho vykonajte čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby `sudo` prestalo pýtať heslo, najčastejšie keď za vás AI agent vykonáva dlhý úsek systémovej práce. _Nastavenie > Bezpečnosť > Sudo bez hesla_ sa opýta, na ako dlho povoliť prístup: **15 minút**, **1 hodina**, **1 deň** alebo **Natrvalo**. Červená výstražná ikona sa objaví vedľa ostatných indikátorov na paneli ponúk, kým je prístup aktívny. Kliknite na ňu alebo znova spustite príkaz, aby ste prístup vypli. Môžete tiež zadať vlastný počet minút (od 1 do 1440) pomocou `omarchy-sudo-passwordless 30` alebo použiť `omarchy-sudo-passwordless permanent`.

Časovaný prístup automaticky vyprší, vrátane okamžite po obnovení z režimu spánku, ktorý prekročil termín. Reštartovanie počítača ho ukončí skôr. Trvalý prístup prežije reštarty a zostáva zapnutý, kým ho nevypnete.

Aktualizácia alebo odstránenie balíka s nastaveniami Omarchy ukončí každé dočasné povolenie ešte pred zmenou podpory jeho vypršania. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju skôr, ako sa pokúsite povoliť ďalšie povolenie; chyba neznamená, že prístup bez hesla je neaktívny.

Majte v tom jasno: kým je to zapnuté, čokoľvek bežiace pod vaším používateľom môže ako root urobiť čokoľvek bez opýtania. To je celý zmysel a zároveň celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balíky repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balík `omarchy/omarchy-keyring` ho tiež obsahuje a bude použitý na bezproblémové zavedenie akýchkoľvek potenciálnych aktualizácií.

Podpis pre akékoľvek vydanie ISO nájdete pridaním `.sig` k jeho URL, napríklad `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
