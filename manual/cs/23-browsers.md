# Prohlížeče

Omarchy se dodává s [Google Chrome](https://www.google.com/chrome/) jako výchozím prohlížečem. Je motivem sladěný se zbytkem vašeho systému a otevřete ho pomocí `Super + Shift + Return` (nebo `Super + Shift + B`), pomocí `Super + Shift + Alt + B` otevřete soukromé okno a běží v něm každá [webová aplikace](25-web-apps.md). Otevírá se rovnou do okna prohlížeče: žádná uvítací obrazovka ani výzva k přihlášení, statistiky používání a hlášení o pádech se Googlu neodesílají a výzvy ohledně soukromí v reklamách jsou vypnuté. Kdykoli budete chtít synchronizaci, můžete se ke svému účtu Google stále přihlásit tlačítkem profilu.

Pokud vám Chrome nevyhovuje, nejste na něj odkázáni. Pod _Instalace > Prohlížeč_ v menu Omarchy najdete [Chromium](https://www.chromium.org/) (prostou open-source verzi, ze které Chrome vzniká), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) a [Ladybird](https://ladybird.org/) (Edge pouze na počítačích x86). Vyberte si jeden a Omarchy ho nainstaluje, nastaví mu adresář zásad a použije na něj váš aktuální motiv.

## Jak jeden nastavit jako výchozí

Nainstalování prohlížeče z něj výchozí neudělá. Chcete-li to změnit, přejděte do _Nastavení > Výchozí > Prohlížeč_ a jeden vyberte. Aktuální výchozí prohlížeč je označený zaškrtnutím a výběr prohlížeče, který ještě nemáte, ho nejprve nainstaluje.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spusťte to bez argumentu a řekne vám to aktuální výchozí prohlížeč. Tím se nastaví obsluha XDG, takže se podle toho neřídí jen klávesové zkratky Omarchy — cokoli, co otevírá odkaz, od chatovací aplikace po příkaz v terminálu, přejde do prohlížeče, který jste vybrali.

## Copy URL a Download Video

Prohlížeče z rodiny Chromium (samotný Chromium, Chrome, Edge, Brave a Brave Origin) přicházejí se třemi rozšířeními Omarchy: dvěma, která sahají ven z prohlížeče do zbytku vašeho systému, a jedním, které uklízí WhatsApp.

**Copy URL** umístí adresu aktuální karty do vaší schránky pomocí `Alt + Shift + L`. Je to rychlejší než klikat do adresního řádku a kopírovat, a protože to prochází systémovou schránkou, a ne schránkou prohlížeče, dostanete potvrzení v podobě oznámení Omarchy a adresa URL je okamžitě k dispozici v [historii schránky](08-unified-clipboard-history.md) a v každé další aplikaci. Pokud dáváte přednost klikání, je tu i tlačítko na panelu nástrojů.

**Download Video** pomocí `Alt + Shift + D` vezme video přehrávané na stránce, na kterou se díváte. Předá adresu URL nástroji [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na mnohem víc než jen YouTube, a stažený soubor skončí v `~/Videos`. Průběh se zobrazuje ve stejném překryvném zobrazení na obrazovce, které používají hlasitost a jas, a aktualizuje se na místě, místo aby skládal oznámení na sebe. Nastavte `OMARCHY_YTDLP_DIR`, pokud byste raději soubory ukládali jinam — kde se proměnné prostředí nastavují, najdete v [FAQ](46-faq.md).

Obě rozšíření komunikují s Omarchy přes malého nativního hostitele pro zprávy, který se vám nainstaluje spolu s prohlížečem. To je ta součást, díky které může video z webové stránky skončit ve vašem domovském adresáři a adresa URL ve vašem správci schránky, což běžné rozšíření samo o sobě nedokáže.

**WhatsApp Slim** přiměje WhatsApp Web řídit se motivem vašeho systému a sbalí jeho seznam chatů, když je okno úzké.

Tato rozšíření jsou pouze pro rodinu Chromium. Firefox a Zen je nedostanou.

## Firefox a Zen

Firefox a Zen jsou jiná rodina, takže se s nimi zachází jinak: Omarchy jim nainstaluje soubor zásad pro rozumná výchozí nastavení a přepne je do nativního režimu Wayland, který chcete kvůli frakčnímu škálování a plynulému posouvání trackpadem.

Nedostanou výše uvedená rozšíření Chromium a Omarchy jim nenastavuje motiv, takže tyto části zážitku si musíte nastavit sami.

## Ladybird

Ladybird je prohlížeč napsaný od nuly, s vlastním jádrem, a ne s jádrem Chromium nebo Firefoxu. Stále je v alfě, takže počítejte se stránkami, které ještě nefungují, a Omarchy ho instaluje tak, jak je: žádná rozšíření, žádný motiv, žádné zásady. Nemá ani soukromé okno, takže `Super + Shift + Alt + B` ho otevře s dočasným profilem, který se po zavření smaže. [Webové aplikace](25-web-apps.md) dál běží v Chrome nebo Chromium.

## Odebrání jednoho z nich

Kterýkoli z těchto prohlížečů, včetně Chrome, můžete znovu odebrat pod _Odebrat > Prohlížeč_. Odkazy pak přejdou na Chrome nebo Chromium, pokud je ten druhý stále nainstalovaný.
