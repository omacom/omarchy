# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _skutočnú prácu_ v _skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzovej situácii. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je povinné*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich dát. Ak sa váš počítač stratí alebo ho ukradnú, dáta sú plne šifrované pomocou štandardného LUKS (Linux Unified Key Setup).
2. *Firewall je predvolene zapnutý*: Všetka prichádzajúca prevádzka je predvolene blokovaná okrem portu 53317 pre [LocalSend](https://localsend.org/). Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Setup > Security > SSHD_, čo v rámci nastavenia otvorí port 22 (s obmedzením rýchlosti proti brute force). Dokonca obmedzujeme prístup Docker pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby sme zabránili tomu, aby boli vaše kontajnery náhodou vystavené svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavené, je rolling distribúcia. To znamená, že akákoľvek bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v ktoromkoľvek balíčku, je rýchlo k dispozícii na inštaláciu pomocou `omarchy-update`. Takto máte vždy najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy spravuje vlastné balíčky a mirror*: Omarchy sa predvolene spolieha len na balíčky z vlastných repozitárov Arch core/extra/multilib a z vlastného Omarchy Package Repository. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — len niekoľko voliteľných inštalácií, ako napríklad prehliadače tretích strán, čerpá z AUR.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO súbory, balíčky Omarchy, mirror Arch — je chránená za mohutným DDoS štítom Cloudflare a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena vašich hesiel

Na šifrovanej inštalácii máte dve heslá: jedno, ktoré odomyká disk pri spustení, a druhé, ktorým sa prihlasujete a používate `sudo`. Nastavenie ich nastaví ako rovnaké. Obe môžete zmeniť v menu Omarchy cez _Update > Password_ — _Drive Encryption_ pre prvé, _User_ pre druhé. Pri zmene hesla disku sa najprv pýta na aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Drive Encryption_ znova: opýta sa na heslo, ktoré disk odomyká teraz, a zmenu dokončí.

## Odovzdanie počítača, ktorý ste už používali

Ak svoj počítač odovzdávate niekomu inému, nemusíte ho preinštalovať. Spustite _Setup > Reset Computer_ v menu Omarchy, na potvrdenie napíšte `reset` a reštartujte. Tým sa vymaže každý používateľský účet a všetko v `/home`, zahodia sa všetky balíčky a systémové zmeny, ktoré ste urobili od inštalácie, a vymaže sa identita počítača — sieťové pripojenia, kľúče hostiteľa a všetko ostatné. Po spustení sa vráti sprievodca nastavením z prvého spustenia, pripravený pre nového majiteľa, aby zadal svoje vlastné meno, heslo a šifrovacie heslo.

Funguje to obnovením základnej snímky, ktorú inštalátor vytvorí, takže je to k dispozícii len na počítačoch nainštalovaných z Omarchy ISO. A na disku bez šifrovania je reset skôr vymazaním než bezpečným prepísaním, takže ak boli dáta citlivé, namiesto toho urobte čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby `sudo` prestalo pýtať heslo, najčastejšie keď pre vás AI agent robí dlhý úsek systémovej práce. _Setup > Security > Passwordless Sudo_ sa opýta, ako dlho povoliť prístup: **15 minút**, **1 hodina**, **1 deň** alebo **Trvalo**. Kým je prístup aktívny, vedľa ostatných indikátorov v paneli menu sa zobrazí červená výstražná ikona. Kliknite na ňu alebo znova spustite príkaz, aby ste prístup vypli. Môžete tiež zadať vlastný počet minút (od 1 do 1440) pomocou `omarchy-sudo-passwordless 30` alebo použiť `omarchy-sudo-passwordless permanent`.

Časovaný prístup vyprší automaticky, vrátane okamžite po obnovení z režimu spánku, ktorý prekročil termín. Reštartovanie počítača ho ukončí predčasne. Trvalý prístup prežije reštarty a zostáva zapnutý, kým ho nevypnete.

Aktualizácia alebo odstránenie balíčka nastavení Omarchy ukončí akékoľvek dočasné povolenie predtým, než sa zmení podpora jeho vypršania. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju predtým, než sa pokúsite povoliť ďalšie povolenie; chyba neznamená, že prístup bez hesla je neaktívny.

Majte v tom jasno: kým je to zapnuté, čokoľvek bežiace pod vaším používateľom môže robiť čokoľvek ako root bez opýtania. To je celý zmysel a zároveň celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balíček repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho tiež obsahuje a bude použitý na bezproblémové zavedenie akýchkoľvek potenciálnych aktualizácií.

Podpis pre akékoľvek vydanie ISO nájdete pridaním `.sig` k jeho URL, napríklad `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
