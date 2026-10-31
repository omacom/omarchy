# Virtuální počítač s Windows

Omarchy nabízí snadnou možnost spouštět Windows prostřednictvím virtuálního počítače v Dockeru. Můžete ho nainstalovat pomocí části _Instalovat > Windows_ z nabídky Omarchy (`Super + Space`).

Váš počítač k tomu potřebuje virtualizaci KVM, což většina má — ale někdy je v systému BIOS vypnutá a instalační program vám řekne, pokud tomu tak je. Budete také chtít místo na disku: cokoli, co Windows dáte, plus asi 10 GB pro samotný obraz.

Instalační program se zeptá, kolik paměti RAM, kolik jader CPU a kolik místa na disku má předat (64 GB nebo více je rozumný základ), a poté na uživatelské jméno a heslo pro Windows. Nechte je prázdná a dostanete `docker` / `admin`. Stažení chvíli trvá — 10–15 minut je normální — a průběh můžete sledovat v prohlížeči na adrese `http://127.0.0.1:8006`. Prohlížeč si před otevřením konzole vyžádá stejné uživatelské jméno a heslo.

 ![windows-vm](images/windows-vm.webp)

## Používání

Jakmile bude nainstalovaný, spusťte _Windows_ ze spouštěče aplikací. Tím se spustí virtuální počítač, pokud ještě neběží, a připojí vás přes RDP na celou obrazovku. Při studeném startu mu dejte 15–30 sekund.

Relace RDP přenáší zvuk, váš mikrofon a sdílenou schránku, takže kopírování textu mezi Linuxem a Windows prostě funguje. Rozlišení sleduje vaše okno a Omarchy předává měřítko vašeho displeje, takže na obrazovce HiDPI to není rozmazaný nepořádek.

Když okno RDP zavřete, virtuální počítač se automaticky vypne. Pokud byste ho raději nechali běžet — řekněme, že tam máte něco, co pracuje — spusťte ho místo toho pomocí příkazu `omarchy windows vm launch --keep-alive`.

Zbytek ovládacích prvků je na stejném příkazu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Sdílení souborů

Adresář `~/Windows` ve vašem domovském adresáři se automaticky sdílí s virtuálním počítačem. Soubory tam vkládejte, pokud chcete, aby byly přístupné systému Windows. Virtuální počítač nemá přístup k žádné jiné části vašeho souborového systému, takže jste v bezpečí před čímkoli nepříjemným na straně Windows. Jeho vlastní virtuální disk je k dispozici v umístění `~/.windows`.

Tyto známé domovské cesty zůstávají na svých vlastních souborových systémech. Mohou být také symbolickými odkazy na adresáře, které vlastníte, což je užitečné, když virtuální disk žije na větší jednotce. Instalační program měří volné místo v souborovém systému, který skutečně obsahuje adresář `~/.windows`, nikoli nutně souborový systém obsahující váš domovský adresář.

Disk a sdílené cesty uchovávejte jako samostatné, nepřekrývající se adresáře. Odebrání záměrně vyprázdní adresář disku, ale zachová sdílený adresář. Bezprostředně před odstraněním Omarchy provede ohraničenou kontrolu uzavření a odmítne cokoli odebrat, pokud tato kontrola vyprší nebo nedokáže prokázat, že jsou oba stromy oddělené.

Před spuštěním virtuálního počítače Omarchy oba tyto adresáře otevře a připne a poté přesné inode adresářů připojí vazebným připojením na soukromé kotvy pro jednotlivé uživatele v části `/var/lib/omarchy/windows/mounts`. Docker vidí pouze tyto kotvy chráněné rootem. Tím se zachovávají vlastní umístění disku a zároveň se zabraňuje tomu, aby jiný proces běžící pod vaším účtem vyměnil zkontrolovanou cestu předtím, než ji privilegovaný kontejner spotřebuje. Stávající disk a sdílené adresáře se během migrace zpřísní do režimu `0700`, aby jiné místní účty nemohly procházet jejich obsah.

Porty virtuálního počítače jsou vázány pouze na localhost, takže nic ve vaší síti nedosáhne na počítač s Windows. Webová konzole také vyžaduje nakonfigurované uživatelské jméno a heslo pro Windows, které brání jinému místnímu účtu v ovládání virtuálního počítače přes port 8006.

## Omezení a licencování

S tímto nastavením není k dispozici propust pro GPU, takže není vhodné pro hraní her ani úpravy videa. Je to skvělý způsob, jak spouštět Microsoft Office nebo cokoli jiného, co naprosto musíte mít.

Nainstalovaná verze je Windows 11 Pro, neaktivovaná. K používání funkcí vázaných na licenci budete potřebovat vlastní licenční klíč.

Pokud byl tento počítač dodán s Windows, je klíč OEM i po instalaci Omarchy stále ve firmwaru. Vytiskněte ho příkazem `omarchy windows key`. Tento klíč je vázán na tento počítač — aktivuje systém Windows přeinstalovaný na tomto hardwaru, ale obvykle neaktivuje virtuální počítač.

Přidělení prostředků můžete později změnit opětovným spuštěním příkazu `omarchy-windows-vm install`, který na základě vašich odpovědí přepíše konfiguraci virtuálního počítače. Samotný soubor compose nyní žije v umístění `/var/lib/omarchy/windows/docker-compose.yml` a vlastní ho root — to je záměrné, aby ho proces běžící pod vaším účtem nemohl přepsat a nechat privilegovaný počáteční proces připojit celý váš disk do kontejneru. Pokud ho potřebujete ručně upravit (například pro připojení zařízení USB), upravte ho pomocí `sudo` a všechny možnosti najděte v projektu [Dockur Windows](https://github.com/dockur/windows).

Chcete-li se toho všeho zbavit, použijte část _Odebrat > Windows_ z nabídky Omarchy. Tím se odstraní disk virtuálního počítače a všechna jeho data, takže se ujistěte, že všechno, na čem vám záleží, je nejprve pryč z adresáře `~/Windows`.
