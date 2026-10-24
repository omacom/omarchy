# Komenco

Omarchy estas instalata per ISO. Vi povas elekti inter instalo al tuta disko, kiu transprenas la tutan diskon, aŭ instalo en libera spaco, kiu metas Omarchy en la nealokitan parton de disko — ĉi tiel vi duobole startas Windows aŭ alian sistemon (vidu [duobla starto](50-dual-boot-install.md) — notu, ke vi unue devas malŝalti BitLocker-on en Windows). En ambaŭ kazoj la instalado defaŭlte inkluzivas ĉifradon, kaj la opcio por tuta disko viŝos la elektitan diskon, do certiĝu, ke vi faris sekurkopion antaŭ ol uzi ekzistantan!

[Konsultu la Omarchy-ISO](https://omarchy.org/) unue, metu ĝin sur USB-memorilon (uzu [balenaEtcher](https://etcher.balena.io/) en Mac/Windows aŭ [caligula](https://github.com/ifd3f/caligula) en Linukso), kaj startu el la memorilo.

_Vi devas malŝalti Secure Boot kaj/aŭ TPM en la BIOS. Vi devas malŝalti ĉi tiujn por povi instali Omarchy. Ili estas sekurecaj schemoj de Microsoft, kreitaj por Windows kaj por Linuksaj distribuoj de Microsoft._

Poste respondu al la agordaj demandoj, kaj konfirmu ilin tiel:

 ![install-config](images/install-config.webp)

Tiam elektu diskon por via instalado, kaj rezide, dum la instalado evidentiĝas. Ĝi povas fariĝi en malpli ol minuto sur la plej rapidaj modernaj maŝinoj, sed ĝi ne devus daŭri pli ol 5 minutojn eĉ sur pli malnova komputilo.

 ![install-done](images/install-done.webp)

Nun vi pretas por Omarchy!

### Uzu klavaron kun kablo aŭ 2.4 GHz!

La ĉifrado de tuta disko ne permesos al vi enigi la pasvorton per Bluetooth-klavaro je starto. Same kiel vi ne povas uzi Bluetooth-klavaron por eniri la BIOS-on en PC. Vi bezonos klavaron, kiu aŭ uzas 2.4 GHz-sendilon aŭ kabelon (kiu ĉefe estas pli plaĉa por latenteco!). Personal mi amas la [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalo por alia posedanto

Se vi agordas maŝinon por alia homo — familiano, nova dungitaro, aĉetanto — vi ne devus respondi la personajn demandojn en lia nomo. Premu `Ctrl + C` je la tre unua paĝo de la instalilo (la elekto de klavaro), kaj Omarchy proponos prepari la maŝinon por alia posedanto anstataŭe. La sistemo instalas tuj, sed la tuta persona agordo — klavararanĝo, uzantnomo, pasvorto — estas prokrastata ĝis la unua starto de la maŝino. La disko restas ĉifrita defaŭlte, kaj la pasvorto, kiun la nova posedanto elektas ĉe tiu unua starto, fariĝas ankaŭ la ĉifra pasvorto. (Maŝino, kiun vi jam uzas, ankaŭ povas esti transdonata sen reinstalado — vidu [restarigi la komputilon](48-security.md).)

### Senzorge instaladoj

La ISO ankaŭ povas tute instali sin mem — sen klavaro, sen asistento — kiam oni transdonas al ĝi sian agordon en dua disko. Tio estas la maniero trakti Omarchy kiel bazan bildon por VM-oj kaj maŝinoj de floto. Vidu [senzorge instaladojn](51-unattended-installs.md).

### Instaloj sen ĉifrado

Omarchy estas instalata kun ĉifrado defaŭlte. Ĝi estas la sekura, responda elekto por ĉiu komputilo, kiun eblas perdi aŭ ŝteli. Vi ne volas, ke iu kun aliro al via hardvaro povu akiri viajn datumojn!

Sed en specialaj cirkonstancoj, kiel distancaj Omarchy-instaloj en protektitaj komputiloj aŭ por forĵetaj instaladoj sen sensitivaj datumoj, vi eble volas instali sen ĉifrado. Vi povas premi `Ctrl + C` je la konfirmo de diskformatado por ŝalti al instalado sen ĉifrado.

### Lingvo

Omarchy parolas 51 lingvojn — la saman aron ol omarchy.org, plus Esperanto — kaj la angla estas defaŭlta. Por ŝanĝi, malfermu la Omarchy-menuon kaj iru al _Agordo > Lingvo_, aŭ rulu `omarchy language <code>` en terminalo (`omarchy language list` montras la kodojn). La menuo, labortablo kaj la propraj sciigoj de Omarchy ŝanĝas lingvon tuj, kaj ĉiu aplikaĵo, kiun vi malfermas poste, sekvas ankaŭ. Aplikaĵoj, kiuj jam estis malfermitaj, ŝanĝas, kiam vi restartigas ilin.

### Helpo se vi estas ŝanĉita

Se vi estas ŝanĉita, vi kutime povas trovi iun, kiu konsentas helpi, en la kanalo _#omarchy-help_ en la [komunuma Discord](https://omarchy.org/discord).