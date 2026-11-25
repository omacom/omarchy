# Horní lišta

Pruh podél horního okraje vaší obrazovky je lišta Omarchy. Není to přišroubovaná stavová lišta, ale součást shellu Omarchy, jediného dlouho běžícího procesu Quickshell, který kreslí i menu, oznámení, vyskakovací okna OSD a zamykací obrazovku. Proto se dokonale motivově sladí se vším ostatním a proto se panel otevře okamžitě, místo aby spouštěl novou aplikaci.

Je to také jediná část plochy, která je neustále na obrazovce, takže stojí za to vědět, co všechny ty malé glyfy dělají.

## Co je na ní ve výchozím nastavení

Lišta má tři sekce. Vlevo sedí logo Omarchy (spouštěč menu) a indikátory pracovních prostorů. Uprostřed dostanete stavové indikátory, hodiny, Elsewhen (světové hodiny), počasí a odznak aktualizace Omarchy. Vpravo: systémová oblast, rozložení klávesnice (když je nakonfigurováno více než jedno rozložení nebo metoda vstupu), agenti, bluetooth, síť, zvuk, displej a napájení.

Několik z nich se ukáže jen tehdy, když mají co říct. Rozložení klávesnice se objeví jen tehdy, pokud jste nakonfigurovali více než jedno rozložení nebo metodu vstupu. Odznak aktualizace se objeví jen tehdy, když čeká aktualizace Omarchy.

## Klikání všude možně

Téměř každý widget něco udělá při kliknutí levým, pravým a prostředním tlačítkem a několik jich reaguje na rolování. Tohle je část, která lidem uniká — pravé a prostřední tlačítko jsou místa, kde se skrývá spousta těch dobrých věcí.

| Widget | Levé | Pravé | Prostřední / rolování |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nový terminál | — |
| Pracovní prostory | Zaměří daný pracovní prostor na tomto monitoru | — | Rolování: další/předchozí pracovní prostor |
| Hodiny | Vyskakovací kalendář | Přepíná formát popisku | Prostřední: výběr časového pásma |
| Světové hodiny | Panel světových hodin | Obnovit | Prostřední: obnovit |
| Počasí | Vyskakovací předpověď | Kompletní počasí jako oznámení | Prostřední: obnovit |
| Zvuk | Panel zvuku | Ztlumit | Prostřední: panel · rolování: hlasitost |
| Mikrofon | Ztlumit mikrofon | — | Prostřední: panel zvuku · rolování: vstupní hlasitost |
| Síť | Panel sítě | — | — |
| Bluetooth | Panel Bluetooth | Přepnout bezdrátové rozhraní | — |
| Displej | Panel displeje | — | Rolování: jas |
| Napájení | Panel napájení | Přepnout procenta baterie | — |
| Média | Přehrát/pozastavit | Vyskakovací okno s obalem alba | Prostřední: další · rolování: předchozí/další |
| Agenti | Panel agentů | Spustit vašeho agenta | Prostřední: obnovit využití |
| Zásobník | Přejetím myší odhalíte zásuvku | Pravým tlačítkem na šipku ji spravujete | — |
| Aktualizace Omarchy | Spustit aktualizaci | — | — |

Ne všechno v té tabulce máte na liště hned od začátku. Widget médií (právě přehrávané přes MPRIS, s posouvající se skladbou a interpretem) a widget mikrofonu jsou oba vestavěné, ale ve výchozím nastavení vypnuté — přidejte si je, pokud je chcete, jak je popsáno níže.

## Panely

Kliknutí na ikonu na liště otevře panel, což je pořádné vyskakovací okno s posuvníky, seznamy a navigací klávesnicí, a ne jen popisek. Každý má také klávesovou zkratku, takže nikdy nemusíte mířit na 16pixelový glyf:

| Klávesová zkratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Síť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájení |
| `Super + Ctrl + Alt + D` | Kalendář |
| `Super + Ctrl + Alt + E` | Světové hodiny |
| `Super + Ctrl + X` | Agenti |
| `Super + Ctrl + 1-9` | Přepnout n-tý panel v pravé sekci |

Panely nejsou jen výpisy. Jsou to místa, kde tu věc skutečně uděláte:

