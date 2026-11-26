# Instalacje bezobsługowe

Obraz ISO Omarchy może zainstalować się sam, bez nikogo przy klawiaturze. Jeśli instalator znajdzie drugi dysk z etykietą `cidata`, na którym znajdują się jego pliki konfiguracyjne, kopiuje je, całkowicie pomija kreator konfiguracji i samodzielnie restartuje się do gotowego systemu. Nie potrzeba specjalnej kompilacji ISO ani dodatkowej pozycji w menu rozruchowym — bez podłączonego takiego dysku nic się nie zmienia i otrzymujesz normalny kreator.

Dzięki temu Omarchy świetnie sprawdza się jako obraz bazowy dla jednorazowych środowisk deweloperskich: tworzysz VM w Proxmox albo za pomocą Packer, uruchamiasz ją, odchodzisz i logujesz się przez SSH. `cidata` to etykieta `NoCloud` z cloud-init, więc wszystkie popularne narzędzia do wirtualizacji już wiedzą, jak podłączyć taki dysk.

## Pliki konfiguracyjne

Pliki te są dokładnie tym, co zapisuje kreator samego instalatora, więc najłatwiejszy sposób na uzyskanie początkowego zestawu to przeprowadzenie jednej instalacji interaktywnej (na przykład w VM) i skopiowanie tego, co zapisał w `/root`:

| Plik | Wymagany | Przeznaczenie |
|------|----------|---------|
| `user_configuration.json` | Tak | Dysk, nazwa hosta, strefa czasowa, klawiatura |
| `user_credentials.json` | Tak | Nazwa użytkownika i hash hasła oraz hasło LUKS dla instalacji szyfrowanej |
| `user_encrypt_installation.txt` | Nie | `true`, gdy konfiguracja zawiera blok `disk_encryption` |
| `authorized_keys` | Nie | Klucze publiczne SSH, jeden w linii |
| `tailscale_authkey` | Nie | Klucz uwierzytelniający Tailscale służący do dołączenia do Twojej sieci tailnet przy pierwszym uruchomieniu |

Wygeneruj hash hasła do `user_credentials.json` za pomocą `openssl passwd -6 "yourpassword"`.

Nazwa i adres e-mail do commitów git nie są częścią instalacji. Ustaw je, gdy maszyna już działa, na przykład przez SSH, za pomocą `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Możesz też umieścić pusty plik o nazwie `defer-provisioning` zamiast `user_credentials.json`. Uruchamia to tę samą [instalację w trybie przygotowania dla innego właściciela](02-getting-started.md), którą możesz wywołać interaktywnie: maszyna instaluje się bez żadnych danych osobistych, a osoba, która uruchomi ją jako pierwsza, wybiera swoją klawiaturę i tworzy swojego użytkownika. To tryb dla stanowisk do tworzenia obrazów, w których dysk nie powinien zawierać niczyich danych uwierzytelniających.

## Dostęp SSH

Gdy obecny jest plik `authorized_keys`, instalacja ustawia klucze jako `~/.ssh/authorized_keys` użytkownika, włącza `sshd` i otwiera dla niego zaporę sieciową. (Standardowa instalacja Omarchy dostarcza openssh z wyłączoną usługą i zamkniętym portem, więc maszyna bezobsługowa byłaby w przeciwnym razie nieosiągalna.) Instalacja tylko dodaje Twoje klucze — nie poluzowuje żadnych innych ustawień uwierzytelniania demona SSH.

Gdy obecny jest plik `tailscale_authkey`, maszyna zamiast tego dołącza do Twojej sieci tailnet przy pierwszym uruchomieniu: Tailscale jest instalowany z pakietów dołączonych do ISO, zapora sieciowa zezwala na interfejs tailnet, a zadanie w tle przeprowadza dołączenie, gdy tylko maszyna faktycznie uzyska dostęp do sieci, ponawiając próby do skutku. Użyj klucza wielokrotnego użytku, wstępnie autoryzowanego, aby jeden obraz dysku mógł obsłużyć wiele maszyn.

## Tworzenie dysku cidata

Działa dowolny system plików z odpowiednią etykietą. Mały obraz ISO to łatwy sposób:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Następnie podłącz go do VM obok obrazu ISO Omarchy. Oto kompletny przykład dla Proxmox:

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

Kolejność rozruchu celowo umieszcza dysk na pierwszym miejscu: pusty dysk przy pierwszym uruchomieniu przechodzi dalej do ISO, a zainstalowany system od tej pory zawsze uruchamia się z dysku.

## Dwa zastrzeżenia

Szyfrowane instalacje bezobsługowe nie są w pełni bezobsługowe — ktoś nadal musi wpisać hasło LUKS przy pierwszym uruchomieniu. A hasło to umieszcza się na najwyższym poziomie `user_credentials.json` jako `encryption_password` — archinstall odczytuje je właśnie tam, a nie z bloku `disk_encryption` w `user_configuration.json` — więc traktuj dysk cidata utworzony na podstawie szyfrowanej instalacji jako sekret, którym rzeczywiście jest.
