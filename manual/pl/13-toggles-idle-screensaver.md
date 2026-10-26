# Przełączniki, bezczynność i wygaszacz ekranu

Wiele z tego, co zmieniasz na co dzień, tak naprawdę nie jest ustawieniem. To tryb, który włączasz na godzinę i potem znów wyłączasz: światło nocne, gdy pracujesz do późna, tryb nie przeszkadzać, gdy prowadzisz prezentację, pozostawanie w czuwaniu, gdy coś oglądasz. Omarchy nazywa je przełącznikami i wszystkie działają tak samo — skrót klawiszowy, pozycja w menu i polecenie trafiają w ten sam przełącznik.

### Menu przełączników

`Super + Ctrl + O` otwiera bezpośrednio _Trigger > Toggle_, albo możesz dojść tam z menu Omarchy (`Super + Space`). Wszystko na tej liście to przełącznik, który możesz przełączyć, nie zastanawiając się, gdzie zapisany jest stan. Przełączniki dotyczące wyglądu pulpitu znajdują się obok, w sekcji _Appearance_.

Z terminala te same przełączniki to `omarchy toggle <thing>`. Uruchom samo `omarchy toggle`, aby zobaczyć całą grupę.

| Przełącznik | Skrót klawiszowy | Polecenie |
| ------ | ------ | ------- |
| Światło nocne | — | `omarchy toggle nightlight` |
| Wyciszenie powiadomień | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Pozostawanie w czuwaniu (brak blokady w bezczynności) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Przechwytywanie awarii | — | `omarchy toggle crash-capture` |
| Wygaszacz ekranu | — | `omarchy toggle screensaver` |
| Synchronizacja motywu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Pasek menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ekran dotykowy | — | `omarchy toggle touchscreen` |
| Uśpienie | — | `omarchy toggle suspend` |
| Hybrydowy GPU | — | `omarchy toggle hybrid gpu` |

Przełączniki touchpada, ekranu dotykowego i hybrydowego GPU znajdują się w _Trigger > Hardware_ (`Super + Ctrl + H`), a nie w Toggle, ponieważ pojawiają się tylko wtedy, gdy faktycznie masz taki sprzęt. Przełączniki touchpada i ekranu dotykowego przetrwają ponowne wczytanie Hyprland — nazwa wyłączonego urządzenia jest zapisywana w małym pliku stanu, który Hyprland odczytuje przy starcie, aby wyłączyć je ponownie.

_Appearance_ zawiera pasek menu i animacje, a także kilka rzeczy, które nie są poleceniami `omarchy toggle`, ale zachowują się tak samo: procent baterii na pasku, domyślny układ obszarów roboczych oraz, w sekcji _Windows_, odstępy między oknami (`Super + Shift + Backspace`) i kwadratowe proporcje dla 1 okna (`Super + Ctrl + Backspace`).

Większość z nich to po prostu plik flagi w `~/.local/state/omarchy/toggles/`. Jeśli chcesz rozgałęziać się na podstawie którejś z nich w skrypcie, `omarchy-toggle-enabled` zwraca kod wyjścia, zamiast zmuszać cię do szukania:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagi są nazwane od stanu wyłączenia — `screensaver-off`, `suspend-off`, `bar-off` — więc ich obecność oznacza, że funkcja jest wyłączona.

### Wskaźniki na pasku

Gdy tryb jest włączony, na środku górnego paska, obok zegara, pojawia się mały znak. To widżet wskaźników, który obejmuje dyktowanie, nagrywanie ekranu, oczekujące przypomnienia, światło nocne, tryb nie przeszkadzać i pozostawanie w czuwaniu.

Nieaktywne wskaźniki są ukryte. Najedź kursorem w dowolne miejsce na pasku, a pojawią się przyciemnione, więc możesz kliknąć jeden z nich, aby go włączyć, nie znając jego skrótu klawiszowego. Kliknięcie aktywnego wskaźnika wyłącza go z powrotem. Jeśli wolisz widzieć je wszystkie przez cały czas, ustaw `alwaysShow` na `true` we wpisie `omarchy.indicators` w `~/.config/omarchy/shell.json` — zobacz [górny pasek](05-the-top-bar.md), aby dowiedzieć się, jak konfigurowane są widżety paska.

### Światło nocne

Światło nocne ociepla ekran do 4000K, a ponowne przełączenie przywraca go do 6500K. Przełącz je z menu przełączników (`Super + Ctrl + O`) albo poleceniem `omarchy toggle nightlight`. Obsługuje je hyprsunset, który przełącznik uruchomi za ciebie, jeśli jeszcze nie działa.

