# Spánok systému

Omarchy má predvolene zapnuté uspanie a po nastavení aj hibernáciu, ale ak s niektorou z týchto funkcií máte na svojom počítači problémy, môžete ich vypnúť.

Na počítačoch s NVIDIA GB10, ako sú DGX Spark a ASUS Ascent GX10, sú uspanie a hibernácia vypnuté, rovnako ako v NVIDIA DGX OS, pretože sa zatiaľ nepreukázalo, že spánok na tomto hardvéri funguje. To isté platí pre ASUS Zenbook A16 (UX3607OA), kde uspanie zatiaľ úplne neuspí čip a počítač môže cez noc zamrznúť. Prepínač uspania ani nastavenie hibernácie sa tam neuplatňujú. Ak chcete spánok znova zapnúť, odstráňte `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomocou `sudo rm`; možnosť uspania sa potom vráti do ponuky a hibernáciu bude možné nastaviť ako na iných počítačoch. Spustením `sudo omarchy apply hardware --install-user "$USER"` sa súbor vráti späť.

### Profily napájania

Na notebooku si Omarchy pamätá váš profil napájania osobitne pre napájanie zo siete a pre prevádzku na batériu a prepína medzi nimi podľa toho, či notebook pripojíte alebo odpojíte. Hneď po inštalácii to znamená výkon pri napájaní zo siete a vyvážený režim na batériu.

Čo váš počítač ponúka, zistíte pomocou `omarchy powerprofiles list`, a profil, ktorý chcete pre stav, v ktorom sa práve nachádzate, nastavíte pomocou `omarchy powerprofiles set autodetect power-saver`. Ak chcete nastaviť druhý stav bez toho, aby ste čokoľvek odpájali, pomenujte ho priamo: `omarchy powerprofiles set battery power-saver`. Čokoľvek si vyberiete, dostanete späť pri ďalšom prechode do daného stavu.

### Prepnutie uspania

Uspávanie prepnete spustením `omarchy toggle suspend` z terminálu. Tým sa len zobrazí/skryje možnosť v ponuke _Systém_ (alebo `Super + Esc`) a potom môžete zistiť, či na vašom systéme funguje spoľahlivo. Ak nie, rovnakým príkazom ju môžete znova skryť.

### Prepnutie hibernácie

Hibernáciu nastavíte spustením `omarchy hibernation setup` z terminálu (na počítačoch Apple Silicon Mac nie je k dispozícii). Hibernácia vytvorí na vašom zavádzacom disku podzväzok /swap s veľkosťou vašej fyzickej pamäte RAM, takže sa uistite, že máte dostatok voľného miesta. Na počítači s 32 GB budete na tento zväzok vždy potrebovať viac ako 32 GB voľného miesta. Hibernácia tiež vyžaduje predvolený zavádzač Limine.

Po nastavení uvidíte možnosť hibernácie v ponuke _Systém_ (alebo `Super + Esc`) a potom môžete zistiť, či na vašom systéme funguje spoľahlivo. Ak nie, môžete ju znova odstrániť spustením `omarchy hibernation remove`.
