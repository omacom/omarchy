# Zabezpečení

Omarchy bere zabezpečení nesmírně vážně. Má to být operační systém, se kterým můžete dělat _Skutečnou práci_ ve _Skutečném světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Takže tady je, co děláme:

1. *Šifrování celého disku je ve výchozím nastavení zapnuté*: Toto je nejdůležitější krok k zajištění fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo vám ho ukradnou, jsou data plně zašifrována pomocí standardního LUKS (Linux Unified Key Setup). Instalační program vám umožní šifrování u strojů na vyhození vynechat (viz [Začínáme](02-getting-started.md)); instalace bez šifrování nemá nic z této ochrany a kdokoli, kdo drží disk, si ho může přečíst.
2. *Firewall je ve výchozím nastavení povolený*: Veškerý příchozí provoz je ve výchozím nastavení blokován, s několika výjimkami: port 53317 pro [LocalSend](https://localsend.org/); dotazy DNS na vlastní resolver počítače na adrese mostu Dockeru (172.17.0.1), přijímané z rozsahů soukromých adres, které Docker přiděluje svým kontejnerům; a multicast DNS (port 5353), který umožňuje tiskárnám a dalším zařízením ve vaší síti, aby se navzájem našly, a také tam oznamuje název vašeho počítače. Kromě toho si firewall ponechává standardní povolení UFW pro ping, získání adresy z vašeho routeru (DHCP) a vyhledávání UPnP. Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Setup > Security > SSHD_, což v rámci nastavení otevře port 22 (s omezením počtu pokusů proti útokům hrubou silou). Dokonce zamykáme i přístup k Dockeru pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker), abychom zabránili tomu, aby vaše kontejnery byly omylem vystaveny světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, základní distribuce, na které je Omarchy postavené, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je v jakémkoli balíčku objevena a opravena, je rychle k dispozici k instalaci pomocí `omarchy-update`. Díky tomu vždy používáte nejnovější, nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky a mirror*: Omarchy ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib a ze svého vlastního Omarchy Package Repository. Software si můžete nainstalovat přímo z AUR, ale základní instalace to nedělá — z AUR čerpá jen pár volitelných instalací, jako jsou prohlížeče třetích stran.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — ISO soubory, balíčky Omarchy, mirror Archu — je chráněna za mohutným DDoS štítem Cloudflare a hostovaná na jejich CDN. To poskytuje vynikající dostupnost.

## Změna vašich hesel

Na zašifrované instalaci máte dvě hesla: jedno, které odemyká disk při startu, a druhé, kterým se přihlašujete a používáte `sudo`. Nastavení je nastaví jako stejná. Obě lze změnit v nabídce Omarchy v části _Update > Password_ — první v _Drive Encryption_, druhé v _User_. Změna hesla disku se nejprve zeptá na to současné, takže ho mějte po ruce. Pokud se změna přeruší, spusťte _Drive Encryption_ znovu: zeptá se na heslo, které disk odemyká nyní, a změnu dokončí.

## Předání počítače, který jste už používali

Pokud svůj počítač předáváte někomu jinému, nemusíte ho přeinstalovávat. Spusťte v nabídce Omarchy _Setup > Reset Computer_, pro potvrzení napište `reset` a restartujte. Tím se smaže každý uživatelský účet a vše v `/home`, zahodí se všechny balíčky a systémové změny, které jste od instalace provedli, a vymaže se identita počítače — síťová připojení, hostitelské klíče, prostě všechno. Po návratu naběhne průvodce nastavením z prvního spuštění, připravený pro nového majitele, aby zadal své vlastní jméno, heslo a heslo k šifrování.

Funguje to obnovením základního snímku, který instalační program pořídí, takže je to k dispozici pouze na počítačích nainstalovaných z ISO Omarchy. A na disku bez šifrování je reset spíše smazáním než bezpečným vymazáním, takže pokud byla data citlivá, proveďte místo toho čerstvou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat o heslo, nejčastěji když za vás AI agent dělá dlouhý kus systémové práce. _Setup > Security > Passwordless Sudo_ se zeptá, na jak dlouho chcete přístup povolit: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Dokud je přístup aktivní, objeví se vedle ostatních indikátorů na liště nabídek červená varovná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Můžete také předat vlastní počet minut (od 1 do 1440) pomocí `omarchy-sudo-passwordless 30`, nebo použít `omarchy-sudo-passwordless permanent`.

Časovaný přístup vyprší automaticky, a to i okamžitě po probuzení z uspání, které překročilo termín. Restart počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává povolený, dokud ho nevypnete.

Aktualizace nebo odebrání balíčku s nastaveními Omarchy ukončí každé dočasné povolení předtím, než se změní podpora jeho vypršení. Pokud příkaz nahlásí chybu autorizace nebo čištění, vyřešte ji před pokusem o povolení dalšího přístupu; chyba neznamená, že přístup bez hesla není aktivní.

Dívejte se na to střízlivě: dokud je to zapnuté, cokoli běžící pod vaším uživatelem může dělat cokoli jako root, aniž by se ptalo. To je celý smysl a zároveň celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíčky z repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřit na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho také obsahuje a bude použit k bezproblémovému zavádění jakýchkoli případných aktualizací.

Podpis pro jakoukoli verzi ISO najdete přidáním `.sig` k její URL, například `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
