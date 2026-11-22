# Przełączniki, bezczynność i wygaszacz ekranu

Wiele z tego, co zmieniasz na co dzień, tak naprawdę nie jest ustawieniem. To tryb, który włączasz na godzinę i potem znów wyłączasz: światło nocne, gdy pracujesz do późna, nie przeszkadzać, gdy prowadzisz prezentację, czuwanie, gdy coś oglądasz. Omarchy nazywa je przełącznikami i wszystkie działają tak samo — skrót klawiszowy, pozycja w menu i polecenie, wszystkie trafiające w ten sam przełącznik.

### Menu przełączników

`Super + Ctrl + O` otwiera bezpośrednio _Trigger > Toggle_, albo możesz dojść tam z menu Omarchy (`Super + Space`). Wszystko na tej liście to przełącznik, który możesz przełączyć bez zastanawiania się, gdzie zapisany jest stan. Przełączniki dotyczące wyglądu pulpitu znajdują się tuż obok, w _Appearance_.

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
| Pełny ekran pulpitu (bez paska, bez odstępów) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animacje, rozmycie i cienie | — | `omarchy toggle animations` |
| Panel dotykowy | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ekran dotykowy | — | `omarchy device touchscreen` |
| Wstrzymanie | — | `omarchy toggle suspend` |
| Hybrydowe GPU | — | `omarchy device gpu hybrid` |

Przełączniki panelu dotykowego, ekranu dotykowego i hybrydowego GPU znajdują się w _Trigger > Hardware_ (`Super + Ctrl + H`), a nie w Toggle, ponieważ pojawiają się tylko wtedy, gdy faktycznie masz taki sprzęt. Przełączniki panelu dotykowego i ekranu dotykowego przetrwają przeładowanie Hyprland — nazwa wyłączonego urządzenia jest zapisywana w małym pliku stanu, który Hyprland odczytuje przy starcie, aby ponownie je wyłączyć.

_Appearance_ zawiera pasek menu i animacje, a także kilka rzeczy, które nie są poleceniami `omarchy toggle`, ale zachowują się tak samo: procent baterii na pasku, domyślny układ obszarów roboczych oraz, w _Windows_, odstępy między oknami (`Super + Shift + Backspace`) i proporcje kwadratu dla 1 okna (`Super + Ctrl + Backspace`).

Gdy Hyprland nie ma GPU do rysowania i renderuje zamiast tego na CPU (llvmpipe), jak na komputerach Mac, których GPU nie jest jeszcze obsługiwane, w większości maszyn wirtualnych lub gdy sterownik graficzny nie załaduje się, Omarchy wyłącza animacje, rozmycie i cienie na tę sesję i informuje cię o tym raz powiadomieniem. _Appearance > Animations On_ przywraca je, a Omarchy zapamiętuje to również na późniejsze sesje.

Większość z nich to po prostu plik flagi w `~/.local/state/omarchy/toggles/`. Jeśli chcesz rozgałęziać się na podstawie jednego z nich w skrypcie, `omarchy-toggle-enabled` daje ci kod wyjścia, zamiast zmuszać cię do szukania:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagi są nazwane od stanu wyłączenia — `screensaver-off`, `suspend-off`, `bar-off` — więc ich obecność oznacza, że funkcja jest wyłączona.

### Wskaźniki na pasku

Gdy tryb jest włączony, otrzymujesz mały glif na środku górnego paska obok zegara. To widżet wskaźników, który zawiera nagrywanie ekranu, oczekujące przypomnienia, światło nocne, nie przeszkadzać i czuwanie, a także ostrzeżenia, gdy włączone jest sudo bez hasła lub ktoś jest połączony ze zdalną sesją.

Nieaktywne wskaźniki są ukryte. Najedź kursorem w dowolne miejsce na pasku, a pojawią się przyciemnione, dzięki czemu możesz kliknąć jeden, aby go włączyć, bez znajomości jego skrótu klawiszowego. Kliknięcie aktywnego wskaźnika wyłącza go ponownie. Jeśli wolisz widzieć je wszystkie przez cały czas, ustaw `alwaysShow` na `true` we wpisie `omarchy.indicators` w `~/.config/omarchy/shell.json` — zobacz [górny pasek](05-the-top-bar.md), aby dowiedzieć się, jak konfigurowane są widżety paska.

### Światło nocne

Światło nocne ociepla ekran do 4000K, a ponowne przełączenie przywraca go do 6500K. Przełącz je z menu przełączników (`Super + Ctrl + O`) lub za pomocą `omarchy toggle nightlight`. Obsługiwane jest przez hyprsunset, który przełącznik uruchamia za ciebie, jeśli nie jest już uruchomiony.

