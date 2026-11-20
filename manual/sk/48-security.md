# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _Skutočnú prácu_ v _Skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzi. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je predvolene zapnuté*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich údajov. Ak sa váš počítač stratí alebo ho ukradnú, údaje sú plne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup). Inštalátor vám umožňuje odmietnuť ho pre stroje na jedno použitie (pozrite si [Začíname](02-getting-started.md)); inštalácia bez šifrovania nemá žiadnu z tejto ochrany a ktokoľvek, kto drží disk, si ho môže prečítať.
2. *Firewall je predvolene povolený*: Všetka prichádzajúca prevádzka je predvolene blokovaná, s niekoľkými výnimkami: port 53317 pre [LocalSend](https://localsend.org/); DNS dotazy na vlastný resolver počítača na adrese Docker bridge (172.17.0.1), prijímané z rozsahov súkromných adries, ktoré Docker dáva svojim kontajnerom; a multicast DNS (port 5353), ktorý umožňuje tlačiarňam a iným zariadeniam vo vašej sieti navzájom sa nájsť a tiež tam oznamuje názov vášho počítača. Okrem toho firewall zachováva štandardné povolenia UFW pre ping, získanie adresy z vášho routera (DHCP) a UPnP discovery. Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Setup > Security > SSHD_, čo v rámci nastavenia otvorí port 22 (s obmedzením rýchlosti proti brute force). Dokonca uzamykame prístup Dockeru pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby sme zabránili náhodnému vystaveniu vašich kontajnerov svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základné distro, na ktorom je Omarchy postavené, je rolling distribúcia. To znamená, že akákoľvek bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v akomkoľvek balíku, je rýchlo dostupná na inštaláciu pomocou `omarchy-update`. Takto máte vždy spustené najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy spravuje vlastné balíky a mirror*: Omarchy sa predvolene spolieha iba na balíky z vlastných repozitárov Archu core/extra/multilib a zo svojho vlastného Omarchy Package Repository. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — z AUR čerpá iba niekoľko voliteľných inštalácií, ako sú prehliadače tretích strán.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO, balíky Omarchy, mirror Archu — je chránená za mohutným DDoS štítom Cloudflare a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena vašich hesiel

Na zašifrovanej inštalácii máte dve heslá: jedno, ktoré odomyká disk pri spustení, a druhé, ktorým sa prihlasujete a používate `sudo`. Nastavenie ich nastaví ako rovnaké. Obe je možné zmeniť v časti _Update > Password_ v menu Omarchy — _Drive Encryption_ pre prvé, _User_ pre druhé. Zmena hesla disku najprv vyžaduje aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Drive Encryption_ znova: požiada o heslo, ktoré teraz odomyká disk, a dokončí zmenu.

## Odovzdanie stroja, ktorý ste už používali

Ak svoj stroj odovzdávate niekomu inému, nemusíte ho preinštalovať. Spustite _Remove > Factory Reset_ v menu Omarchy, na potvrdenie napíšte `reset` a reštartujte. Tým sa vymažú všetky používateľské účty a všetko v `/home`, zahodia sa všetky balíky a systémové zmeny, ktoré ste od inštalácie vykonali, a vymaže sa identita stroja — sieťové pripojenia, host keys a všetko. Po spustení sa zobrazí sprievodca nastavením z prvého spustenia, pripravený pre nového majiteľa, aby zadal svoje vlastné meno, heslo a šifrovacie heslo.

Funguje to obnovením základného snapshotu, ktorý inštalátor vytvorí, takže je k dispozícii iba na strojoch nainštalovaných z Omarchy ISO. A na disku bez šifrovania je reset skôr vymazaním než bezpečným vymazaním, takže ak boli údaje citlivé, namiesto toho vykonajte čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby `sudo` prestalo pýtať heslo, najčastejšie keď za vás AI agent robí dlhý úsek systémovej práce. _Setup > Security > Passwordless Sudo_ sa spýta, na ako dlho povoliť prístup: **15 minút**, **1 hodina**, **1 deň** alebo **Natrvalo**. Kým je prístup aktívny, vedľa ostatných indikátorov na paneli menu sa zobrazí červená výstražná ikona. Kliknite na ňu alebo znova spustite príkaz, aby ste prístup vypli. Môžete tiež odovzdať vlastný počet minút (od 1 do 1440) pomocou `omarchy-sudo-passwordless 30`, alebo použiť `omarchy-sudo-passwordless permanent`.

Časovaný prístup vyprší automaticky, vrátane okamžite po obnovení z režimu spánku, ktorý prekročil termín. Reštartovanie počítača ho ukončí predčasne. Trvalý prístup prežije reštarty a zostáva povolený, kým ho nezakážete.

Aktualizácia alebo odstránenie balíka nastavení Omarchy ukončí akékoľvek dočasné oprávnenie pred zmenou jeho podpory vypršania. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju pred pokusom o povolenie ďalšieho oprávnenia; chyba neznamená, že prístup bez hesla je neaktívny.

Pozerajte sa na to triezvo: kým je to zapnuté, čokoľvek spustené ako váš používateľ môže robiť čokoľvek ako root bez opýtania. To je celý zmysel, a zároveň celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balík repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balík `omarchy/omarchy-keyring` ho tiež obsahuje a bude použitý na bezproblémové zavedenie akýchkoľvek potenciálnych aktualizácií.

Podpis pre akékoľvek vydanie ISO nájdete pridaním `.sig` k jeho URL, napríklad `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
