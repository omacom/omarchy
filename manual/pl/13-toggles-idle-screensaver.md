# Przełączniki, bezczynność i wygaszacz ekranu

Wiele z tego, co zmieniasz na co dzień, tak naprawdę nie jest ustawieniem. To tryb, który włączasz na godzinę i znów wyłączasz: światło nocne, gdy pracujesz do późna, tryb nie przeszkadzać, gdy prowadzisz prezentację, czuwanie, gdy coś oglądasz. Omarchy nazywa je przełącznikami i wszystkie działają tak samo — skrót klawiszowy, pozycja w menu i polecenie trafiają w ten sam przełącznik.

### Menu przełączników

`Super + Ctrl + O` otwiera bezpośrednio _Trigger > Toggle_, albo możesz dojść tam z menu Omarchy (`Super + Space`). Wszystko na tej liście to przełącznik, który możesz przełączyć bez zastanawiania się, gdzie przechowywany jest stan. Przełączniki dotyczące wyglądu pulpitu znajdują się tuż obok, w _Appearance_.

Z terminala te same przełączniki to `omarchy toggle <thing>`. Uruchom samo `omarchy toggle`, aby zobaczyć całą grupę.

| Przełącznik | Skrót klawiszowy | Polecenie |
| ------ | ------ | ------- |
| Światło nocne | — | `omarchy toggle nightlight` |
| Wyciszenie powiadomień | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Czuwanie (brak blokady przy bezczynności) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Przechwytywanie awarii | — | `omarchy toggle crash-capture` |
| Wygaszacz ekranu | — | `omarchy toggle screensaver` |
| Synchronizacja motywu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Pasek menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ekran dotykowy | — | `omarchy toggle touchscreen` |
| Wstrzymanie | — | `omarchy toggle suspend` |
| Hybrydowy GPU | — | `omarchy toggle hybrid gpu` |

Przełączniki touchpada, ekranu dotykowego i hybrydowego GPU znajdują się w _Trigger > Hardware_ (`Super + Ctrl + H`), a nie w Toggle, ponieważ pojawiają się tylko wtedy, gdy faktycznie masz taki sprzęt. Przełączniki touchpada i ekranu dotykowego przetrwają przeładowanie Hyprland — nazwa wyłączonego urządzenia jest zapisywana w małym pliku stanu, który Hyprland odczytuje przy starcie, aby ponownie je wyłączyć.

W _Appearance_ znajdują się pasek menu i animacje, a także kilka rzeczy, które nie są poleceniami `omarchy toggle`, ale zachowują się tak samo: procent baterii na pasku, domyślny układ obszaru roboczego oraz, w _Windows_, odstępy okien (`Super + Shift + Backspace`) i kwadratowe proporcje 1 okna (`Super + Ctrl + Backspace`).

Większość z nich to po prostu plik flagi w `~/.local/state/omarchy/toggles/`. Jeśli chcesz rozgałęzić na jego podstawie w skrypcie, `omarchy-toggle-enabled` daje ci kod wyjścia, zamiast zmuszać cię do szukania:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagi są nazywane od stanu wyłączenia — `screensaver-off`, `suspend-off`, `bar-off` — więc ich obecność oznacza, że funkcja jest wyłączona.

### Wskaźniki na pasku

Gdy tryb jest włączony, na środku górnego paska obok zegara pojawia się mały glif. To widżet wskaźników, a zawiera on dyktowanie, nagrywanie ekranu, oczekujące przypomnienia, światło nocne, tryb nie przeszkadzać oraz czuwanie.

Nieaktywne wskaźniki są ukryte. Najedź w dowolne miejsce na pasku, a pojawią się przyciemnione, więc możesz kliknąć jeden z nich, aby go włączyć bez znajomości jego skrótu klawiszowego. Kliknięcie aktywnego wskaźnika wyłącza go z powrotem. Jeśli wolisz widzieć je wszystkie przez cały czas, ustaw `alwaysShow` na `true` we wpisie `omarchy.indicators` w `~/.config/omarchy/shell.json` — zobacz [górny pasek](05-the-top-bar.md), aby dowiedzieć się, jak konfigurowane są widżety paska.

### Światło nocne

Światło nocne ociepla ekran do 4000K, a ponowne przełączenie przywraca 6500K. Przełącz je z menu przełączników (`Super + Ctrl + O`) lub za pomocą `omarchy toggle nightlight`. Jest napędzane przez hyprsunset, który przełącznik uruchamia za ciebie, jeśli jeszcze nie działa.

