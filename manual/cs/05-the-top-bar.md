# Horní lišta

Pruh podél horního okraje obrazovky je lišta Omarchy. Není to přišroubovaná stavová lišta, ale součást shellu Omarchy, jediného dlouho běžícího procesu Quickshell, který kreslí také menu, oznámení, vyskakovací okna OSD a zamykací obrazovku. Proto dokonale ladí se vším ostatním a proto se panel otevře okamžitě, místo aby spouštěl novou aplikaci.

Je to také jediná část plochy, která je neustále na obrazovce, takže stojí za to vědět, co všechny ty malé glyfy dělají.

## Co na ní je ve výchozím nastavení

Lišta má tři části. Vlevo sedí logo Omarchy (spouštěč menu) a indikátory pracovních ploch. Uprostřed máte indikátory stavu, hodiny, Elsewhen (světové hodiny), počasí a odznak aktualizace Omarchy. Vpravo: systémový zásobník, rozložení klávesnice (když je nakonfigurováno více než jedno), agenty, Bluetooth, síť, zvuk, displej a napájení.

Některé z nich se objeví jen tehdy, když mají co říct. Rozložení klávesnice se objeví jen tehdy, pokud jste nakonfigurovali více než jedno rozložení. Odznak aktualizace se objeví jen tehdy, když čeká aktualizace Omarchy. A ikona agentů se objeví, když Omarchy poprvé najde na počítači využití AI kódování (viz [AI](17-ai.md)).

## Klikání

Téměř každý widget něco dělá při kliknutí levým, pravým a prostředním tlačítkem a několik jich reaguje na rolování. Právě tohle lidé přehlížejí — pod pravým a prostředním tlačítkem se skrývá spousta těch dobrých věcí.

| Widget | Levé | Pravé | Prostřední / rolování |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nový terminál | — |
| Pracovní plochy | Zaměřit danou pracovní plochu na tomto monitoru | — | Rolování: další/předchozí pracovní plocha |
| Hodiny | Vyskakovací kalendář | Přepínat formát popisku | Prostřední: výběr časového pásma |
| Počasí | Vyskakovací předpověď | Úplné počasí jako oznámení | Prostřední: obnovit |
| Zvuk | Panel zvuku | Ztlumit | Prostřední: panel · rolování: hlasitost |
| Mikrofon | Ztlumit mikrofon | — | Prostřední: panel zvuku · rolování: vstupní hlasitost |
| Síť | Panel sítě | — | — |
| Bluetooth | Panel Bluetooth | Přepnout rádio | — |
| Displej | Panel displeje | — | Rolování: jas |
| Napájení | Panel napájení | Přepnout procenta baterie | — |
| Média | Přehrát/pozastavit | Vyskakovací okno s obalem alba | Prostřední: další · rolování: předchozí/další |
| Agenti | Panel agentů | Spustit vašeho agenta | Prostřední: další předplatné |
| Tray | Najetím myší odhalíte zásuvku | Pravým tlačítkem na šipku spravujete | — |
| Aktualizace Omarchy | Spustit aktualizaci | — | — |

Ne všechno z té tabulky máte na liště hned po vybalení. Widget médií (právě přehrávané MPRIS s posouvající se skladbou a interpretem) a widget mikrofonu jsou oba vestavěné, ale ve výchozím nastavení vypnuté — přidejte si je, pokud je chcete, jak je popsáno níže.

## Panely

Kliknutím na ikonu na liště otevřete panel, což je pořádné vyskakovací okno s posuvníky, seznamy a navigací klávesnicí, ne jen popisek. Každý má také klávesovou zkratku, takže nikdy nemusíte mířit na 16pixelový glyf:

| Klávesová zkratka | Panel |
| --- | --- |
| `Super + Ctrl + A` | Zvuk |
| `Super + Ctrl + N` | Síť |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displej |
| `Super + Ctrl + P` | Napájení |
| `Super + Ctrl + Alt + D` | Kalendář |
| `Super + Ctrl + Alt + E` | Světové hodiny |
| `Super + Ctrl + 1-9` | Přepnout n-tý panel v pravé části |

Panely nejsou jen výpisy. Jsou to místa, kde tu věc skutečně uděláte:

