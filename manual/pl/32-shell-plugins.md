# Wtyczki powłoki

Pulpit Omarchy działa jako pojedynczy długotrwały proces Quickshell o nazwie `omarchy-shell`, a prawie wszystko, co widzisz na ekranie, jest wtyczką wewnątrz niego. Pasek jest wtyczką. Podobnie jak panele, które opadają z niego, nakładki pełnoekranowe, takie jak selektor emoji i menedżer schowka, samo menu Omarchy, ekran blokady, dialog polkit i bezgłowe usługi, które obserwują twoją baterię i ocieplają ekran w nocy.

To nie jest tylko szczegół implementacyjny. Oznacza to, że możesz wyłączać fragmenty pulpitu, wymieniać je lub pisać własne bez dotykania ani jednej linii kodu źródłowego Omarchy.

Wtyczki własne są dostarczane z Omarchy i żyją w `$OMARCHY_PATH/shell/plugins/`. Wszystko, co dodasz sam — własne eksperymenty lub coś, co znalazłeś na GitHub — żyje w `~/.config/omarchy/plugins/`. Oba są wykrywane w ten sam sposób przy uruchomieniu, ale wbudowane otrzymują zaufane interfejsy powłoki, podczas gdy wtyczki stron trzecich otrzymują ograniczony interfejs ograniczony do ich własnej usługi i cyklu życia. Klony wbudowanych zachowują tylko konfigurację specyficzną dla źródła i wywołania interfejsu użytkownika potrzebne do pierwotnego zachowania.

## Zobacz, co masz

```
omarchy plugin list
```

To wypisuje każdą wykrytą wtyczkę z jej id, czy jest włączona, czy jest własna czy strony trzeciej, jej rodzaje i nazwę wyświetlaną. Dodaj `--json`, jeśli przekazujesz to do czegoś innego.

