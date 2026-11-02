# Horní lišta

Pruh podél horní části obrazovky je lišta Omarchy. Není to přišroubovaná stavová lišta, ale součást shellu Omarchy, jediného dlouho běžícího procesu Quickshell, který kreslí i nabídku, oznámení, vyskakovací OSD okna a zamykací obrazovku. Proto dokonale ladí se vším ostatním a proto se panel otevře okamžitě, místo aby spouštěl novou aplikaci.

Je to taky jediná část plochy, která je pořád na obrazovce, takže stojí za to vědět, co všechny ty malé glyfy dělají.

## Co je na ní ve výchozím stavu

Lišta má tři sekce. Vlevo sedí logo Omarchy (spouštěč nabídky) a ukazatele pracovních ploch. Uprostřed máte stavové ukazatele, hodiny, Elsewhen (světové hodiny), počasí a odznak aktualizace Omarchy. Vpravo: oznamovací oblast, rozložení klávesnice (když je nakonfigurováno víc než jedno), agenti, bluetooth, síť, zvuk, displej a napájení.

Několik z nich se objeví jen tehdy, když mají co říct. Rozložení klávesnice se objeví jen tehdy, pokud jste nakonfigurovali víc než jedno rozložení. Odznak aktualizace se objeví jen tehdy, když čeká aktualizace Omarchy. A ikona agentů se objeví, jakmile Omarchy na počítači poprvé zjistí používání AI nástrojů pro programování (viz [AI](17-ai.md)).

## Klikání po liště

Skoro každý widget něco dělá při levém, pravém a prostředním kliknutí a několik jich reaguje na rolování. Tohle je část, která lidem uniká — pod pravým a prostředním tlačítkem se skrývá spousta těch dobrých věcí.

| Widget | Levý klik | Pravý klik | Prostřední klik / rolování |
| --- | --- | --- | --- |
| Nabídka | Nabídka Omarchy | Nový terminál | — |
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
| Oznamovací oblast | Najetím myši odhalíte zásuvku | Pravý klik na šipku pro správu | — |
| Aktualizace Omarchy | Spustit aktualizaci | — | — |

Ne všechno v té tabulce máte na liště hned po vybalení. Widget médií (právě hrající MPRIS, s posouvající se skladbou a interpretem) a widget mikrofonu jsou oba vestavěné, ale ve výchozím stavu vypnuté — přidejte si je, pokud je chcete, jak je popsáno níže.

## Panely

Kliknutí na ikonu na liště otevře panel, což je pořádné vyskakovací okno s posuvníky, seznamy a ovládáním z klávesnice, ne jen popisek. Každý má taky klávesovou zkratku, takže nikdy nemusíte mířit na 16pixelový glyf:

| Klávesová zkratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Síť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájení |
| `Super + Ctrl + Alt + D` | Kalendář |
| `Super + Ctrl + Alt + E` | Světové hodiny |
| `Super + Ctrl + 1-9` | Přepnout n-tý panel v pravé sekci |

Panely nejsou jen výpisy. Právě v nich tu věc skutečně uděláte:

- **Zvuk** má hlavní posuvník hlasitosti, výběr výstupního zařízení a mixér pro jednotlivé aplikace, takže můžete ztlumit jednu kartu prohlížeče, aniž byste sahali na všechno ostatní.
- **Síť** vyhledává sítě Wi-Fi, ukazuje sílu signálu, připojuje se a umožňuje vybrat poskytovatele DNS.
- **Bluetooth** vypisuje vaše zařízení s možností připojit/odpojit a s úrovní baterie.
- **Napájení** ukazuje statistiky baterie, přepíná profily napájení (pro baterii a napájení ze sítě si pamatuje volbu zvlášť) a vypisuje některé informace o systému.
- **Displej** nabízí posuvník jasu, velikost textu, předvolby škálování monitoru a — pokud máte více obrazovek — ovládání jednotlivých monitorů. Podrobnosti najdete v kapitole [Monitory](33-monitors.md).
- **Hodiny** otevřou měsíční mřížku s čísly týdnů podle ISO a přepínáním měsíců.
- **Světové hodiny** mají řádek pro každé město s jeho počasím a s tím, jaká část dne tam právě je. Vyhledávání najde města i časová pásma, takže Fort Lauderdale je Fort Lauderdale, a ne New York. Pokud řádek nahoře uvádí špatné město, klikněte na něj a zadejte, kde jste; zvolíte-li místo v jiném časovém pásmu, přesunou se tam i systémové hodiny, což se hodí na cestách. Najeďte na město a kliknutím na tlačítko osoby zadejte, kdo tam žije — prostá jména, nebo přezdívky z GitHubu s `@`, které přinesou i jejich fotky.

Každý panel bere klávesnici stejně jako myš: šipky přesouvají výběr, Return aktivuje, Tab přeskočí na sousední panel a Escape zavře.

`Super + Ctrl + 1-9` počítá panely zleva doprava v pravé sekci a přeskakuje oznamovací oblast, protože ta nemá vlastní panel. Takže číslo odpovídá ikoně, na kterou byste ukázali.

### Tailscale a Dropbox