- **Zvuk** má hlavní posuvník hlasitosti, výběr výstupního zařízení a mixážní pult pro jednotlivé aplikace, takže můžete ztlumit právě tu jednu kartu prohlížeče, aniž byste sahali na všechno ostatní.
- **Síť** vyhledává Wi-Fi, ukazuje sílu signálu, připojuje a umožňuje vybrat poskytovatele DNS.
- **Bluetooth** vypisuje vaše zařízení s připojením/odpojením a úrovněmi baterie.
- **Napájení** ukazuje statistiky baterie, přepíná profily napájení (pamatuje si zvláštní volbu pro baterii a pro AC) a vypisuje některé systémové informace.
- **Displej** nese posuvník jasu, velikost textu, předvolby škálování monitoru a — když máte více než jednu obrazovku — ovládací prvky pro jednotlivé monitory. Podrobnější příběh najdete v [monitorech](33-monitors.md).
- **Hodiny** otevírají měsíční mřížku s čísly týdnů podle ISO a krokováním po měsících.
- **Světové hodiny** drží řádek pro každé město, s jeho počasím a tím, jak mu plyne den. Vyhledávání nachází městečka stejně jako časová pásma, takže Fort Lauderdale je Fort Lauderdale a ne New York. Pokud řádek nahoře uvádí špatné město, klikněte na něj a řekněte, kde jste; vyberte si místo v jiném časovém pásmu a systémové hodiny se tam přesunou také, což se hodí při cestování. Najeďte na město a klikněte na tlačítko s osobou, abyste řekli, kdo tam žije — obyčejná jména, nebo popisovače GitHub s `@`, abyste s sebou přivedli i jejich tváře.

Každý panel přijímá klávesnici stejně jako myš: šipky se pohybují, Return aktivuje, Tab skočí na sousední panel a Escape zavírá.

`Super + Ctrl + 1-9` počítá panely zleva doprava v pravé části, přeskakuje zásobník, protože ten nemá vlastní panel. Takže číslo odpovídá ikoně, na kterou byste ukázali.

### Tailscale a Dropbox

Další dva widgety se na liště objeví, jen jakmile nainstalujete odpovídající službu z **Instalace → Služba**, a oba stojí za pozornost, protože dělají víc než jen hlásí stav.

