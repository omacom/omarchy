# Zabezpečení

Omarchy bere zabezpečení nesmírně vážně. Má jít o operační systém, který můžete použít k _opravdové práci_ v _opravdovém světě_. Kde ztráta notebooku nemůže vést k bezpečnostní nouzi. Zde je tedy, co děláme:

1. *Šifrování celého disku je povinné*: Jde o nejdůležitější krok k zabezpečení fyzické ochrany vašich dat. Pokud se váš počítač ztratí nebo bude odcizen, data jsou plně šifrována standardním systémem LUKS (Linux Unified Key Setup).
2. *Firewall je ve výchozím nastavení zapnutý*: Veškerý příchozí provoz je ve výchozím nastavení blokován s výjimkou portu 53317 pro aplikaci [LocalSend](https://localsend.org/). I SSH je vypnuté, dokud ho nezapnete v části _Nastavení > Security > SSHD_, která v rámci nastavení otevře port 22 (s omezením rychlosti proti útokům hrubou silou). Přístup Dockeru dokonce zamykáme pomocí sestavení [ufw-docker](https://github.com/chaifeng/ufw-docker), abychom zabránili nechtěnému vystavení vašich kontejnerů světu.
3. *Arch má vždy nejnovější aktualizace*: Arch, podkladová distribuce, na které je Omarchy postavený, je průběžně aktualizovaná distribuce. To znamená, že jakákoli bezpečnostní chyba, která je v některém balíčku odhalena a opravena, je rychle k dispozici k instalaci příkazem `omarchy-update`. Tímto způsobem vždy používáte nejnovější a nejbezpečnější verze všeho.
4. *Omarchy spravuje vlastní balíčky i zrcadlo*: Omarchy se ve výchozím nastavení spoléhá pouze na balíčky z vlastních repozitářů Archu core/extra/multilib a ze svého vlastního repozitáře balíčků Omarchy. Software můžete instalovat přímo z AUR, ale základní instalace to nedělá — z AUR čerpá jen několik volitelných instalací, například prohlížeče třetích stran.
5. *Cloudflare nás chrání před útoky DDoS*: Veškerá distribuční infrastruktura Omarchy — obrazy ISO, balíčky Omarchy, zrcadlo Archu — je chráněna impozantním štítem proti útokům DDoS společnosti Cloudflare a hostována na jejich síti CDN. To zajišťuje vynikající dostupnost.

## Změna hesel

U šifrované instalace máte dvě hesla: jedno odemyká disk při spouštění, druhé používáte při přihlašování a pro `sudo`. Při nastavení se obě shodují. Obě můžete změnit v nabídce Omarchy v části _Aktualizovat > Password_ — _Drive Encryption_ pro první, _User_ pro druhé. Při změně hesla disku se vás systém nejprve zeptá na současné heslo, takže je mějte po ruce. Pokud je změna přerušena, spusťte volbu _Drive Encryption_ znovu: zeptá se na heslo, kterým se disk nyní odemyká, a změnu dokončí.

## Předání počítače, který jste už používali

Pokud svůj počítač předáváte někomu jinému, nemusíte ho přeinstalovávat. V nabídce Omarchy spusťte volbu _Nastavení > Reset Computer_, zadejte pro potvrzení `reset` a restartujte počítač. Tím se vymažou všechny uživatelské účty a všechny soubory ve složce `/home`, zahodí se všechny balíčky a systémové změny, které jste provedli od instalace, a vymaže se identita počítače — síťová připojení, klíče hostitele a vůbec všechno. Po opětovném spuštění se objeví průvodce prvotním nastavením, připravený pro nového majitele, aby zadal své vlastní jméno, heslo a šifrovací heslo.

Funguje to tak, že se obnoví výchozí snímek, který pořídí instalátor, takže je možnost k dispozici pouze na počítačích nainstalovaných z obrazu ISO Omarchy. A u disku bez šifrování je obnovení pouze smazání, nikoli bezpečné vymazání, takže pokud byla data citlivá, udělejte namísto toho čistou instalaci.

## Sudo bez hesla

Někdy chcete, aby příkaz `sudo` přestal vyžadovat heslo, nejčastěji když za vás agent umělé inteligence vykonává delší úsek práce se systémem. Volba _Nastavení > Security > Passwordless Sudo_ se ptá, jak dlouho má být přístup povolen: **15 minut**, **1 hodina**, **1 den** nebo **Trvale**. Po dobu aktivního přístupu se vedle ostatních indikátorů v pruhu nabídek zobrazuje červená výstražná ikona. Kliknutím na ni nebo opětovným spuštěním příkazu přístup vypnete. Pomocí příkazu `omarchy-sudo-passwordless 30` můžete předat také vlastní počet minut (od 1 do 1440), případně použít variantu `omarchy-sudo-passwordless permanent`.

Časově omezený přístup vyprší automaticky, a to i ihned po obnovení z uspání, které překročilo lhůtu. Restart počítače ho ukončí předčasně. Trvalý přístup přežije restart počítače a zůstává povolený, dokud ho nevypnete.

Aktualizací nebo odebráním balíčku s nastavením Omarchy se jakékoli dočasné udělení přístupu ukončí předtím, než se změní podpora jeho vypršení. Pokud příkaz nahlásí chybu autorizace nebo vyčištění, vyřešte ji předtím, než se pokusíte povolit jiné udělení přístupu; chyba neznamená, že je přístup bez hesla neaktivní.

Buďte v tomto ohledu racionální: dokud je přístup zapnutý, může cokoli běžící pod vaším uživatelem dělat cokoli jako root, aniž by se vás někdo zeptal. Přesně v tom spočívá smysl, a také přesně v tom spočívá celé riziko.

## Podpisové klíče

Veřejný klíč pro všechny podpisy obrazů ISO a balíčků v repozitáři Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([ověřit na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Balíček `omarchy/omarchy-keyring` ho obsahuje rovněž a bude použitý k plynulému zavedení všech možných aktualizací.

Podpis pro jakoukoli verzi obrazu ISO najdete přidáním koncovky .sig k adrese URL. Jako například https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
