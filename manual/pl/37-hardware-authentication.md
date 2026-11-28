# Uwierzytelnianie sprzętowe

### Uwierzytelnianie odciskiem palca

Wiele laptopów jest wyposażonych w czytnik linii papilarnych służący do uwierzytelniania. Możesz używać go w Omarchy, wybierając _Konfiguracja > Bezpieczeństwo > Odcisk palca_ w menu Omarchy (`Super + Space`).

Spowoduje to otwarcie pełnoekranowego odcisku palca, który wypełnia się w miarę dotykania czytnika. W tle Omarchy zainstaluje pakiet obsługi odcisków palców, zarejestruje Twój odcisk, zweryfikuje go i wszystko będzie gotowe, abyś mógł używać odcisku palca do odblokowywania z ekranu blokady (który możesz wywołać za pomocą `Super + Ctrl + L`), przechodzenia w tryb sudo oraz autoryzowania monitów systemowych.

Gdy ekran blokady wyłączy wyświetlacz, czytnik przechodzi w stan spoczynku, aby oszczędzać energię, więc przed dotknięciem go wybudź ekran dowolnym klawiszem lub touchpadem.

Gdy pokrywa laptopa jest zamknięta, monit o odcisk palca jest automatycznie pomijany, więc od razu przechodzisz do monitu o hasło, zamiast czekać na czytnik, do którego nie masz dostępu. Jeśli z innego powodu musisz pracować na zewnętrznej klawiaturze bez czytnika, po prostu naciśnij `CTRL + C`, gdy podczas używania `sudo` pojawi się monit o odcisk palca.

Uwierzytelnianie odciskiem palca możesz usunąć, wybierając _Usuń > Bezpieczeństwo > Odcisk palca_ w menu Omarchy.

### Uwierzytelnianie Fido2

Jeśli używasz urządzenia Fido2, możesz skonfigurować je do uwierzytelniania `sudo`, wybierając _Konfiguracja > Bezpieczeństwo > Fido2_ w menu Omarchy (`Super + Space`). Obejmuje to jednak monity `sudo` i autoryzacji systemowej, a nie odblokowywanie komputera.

Uwierzytelnianie fido2 możesz usunąć, wybierając _Usuń > Bezpieczeństwo > Fido2_ w menu Omarchy.