Další dva widgety se na liště objeví, až když si z _Instalovat > Služba_ nainstalujete odpovídající službu, a oba stojí za to znát, protože dělají víc než jen hlásí stav.

Panel **Tailscale** připojuje a odpojuje tailnet, přepíná mezi účty a vybírá exit node (v tom seznamu se objeví vaše vlastní stroje i regiony Mullvadu). Taky prochází vaše stroje — a když je jeden vybraný, `s` mu pošle soubory přes Taildrop, což je nejrychlejší způsob, jak přesunout soubor do telefonu nebo jiného laptopu. `c` zkopíruje IP stroje, `n` jeho název a `d` jeho úplný název DNS. Na každém řádku stroje je taky tlačítko pro odeslání, pokud raději klikáte. Totéž z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** řeší přihlášení, ukazuje, kolik úložiště jste využili, a vypisuje nedávno synchronizované soubory.

Odstranění kterékoli služby stáhne její widget z lišty zase pryč.

## Ukazatele

Malý shluk uprostřed je widget ukazatelů. Jsou to stavové glyfy pro režimy, které jste zapnuli: nerušit, noční světlo, naplánovaná [připomínka](09-reminders.md), aktivní nahrávání obrazovky, vypnuté zamykání a spořič a [diktování](11-text-extraction-dictation.md). Rozsvítí se, když je režim aktivní, a jinak zůstávají stranou — najeďte kamkoli na lištu, abyste se podívali na ty neaktivní. Kliknutí na ukazatel daný režim přepne. Jeden další je pouze stavový: vzdálená relace svítí červeně, zatímco je k tomuto stroji přes gliff někdo připojen.

Pokud byste raději, aby byly vždy viditelné, nastavte u widgetu `alwaysShow` na `true`. A pokud vám záleží jen na některých z nich, uveďte ty, které chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Widgetů ukazatelů můžete mít víc než jeden, takže různé sekce mohou zobrazovat různé podmnožiny.

## Přeskupení lišty

Lišta se konfiguruje sama. Nemusíte kvůli přesouvání věcí otevírat konfigurační soubor.

Chyťte prázdné místo na liště kolem středu a táhněte ho k jinému okraji obrazovky a lišta se tam přesune — doleva, doprava, nahoru i dolů to všechno funguje a každý widget se přizpůsobí (svislé lišty se vrátí ke kompaktním formám pouze s ikonami). Kliknutí a podržení spustí stejné tažení. Dvojitý levý klik na totéž prázdné místo přepne pozadí lišty z průhledného přes skleněné na neprůhledné. A táhněte libovolný widget, abyste změnili jeho pořadí nebo ho hodili do jiné sekce; ostatní widgety se rozestoupí, aby udělaly místo tam, kam dopadne.

Střed lišty je box: cokoli je v něm, zůstává vycentrované jako jedna skupina a widgety po jeho obou stranách visí na jeho okrajích. Zatímco táhnete widget, box se ukáže jako obrys, nebo jako čára přes lištu, když je prázdný, a widget můžete pustit do něj nebo vedle něj. Když by widget dopadl do boxu, box se zvětší, aby widget přijal.

Widget, který chcete mít po ruce, ale ne vždy na očích, může jít do zásuvky oznamovací oblasti: táhněte ho na oznamovací oblast a zásuvka se otevře, aby ho přijala. Sedí tam za ikonami aplikací, objeví se, kdykoli se objeví zásuvka, a nechá svou zásuvku otevřenou, dokud je jeho panel otevřený. Táhněte ho zpět na lištu, abyste ho vrátili.

Pokud byste raději vybírali z nabídky, _Vzhled > Lišta_ má polohu a _Pozadí lišty_ vybírá, jak se lišta kreslí: _Neprůhledná lišta_, _Skleněná lišta_ (průsvitná, s rozmazaným pozadím) nebo _Průhledná lišta_.

Tytéž věci mají příkazy, což je to, co chcete pro nastavení [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Chcete-li widget úplně přidat nebo odebrat, použijte příkazy pluginů. `omarchy plugin list` vypíše každý widget, který shell zná, s jeho id, a pak:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrytí lišty

`Super + Shift + Space` skryje a znovu zobrazí lištu, aniž by ukončila shell — panely a klávesové zkratky dál fungují, jen získáte zpět pixely. Je to taky v nabídce pod _Vzhled > Lišta > Skrýt lištu_.

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

Jedno pravidlo, které stojí za to si vštípit: **jakmile máte vlastní `shell.json`, je kanonický**. Dokud si nic nepřizpůsobíte, shell čte výchozí soubor Omarchy. V okamžiku, kdy přetáhnete widget, spustíte `omarchy bar` nebo sami upravíte soubor, vlastníte ho vy — nedochází k žádnému hlubokému slučování, takže nové výchozí widgety v budoucích vydáních Omarchy se na vaší liště neobjeví automaticky. `omarchy bar defaults` vrátí dodávané rozložení, kdykoli chcete začít od nuly.

Tentýž soubor taky drží vaše časování nečinnosti na nejvyšší úrovni, mimo klíč `bar`: `idle.screensaver` a `idle.lock`, obojí v sekundách od chvíle, kdy jste přestali být aktivní. Takže výchozí spořič obrazovky naskočí po 150 sekundách a zámek po 300.
