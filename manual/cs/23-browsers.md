# Prohlížeče

Omarchy se dodává s [Google Chrome](https://www.google.com/chrome/) jako výchozím prohlížečem. Je motivem sladěný se zbytkem vašeho systému a právě ten se otevírá pomocí `Super + Shift + Return` (nebo `Super + Shift + B`), pomocí `Super + Shift + Alt + B` pro soukromé okno, a právě v něm běží každá [webová aplikace](25-web-apps.md). Otevírá se rovnou do okna prohlížeče: žádná uvítací obrazovka ani výzva k přihlášení, statistiky používání a hlášení o pádech se Googlu neodesílají a výzvy ohledně soukromí v reklamách jsou vypnuté. Ke svému účtu Google se přesto můžete kdykoli přihlásit tlačítkem profilu, když budete chtít synchronizaci.

Pokud Chrome není podle vašeho gusta, nemusíte u něj zůstat. V nabídce Omarchy v části _Install > Browser_ najdete [Chromium](https://www.chromium.org/) (obyčejnou open-source verzi, ze které je Chrome postavený), Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/) (Edge pouze na počítačích x86). Vyberte si jeden a Omarchy ho nainstaluje, nastaví mu adresář zásad a použije na něj váš aktuální motiv.

## Nastavení jednoho jako výchozího

Instalací prohlížeče se z něj výchozí nestane. Pro přepnutí přejděte do _Setup > Defaults > Browser_ a jeden vyberte. Aktuální výchozí prohlížeč je označený fajfkou a výběr prohlížeče, který ještě nemáte, ho nejprve nainstaluje.

Z terminálu je to:

```bash
omarchy default browser firefox
```

Spusťte ho bez argumentu a řekne vám aktuální výchozí prohlížeč. Tím se nastaví XDG handler, takže se tím neřídí jen klávesové zkratky Omarchy — cokoli, co otevírá odkaz, od chatovací aplikace po příkaz v terminálu, půjde do prohlížeče, který jste vybrali.

## Copy URL a Download Video

Prohlížeče z rodiny Chromium (samotné Chromium, Chrome, Edge, Brave a Brave Origin) přicházejí se třemi rozšířeními Omarchy: dvěma, která sahají ven z prohlížeče do zbytku vašeho systému, a jedním, které dává do pořádku WhatsApp.

**Copy URL** vloží adresu aktuální karty do vaší schránky pomocí `Alt + Shift + L`. Je to rychlejší než klikat do adresního řádku a kopírovat, a protože to jde přes systémovou schránku, a ne přes schránku prohlížeče, dostanete potvrzení v podobě oznámení Omarchy a URL je okamžitě dostupná v [historii schránky](08-unified-clipboard-history.md) a v každé další aplikaci. Pokud raději klikáte, je tu i tlačítko na panelu nástrojů.

**Download Video** stáhne video přehrávané na stránce, na kterou se díváte, pomocí `Alt + Shift + D`. Předá URL nástroji [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na mnohem více než jen na YouTube, a stažený soubor skončí v `~/Videos`. Průběh se zobrazuje ve stejném zobrazení na obrazovce, které používá hlasitost a jas, a aktualizuje se na místě, místo aby se hromadila oznámení. Nastavte `OMARCHY_YTDLP_DIR`, pokud chcete, aby soubory šly jinam — kde se proměnné prostředí nastavují, najdete ve [FAQ](46-faq.md).

Obě rozšíření komunikují s Omarchy přes malého native messaging hosta, který se vám nainstaluje spolu s prohlížečem. To je ten dílek, díky kterému může video z webové stránky skončit ve vašem domovském adresáři a URL ve vašem správci schránky, což běžné rozšíření samo o sobě nedokáže.

**WhatsApp Slim** zajistí, že WhatsApp Web následuje váš systémový motiv, a sbalí jeho seznam chatů, když je okno úzké.

Ty jsou pouze pro rodinu Chromium. Firefox a Zen je nedostanou.

## Firefox a Zen

Firefox a Zen jsou jiná rodina, takže se k nim přistupuje jinak: Omarchy nainstaluje soubor zásad pro rozumná výchozí nastavení a přepne je do nativního režimu Wayland, který chcete pro frakční škálování a plynulé posouvání trackpadem.

Nedostanou výše uvedená rozšíření Chromium a Omarchy jim nenastavuje motiv, takže tyto části zážitku si musíte nastavit sami.

## Opětovné odstranění

Kterýkoli z těchto prohlížečů, včetně Chrome, můžete zase odebrat v části _Remove > Browser_. Odkazy pak půjdou do Chrome nebo Chromium, pokud je ten druhý stále nainstalovaný.
