# Horní lišta

Pruh podél horní části obrazovky je lišta Omarchy. Není to přišroubovaná stavová lišta, ale součást shellu Omarchy, jediného dlouho běžícího procesu Quickshell, který kreslí i menu, oznámení, vyskakovací OSD okna a zamykací obrazovku. Proto dokonale ladí se vším ostatním a proto se panel otevře okamžitě, místo aby spouštěl novou aplikaci.

Je to taky jediná část plochy, která je pořád na obrazovce, takže stojí za to vědět, co všechny ty malé glyfy dělají.

## Co je na ní ve výchozím stavu

Lišta má tři sekce. Vlevo sedí logo Omarchy (spouštěč menu) a indikátory pracovních ploch. Uprostřed máte stavové indikátory, hodiny, Elsewhen (světové hodiny), počasí a odznak aktualizace Omarchy. Vpravo: systémová oblast, rozložení klávesnice (když je nakonfigurováno víc než jedno), agenti, bluetooth, síť, zvuk, displej a napájení.

Několik z nich se objeví jen tehdy, když mají co říct. Rozložení klávesnice se objeví jen tehdy, pokud jste nakonfigurovali víc než jedno rozložení. Odznak aktualizace se objeví jen tehdy, když čeká aktualizace Omarchy. A ikona agentů se objeví poprvé, když Omarchy na počítači najde využití AI kódování (viz [AI](17-ai.md)).

## Klikání po liště

Skoro každý widget něco dělá při levém, pravém a prostředním kliknutí a několik jich reaguje na rolování. Tohle je část, která lidem uniká — pod pravým a prostředním tlačítkem se skrývá spousta těch dobrých věcí.

| Widget | Levý klik | Pravý klik | Prostřední klik / rolování |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nový terminál | — |
| Pracovní plochy | Zaměřit danou pracovní plochu na tomto monitoru | — | Rolování: další/předchozí pracovní plocha |
| Hodiny | Vyskakovací kalendář | Přepnout formát popisku | Prostřední: výběr časového pásma |
| Počasí | Vyskakovací předpověď | Úplné počasí jako oznámení | Prostřední: obnovit |
| Zvuk | Panel zvuku | Ztlumit | Prostřední: panel · rolování: hlasitost |
| Mikrofon | Ztlumit mikrofon | — | Prostřední: panel zvuku · rolování: vstupní hlasitost |
| Síť | Panel sítě | — | — |
| Bluetooth | Panel Bluetooth | Přepnout vysílač | — |
| Displej | Panel displeje | — | Rolování: jas |
| Napájení | Panel napájení | Přepnout procenta baterie | — |
| Média | Přehrát/pozastavit | Vyskakovací okno s obalem alba | Prostřední: další · rolování: předchozí/další |
| Agenti | Panel agentů | Spustit vašeho agenta | Prostřední: další předplatné |
| Systémová oblast | Najetím myši odhalíte zásuvku | Pravý klik na šipku pro správu | — |
| Aktualizace Omarchy | Spustit aktualizaci | — | — |

Ne všechno v té tabulce máte na liště hned po vybalení. Widget médií (právě hrající MPRIS, s posouvající se skladbou a interpretem) a widget mikrofonu jsou oba vestavěné, ale ve výchozím stavu vypnuté — přidejte si je, pokud je chcete, jak je popsáno níže.

## Panely

Kliknutí na ikonu na liště otevře panel, což je pořádné vyskakovací okno s posuvníky, seznamy a ovládáním z klávesnice, ne jen tooltip. Každý má taky klávesovou zkratku, takže nikdy nemusíte mířit na 16pixelový glyf:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Panely nejsou jen výpisy. Právě v nich tu věc skutečně uděláte:

- **Audio** has a master volume slider, an output-device picker, and a per-app mixer, so you can turn down that one browser tab without touching everything else.
- **Network** scans for Wi-Fi, shows signal strength, connects, and lets you pick a DNS provider.
- **Bluetooth** lists your devices with connect/disconnect and battery levels.
- **Power** shows battery stats, switches power profiles (it remembers a separate choice for battery and AC), and prints some system info.
- **Display** carries a brightness slider, text size, monitor scaling presets, and — when you have more than one screen — per-monitor controls. See [monitors](33-monitors.md) for the deeper story.
- **Clock** opens a month grid with ISO week numbers and month stepping.
- **World clock** keeps a row per city, with its weather and how its day is going. Search finds towns as well as time zones, so Fort Lauderdale is Fort Lauderdale and not New York. If the line at the top names the wrong city, click it and say where you are; pick somewhere on another time zone and the system clock moves there too, which is handy when you travel. Hover a city and click the person button to say who lives there — plain names, or `@` GitHub handles to bring their faces along.

Každý panel bere klávesnici stejně jako myš: šipky se pohybují, Return aktivuje, Tab přeskočí na sousední panel a Escape zavře.

`Super + Ctrl + 1-9` počítá panely zleva doprava v pravé sekci a přeskakuje systémovou oblast, protože ta nemá vlastní panel. Takže číslo odpovídá ikoně, na kterou byste ukázali.

### Tailscale a Dropbox

Další dva widgety se na liště objeví, až když si z **Install → Service** nainstalujete odpovídající službu, a oba stojí za to znát, protože dělají víc než jen hlásí stav.

Panel **Tailscale** připojuje a odpojuje tailnet, přepíná mezi účty a vybírá exit node (v tom seznamu se objeví vaše vlastní stroje i regiony Mullvadu). Taky prochází vaše stroje — a když je jeden vybraný, `s` mu pošle soubory přes Taildrop, což je nejrychlejší způsob, jak přesunout soubor do telefonu nebo jiného laptopu. `c` zkopíruje IP stroje, `n` jeho název a `d` jeho úplný název DNS. Na každém řádku stroje je taky tlačítko pro odeslání, pokud raději klikáte. Totéž z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** řeší přihlášení, ukazuje, kolik úložiště jste využili, a vypisuje nedávno synchronizované soubory.

