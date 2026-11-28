# Windows VM

Omarchy ponúka jednoduchý spôsob, ako spustiť Windows cez Docker VM na počítačoch s architektúrou x86_64. Nainštalujete ho pomocou _Install > Windows_ v menu Omarchy (`Super + Space`).

Váš počítač na to potrebuje virtualizáciu KVM, čo väčšina podporuje — niekedy je však vypnutá v BIOS-e a inštalátor vám povie, ak je to tak. Budete potrebovať aj miesto na disku: toľko, koľko pridelíte Windowsu, plus približne 10GB na samotný obraz.

Inštalátor sa spýta, koľko RAM, koľko jadier CPU a koľko miesta na disku má prideliť (rozumné minimum je 64GB alebo viac), a potom na používateľské meno a heslo pre Windows. Ak ich necháte prázdne, dostanete `docker` / `admin`. Sťahovanie chvíľu trvá — 10-15 minút je normálne — a priebeh môžete sledovať v prehliadači na `http://127.0.0.1:8006`. Prehliadač si pred otvorením konzoly vyžiada rovnaké používateľské meno a heslo.

 ![windows-vm](images/windows-vm.webp)

## Používanie

Po nainštalovaní spustite _Windows_ zo spúšťača aplikácií. Tým sa VM spustí, ak ešte nebeží, a pripojí vás cez RDP na celú obrazovku. Pri studenom štarte mu dajte 15-30 sekúnd.

Relácia RDP prenáša zvuk, váš mikrofón a zdieľanú schránku, takže kopírovanie textu medzi Linuxom a Windowsom jednoducho funguje. Rozlíšenie sa prispôsobuje vášmu oknu a Omarchy prenáša nastavenie mierky zobrazenia, takže na HiDPI obrazovke to nie je rozmazaný neporiadok.

Keď zatvoríte okno RDP, VM sa automaticky vypne. Ak ho radšej chcete nechať bežať — povedzme, že tam niečo pracuje — spustite ho namiesto toho príkazom `omarchy windows vm launch --keep-alive`.

Ostatné ovládanie je pod tým istým príkazom:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Zdieľanie súborov

Adresár `~/Windows` vo vašom domovskom adresári sa automaticky zdieľa s VM. Ak chcete, aby boli súbory prístupné pre Windows, vložte ich tam. VM nemá prístup k žiadnej inej časti vášho súborového systému, takže ste v bezpečí pred čímkoľvek nepríjemným na strane Windowsu. Jej vlastný virtuálny disk je dostupný v `~/.windows`.

Tieto známe domovské cesty zostávajú na svojich vlastných súborových systémoch. Môžu to byť aj symlinky na adresáre, ktoré vlastníte, čo je užitočné, keď virtuálny disk žije na väčšom disku. Inštalátor meria voľné miesto na súborovom systéme, ktorý skutočne obsahuje `~/.windows`, nie nevyhnutne na súborovom systéme obsahujúcom váš domovský adresár.

Disk a zdieľané cesty udržiavajte ako samostatné, neprekrývajúce sa adresáre. Odstránenie zámerne vyprázdni adresár disku, ale zachová zdieľaný adresár. Bezprostredne pred odstránením Omarchy vykoná ohraničenú kontrolu oddelenia a odmietne čokoľvek odstrániť, ak táto kontrola prekročí časový limit alebo nedokáže preukázať, že sú oba stromy oddelené.

Pred spustením VM Omarchy otvorí a pripne tieto dva adresáre a potom bind-mountne presné inody adresárov na súkromné kotvy jednotlivých používateľov pod `/var/lib/omarchy/windows/mounts`. Docker vidí iba tieto kotvy chránené rootom. Tým sa zachovajú vlastné umiestnenia disku a zároveň sa zabráni inému procesu bežiacemu pod vaším účtom, aby vymenil skontrolovanú cestu skôr, ako ju privilegovaný kontajner použije. Existujúce adresáre disku a zdieľaný adresár sa počas migrácie sprísnia na režim `0700`, aby iné lokálne účty nemohli prezerať ich obsah.

Porty VM sú viazané iba na localhost, takže nič vo vašej sieti sa nedostane k počítaču s Windowsom. Webová konzola tiež vyžaduje nastavené používateľské meno a heslo pre Windows, čo zabraňuje inému lokálnemu účtu ovládať VM cez port 8006.

## Obmedzenia a licencie

Pri tomto nastavení nie je k dispozícii GPU passthrough, takže nie je vhodné na hranie hier ani úpravu videa. Je to skvelý spôsob, ako používať Microsoft Office alebo čokoľvek iné, čo bezpodmienečne musíte mať.

Nainštalovaná verzia je Windows 11 Pro, neaktivovaná. Na používanie funkcií viazaných na licenciu budete potrebovať vlastný licenčný kľúč.

Ak bol tento počítač dodaný s Windowsom, OEM kľúč je stále vo firmvéri aj po nainštalovaní Omarchy. Vypíšete ho príkazom `omarchy windows key`. Tento kľúč je viazaný na tento počítač — aktivuje Windows preinštalovaný na tomto hardvéri, ale VM zvyčajne neaktivuje.

Pridelenie zdrojov môžete neskôr zmeniť spustením `omarchy windows vm install` v termináli, čo prepíše konfiguráciu VM podľa vašich odpovedí. Samotný compose súbor sa teraz nachádza v `/var/lib/omarchy/windows/docker-compose.yml` a vlastní ho root — je to zámer, aby proces bežiaci pod vaším účtom nemohol tento súbor prepísať a prinútiť privilegované spustenie pripojiť celý váš disk do kontajnera. Ak ho potrebujete upraviť ručne (napríklad na pripojenie USB zariadenia), upravte ho pomocou `sudo` a všetky možnosti nájdete v [projekte Dockur Windows](https://github.com/dockur/windows).

Ak sa chcete celého zbaviť, použite _Remove > Windows_ v menu Omarchy. Tým sa odstráni disk VM v `~/.windows` a všetko nainštalované vnútri Windowsu, takže si najprv skopírujte z VM všetko, čo potrebujete. Váš zdieľaný priečinok `~/Windows` zostane nedotknutý.
