# Horní panel

Pruh podél horní části obrazovky je panel Omarchy. Není to přišroubovaná stavová lišta, ale součást shellu Omarchy, jediného dlouhodobě běžícího procesu Quickshell, který kreslí také nabídku, oznámení, vyskakovací okna OSD a zamykací obrazovku. Proto se dokonale stylizuje se vším ostatním a proto se panel otevře okamžitě, místo aby spouštěl novou aplikaci.

Je to také jediný kus plochy, který je vždy na obrazovce, takže stojí za to vědět, co všechny ty malé glyfy dělají.

## Co je na něm ve výchozím nastavení

Panel má tři sekce. Vlevo sedí logo Omarchy (spouštěč nabídky) a ukazatele pracovních ploch. Uprostřed máte stavové ukazatele, hodiny, Elsewhen (světové hodiny), počasí a odznak aktualizace Omarchy. Vpravo: rozložení klávesnice (když je nakonfigurováno více než jedno), systémová lišta, agenti, bluetooth, síť, zvuk, displej a napájení.

Několik z nich se objeví, jen když mají co říct. Rozložení klávesnice se objeví, jen pokud jste nakonfigurovali více než jedno rozložení. Odznak aktualizace se objeví, jen když čeká aktualizace Omarchy. A ikona agentů se objeví, když Omarchy poprvé najde na počítači používání AI pro kódování (viz [AI](17-ai.md)).

## Klikání kolem

Téměř každý widget dělá něco při levém, pravém a prostředním kliknutí a několik jich reaguje na posouvání. To je část, kterou lidé přehlížejí — pravé a prostřední tlačítko je místo, kde se skrývá spousta dobrých věcí.

| Widget | Vlevo | Vpravo | Prostřední / posouvání |
| --- | --- | --- | --- |
| Nabídka | Nabídka Omarchy | Nový terminál | — |
| Pracovní plochy | Zaměřit danou pracovní plochu | — | Posouvání: další/předchozí pracovní plocha |
| Hodiny | Vyskakovací kalendář | Přepnout formát popisku | Prostřední: výběr časového pásma |
| Počasí | Vyskakovací předpověď | Úplné počasí jako oznámení | Prostřední: obnovit |
| Zvuk | Panel zvuku | Ztlumit | Prostřední: panel · posouvání: hlasitost |
| Mikrofon | Ztlumit mikrofon | — | Prostřední: panel zvuku · posouvání: vstupní hlasitost |
| Síť | Panel sítě | — | — |
| Bluetooth | Panel Bluetooth | Přepnout rádio | — |
| Displej | Panel displeje | — | Posouvání: jas |
| Napájení | Panel napájení | Přepnout procenta baterie | — |
| Média | Přehrát/pozastavit | Vyskakovací obal alba | Prostřední: další · posouvání: předchozí/další |
| Agenti | Panel agentů | Spustit vašeho agenta | Prostřední: další předplatné |
| Lišta | Najeďte pro odhalení zásuvky | Pravé kliknutí na šipku pro správu | — |
| Aktualizace Omarchy | Spustit aktualizaci | — | — |

Ne všechno v této tabulce je na vašem panelu hned po vybalení. Widget médií (nyní přehrávané MPRIS s posouvající se skladbou a interpretem) i widget mikrofonu jsou zabudované, ale ve výchozím nastavení vypnuté — přidejte je, pokud je chcete, jak je popsáno níže.

## Panely

Kliknutím na ikonu panelu se otevře panel, což je řádné vyskakovací okno s posuvníky, seznamy a navigací z klávesnice, nikoli popisek. Každý má také klávesovou zkratku, takže nikdy nemusíte mířit na 16pixelový glyf:

| Klávesová zkratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + W` | Síť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájení |
| `Super + Ctrl + Alt + D` | Kalendář |
| `Super + Ctrl + Alt + E` | Světové hodiny |
| `Super + Ctrl + 1-9` | Přepnout n-tý panel v pravé sekci |

Panely nejsou jen výpisy. Jsou místem, kde danou věc skutečně uděláte:

- **Zvuk** má hlavní posuvník hlasitosti, výběr výstupního zařízení a mixér pro jednotlivé aplikace, takže můžete ztlumit tu jednu záložku prohlížeče, aniž byste se dotkli všeho ostatního.
- **Síť** vyhledává Wi-Fi, zobrazuje sílu signálu, připojuje se a umožňuje vám vybrat poskytovatele DNS.
- **Bluetooth** uvádí vaše zařízení s připojením/odpojením a úrovněmi baterie.
- **Napájení** zobrazuje statistiky baterie, přepíná profily napájení (pamatuje si samostatnou volbu pro baterii a AC) a vypisuje některé informace o systému.
- **Displej** obsahuje posuvník jasu, velikost textu, předvolby škálování monitoru a — když máte více než jednu obrazovku — ovládací prvky pro jednotlivé monitory. Podrobnější příběh viz [monitory](33-monitors.md).
- **Hodiny** otevírají mřížku měsíce s čísly týdnů ISO a krokováním po měsících.

Každý panel přijímá klávesnici stejně jako myš: šipky se pohybují, Return aktivuje, Tab přejde na sousední panel a Escape zavře.

`Super + Ctrl + 1-9` počítá panely zleva doprava v pravé sekci, přičemž přeskakuje lištu, protože nemá vlastní panel. Číslo tedy odpovídá ikoně, na kterou byste ukázali.

### Tailscale a Dropbox

Další dva widgety se na panelu objeví, až když nainstalujete odpovídající službu z **Instalovat → Služba**, a oba stojí za to znát, protože dělají víc než jen hlásí stav.

Panel **Tailscale** připojuje a odpojuje tailnet, přepíná mezi účty a vybírá výstupní uzel (v seznamu se objevují vaše vlastní počítače i regiony Mullvadu). Prochází také vaše počítače — a když je jeden vybrán, `s` mu pošle soubory přes Taildrop, což je nejrychlejší způsob, jak přesunout soubor do telefonu nebo jiného notebooku. `c` zkopíruje IP počítače, `n` jeho název a `d` jeho úplné jméno DNS. Na každém řádku počítače je také tlačítko pro odeslání, pokud raději klikáte. Totéž z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** zajišťuje přihlášení, zobrazuje, kolik úložiště jste využili, a uvádí nedávno synchronizované soubory.

Odebráním kterékoli služby se její widget z panelu opět odstraní.

## Ukazatele

Malý shluk uprostřed je widget ukazatelů. Jsou to stavové glyfy pro režimy, které jste zapnuli: nerušit, noční světlo, zařazená [připomínka](09-reminders.md), aktivní nahrávání obrazovky, zůstat vzhůru a [diktování](11-text-extraction-dictation.md). Rozsvítí se, když je režim aktivní, a jinak zůstávají stranou — najeďte nalevo od hodin (nad nimi na svislém panelu) a nahlédněte na neaktivní. Kliknutím na ukazatel daný režim přepnete. Ještě jeden je pouze stavový: vzdálená relace svítí červeně, zatímco je někdo připojen k tomuto počítači přes gliff.

Pokud byste je raději měli vždy viditelné, nastavte na widgetu `alwaysShow` na `true`. A pokud vám záleží jen na některých, uveďte ty, které chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Můžete mít více než jeden widget ukazatelů, takže různé sekce mohou zobrazovat různé podmnožiny.

## Přeskupení panelu

Panel se konfiguruje sám. Pro přesouvání věcí nemusíte otevírat konfigurační soubor.

Uchopte prázdný kus panelu kolem středu a přetáhněte ho směrem k jinému okraji obrazovky a panel se tam přesune — vlevo, vpravo, nahoře i dole funguje a každý widget se přizpůsobí (svislé panely se vracejí ke kompaktním formám pouze s ikonami). Kliknutí a podržení zahájí stejné přetažení. Dvojitým levým kliknutím na totéž prázdné místo přepnete pozadí panelu z průhledného na skleněné a neprůhledné. A přetáhněte jakýkoli widget, chcete-li změnit jeho pořadí, nebo ho hoďte do jiné sekce.

Widget, který chcete mít po ruce, ale ne stále na očích, může jít do zásuvky systémové lišty: přetáhněte ho na lištu a zásuvka se otevře, aby ho přijala. Sedí tam za ikonami aplikací, objeví se pokaždé, když se objeví zásuvka, a zásuvku drží otevřenou, dokud je otevřený jeho panel. Přetáhněte ho zpět ven na panel a vrátí se zpět.

Pokud si raději vybíráte z nabídky, **Akce → Vzhled → Panel** má polohu a **Pozadí panelu** vybírá, jak je panel vykreslen: **Neprůhledný panel**, **Skleněný panel** (průhledný, s rozmazáním toho, co je za ním), nebo **Průhledný panel**.

Tytéž věci mají příkazy, což je to, co chcete pro nastavení [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Chcete-li widget zcela přidat nebo odebrat, použijte příkazy pluginů. `omarchy plugin list` vypíše každý widget, který shell zná, s jeho id, a pak:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Skrývání panelu

`Super + Shift + Space` přepne panel vypnuto a zase zapnuto, aniž by zabilo shell — panely a klávesové zkratky dál fungují, jen získáte pixely zpět. Je to také v nabídce pod **Akce → Vzhled → Panel → Skrýt panel**.

## Konfigurační soubor

Vše je uloženo v `~/.config/omarchy/shell.json` pod klíčem `bar`. Tady je zkrácená verze:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Každý widget je jedna položka v jednom ze tří polí rozložení a jeho nastavení sedí přímo na této položce — neexistuje žádný samostatný soubor nastavení ani žádný podobjekt `config`. `format` hodin, `formatAlt` (to, na co přepne pravé kliknutí) a `verticalFormat` všechny žijí právě tam na `{ "id": "omarchy.clock" }`.

`centerAnchor` pojmenovává jeden středový widget, který se připne přesně do středu obrazovky a ostatní ho lemují. Tak zůstávají hodiny přesně uprostřed, i když počasí a odznak aktualizace přicházejí a odcházejí. Nastavte ho na prázdný řetězec a středový seznam se místo toho vycentruje jako skupina.

Jedno pravidlo, které stojí za to si osvojit: **jakmile máte vlastní `shell.json`, je kanonický**. Dokud nic nepřizpůsobíte, shell čte výchozí soubor Omarchy. V okamžiku, kdy přetáhnete widget, spustíte `omarchy bar` nebo sami upravíte soubor, vlastníte ho — nedochází k žádnému hlubokému slučování, takže nové výchozí widgety v budoucích verzích Omarchy se na vašem panelu neobjeví automaticky. `omarchy bar defaults` vrátí dodávané rozložení, kdykoli budete chtít čistý štít.

Tentýž soubor obsahuje také vaše časování nečinnosti na nejvyšší úrovni, mimo klíč `bar`: `idle.screensaver` a `idle.lock`, obojí v sekundách od chvíle, kdy jste se stali nečinnými. Takže výchozí spořič obrazovky naskočí po 150 sekundách a zámek po 300.
