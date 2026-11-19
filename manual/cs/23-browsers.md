# Prohlížeče

Omarchy se dodává s [Google Chrome](https://www.google.com/chrome/) jako výchozím prohlížečem. Je sladěný se zbytkem vašeho systému a právě ten se otevírá klávesami `Super + Shift + Return` a běží v něm každá [webová aplikace](25-web-apps.md). Otevírá se rovnou do okna prohlížeče: neuvidíte žádnou uvítací obrazovku ani výzvu k přihlášení, statistiky používání a zprávy o pádech se neodesílají do Googlu a výzvy týkající se soukromí u reklam jsou vypnuté. Ke svému účtu Google se stále můžete kdykoli přihlásit přes tlačítko profilu, pokud chcete synchronizaci.

Pokud vám Chrome nesedí, nemusíte u něj zůstat. V nabídce Omarchy pod _Install > Browser_ najdete [Chromium](https://www.chromium.org/) (prostou open-source podobu, ze které Chrome vychází), Edge, Brave, Brave Origin, Firefox a [Zen](https://zen-browser.app/). Vyberte si jeden a Omarchy ho nainstaluje, nastaví jeho adresář se zásadami a použije na něj váš aktuální motiv.

## Nastavení jednoho jako výchozího

Nainstalování prohlížeče z něj ještě nedělá výchozí. Jakmile je v počítači, přejděte do _Setup > Defaults > Browser_ a vyberte ho — nabídka zobrazuje pouze prohlížeče, které máte skutečně nainstalované, a aktuální výchozí označuje fajfkou.

Z terminálu to uděláte takto:

```bash
omarchy default browser firefox
```

Spusťte příkaz bez argumentu a řekne vám aktuální výchozí prohlížeč. Nastaví to obslužnou rutinu XDG, takže na to nereagují jen klávesové zkratky Omarchy — cokoli, co otevírá odkaz, od chatovací aplikace po příkaz v terminálu, přejde do prohlížeče, který jste si vybrali.

## Copy URL a Download Video

Prohlížeče z rodiny Chromium (samotné Chromium, Chrome, Edge a Brave) přicházejí se dvěma rozšířeními Omarchy, která sahají ven z prohlížeče do zbytku vašeho systému.

**Copy URL** vloží adresu aktuální karty do vaší schránky pomocí `Alt + Shift + L`. Je to rychlejší než klikat do adresního řádku a kopírovat z něj, a protože to prochází přes systémovou schránku, a ne přes schránku prohlížeče, dostanete potvrzení v podobě oznámení Omarchy a adresa URL je okamžitě k dispozici v [historii schránky](08-unified-clipboard-history.md) a v každé další aplikaci. Pokud dáváte přednost klikání, je tu i tlačítko na panelu nástrojů.

**Download Video** stáhne video přehrávané na stránce, na kterou se díváte, pomocí `Alt + Shift + D`. Předá adresu URL nástroji [yt-dlp](https://github.com/yt-dlp/yt-dlp), takže funguje na mnohem více místech než jen na YouTube, a stahování skončí v `~/Videos`. Průběh se zobrazuje ve stejném zobrazení na obrazovce, které používají hlasitost a jas, a aktualizuje se na místě, místo aby skládalo oznámení na sebe. Nastavte `OMARCHY_YTDLP_DIR`, pokud chcete, aby soubory chodily někam jinam — v [FAQ](46-faq.md) najdete, kam umístit proměnné prostředí.

Obě rozšíření komunikují s Omarchy prostřednictvím malého nativního hostitele zpráv, který se vám nainstaluje spolu s prohlížečem. To je ta součást, díky které může video z webové stránky skončit ve vašem domovském adresáři a adresa URL ve vašem správci schránky, což běžné rozšíření samo o sobě nedokáže.

Tato rozšíření jsou pouze pro rodinu Chromium. Firefox a Zen je nedostanou.

## Firefox a Zen

Firefox a Zen jsou jiná rodina, takže se s nimi zachází jinak: Omarchy nainstaluje soubor se zásadami pro rozumná výchozí nastavení a přepne je do nativního režimu Wayland, který chcete kvůli škálování s desetinnými hodnotami a plynulému posouvání trackpadem.

Nedostanou výše uvedená rozšíření pro Chromium a Omarchy je neladí motivem, takže tyhle části si musíte nastavit sami.

## Opětovné odstranění

Kterýkoli z těchto prohlížečů, včetně Chrome, můžete zase odebrat pod _Remove > Browser_. Odkazy pak povedou do Chrome nebo Chromium, pokud je ten druhý stále nainstalovaný.
