# Bezpečnosť

Omarchy berie bezpečnosť mimoriadne vážne. Má to byť operačný systém, ktorý môžete používať na _skutočnú prácu_ v _skutočnom svete_. Kde strata notebooku nemôže viesť k bezpečnostnej núdzi. Takže tu je, čo robíme:

1. *Šifrovanie celého disku je povinné*: Toto je najdôležitejší krok na zabezpečenie fyzickej ochrany vašich údajov. Ak sa váš počítač stratí alebo vám ho ukradnú, údaje sú plne zašifrované pomocou štandardného LUKS (Linux Unified Key Setup).
2. *Firewall je predvolene povolený*: Všetka prichádzajúca prevádzka je predvolene blokovaná, okrem portu 53317 pre [LocalSend](https://localsend.org/). Dokonca aj ssh je vypnuté, kým ho nezapnete cez _Nastavenie > Security > SSHD_, čo v rámci nastavenia otvorí port 22 (s obmedzením rýchlosti proti útokom hrubou silou). Dokonca uzamykáme prístup Dockeru pomocou nastavenia [ufw-docker](https://github.com/chaifeng/ufw-docker), aby sme zabránili tomu, aby sa vaše kontajnery náhodne vystavili svetu.
3. *Arch má vždy najnovšie aktualizácie*: Arch, základná distribúcia, na ktorej je Omarchy postavený, je priebežne aktualizovaná distribúcia. To znamená, že každá bezpečnostná zraniteľnosť, ktorá sa objaví a opraví v akomkoľvek balíku, je rýchlo dostupná na inštaláciu pomocou `omarchy-update`. Týmto spôsobom vždy používate najnovšie a najbezpečnejšie verzie všetkého.
4. *Omarchy udržiava vlastné balíky a zrkadlo*: Omarchy sa predvolene spolieha len na balíky z vlastných repozitárov Archu core/extra/multilib a z vlastného repozitára balíkov Omarchy. Softvér môžete inštalovať priamo z AUR, ale základná inštalácia to nerobí — len niekoľko voliteľných inštalácií, ako prehliadače tretích strán, čerpá z AUR.
5. *Cloudflare nás chráni pred DDoS*: Celá distribučná infraštruktúra Omarchy — ISO, balíky Omarchy, zrkadlo Archu — je chránená za mohutným štítom Cloudflare proti DDoS a hosťovaná na ich CDN. To poskytuje vynikajúcu dostupnosť.

## Zmena hesiel

Na zašifrovanej inštalácii máte dve heslá: jedno, ktoré odomyká disk pri zavádzaní, a jedno, ktorým sa prihlasujete a používate `sudo`. Nastavenie ich robí rovnakými. Obe môžete zmeniť v časti _Aktualizovať > Password_ v ponuke Omarchy — _Drive Encryption_ pre prvé, _User_ pre druhé. Zmena hesla disku si najskôr vyžiada aktuálne heslo, takže ho majte poruke. Ak sa zmena preruší, spustite _Drive Encryption_ znova: vyžiada si heslo, ktoré disk odomyká teraz, a zmenu dokončí.

## Odovzdanie stroja, ktorý ste už používali

Ak svoj stroj odovzdávate niekomu inému, nemusíte ho preinštalovať. Spustite _Nastavenie > Reset Computer_ v ponuke Omarchy, na potvrdenie napíšte `reset` a reštartujte. Tým sa vymaže každý používateľský účet a všetko v `/home`, zahodia sa všetky balíky a systémové zmeny, ktoré ste od inštalácie urobili, a vymaže sa identita stroja — sieťové pripojenia, kľúče hostiteľa a všetko. Čo sa vráti, je sprievodca nastavením z prvého zavedenia, pripravený na to, aby nový vlastník zadal svoje vlastné meno, heslo a šifrovacie heslo.

Funguje to tak, že sa obnoví základná snímka, ktorú inštalačný program vytvorí, takže je to dostupné len na strojoch nainštalovaných z ISO Omarchy. A na disku bez šifrovania je reset vymazanie, nie bezpečné vymazanie, takže ak boli údaje citlivé, urobte namiesto toho čerstvú inštaláciu.

## Sudo bez hesla

Niekedy chcete, aby vás `sudo` prestalo otravovať, najčastejšie vtedy, keď za vás agent s umelou inteligenciou robí dlhý úsek systémovej práce. _Nastavenie > Security > Passwordless Sudo_ sa pýta, ako dlho povoliť prístup: **15 minutes**, **1 Hour**, **1 Day** alebo **Permanently**. Kým je prístup aktívny, vedľa ostatných ukazovateľov lišty ponuky sa zobrazí červená výstražná ikona. Kliknite na ňu alebo znova spustite príkaz, ak chcete prístup vypnúť. Môžete tiež odovzdať vlastný počet minút (od 1 do 1440) príkazom `omarchy-sudo-passwordless 30` alebo použiť `omarchy-sudo-passwordless permanent`.

Načasovaný prístup vyprší automaticky, a to aj okamžite po obnovení z uspania, ktoré prekročilo termín. Reštart počítača ho predčasne ukončí. Trvalý prístup prežije reštarty a zostáva povolený, kým ho nevypnete.

Aktualizácia alebo odstránenie balíka nastavení Omarchy ukončí každé dočasné udelenie ešte predtým, než sa zmení jeho podpora vypršania. Ak príkaz nahlási chybu autorizácie alebo čistenia, vyriešte ju skôr, než sa pokúsite povoliť ďalšie udelenie; chyba neznamená, že prístup bez hesla je neaktívny.

Pri tomto majte otvorené oči: kým je to zapnuté, čokoľvek, čo beží ako váš používateľ, môže robiť čokoľvek ako root bez opýtania. To je celý zmysel a je to aj celé riziko.

## Podpisové kľúče

Verejný kľúč pre všetky podpisy ISO a balíky repozitára Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([overiť na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balík `omarchy/omarchy-keyring` ho obsahuje tiež a bude sa používať na bezproblémové zavedenie prípadných aktualizácií.

Podpis pre každé vydanie ISO nájdete pridaním .sig k adrese URL. Napríklad https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
