# Uwierzytelnianie sprzętowe

### Uwierzytelnianie odciskiem palca

Wiele laptopów ma czytnik linii papilarnych do uwierzytelniania. Możesz używać go w Omarchy, uruchamiając _Konfiguracja > Bezpieczeństwo > Odcisk palca_ w menu Omarchy (`Super + Space`).

To zainstaluje pakiet obsługi odcisku palca, pobierze Twój odcisk, zweryfikuje go i będziesz gotowy, aby używać odcisku palca do odblokowywania ekranu blokady (który możesz wywołać za pomocą `Super + Ctrl + L`), przechodzenia w tryb sudo i zatwierdzania monitów systemowych.

Gdy ekran blokady wyłączy wyświetlacz, czytnik przechodzi w stan spoczynku, aby oszczędzać energię, więc przed dotknięciem go wybudź ekran dowolnym klawiszem lub touchpadem.

Gdy pokrywa laptopa jest zamknięta, monit o odcisk palca jest automatycznie pomijany, więc przechodzisz od razu do monitu o hasło, zamiast czekać na czytnik, do którego nie masz dostępu. Jeśli w innych sytuacjach musisz pracować na zewnętrznej klawiaturze, która nie ma czytnika, po prostu naciśnij `CTRL + C`, gdy podczas `sudo` pojawi się monit o odcisk palca.

Uwierzytelnianie odciskiem palca możesz usunąć w _Usuń > Bezpieczeństwo > Odcisk palca_ w menu Omarchy.

### Uwierzytelnianie Fido2

Jeśli używasz urządzenia Fido2, możesz skonfigurować je do uwierzytelniania `sudo` za pomocą _Konfiguracja > Bezpieczeństwo > Fido2_ w menu Omarchy (`Super + Space`). Obejmuje ono jednak `sudo` i monity o autoryzację systemową, a nie odblokowywanie komputera.

Uwierzytelnianie fido2 możesz usunąć w _Usuń > Bezpieczeństwo > Fido2_ w menu Omarchy.