Id wtyczek są w przestrzeni nazw. Wszystkie wbudowane zaczynają się od `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — a ta przestrzeń nazw jest zastrzeżona, więc wtyczka strony trzeciej nigdy nie może jej zgłosić.

## Włączanie i wyłączanie ich

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Lub użyj menu: _Ustawienia > Plugins_ ma Enable, Disable, Add, Clone i Remove, każde z selektorem, który oferuje tylko wtyczki, które mają sens dla tego działania.

Stan włączony jest przechowywany w `~/.config/omarchy/shell.json`, a reguła różni się nieco dla obu rodzajów wtyczek. Wtyczka strony trzeciej jest włączona dokładnie wtedy, gdy jej id występuje gdzieś w tym pliku — jako wpis układu paska, jako wpis w `plugins[]` lub jako `bar.id`. Wtyczki własne, które nie są widżetami paska, działają na odwrót: są domyślnie włączone i wyłączają się tylko poprzez umieszczenie na liście w `disabledPlugins[]`.

Pełna wtyczka paska w ogóle nie ma stanu wyłączonego. Zawsze jest dokładnie jeden pasek, więc zastępujesz go, włączając inny. Rozmieszczenie widżetów paska opisano w [górnym pasku](05-the-top-bar.md).

## Dodawanie wtyczki z git

Wtyczka strony trzeciej to po prostu repozytorium git z `manifest.json` w swoim katalogu głównym.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Zanim cokolwiek zrobi, mówi ci wprost, że wtyczki działają jako dowolny, niesandboxowany kod wewnątrz twojego długotrwałego procesu powłoki, pokazuje ci URL i prosi o potwierdzenie. Traktuj to poważnie. Interfejs wtyczek stron trzecich nie eksponuje bezpośrednio usług uwierzytelniania, a zamiennik paska otrzymuje jedynie ograniczone możliwości dla skonfigurowanego interfejsu użytkownika niezwiązanego z uwierzytelnianiem. Wtyczki wizualne nadal współdzielą scenę QML powłoki i mogą przechodzić zwykłe obiekty nadrzędne, podczas gdy cały kod wtyczki działa ze wszystkim, do czego może dosięgnąć twoje konto użytkownika. Stan uwierzytelniania jest chroniony osobno poprzez utrzymywanie tych usług poza osiągalnym grafem obiektów hosta. Dodawaj tylko repozytoria, które jesteś gotów uruchomić, i przeczytaj je przed włączeniem.

Zamiennik paska może renderować zainstalowane widżety, ale widżety stron trzecich oparte na usłudze mogą mieć tam ograniczoną funkcjonalność, ponieważ pasek nie może żądać żywego obiektu usługi innej wtyczki. Przełącz się z powrotem na wbudowany `omarchy.bar`, jeśli taki widżet potrzebuje swojej usługi towarzyszącej.

Następnie klonuje repozytorium do katalogu staging, waliduje manifest, odmawia instalacji, jeśli inna wtyczka już zgłosiła to id, i przenosi je do `~/.config/omarchy/plugins/<id>/`. Bez `--enable` zapytu, czy chcesz je włączyć teraz, a możesz powiedzieć nie i najpierw przeczytać kod. Nigdy nie uruchamia niczego z wtyczki, nigdy nie wykonuje hooka instalacji i nigdy nie prosi o sudo — klonuje pliki, sprawdza manifest i przełącza bit przez IPC.

Aktualizacja to szybkie pobranie typu fast-forward tego samego checkoutu:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Bez id aktualizuje każdą zarządzaną przez git wtyczkę, jaką masz. Pokazuje ci diff przed zastosowaniem go, odmawia aktualizacji, jeśli masz lokalne zmiany, których nie może ominąć przez fast-forward, i wycofuje, jeśli nowa rewizja nie przechodzi walidacji.

```
omarchy plugin remove acme.weather
```

Usuwanie najpierw wyłącza wtyczkę, a następnie usuwa ją, jeśli jest checkoutem git (repozytorium nadal jest upstream), lub odłącza ją, jeśli jest dowiązaniem symbolicznym. Ręcznie wykonany folder wtyczki bez repozytorium git zostaje zamiast tego przeniesiony do kopii zapasowej opatrzonej znacznikiem czasu wewnątrz katalogu wtyczek, zamiast być usuniętym od razu.

## Klonowanie wbudowanej, aby ją zmodyfikować

To moja ulubiona część. Jeśli chcesz zmienić sposób działania wbudowanego widżetu, nie edytuj plików w `$OMARCHY_PATH` — należą do pakietu, a następna aktualizacja je nadpisze. Zamiast tego sklonuj ją:

```
omarchy plugin clone omarchy.clock
```

To kopiuje całą wtyczkę do `~/.config/omarchy/plugins/dhh.clock` (twoja nazwa użytkownika, nie moja), zmienia jej nazwę na „My Clock”, włącza ją i przełącza powłokę z wbudowanej na twoją kopię — zachowując pozycję i ustawienia istniejącego widżetu paska. Dodaj `--edit`, aby otworzyć nowy katalog w swoim `$EDITOR` od razu, co robi dla ciebie menu _Ustawienia > Plugins > Clone Plugin_.

Prefiks z nazwą użytkownika sprawia, że id twojego klonu pozostaje twoje, więc udostępnianie go nie koliduje z niczyim innym. Wywołania wykonywane na oryginalne id wbudowanej są kierowane do twojego klonu, więc nic, co odnosiło się do `omarchy.clock`, nie wymaga aktualizacji. A jeśli narobisz w niej bałaganu, `omarchy plugin remove dhh.clock` przywraca wbudowaną.

Zapisywanie pliku w dowolnym miejscu w `~/.config/omarchy/plugins/` automatycznie ponownie ładuje kod wtyczki, więc możesz zostawić edytor otwarty i obserwować, jak twoje zmiany lądują.

## Pisanie własnych

Wtyczka to katalog z `manifest.json` i pewnym QML. Manifest deklaruje `schemaVersion: 1`, `id`, `name`, `version`, jeden lub więcej `kinds` oraz obiekt `entryPoints` wskazujący na plik QML dla każdego rodzaju:

| Kind | What it is |
|------|------------|
| `bar-widget` | Komponent, który aktywny pasek może wrzucić do sekcji |
| `panel` | Trwałe lub przywołane pływające okno |
| `overlay` | Nakładka pełnoekranowa |
| `menu` | Przywołana powierzchnia menu |
| `service` | Bezgłowy singleton bez interfejsu użytkownika |
| `bar` | Pełny pasek, który zastępuje wbudowany |

Wtyczka może zadeklarować kilka rodzajów naraz — wtyczka mediów jest zarówno `service`, jak i `bar-widget`. Widżety paska otrzymują dodatkowy blok `barWidget` z nazwą wyświetlaną, kategorią, opcjonalnym `defaultSection` i `allowMultiple`, które mówi, czy ma sens mieć więcej niż jedną na pasku. Większość widżetów ustawia je na `false`; odstępniki i wskaźniki ustawiają je na `true`.

Zanim cokolwiek opublikujesz, sprawdź to:

```
omarchy plugin validate ./my-plugin
```

To uruchamia te same kontrole, które powłoka przeprowadza podczas ładowania: wersję schematu, wymagane pola, id, które nie jest zastrzeżone, punkty wejścia, które są bezpiecznymi ścieżkami względnymi i rzeczywiście istnieją, punkt wejścia dla każdego zgłoszonego rodzaju i brak dowiązań symbolicznych w dowolnym miejscu wewnątrz folderu.

W kwestii rozwoju wtyczek zobacz [dokumentację powłoki](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) i [katalog wtyczek własnych](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Dzielenie się swoimi ze światem

Gdy stworzysz coś, co ci się podoba, umieść to w publicznym repozytorium git. To cały mechanizm dystrybucji — każdy może wtedy uruchomić `omarchy plugin add` na twój URL i mieć to działające w kilka sekund.

Aby pomóc ludziom rzeczywiście to znaleźć, umieść to na [plugins.omarchy.org](https://plugins.omarchy.org). To marketplace dla wtyczek powłoki Omarchy i pierwsze miejsce, do którego należy zajrzeć, gdy zastanawiasz się, czy ktoś nie zbudował już widżetu, który zamierzasz napisać. Przejrzyj go przed rozpoczęciem!