Odstranění kterékoli služby stáhne její widget z lišty zase pryč.

## Indikátory

Malý shluk uprostřed je widget indikátorů. Jsou to stavové glyfy pro režimy, které jste zapnuli: nerušit, noční osvětlení, zařazené [připomenutí](09-reminders.md), aktivní nahrávání obrazovky, zůstat vzhůru a [diktování](11-text-extraction-dictation.md). Rozsvítí se, když je režim aktivní, a jinak zůstávají stranou — najeďte kamkoli na lištu, abyste se podívali na ty neaktivní. Kliknutí na indikátor daný režim přepne. Jeden další je pouze stavový: vzdálená relace svítí červeně, zatímco je k tomuto stroji přes gliff někdo připojen.

Pokud byste raději, aby byly vždy viditelné, nastavte u widgetu `alwaysShow` na `true`. A pokud vám záleží jen na některých z nich, uveďte ty, které chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Widgetů indikátorů můžete mít víc než jeden, takže různé sekce mohou zobrazovat různé podmnožiny.

## Přeskupení lišty

Lišta se konfiguruje sama. Nemusíte kvůli přesouvání věcí otevírat konfigurační soubor.

Chyťte prázdné místo na liště kolem středu a táhněte je k jinému okraji obrazovky a lišta se tam přesune — doleva, doprava, nahoru i dolů to všechno funguje a každý widget se přizpůsobí (svislé lišty se vrátí ke kompaktním formám pouze s ikonami). Kliknutí a podržení spustí stejné tažení. Dvojitý levý klik na totéž prázdné místo přepne pozadí lišty z čirého na skleněné na neprůhledné. A táhněte libovolný widget, abyste změnili jeho pořadí nebo ho hodili do jiné sekce; ostatní widgety se rozestoupí, aby udělaly místo tam, kam dopadne.

Střed lišty je box: cokoli je v něm, zůstává vycentrované jako jedna skupina a widgety po jeho obou stranách visí na jeho okrajích. Zatímco táhnete widget, box se ukáže jako obrys, nebo jako čára přes lištu, když je prázdný, a můžete pustit do něj nebo vedle něj. Když by puštění dopadlo do boxu, box se zvětší, aby widget přijal.

Widget, který chcete mít po ruce, ale ne vždy na očích, může jít do zásuvky systémové oblasti: táhněte ho na systémovou oblast a zásuvka se otevře, aby ho přijala. Sedí tam za ikonami aplikací, objeví se, kdykoli se objeví zásuvka, a nechá svou zásuvku otevřenou, zatímco je jeho panel nahoře. Táhněte ho zpět na lištu, abyste ho vrátili.

Pokud byste raději vybírali z menu, **Appearance → Menu Bar** má pozici a **Bar Background** vybírá, jak se lišta kreslí: **Opaque Bar**, **Glassy Bar** (průhledná, s tím, co je za ní, rozmazaným) nebo **Clear Bar**.

Tytéž věci mají příkazy, což je to, co chcete pro nastavení [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Chcete-li widget úplně přidat nebo odebrat, použijte příkazy pluginů. `omarchy plugin list` vytiskne každý widget, který shell zná, s jeho id, a pak:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrytí lišty

`Super + Shift + Space` přepne lištu pryč a zase zpět, aniž by zabil shell — panely a klávesové zkratky dál fungují, jen získáte zpět pixely. Je to taky v menu pod **Appearance → Menu Bar → Hide Bar**.

## Konfigurační soubor

Všechno je uloženo v `~/.config/omarchy/shell.json`, pod klíčem `bar`. Tady je ořezaná verze:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Každý widget je jeden záznam v jednom z pěti polí rozložení a jeho nastavení sedí přímo na tom záznamu — není žádný samostatný soubor nastavení a žádný podobjekt `config`. `format`, `formatAlt` (na co přepne pravý klik) a `verticalFormat` hodin žijí všechny přímo tam na `{ "id": "omarchy.clock" }`.

`center` je box uprostřed lišty: všechno v něm je vycentrováno na obrazovce jako jedna skupina. `centerBegin` a `centerEnd` visí po obou stranách boxu, což je způsob, jak hodiny zůstávají přesně uprostřed, i když počasí a odznak aktualizace přicházejí a odcházejí. Dejte do `center` víc než jeden widget a budou vycentrovány společně; nechte ho prázdný a `centerBegin` a `centerEnd` se setkají uprostřed lišty.

Jedno pravidlo, které stojí za to si vštípit: **jakmile máte vlastní `shell.json`, je kanonický**. Dokud si nic nepřizpůsobíte, shell čte výchozí soubor Omarchy. V okamžiku, kdy přetáhnete widget, spustíte `omarchy bar` nebo sami upravíte soubor, vlastníte ho vy — nedochází k žádnému hlubokému slučování, takže nové výchozí widgety v budoucích vydáních Omarchy se na vaší liště neobjeví automaticky. `omarchy bar defaults` vrátí dodávané rozložení, kdykoli chcete čistý štít.

Tentýž soubor taky drží vaše časování nečinnosti na nejvyšší úrovni, mimo klíč `bar`: `idle.screensaver` a `idle.lock`, obojí v sekundách od chvíle, kdy jste přestali být aktivní. Takže výchozí spořič obrazovky naskočí po 150 sekundách a zámek po 300.
