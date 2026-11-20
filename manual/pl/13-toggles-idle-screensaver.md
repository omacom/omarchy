# Przełączniki, bezczynność i wygaszacz ekranu

Wiele z tego, co zmieniasz na co dzień, tak naprawdę nie jest ustawieniem. To tryb, który włączasz na godzinę i potem z powrotem wyłączasz: światło nocne, gdy pracujesz do późna, tryb nie przeszkadzać, gdy prowadzisz prezentację, czuwanie, gdy coś oglądasz. Omarchy nazywa je przełącznikami i wszystkie działają tak samo — skrót klawiszowy, pozycja w menu i polecenie trafiają w ten sam przełącznik.

### Menu przełączników

`Super + Ctrl + O` otwiera bezpośrednio _Wyzwalanie > Przełączniki_, a możesz też dojść tam z menu Omarchy (`Super + Space`). Wszystko na tej liście to przełącznik, który możesz przełączyć bez zastanawiania się, gdzie zapisany jest jego stan. Przełączniki dotyczące wyglądu pulpitu znajdują się tuż obok, w sekcji _Wygląd_.

Z terminala te same przełączniki to `omarchy toggle <thing>`. Uruchom samo `omarchy toggle`, aby zobaczyć całą grupę.

| Przełącznik | Skrót klawiszowy | Polecenie |
| ------ | ------ | ------- |
| Światło nocne | — | `omarchy toggle nightlight` |
| Wyciszanie powiadomień | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Czuwanie (bez blokady przy bezczynności) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Przechwytywanie awarii | — | `omarchy toggle crash-capture` |
| Wygaszacz ekranu | — | `omarchy toggle screensaver` |
| Synchronizacja motywu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Pasek menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Panel dotykowy | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Ekran dotykowy | — | `omarchy device touchscreen` |
| Uśpienie | — | `omarchy toggle suspend` |
| Hybrydowy GPU | — | `omarchy toggle hybrid gpu` |

Przełączniki panelu dotykowego, ekranu dotykowego i hybrydowego GPU znajdują się w sekcji _Wyzwalanie > Sprzęt_ (`Super + Ctrl + H`), a nie w sekcji Przełączniki, ponieważ pojawiają się tylko wtedy, gdy faktycznie masz taki sprzęt. Przełączniki panelu dotykowego i ekranu dotykowego przetrwają przeładowanie Hyprland — nazwa wyłączonego urządzenia jest zapisywana w małym pliku stanu, który Hyprland odczytuje przy starcie, aby ponownie je wyłączyć.

Sekcja _Wygląd_ zawiera pasek menu i animacje, a także kilka rzeczy, które nie są poleceniami `omarchy toggle`, ale zachowują się tak samo: procent baterii na pasku, domyślny układ obszarów roboczych oraz, w sekcji _Okna_, odstępy między oknami (`Super + Shift + Backspace`) i kwadratowe proporcje dla 1 okna (`Super + Ctrl + Backspace`).

Gdy Hyprland nie ma GPU do rysowania i zamiast tego renderuje na CPU (llvmpipe), jak na komputerach Mac, których GPU nie jest jeszcze obsługiwany, w większości maszyn wirtualnych (VM) lub gdy sterownik graficzny nie wczyta się, Omarchy wyłącza animacje, rozmycie i cienie na tę sesję i informuje cię o tym raz powiadomieniem. _Wygląd > Animacje włączone_ przywraca je, a Omarchy pamięta to także na późniejsze sesje.

Większość z nich to po prostu plik flagi w `~/.local/state/omarchy/toggles/`. Jeśli chcesz rozgałęziać się na podstawie którejś z nich w skrypcie, `omarchy-toggle-enabled` daje ci kod wyjścia, zamiast zmuszać cię do szukania:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagi są nazwane od stanu wyłączonego — `screensaver-off`, `suspend-off`, `bar-off` — więc ich obecność oznacza, że funkcja jest wyłączona.

### Wskaźniki na pasku

Gdy tryb jest włączony, otrzymujesz mały glif na środku górnego paska obok zegara. To widżet wskaźników i zawiera dyktowanie, nagrywanie ekranu, oczekujące przypomnienia, światło nocne, tryb nie przeszkadzać i czuwanie.

Nieaktywne wskaźniki są ukryte. Najedź kursorem w dowolne miejsce na pasku, a pojawią się przyciemnione, więc możesz kliknąć jeden, aby go włączyć, bez znajomości jego skrótu klawiszowego. Kliknięcie aktywnego wskaźnika wyłącza go z powrotem. Jeśli wolisz widzieć je wszystkie przez cały czas, ustaw `alwaysShow` na `true` we wpisie `omarchy.indicators` w `~/.config/omarchy/shell.json` — zobacz [górny pasek](05-the-top-bar.md), aby dowiedzieć się, jak konfigurowane są widżety paska.

### Światło nocne