- **Zvuk** má posuvník hlavní hlasitosti, výběr výstupního zařízení a mixér pro jednotlivé aplikace, takže můžete ztišit právě tu jednu kartu prohlížeče, aniž byste sahali na všechno ostatní.
- **Síť** vyhledává Wi-Fi, ukazuje sílu signálu, připojuje a umožňuje vám vybrat poskytovatele DNS.
- **Bluetooth** vypíše vaše zařízení s připojením/odpojením a úrovněmi baterie.
- **Napájení** ukazuje statistiky baterie, přepíná profily napájení (pamatuje si zvláštní volbu pro baterii a pro AC) a vypíše pár systémových informací.
- **Displej** nese posuvník jasu, velikost textu, předvolby škálování monitoru a — když máte více než jednu obrazovku — ovládání pro jednotlivé monitory. Podrobnější příběh najdete v části [monitory](33-monitors.md).
- **Hodiny** otevřou měsíční mřížku s čísly týdnů podle ISO a krokováním po měsících.
- **Světové hodiny** drží řádek pro každé město, s jeho počasím a tím, jak mu plyne den. Vyhledávání nachází města stejně jako časová pásma, takže Fort Lauderdale je Fort Lauderdale, a ne New York. Pokud řádek nahoře jmenuje špatné město, klikněte na něj a řekněte, kde jste; vyberte místo v jiném časovém pásmu a systémové hodiny se tam přesunou také, což se hodí, když cestujete. Najeďte na město a klikněte na tlačítko osoby, abyste řekli, kdo tam žije — prostá jména, nebo `@` GitHub handles, aby se s nimi přenesly i jejich tváře.

Každý panel bere klávesnici stejně jako myš: šipky se pohybují, Return aktivuje, Tab přeskočí na sousední panel a Escape zavře.

`Super + Ctrl + 1-9` počítá panely zleva doprava v pravé sekci, přičemž přeskakuje zásobník, protože ten nemá vlastní panel. Číslo tedy odpovídá ikoně, na kterou byste ukázali.

### Tailscale a Dropbox

Další dva widgety se na liště objeví až poté, co si nainstalujete odpovídající službu z **Instalovat → Služba**, a oba stojí za to znát, protože dělají víc než jen hlásí stav.

Panel **Tailscale** připojuje a odpojuje tailnet, přepíná mezi účty a vybírá exit node (v tom seznamu se objeví vaše vlastní stroje i regiony Mullvad). Také prochází vaše stroje — a když je jeden vybraný, `s` mu pošle soubory přes Taildrop, což je nejrychlejší způsob, jak přesunout soubor do telefonu nebo jiného laptopu. `c` zkopíruje IP stroje, `n` jeho název a `d` jeho úplný název DNS. Na každém řádku stroje je také tlačítko pro odeslání, pokud raději klikáte. Totéž z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** obsluhuje přihlášení, ukazuje, kolik úložiště jste využili, a vypíše nedávno synchronizované soubory.

Odebrání kterékoli služby stáhne její widget zpět z lišty.

## Indikátory

Malý shluk uprostřed je widget indikátorů. Jsou to stavové glyfy pro režimy, které jste zapnuli: nerušit, noční světlo, zařazená [připomínka](09-reminders.md), aktivní nahrávání obrazovky a zůstat vzhůru, plus varování, když je zapnuté sudo bez hesla nebo je někdo připojený ke vzdálené relaci. Rozsvítí se, když je režim aktivní, a jinak se drží stranou — najeďte těsně vedle nich, tam, kde by seděly ty neaktivní, abyste se na ty neaktivní podívali. Kliknutí na indikátor daný režim přepne. Jeden další je pouze stavový: vzdálená relace svítí červeně, když je někdo připojený k tomuto stroji přes gliff.

Pokud byste raději, aby byly vždy viditelné, nastavte na widgetu `alwaysShow` na `true`. A pokud vám záleží jen na některých z nich, vypište ty, které chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Widgetů indikátorů můžete mít více než jeden, takže různé sekce mohou ukazovat různé podmnožiny.

## Přeskládání lišty