Domyślnie hyprsunset w ogóle nic nie robi z twoim ekranem. `~/.config/hypr/hyprsunset.conf` jest dostarczany z profilem tożsamości właśnie po to, aby wyświetlacz pozostawał nietknięty, dopóki nie poprosisz o ciepło. Jeśli wolisz, aby przełączał się według zegara, zastąp go profilem czasowym:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Następnie uruchom hyprsunset przy logowaniu, dodając `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Para 4000K/6500K używana przez przełącznik jest stała, więc jeśli chcesz innej temperatury, musisz zajrzeć do pliku konfiguracyjnego.

### Nie przeszkadzać

`Super + Ctrl + Alt + ,` wycisza powiadomienia. Gdy jest włączony, nie wyskakują żadne powiadomienia, a wskaźnik przekreślonego dzwonka siedzi na pasku, aby przypominać ci, dlaczego pulpit ucichł.

Nic jednak nie ginie. Wyciszone powiadomienia są wstrzymywane: przywróć kilka ostatnich na ekran za pomocą `Super + Shift + Alt + ,`. Zobacz [powiadomienia](10-notices.md), aby dowiedzieć się reszty.

Dwa rodzaje wiadomości nadal się przebijają: własne powiadomienia potwierdzające Omarchy dotyczące czegoś, co właśnie zrobiłeś ("Theme changed", "Screenshot saved"), oraz krytyczne alerty wysyłane z wiersza poleceń. Aplikacje czatu, które oznaczają wszystko jako krytyczne, aby na siłę przebić się przed ciebie, się nie kwalifikują.

### Bezczynność

Powłoka Omarchy odpowiada za zachowanie przy bezczynności, a czasy określa blok `idle` najwyższego poziomu w `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obie liczby to sekundy liczone od momentu przejścia w stan bezczynności — a nie jedna od drugiej. Przy ustawieniach domyślnych wygaszacz ekranu pojawia się więc po dwóch i pół minuty, a ekran blokady przejmuje kontrolę po pięciu minutach, niezależnie od tego, czy wygaszacz ekranu się uruchomił. Zapisz plik, a powłoka od razu przejmie nowe czasy.

Jeśli odrzucisz wygaszacz ekranu przed upływem czasu blokady, liczy się to jako aktywność, a oczekująca blokada zostaje anulowana. Nie zostaniesz zablokowany za zerkanie na swoją maszynę.

Aby całkowicie wyłączyć blokowanie przy bezczynności, `Super + Ctrl + I` — lub `omarchy toggle idle` — włącza czuwanie, a na pasku pojawia się wskaźnik filiżanki kawy. To ten, który należy wcisnąć przed długą prezentacją lub kompilacją, którą chcesz obserwować. Wciśnij go ponownie, aby wrócić do normalnego trybu. `omarchy toggle idle status` wypisuje bieżący stan jako JSON, jeśli potrzebujesz go ze skryptu.

Tu chodzi o blokowanie i wygaszacz ekranu, a nie o zasilanie. Wstrzymanie i hibernacja mają własną konfigurację w [uśpieniu systemu](36-system-sleep.md).

### Wygaszacz ekranu

Wygaszacz ekranu Omarchy to grafika ASCII przechodząca przez losowe efekty tekstowe, po jednej instancji na monitor. Dowolny klawisz lub ruch myszy go wyłącza.

Możesz uruchomić go na żądanie z _System > Screensaver_ (`Super + Esc`), co wymusza jego pojawienie się, nawet jeśli wyłączyłeś wygaszacz ekranu przy bezczynności. Domyślnie nie jest do niego przypisany żaden skrót klawiszowy.

`omarchy toggle screensaver` wyłącza ten przy bezczynności, jeśli wolisz przechodzić prosto od pracy do blokady. Dowolny klawisz, kliknięcie, przewinięcie lub ruch myszy go zamyka.

Logo, które rysuje, możesz zmienić w _Appearance > Branding > Screensaver_. Prześlij plik png lub svg, a Omarchy przekonwertuje go na ASCII. Zobacz [branding](41-branding.md).

### Ekran blokady

`Super + Ctrl + L` blokuje maszynę. Uruchamia to ekran blokady z powłoki Omarchy, wygasza wyświetlacz, resetuje układ klawiatury do pierwszego, abyś nie wpisywał hasła w złym alfabecie, oraz — jeśli masz go uruchomionego — blokuje po drodze 1Password.

Ekran blokady przyjmuje hasło, a przyjmie też odcisk palca, gdy już go skonfigurujesz. To oraz inne sposoby uwierzytelniania są omówione w [uwierzytelnianiu sprzętowym](37-hardware-authentication.md).