Domyślnie hyprsunset w ogóle nie robi nic z twoim ekranem. `~/.config/hypr/hyprsunset.conf` jest dostarczany z profilem tożsamości właśnie po to, aby wyświetlacz pozostał nietknięty, dopóki nie poprosisz o ciepło. Jeśli wolisz, aby przełączał się według zegara, zastąp go profilem czasowym:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Następnie uruchamiaj hyprsunset przy logowaniu, dodając `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Para 4000K/6500K używana przez przełącznik jest stała, więc plik konfiguracyjny jest miejscem, do którego się udajesz, jeśli chcesz inną temperaturę.

### Nie przeszkadzać

`Super + Ctrl + Alt + ,` wycisza powiadomienia. Gdy jest włączone, nie pojawiają się żadne powiadomienia wyskakujące, a wskaźnik przekreślonego dzwonka znajduje się na pasku, aby przypominać ci, dlaczego pulpit ucichł.

Nic jednak nie ginie. Wyciszone powiadomienia są wstrzymywane: przywróć kilka ostatnich na ekran za pomocą `Super + Shift + Alt + ,`. Resztę zobacz w [powiadomieniach](10-notices.md).

Trzy rodzaje wiadomości nadal się przedostają: własne powiadomienia potwierdzające Omarchy dotyczące czegoś, co właśnie zrobiłeś ("Theme changed", "Screenshot saved"), krytyczne alerty wysyłane z wiersza poleceń oraz kody weryfikacyjne. Aplikacje czatu, które oznaczają wszystko jako krytyczne, aby siłą wcisnąć się przed ciebie, nie kwalifikują się.

### Bezczynność

Za zachowanie przy bezczynności odpowiada powłoka Omarchy, a czasy znajdują się w bloku `idle` najwyższego poziomu w `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obie liczby to sekundy liczone od momentu, gdy przeszedłeś w stan bezczynności — nie od siebie nawzajem. Tak więc przy ustawieniach domyślnych wygaszacz ekranu pojawia się po dwóch i pół minuty, a ekran blokady przejmuje kontrolę po pięciu minutach, niezależnie od tego, czy wygaszacz ekranu się uruchomił. Zapisz plik, a powłoka od razu przejmie nowe czasy.

Jeśli odrzucisz wygaszacz ekranu przed upływem terminu blokady, liczy się to jako aktywność, a oczekująca blokada jest anulowana. Nie zostaniesz zablokowany za zerkanie na swój komputer.

Aby całkowicie zatrzymać blokowanie przy bezczynności, `Super + Ctrl + I` — lub `omarchy toggle idle` — włącza czuwanie, a na pasku pojawia się wskaźnik filiżanki kawy. To ten, który należy nacisnąć przed długą prezentacją lub kompilacją, którą chcesz obserwować. Naciśnij go ponownie, aby wrócić do normy. `omarchy toggle idle status` wypisuje bieżący stan jako JSON, jeśli potrzebujesz go ze skryptu.

Chodzi tu o blokowanie i wygaszacz ekranu, nie o zasilanie. Wstrzymanie i hibernacja mają własną konfigurację w [uśpieniu systemu](36-system-sleep.md).

### Wygaszacz ekranu

Wygaszacz ekranu Omarchy to grafika ASCII przechodząca przez losowe efekty tekstowe, jedna instancja na monitor. Dowolny klawisz lub ruch myszy go wyłącza.

Możesz uruchomić go na żądanie z _System > Screensaver_ (`Super + Esc`), co wymusza jego pojawienie się, nawet jeśli wyłączyłeś wygaszacz ekranu przy bezczynności. Domyślnie nie jest do niego przypisany żaden skrót klawiszowy.

`omarchy toggle screensaver` to polecenie, które wyłącza ten przy bezczynności, jeśli wolisz przejść prosto z pracy do blokady. Dowolny klawisz, kliknięcie, przewinięcie lub ruch myszy go zamyka.

Logo, które rysuje, możesz zmienić w _Appearance > Branding > Screensaver_. Prześlij plik png lub svg, a Omarchy przekonwertuje go na ASCII. Zobacz [branding](41-branding.md).

### Ekran blokady

`Super + Ctrl + L` blokuje komputer. Uruchamia to ekran blokady z powłoki Omarchy, wygasza wyświetlacz, resetuje układ klawiatury do pierwszego, abyś nie wpisywał hasła w niewłaściwym alfabecie, i — jeśli masz go uruchomionego — blokuje 1Password przy wyjściu.

Ekran blokady przyjmuje hasło, a przyjmie też odcisk palca, gdy już go skonfigurujesz. To oraz inne sposoby uwierzytelniania są omówione w [uwierzytelnianiu sprzętowym](37-hardware-authentication.md).