Lišta se konfiguruje sama. Nemusíte kvůli přesouvání věcí otevírat konfigurační soubor.

Uchopte prázdnou plochu lišty kolem středu a táhněte ji k jinému okraji obrazovky a lišta se tam přesune — funguje levý, pravý, horní i spodní okraj a každý widget se přizpůsobí (svislé lišty spadnou zpět do kompaktních forem jen s ikonami). Kliknutí a podržení spustí stejné tažení. Dvojité kliknutí levým tlačítkem na totéž prázdné místo přepíná pozadí lišty z čirého na skleněné a na neprůhledné. A táhněte libovolný widget, abyste ho přeskládali nebo hodili do jiné sekce; ostatní widgety se roztáhnou, aby udělaly místo tam, kde přistane.

Střed lišty je box: cokoli je v něm, zůstává vystředěné jako jedna skupina a widgety po jeho stranách visí na jeho okrajích. Když widget táhnete, box se ukáže jako obrys, nebo jako čára přes lištu, když je prázdný, a můžete ho pustit do něj nebo vedle něj. Když by pád přistál v boxu, box se zvětší, aby widget přijal.

Widget, který chcete mít po ruce, ale ne vždy na očích, může jít do zásuvky zásobníku: táhněte ho na zásobník a zásuvka se otevře, aby ho přijala. Sedí tam za ikonami aplikací, ukáže se, kdykoli se ukáže zásuvka, a drží svou zásuvku otevřenou, když je jeho panel nahoře. Táhněte ho zpět na lištu, abyste ho vrátili.

Pokud byste si raději vybrali z menu, **Vzhled → Lišta menu** má pozici a **Pozadí lišty** vybírá, jak se lišta kreslí: **Neprůhledná lišta**, **Skleněná lišta** (průhledná, s tím, co je za ní, rozostřeným), nebo **Čirá lišta**.

Tytéž věci mají příkazy, což je to, co chcete pro nastavení pomocí [dotfiles](31-dotfiles.md):

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

## Skrývání lišty

`Super + Shift + Space` přepne lištu pryč a zase zpět, aniž by zabilo shell — panely a klávesové zkratky dál fungují, jen dostanete zpět pixely. Je to také v menu pod **Vzhled → Lišta menu → Skrýt lištu**.

## Konfigurační soubor

Všechno je to uložené v `~/.config/omarchy/shell.json`, pod klíčem `bar`. Tady je oříznutá verze:

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

Každý widget je jeden záznam v jednom z pěti polí layoutu a jeho nastavení sedí přímo na tom záznamu — není žádný samostatný soubor nastavení a žádný podobjekt `config`. `format`, `formatAlt` (to, na co přepne kliknutí pravým tlačítkem) a `verticalFormat` hodin žijí všechny přímo tam na `{ "id": "omarchy.clock" }`.

`center` je box uprostřed lišty: všechno v něm je vystředěné na obrazovce jako jedna skupina. `centerBegin` a `centerEnd` visí na obou stranách boxu, což je způsob, jak hodiny zůstávají přesně uprostřed, i když počasí a odznak aktualizace přicházejí a odcházejí. Dejte do `center` více než jeden widget a budou vystředěné společně; nechte ho prázdný a `centerBegin` a `centerEnd` se setkají uprostřed lišty.

Jedno pravidlo, které stojí za to zvnitřnit: **jakmile máte vlastní `shell.json`, je kanonický**. Dokud si nic nepřizpůsobíte, shell čte výchozí soubor Omarchy. V okamžiku, kdy widget přetáhnete, spustíte `omarchy bar` nebo soubor sami upravíte, vlastníte ho — není žádné hluboké slučování, takže nové výchozí widgety v budoucích vydáních Omarchy se na vaší liště automaticky neobjeví. `omarchy bar defaults` vrátí dodávaný layout, kdykoli chcete čistý list.

Tentýž soubor drží také vaše časování nečinnosti na nejvyšší úrovni, mimo klíč `bar`: `idle.screensaver` a `idle.lock`, obojí v sekundách od doby, kdy jste odešli do nečinnosti. Výchozí spořič obrazovky tedy nastoupí po 150 sekundách a zámek po 300.
