# Spánok systému

Omarchy má predvolene povolené uspanie a po nastavení aj hibernáciu, ale ak máte na svojom počítači problémy s niektorým z nich, môžete ich vypnúť.

Na počítačoch s NVIDIA GB10, ako sú DGX Spark a ASUS Ascent GX10, sú uspanie a hibernácia vypnuté, rovnako ako v DGX OS od NVIDIA, pretože na tomto hardvéri zatiaľ nebolo preukázané, že spánok funguje. Prepínač uspania ani nastavenie hibernácie sa tam neuplatňujú. Ak chcete spánok znova zapnúť, odstráňte `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomocou `sudo rm`; možnosť Suspend sa potom vráti do ponuky a hibernáciu bude možné nastaviť ako na iných počítačoch. Spustením `sudo omarchy apply hardware --install-user "$USER"` súbor vrátite späť.

### Profily napájania

Na notebooku si Omarchy pamätá váš profil napájania osobitne pre napájanie zo siete a pre prevádzku na batériu a prepína medzi nimi pri pripojení a odpojení napájania. Predvolene to znamená výkon pri napájaní zo siete a vyvážený režim na batériu.

Pomocou `omarchy powerprofiles list` si môžete pozrieť, čo váš počítač ponúka, a pomocou `omarchy powerprofiles set autodetect power-saver` nastaviť ten, ktorý chcete pre stav, v ktorom sa práve nachádzate. Ak chcete nastaviť druhý stav bez toho, aby ste čokoľvek odpájali, pomenujte ho priamo: `omarchy powerprofiles set battery power-saver`. Čokoľvek si vyberiete, dostanete späť, keď budete nabudúce v danom stave.

### Prepnutie uspania

Uspatie prepnete spustením `omarchy toggle suspend` z terminálu. Tým sa len zobrazí/skryje možnosť v ponuke _Systém_ (alebo `Super + Esc`) a potom môžete zistiť, či na vašom systéme funguje spoľahlivo. Ak nie, rovnakým príkazom ju môžete znova skryť.

### Prepnutie hibernácie

Hibernáciu nastavíte spustením `omarchy hibernation setup` z terminálu (nie je k dispozícii na počítačoch Mac s Apple Silicon). Hibernácia vytvorí na vašom zavádzacom disku podzväzok /swap s veľkosťou vašej fyzickej pamäte RAM, takže sa uistite, že máte dostatok voľného miesta. Na 32GB počítači budete pre tento zväzok vždy potrebovať 32GB+ voľného miesta. Hibernácia vyžaduje aj predvolený zavádzač Limine.

Po nastavení uvidíte možnosť hibernácie v ponuke _Systém_ (alebo `Super + Esc`) a potom môžete zistiť, či na vašom systéme funguje spoľahlivo. Ak nie, môžete ju znova odstrániť spustením `omarchy hibernation remove`.