Domyślnie hyprsunset w ogóle nic nie robi z twoim ekranem. Plik `~/.config/hypr/hyprsunset.conf` jest dostarczany z profilem tożsamościowym właśnie po to, aby wyświetlacz pozostawał nietknięty, dopóki nie poprosisz o ciepło. Jeśli wolisz, aby przełączał się według zegara, zastąp go profilem czasowym:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Następnie uruchamiaj hyprsunset przy logowaniu, dodając `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Para 4000K/6500K używana przez przełącznik jest stała, więc plik konfiguracyjny to miejsce, do którego się udajesz, jeśli chcesz inną temperaturę.

### Nie przeszkadzać

`Super + Ctrl + Alt + ,` wycisza powiadomienia. Gdy jest włączone, nie wyskakują żadne powiadomienia, a przekreślony dzwonek na pasku przypomina ci, dlaczego na pulpicie zrobiło się cicho.

Nic jednak nie ginie. Wyciszone powiadomienia są wstrzymywane: przywróć kilka ostatnich na ekran poleceniem `Super + Shift + Alt + ,`. Zobacz [powiadomienia](10-notices.md), aby dowiedzieć się reszty.

Dwa rodzaje wiadomości nadal się przedostają: własne powiadomienia potwierdzające Omarchy dotyczące czegoś, co właśnie zrobiłeś („Motyw zmieniony”, „Zrzut ekranu zapisany”), oraz alerty krytyczne wysłane z wiersza poleceń. Aplikacje czatu, które oznaczają wszystko jako krytyczne, aby wymusić swoją obecność przed tobą, nie kwalifikują się.

### Bezczynność

Powłoka Omarchy zarządza zachowaniem w bezczynności, a czasy są najwyższego poziomu blokiem `idle` w `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obie liczby to sekundy liczone od momentu przejścia w stan bezczynności — nie od siebie nawzajem. Zatem przy ustawieniach domyślnych wygaszacz ekranu pojawia się po dwóch i pół minuty, a ekran blokady przejmuje kontrolę po pięciu minutach, niezależnie od tego, czy wygaszacz ekranu się uruchomił. Zapisz plik, a powłoka od razu odbierze nowe czasy.

Jeśli odrzucisz wygaszacz ekranu przed upływem terminu blokady, liczy się to jako aktywność, a oczekująca blokada jest anulowana. Nie zostaniesz zablokowany za zerkanie na swoją maszynę.

Aby całkowicie przestać blokować przy bezczynności, `Super + Ctrl + I` — albo `omarchy toggle idle` — włącza pozostawanie w czuwaniu, a na pasku pojawia się wskaźnik filiżanki kawy. To ten, który należy nacisnąć przed długą prezentacją albo kompilacją, którą chcesz obserwować. Naciśnij go ponownie, aby wrócić do normalnego działania. `omarchy toggle idle status` wypisuje bieżący stan jako JSON, jeśli potrzebujesz go ze skryptu.

Chodzi tu o blokowanie i wygaszacz ekranu, nie o zasilanie. Uśpienie i hibernacja mają własną konfigurację w [uśpieniu systemu](36-system-sleep.md).

### Wygaszacz ekranu

Wygaszacz ekranu Omarchy to grafika ASCII przechodząca przez losowe efekty tekstowe, po jednej instancji na monitor. Dowolny klawisz lub ruch myszy go wyłącza.

Możesz uruchomić go na żądanie z _System > Screensaver_ (`Super + Esc`), co wymusza jego pojawienie się, nawet jeśli wyłączyłeś wygaszacz ekranu w bezczynności. Domyślnie nie jest do niego przypisany żaden skrót klawiszowy.

`omarchy toggle screensaver` to polecenie, które wyłącza ten w bezczynności, jeśli wolisz przechodzić bezpośrednio od pracy do blokady. Potrzebuje terminala, który wie, jak skonfigurować — Alacritty, Foot, Ghostty albo Kitty — i powie ci o tym, jeśli twoim domyślnym terminalem jest coś innego.

Logo, które rysuje, możesz zmienić w _Appearance > Branding > Screensaver_. Prześlij png lub svg, a Omarchy przekształci je w ASCII. Zobacz [identyfikację wizualną](41-branding.md).

### Ekran blokady

`Super + Ctrl + L` blokuje maszynę. Uruchamia to ekran blokady z powłoki Omarchy, wygasza wyświetlacz, resetuje układ klawiatury do pierwszego, abyś nie wpisywał hasła w niewłaściwym alfabecie, oraz — jeśli masz go uruchomionego — blokuje po drodze 1Password.

Ekran blokady przyjmuje hasło, a przyjmie też odcisk palca, gdy już go skonfigurujesz. To oraz inne sposoby uwierzytelniania są opisane w [uwierzytelnianiu sprzętowym](37-hardware-authentication.md).