Światło nocne ociepla ekran do 4000K, a ponowne przełączenie przywraca go do 6500K. Przełącz je z menu przełączników (`Super + Ctrl + O`) lub poleceniem `omarchy toggle nightlight`. Steruje nim hyprsunset, który przełącznik uruchomi za ciebie, jeśli jeszcze nie działa.

Domyślnie hyprsunset w ogóle nic nie robi z twoim ekranem. Plik `~/.config/hypr/hyprsunset.conf` jest dostarczany z profilem tożsamościowym właśnie po to, aby wyświetlacz pozostał nietknięty, dopóki nie poprosisz o ciepło. Jeśli wolisz, aby przełączał się według zegara, zastąp go profilem czasowym:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Następnie uruchom hyprsunset przy logowaniu, dodając `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Para 4000K/6500K używana przez przełącznik jest stała, więc plik konfiguracyjny to miejsce, do którego idziesz, jeśli chcesz inną temperaturę.

### Nie przeszkadzać

`Super + Ctrl + Alt + ,` wycisza powiadomienia. Gdy jest włączony, nie pojawiają się żadne powiadomienia wyskakujące, a wskaźnik przekreślonego dzwonka znajduje się na pasku, aby przypominać ci, dlaczego pulpit ucichł.

Nic jednak nie ginie. Wyciszone powiadomienia są wstrzymywane: przywróć kilka ostatnich na ekran poleceniem `Super + Shift + Alt + ,`. Zobacz [powiadomienia](10-notices.md), aby dowiedzieć się reszty.

Dwa rodzaje wiadomości nadal się przedostają: własne powiadomienia potwierdzające Omarchy dotyczące czegoś, co właśnie zrobiłeś („Motyw zmieniony”, „Zrzut ekranu zapisany”), oraz krytyczne alerty wysyłane z wiersza poleceń. Aplikacje czatu, które oznaczają wszystko jako krytyczne, aby wymusić swoją obecność przed tobą, nie kwalifikują się.

### Bezczynność

Powłoka Omarchy odpowiada za zachowanie przy bezczynności, a czasy są najwyższego poziomu blokiem `idle` w `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obie liczby to sekundy liczone od momentu, gdy stałeś się bezczynny — a nie od siebie nawzajem. Zatem przy ustawieniach domyślnych wygaszacz ekranu pojawia się po dwóch i pół minuty, a ekran blokady przejmuje kontrolę po pięciu minutach, niezależnie od tego, czy wygaszacz ekranu działał. Zapisz plik, a powłoka od razu odbierze nowe czasy.

Jeśli odrzucisz wygaszacz ekranu przed terminem blokady, liczy się to jako aktywność, a oczekująca blokada zostanie anulowana. Nie zostaniesz zablokowany za zerkanie na swoją maszynę.

Aby całkowicie przestać blokować przy bezczynności, `Super + Ctrl + I` — lub `omarchy toggle idle` — włącza czuwanie, a na pasku pojawia się wskaźnik filiżanki kawy. To ten, który należy nacisnąć przed długą prezentacją lub kompilacją, którą chcesz obserwować. Naciśnij go ponownie, aby wrócić do normalności. `omarchy toggle idle status` wypisuje bieżący stan jako JSON, jeśli potrzebujesz go ze skryptu.

Chodzi tu o blokowanie i wygaszacz ekranu, a nie o zasilanie. Uśpienie i hibernacja mają swoją własną konfigurację w [uśpieniu systemu](36-system-sleep.md).

### Wygaszacz ekranu

Wygaszacz ekranu Omarchy to grafika ASCII przechodząca przez losowe efekty tekstowe, jedna instancja na monitor. Dowolny klawisz lub ruch myszy go wyłącza.

Możesz uruchomić go na żądanie z _System > Wygaszacz ekranu_ (`Super + Esc`), co wymusza jego pojawienie się, nawet jeśli wyłączyłeś wygaszacz ekranu przy bezczynności. Domyślnie nie jest do niego przypisany żaden skrót klawiszowy.

`omarchy toggle screensaver` to polecenie, które wyłącza ten przy bezczynności, jeśli wolisz przejść prosto od pracy do blokady. Dowolny klawisz, kliknięcie, przewinięcie lub ruch myszy go zamyka.

Logo, które rysuje, możesz zmienić w _Wygląd > Identyfikacja wizualna > Wygaszacz ekranu_. Prześlij plik png lub svg, a Omarchy przekształci go na ASCII. Zobacz [identyfikację wizualną](41-branding.md).

### Ekran blokady

`Super + Ctrl + L` blokuje maszynę. Uruchamia to ekran blokady z powłoki Omarchy, wygasza wyświetlacz, resetuje układ klawiatury do pierwszego, abyś nie wpisywał hasła w niewłaściwym alfabecie, oraz — jeśli masz go uruchomionego — blokuje 1Password przy wyjściu.

Ekran blokady przyjmuje hasło, a przyjmie też odcisk palca, gdy już go skonfigurujesz. To oraz inne sposoby uwierzytelniania są omówione w [uwierzytelnianiu sprzętowym](37-hardware-authentication.md).
