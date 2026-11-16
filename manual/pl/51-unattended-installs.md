# Instalacje nienadzorowane

Obraz ISO Omarchy może zainstalować się sam, bez nikogo przy klawiaturze. Jeśli instalator znajdzie drugi dysk o etykiecie `cidata` zawierający jego pliki konfiguracyjne, skopiuje je, całkowicie pominie kreator konfiguracji i samodzielnie zrestartuje się do gotowego systemu. Nie potrzeba żadnego specjalnego obrazu ISO ani dodatkowej pozycji w menu rozruchowym — bez takiego dysku nic się nie zmienia i dostajesz normalny kreator.

Dzięki temu Omarchy świetnie sprawdza się jako obraz bazowy dla jednorazowych środowisk deweloperskich: tworzysz VM w Proxmox albo za pomocą Packer, uruchamiasz ją, odchodzisz, logujesz się przez SSH. `cidata` to etykieta `NoCloud` z cloud-init, więc wszystkie popularne narzędzia do wirtualizacji już wiedzą, jak podłączyć taki dysk.

## Pliki konfiguracyjne

Te pliki to dokładnie to, co zapisuje własny kreator instalatora, więc najłatwiej zdobyć zestaw startowy, przeprowadzając jedną instalację interaktywną (na przykład w VM) i kopiując to, co zapisał w `/root`:

| Plik | Wymagany | Przeznaczenie |
|------|----------|---------|
| `user_configuration.json` | Tak | Dysk, nazwa hosta, strefa czasowa, klawiatura |
| `user_credentials.json` | Tak | Nazwa użytkownika i hash hasła |
| `user_encrypt_installation.txt` | Nie | `true`, gdy konfiguracja zawiera blok `disk_encryption` |
| `authorized_keys` | Nie | Klucze publiczne SSH, jeden w wierszu |
| `tailscale_authkey` | Nie | Klucz uwierzytelniający Tailscale do dołączenia do Twojej sieci tailnet przy pierwszym uruchomieniu |

Hash hasła do `user_credentials.json` wygeneruj poleceniem `openssl passwd -6 "yourpassword"`.

Nazwa i adres e-mail do commitów w git nie są częścią instalacji. Ustaw je, gdy maszyna już działa, na przykład przez SSH, poleceniem `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Możesz też zamiast `user_credentials.json` umieścić pusty plik o nazwie `defer-provisioning`. Uruchamia to tę samą [instalację z przygotowaniem dla innego właściciela](02-getting-started.md), którą możesz wywołać interaktywnie: maszyna instaluje się bez żadnych danych osobowych, a osoba, która uruchomi ją jako pierwsza, wybiera swoją klawiaturę i tworzy swoje konto. To tryb dla stanowisk do tworzenia obrazów, w których dysk nie powinien zawierać niczyich danych logowania.

## Dostęp SSH

Gdy obecny jest plik `authorized_keys`, instalator ustawia te klucze jako `~/.ssh/authorized_keys` użytkownika, włącza `sshd` i otwiera dla niego zaporę. (Standardowa instalacja Omarchy dostarcza openssh z wyłączoną usługą i zamkniętym portem, więc maszyna instalowana bez nadzoru byłaby w przeciwnym razie nieosiągalna.) Instalator tylko dodaje Twoje klucze — nie poluzowuje żadnych innych ustawień uwierzytelniania demona SSH.

Gdy obecny jest plik `tailscale_authkey`, maszyna przy pierwszym uruchomieniu dołącza zamiast tego do Twojej sieci tailnet: Tailscale jest instalowany z pakietów dołączonych do obrazu ISO, zapora dopuszcza interfejs tailnet, a zadanie w tle wykonuje dołączenie, gdy tylko maszyna faktycznie uzyska dostęp do sieci, ponawiając próby aż do skutku. Użyj klucza wielokrotnego użytku, wstępnie autoryzowanego, aby jeden obraz dysku mógł obsłużyć wiele maszyn.

## Tworzenie dysku cidata

Zadziała dowolny system plików z właściwą etykietą. Mały obraz ISO to najprostszy sposób:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Następnie podłącz go do VM obok obrazu ISO Omarchy. Oto pełny przykład dla Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Kolejność rozruchu celowo stawia dysk na pierwszym miejscu: pusty dysk przy pierwszym uruchomieniu przechodzi dalej do obrazu ISO, a zainstalowany system już zawsze uruchamia się z dysku.

## Dwa zastrzeżenia

Zaszyfrowane instalacje nienadzorowane nie są w pełni nienadzorowane — ktoś nadal musi wpisać hasło LUKS przy pierwszym uruchomieniu. A blok `disk_encryption` w `user_configuration.json` przechowuje to hasło w postaci zwykłego tekstu, więc dysk cidata zbudowany na podstawie zaszyfrowanej instalacji traktuj jak sekret, którym jest.
