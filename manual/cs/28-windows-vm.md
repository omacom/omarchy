# Windows VM

Omarchy nabízí snadný způsob, jak spustit Windows prostřednictvím Docker VM na počítačích s architekturou x86_64. Nainstalovat ho můžete pomocí _Install > Windows_ z nabídky Omarchy (`Super + Space`).

Váš počítač k tomu potřebuje virtualizaci KVM, kterou většina má — někdy je ale vypnutá v BIOSu a instalátor vám to v takovém případě řekne. Budete také potřebovat místo na disku: tolik, kolik přidělíte Windows, plus asi 10GB na samotný obraz.

Instalátor se zeptá, kolik RAM, kolik jader CPU a kolik místa na disku chcete předat (64GB a víc je rozumné minimum), a poté na uživatelské jméno a heslo pro Windows. Nechte je prázdná a dostanete `docker` / `admin`. Stahování chvíli trvá — 10-15 minut je normální — a průběh můžete sledovat v prohlížeči na adrese `http://127.0.0.1:8006`. Prohlížeč si před otevřením konzole vyžádá stejné uživatelské jméno a heslo.

 ![windows-vm](images/windows-vm.webp)

## Používání

Po instalaci spusťte _Windows_ ze spouštěče aplikací. Tím se VM spustí, pokud ještě neběží, a připojí vás přes RDP na celou obrazovku. Při studeném startu jí dejte 15-30 sekund.

Relace RDP přenáší zvuk, váš mikrofon a sdílenou schránku, takže kopírování textu mezi Linuxem a Windows prostě funguje. Rozlišení se přizpůsobuje vašemu oknu a Omarchy propouští škálování vašeho displeje, takže na HiDPI obrazovce to není rozmazaná bída.

Když okno RDP zavřete, VM se automaticky vypne. Pokud ji raději chcete nechat běžet — řekněme, že v ní něco pracuje — spusťte ji místo toho pomocí `omarchy windows vm launch --keep-alive`.

Zbytek ovládání je na stejném příkazu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Sdílení souborů

Adresář `~/Windows` ve vašem domovském adresáři se s VM sdílí automaticky. Pokud chcete, aby byly soubory přístupné pro Windows, dejte je tam. VM nemá přístup k žádné jiné části vašeho souborového systému, takže jste v bezpečí před čímkoli ošklivým na straně Windows. Její vlastní virtuální disk je k dispozici na adrese `~/.windows`.

Tyto známé domovské cesty zůstávají na svých vlastních souborových systémech. Mohou to být také symlinky na adresáře, které vlastníte, což se hodí, když virtuální disk žije na větším disku. Instalátor měří volné místo na souborovém systému, který skutečně obsahuje `~/.windows`, ne nutně na souborovém systému obsahujícím váš domovský adresář.

Cesty disku a sdílenou cestu udržujte jako oddělené, nepřekrývající se adresáře. Odebrání záměrně vyprázdní adresář disku, ale zachová sdílený adresář. Těsně před smazáním Omarchy provede časově omezenou kontrolu oddělenosti a odmítne cokoli odstranit, pokud tato kontrola vyprší nebo nedokáže prokázat, že jsou oba stromy oddělené.

Před spuštěním VM Omarchy tyto dva adresáře otevře a připne a poté přes bind mount připojí přesné inody adresářů na soukromé kotvy jednotlivých uživatelů pod `/var/lib/omarchy/windows/mounts`. Docker vidí pouze tyto kotvy chráněné uživatelem root. Díky tomu zůstanou zachována vlastní umístění disku a zároveň to zabrání jinému procesu spuštěnému pod vaším účtem, aby prohodil zkontrolovanou cestu dřív, než ji privilegovaný kontejner použije. Stávající adresáře disku a sdílený adresář se během migrace zpřísní na režim `0700`, aby si jejich obsah nemohly prohlížet jiné místní účty.

Porty VM jsou vázány pouze na localhost, takže se k počítači s Windows nedostane nic z vaší sítě. Webová konzole také vyžaduje nakonfigurované uživatelské jméno a heslo pro Windows, což brání jinému místnímu účtu, aby VM ovládal přes port 8006.

## Omezení a licencování

V tomto nastavení není žádné propouštění GPU, takže se nehodí na hraní her ani střih videa. Je to skvělý způsob, jak spustit Microsoft Office nebo cokoli jiného, co bezpodmínečně musíte mít.

Nainstalovaná verze je Windows 11 Pro, neaktivovaná. K používání uzamčených funkcí budete potřebovat vlastní licenční klíč.

Pokud byl tento počítač dodán s Windows, klíč OEM je i po instalaci Omarchy stále ve firmwaru. Vytisknete ho příkazem `omarchy windows key`. Tento klíč je vázán na tento počítač — aktivuje Windows přeinstalované na tomto hardwaru, ale VM obvykle neaktivuje.

Přidělení prostředků můžete později změnit spuštěním `omarchy windows vm install` v terminálu, což přepíše konfiguraci VM na základě vašich odpovědí. Samotný soubor compose nyní žije na adrese `/var/lib/omarchy/windows/docker-compose.yml` a vlastní ho root — to je záměrné, aby proces běžící pod vaším účtem nemohl soubor přepsat a nechat privilegované spuštění připojit do kontejneru celý váš disk. Pokud ho potřebujete upravit ručně (například připojit zařízení USB), upravte ho pomocí `sudo` a všechny možnosti si prohlédněte na [projektu Dockur Windows](https://github.com/dockur/windows).

Chcete-li se toho celého zbavit, použijte _Remove > Windows_ z nabídky Omarchy. Tím se smaže disk VM v `~/.windows` a vše nainstalované uvnitř Windows, takže si nejprve z VM zkopírujte vše, co potřebujete. Vaše sdílená složka `~/Windows` zůstane nedotčená.