Panel **Tailscale** připojuje a odpojuje tailnet, přepíná mezi účty a vybírá výstupní uzel (v tom seznamu se objeví vaše vlastní počítače i oblasti Mullvad). Prochází také vaše počítače — a když je jeden vybraný, `s` na něj pošle soubory přes Taildrop, což je nejrychlejší způsob, jak přesunout soubor do telefonu nebo jiného laptopu. `c` kopíruje IP počítače, `n` jeho název a `d` jeho úplný název DNS. Na každém řádku počítače je také tlačítko pro odeslání, pokud raději klikáte. Totéž z terminálu je `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** vyřizuje přihlášení, ukazuje, kolik úložiště jste využili, a vypisuje nedávno synchronizované soubory.

Odstraněním kterékoli z těchto služeb zmizí její widget zase z lišty.

## Indikátory

Malý shluk uprostřed je widget indikátorů. Jsou to stavové glyfy pro režimy, které jste zapnuli: nerušit, noční světlo, zařazenou [připomínku](09-reminders.md), aktivní nahrávání obrazovky, zůstávání vzhůru a [diktování](11-text-extraction-dictation.md). Rozsvítí se, když je režim aktivní, a jinak se drží stranou — najeďte myší přímo vedle nich, tam, kde by seděly ty neaktivní, abyste se na ně podívali. Kliknutím na indikátor daný režim přepnete. Jeden další je pouze stavový: vzdálená relace svítí červeně, dokud je k tomuto počítači někdo připojený přes gliff.

Pokud byste je raději měli vždy viditelné, nastavte na widgetu `alwaysShow` na `true`. A pokud vám záleží jen na některých z nich, vypište ty, které chcete, v `items`: `["Dnd", "Reminder", "NightLight"]`. Widgetů indikátorů můžete mít víc než jeden, takže různé části mohou ukazovat různé podmnožiny.

## Přeskládání lišty

Lišta se konfiguruje sama. Nemusíte kvůli přesouvání věcí otevírat konfigurační soubor.

Chyťte prázdné místo na liště okolo středu a táhněte je směrem k jinému okraji obrazovky a lišta se tam přesune — funguje levý, pravý, horní i dolní okraj a každý widget se přizpůsobí (svislé lišty se vracejí ke kompaktním formám pouze z ikon). Stejný tah spustí kliknutí a podržení. Dvojitým kliknutím levým tlačítkem na totéž prázdné místo přepínáte pozadí lišty z čirého na skleněné až po neprůhledné. A táhněte libovolný widget, abyste změnili jeho pořadí nebo ho hodili do jiné části; ostatní widgety se rozestoupí, aby udělaly místo tam, kam dopadne.

Střed lišty je krabice: cokoli je v ní, zůstává vystředěné jako jedna skupina a widgety po jejích stranách visí z jejích okrajů. Zatímco widget táhnete, krabice se ukazuje jako obrys, nebo jako čára napříč lištou, když je prázdná, a můžete pustit dovnitř ní nebo vedle ní. Když by puštění dopadlo do krabice, krabice se zvětší, aby widget pojala.

Widget, který chcete mít po ruce, ale ne pořád na očích, může jít do zásuvky zásobníku: přetáhněte ho na zásobník a zásuvka se otevře, aby ho přijala. Sedí tam za ikonami aplikací, objeví se vždy, když se objeví zásuvka, a nechá svou zásuvku otevřenou, dokud je jeho panel nahoře. Přetáhněte ho zpět ven na lištu, abyste ho vrátili.

Pokud raději vybíráte z menu, **Vzhled → Lišta menu** má polohu a **Pozadí lišty** vybírá, jak se lišta kreslí: **Neprůhledná lišta**, **Skleněná lišta** (průhledná, s tím, co je za ní, rozostřeným) nebo **Čirá lišta**.

Tytéž věci mají příkazy, což je to, co chcete pro nastavení s [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Chcete-li widget zcela přidat nebo odebrat, použijte příkazy pro pluginy. `omarchy plugin list` vypíše každý widget, který shell zná, i s jeho id, a pak:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skrytí lišty

`Super + Shift + Space` vypíná lištu a zase ji zapíná, aniž by zabíjela shell — panely a klávesové zkratky dál fungují, jen získáte zpět pixely. Je to také v menu pod **Vzhled → Lišta menu → Skrýt lištu**.

## Konfigurační soubor

Vše je uloženo v `~/.config/omarchy/shell.json`, pod klíčem `bar`. Tady je zkrácená verze:

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

Každý widget je jedna položka v jednom z pěti polí layoutu a jeho nastavení sedí přímo na té položce — neexistuje žádný samostatný soubor s nastavením a žádný podobjekt `config`. Hodinové `format`, `formatAlt` (to, na co přepíná kliknutí pravým tlačítkem) a `verticalFormat` všechny žijí přímo tam na `{ "id": "omarchy.clock" }`.

`center` je krabice uprostřed lišty: všechno v ní je vystředěno na obrazovce jako jedna skupina. `centerBegin` a `centerEnd` visí po obou stranách krabice, a právě tak zůstávají hodiny přesně uprostřed, i když počasí a odznak aktualizace přicházejí a odcházejí. Dejte do `center` více než jeden widget a budou vystředěny společně; nechte ho prázdné a `centerBegin` a `centerEnd` se potkají uprostřed lišty.

Jedno pravidlo, které stojí za to si osvojit: **jakmile máte vlastní `shell.json`, je kanonický**. Dokud si nic nepřizpůsobíte, shell čte výchozí soubor Omarchy. V okamžiku, kdy přetáhnete widget, spustíte `omarchy bar` nebo soubor sami upravíte, vlastníte ho vy — nedochází k žádnému hlubokému slučování, takže se nové výchozí widgety z budoucích vydání Omarchy na vaší liště automaticky neobjeví. `omarchy bar defaults` vrátí dodávané rozložení zpět, kdykoli budete chtít čistý štít.

Tentýž soubor také drží vaše časování nečinnosti na nejvyšší úrovni, mimo klíč `bar`: `idle.screensaver` a `idle.lock`, obojí v sekundách od doby, kdy jste odešli do nečinnosti. Takže výchozí spořič obrazovky naskočí po 150 sekundách a zámek po 300.
