# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Toto má byť operačný systém, ktorý môžete používať na _Skutočnú prácu_ v _skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzi. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je povinné*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich údajov. Ak sa váš počítač stratí alebo vám ho ukradnú, údaje sú plne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup).
2. *Firewall je predvolene zapnutý*: Všetka prichádzajúca prevádzka je predvolene blokovaná okrem portu 53317 pre [LocalSend](https://localsend.org/). Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Nastavenie > Bezpečnosť > SSHD_, čo v rámci nastavenia otvorí port 22 (s obmedzením rýchlosti proti útokom hrubou silou). Dokonca obmedzujeme aj prístup Dockeru pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby vaše kontajnery neboli náhodou vystavené svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavené, je priebežne aktualizovaná distribúcia. To znamená, že akákoľvek bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v ktoromkoľvek balíku, je rýchlo k dispozícii na inštaláciu pomocou `omarchy-update`. Vďaka tomu vždy používate najnovšie, najbezpečnejšie verzie všetkého.
4. *Omarchy spravuje vlastné balíky a zrkadlo*: Omarchy predvolene využíva iba balíky z vlastných repozitárov Archu core/extra/multilib a zo svojho vlastného repozitára balíkov Omarchy Package Repository. Softvér si môžete nainštalovať priamo z AUR, ale základná inštalácia to nerobí — z AUR čerpá len niekoľko voliteľných inštalácií, napríklad prehliadače tretích strán.
5. *Cloudflare nás chráni pred DDoS*: Distribučná infraštruktúra Omarchy — ISO súbory, balíky Omarchy, zrkadlo Archu — je chránená za mohutným štítom Cloudflare proti DDoS a hostovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena hesiel

Na zašifrovanej inštalácii máte dve heslá: jedno, ktorým pri štarte odomykáte disk, a druhé, ktorým sa prihlasujete a používate `sudo`. Pri nastavení sa nastavia ako rovnaké. Obe môžete zmeniť v ponuke Omarchy pod _Aktualizácia > Heslo_ — _Šifrovanie disku_ pre prvé, _Používateľ_ pre druhé. Pri zmene hesla disku sa najprv pýta na aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Šifrovanie disku_ znova: opýta sa na heslo, ktoré disk odomyká teraz, a zmenu dokončí.

## Odovzdanie počítača, ktorý ste už používali

Ak svoj počítač odovzdávate niekomu inému, nemusíte ho preinštalovávať. V ponuke Omarchy spustite _Nastavenie > Resetovať počítač_, na potvrdenie napíšte `reset` a reštartujte. Tým sa vymažú všetky používateľské účty a všetko v `/home`, zahodia sa všetky balíky a systémové zmeny, ktoré ste od inštalácie urobili, a vymaže sa identita počítača — sieťové pripojenia, hostiteľské kľúče, všetko. Po reštarte sa zobrazí sprievodca nastavením z prvého spustenia, pripravený na to, aby nový majiteľ zadal svoje vlastné meno, heslo a heslo šifrovania.

Funguje to obnovením základnej snímky, ktorú vytvorí inštalátor, takže je to dostupné iba na počítačoch nainštalovaných z ISO súboru Omarchy. A na disku bez šifrovania je resetovanie vymazaním, nie bezpečným vymazaním, takže ak boli údaje citlivé, namiesto toho vykonajte čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby sa `sudo` prestalo pýtať, najčastejšie keď za vás AI agent robí dlhý úsek systémovej práce. _Nastavenie > Bezpečnosť > Sudo bez hesla_ sa opýta, ako dlho chcete prístup povoliť: **15 minút**, **1 hodina**, **1 deň** alebo **Natrvalo**. Kým je prístup aktívny, vedľa ostatných indikátorov panela ponuky sa zobrazí červená varovná ikona. Kliknite na ňu alebo príkaz spustite znova, aby ste prístup vypli. Vlastný počet minút (od 1 do 1440) môžete zadať aj príkazom `omarchy-sudo-passwordless 30`, alebo použite `omarchy-sudo-passwordless permanent`.

Časovo obmedzený prístup automaticky vyprší, a to aj okamžite po obnovení z režimu spánku, počas ktorého uplynul termín. Reštartovanie počítača ho ukončí predčasne. Trvalý prístup pretrvá aj po reštartoch a zostáva zapnutý, kým ho nevypnete.

Aktualizácia alebo odstránenie balíka nastavení Omarchy ukončí každé dočasné povolenie skôr, ako sa zmení jeho podpora vypršania platnosti. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju pred pokusom o povolenie ďalšieho prístupu; chyba neznamená, že prístup bez hesla je neaktívny.

Majte v tom jasno: kým je to zapnuté, čokoľvek spustené pod vaším používateľom môže bez opýtania robiť čokoľvek ako root. To je celý zmysel, a zároveň aj celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO súborov a balíky repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overte na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balík `omarchy/omarchy-keyring` ho tiež obsahuje a bude sa používať na bezproblémové zavádzanie prípadných aktualizácií.

Podpis pre ktorékoľvek vydanie ISO nájdete pridaním .sig k URL. Napríklad https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
