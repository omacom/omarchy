# Zabezpečení

Omarchy bere zabezpečení extrémně vážně. Toto má být operační systém, který můžete používat ke _Skutečné práci_ v _Reálném světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Takže tady je, co děláme:

1. *Šifrování celého disku je ve výchozím nastavení zapnuté*: Toto je nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo je ukraden, data jsou plně zašifrována pomocí standardního LUKS (Linux Unified Key Setup). Instalační program vám umožní ho vypnout u počítačů na jedno použití (viz [Začínáme](02-getting-started.md)); instalace bez šifrování nemá žádnou z této ochrany a kdokoli, kdo má disk, si ho může přečíst.
2. *Firewall je ve výchozím nastavení povolený*: Veškerý příchozí provoz je ve výchozím nastavení blokován, s několika výjimkami: port 53317 pro [LocalSend](https://localsend.org/); dotazy DNS na vlastní resolver počítače na adrese mostu Dockeru (172.17.0.1), přijímané ze soukromých rozsahů adres, které Docker dává svým kontejnerům; a multicast DNS (port 5353), který umožňuje tiskárnám a dalším zařízením ve vaší síti najít se navzájem a také tam oznamuje název vašeho počítače. Kromě toho firewall zachovává standardní povolení UFW pro ping, získání adresy z vašeho routeru (DHCP) a zjišťování UPnP. Dokonce i ssh je vypnuté, dokud ho nezapnete přes _Nastavení > Zabezpečení > SSHD_, což autorizuje váš klíč SSH, vypne přihlašování heslem a teprve poté otevře port 22 (s omezením rychlosti proti útokům hrubou silou). Dokonce zamykáme přístup k Dockeru pomocí nastavení [ufw-docker](https://github.com/chaifeng/ufw-docker), abychom zabránili tomu, aby vaše kontejnery byly omylem vystaveny světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, podkladové distro, na němž Omarchy stojí, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní zranitelnost, která je objevena a opravena v jakémkoli balíčku, je rychle k dispozici k instalaci pomocí `omarchy-update`. Tímto způsobem vždy používáte nejnovější, nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky a zrcadlo*: Omarchy se ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib (na počítačích ARM z Arch Linux ARM, plus Asahi ALARM na Apple Silicon) a na vlastní Omarchy Package Repository. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — pouze několik volitelných instalací, jako jsou prohlížeče třetích stran, čerpá z AUR.
5. *Cloudflare nás chrání před DDoS*: Distribuční infrastruktura Omarchy — ISO obrazy, balíčky Omarchy, zrcadlo Archu — je chráněna za ohromným štítem Cloudflare proti DDoS a hostována na jejich CDN. To poskytuje vynikající dostupnost.

## Změna hesel

Při šifrované instalaci máte dvě hesla: jedno, které odemyká disk při spuštění, a jedno, kterým se přihlašujete a používáte `sudo`. Při nastavení jsou stejná. _Aktualizace > Heslo_ v nabídce Omarchy mění obě najednou, takže zůstanou stejná: zeptá se na aktuální heslo disku, poté na nové, změní heslo disku a poté nastaví vaše přihlašovací heslo tak, aby odpovídalo. Bez šifrování disku změní pouze vaše přihlašovací heslo. Pokud je změna přerušena, spusťte _Aktualizace > Heslo_ znovu: zeptá se na heslo, které nyní odemyká disk, dokončí změnu a nastaví k němu vaše přihlašovací heslo. Chcete-li změnit heslo jiného šifrovaného disku, spusťte v terminálu `omarchy-drive-password`.

## Předání počítače, který jste už používali

Pokud předáváte svůj počítač někomu jinému, nemusíte ho znovu instalovat. Spusťte _Odebrat > Obnovení do továrního nastavení_ v nabídce Omarchy, napište `reset` pro potvrzení, v případě dotazu zadejte heslo šifrování disku a restartujte. Tím se vymažou všechny uživatelské účty a vše v `/home`, zahodí se všechny balíčky a systémové změny, které jste provedli od instalace, a vymaže se identita počítače — síťová připojení, hostitelské klíče a vše. Co se vrátí, je průvodce nastavením z prvního spuštění, připravený pro nového vlastníka, aby zadal své vlastní jméno, heslo a heslo šifrování.

Funguje to obnovením základního snímku, který instalační program pořídí, takže je k dispozici pouze na počítačích nainstalovaných z ISO Omarchy. A na disku bez šifrování je obnovení spíše mazáním než bezpečným vymazáním, takže pokud byla data citlivá, proveďte místo toho čerstvou instalaci.

## Sudo bez hesla

Někdy chcete, aby `sudo` přestalo žádat, nejčastěji když za vás AI agent provádí dlouhou sérii systémové práce. _Nastavení > Zabezpečení > Sudo bez hesla_ se zeptá, jak dlouho povolit přístup: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Zatímco je přístup aktivní, vedle ostatních indikátorů panelu nabídek se objeví červená výstražná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Můžete také zadat vlastní počet minut (od 1 do 1440) pomocí `omarchy-sudo-passwordless 30` nebo použít `omarchy-sudo-passwordless permanent`.

Časovaný přístup automaticky vyprší, včetně okamžitě po obnovení z režimu spánku, který překročil lhůtu. Restartování počítače ho ukončí předčasně. Trvalý přístup přežije restarty a zůstává povolený, dokud ho nezakážete.

Aktualizace nebo odebrání balíčku nastavení Omarchy ukončí jakékoli dočasné udělení přístupu před uplynutím jeho platnosti, pokud se změní podpora vypršení. Pokud příkaz nahlásí chybu autorizace nebo čištění, vyřešte ji před pokusem o povolení dalšího udělení; chyba neznamená, že přístup bez hesla není aktivní.

Mějte v tom jasno: dokud je to zapnuté, cokoli spuštěné pod vaším uživatelem může dělat cokoli jako root, aniž by se ptalo. To je celý smysl, a také celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy ISO a balíčky repozitáře Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřte na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho také obsahuje a bude použit k bezproblémovému zavedení případných aktualizací.

Podpis pro jakékoli vydání ISO najdete přidáním `.sig` k jeho URL, jako `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
