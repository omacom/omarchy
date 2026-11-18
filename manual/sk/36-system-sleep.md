# Spánok systému

Omarchy má uspanie a hibernáciu v predvolenom nastavení povolené, ale ak máš na svojom počítači problémy s jedným z nich, môžeš ich vypnúť.

Na počítačoch s NVIDIA GB10, ako sú DGX Spark a ASUS Ascent GX10, sú uspanie a hibernácia vypnuté, rovnako ako v systéme DGX OS od NVIDIA, pretože sa zatiaľ nepreukázalo, že spánok na tomto hardvéri funguje. To isté platí pre ASUS Zenbook A16 (UX3607OA), kde uspanie zatiaľ čip úplne neuspí a môže cez noc zamrznúť. Prepínač uspania a nastavenie hibernácie sa tam neuplatňujú. Ak chceš spánok znova zapnúť, odstráň `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomocou `sudo rm`; Uspať sa potom vráti do ponuky a hibernáciu je možné nastaviť ako na iných počítačoch. Spustením `sudo omarchy apply hardware --install-user "$USER"` súbor vrátiš späť.

### Profily napájania

Na notebooku si Omarchy pamätá tvoj profil napájania zvlášť pre napájanie zo siete a pre prevádzku na batériu a prepína medzi nimi, keď počítač pripojíš a odpojíš. V predvolenom nastavení to znamená výkon pri AC a vyvážený režim na batériu.

Pomocou `omarchy powerprofiles list` si môžeš pozrieť, čo tvoj počítač ponúka, a pomocou `omarchy powerprofiles set autodetect power-saver` nastaviť ten, ktorý chceš pre stav, v ktorom sa práve nachádzaš. Ak chceš nastaviť druhý stav bez toho, aby si čokoľvek odpájal, pomenuj ho priamo: `omarchy powerprofiles set battery power-saver`. Čokoľvek si vyberieš, presne to dostaneš späť, keď budeš nabudúce v danom stave.

### Prepnutie uspania

Uspávanie prepneš spustením `omarchy toggle suspend` z terminálu. Tým sa len zobrazí/skryje možnosť v časti _System_ (alebo `Super + Esc`) a potom môžeš zistiť, či na tvojom systéme funguje spoľahlivo. Ak nie, môžeš ju rovnakým príkazom znova skryť.

### Prepnutie hibernácie

Hibernáciu nastavíš spustením `omarchy hibernation setup` z terminálu. Hibernácia vytvorí podzväzok /swap na tvojom zavádzacom disku s veľkosťou tvojej fyzickej pamäte RAM, takže sa uisti, že máš dostatok voľného miesta. Na počítači s 32GB pamäťou budeš pre tento zväzok vždy potrebovať viac ako 32GB voľného miesta. Hibernácia tiež vyžaduje predvolený zavádzač Limine.

Po nastavení uvidíš možnosť hibernácie v časti _System_ (alebo `Super + Esc`) a potom môžeš zistiť, či na tvojom systéme funguje spoľahlivo. Ak nie, môžeš ju znova odstrániť spustením `omarchy hibernation remove`.
