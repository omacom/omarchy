# Instalacje nienadzorowane

Obraz ISO Omarchy potrafi zainstalować się sam, gdy nikogo nie ma przy klawiaturze. Jeśli instalator znajdzie drugi dysk o etykiecie `cidata` niosący jego pliki konfiguracyjne, kopiuje je stamtąd, całkowicie pomija kreatora konfiguracji i sam restartuje się do gotowego systemu. Żadnej specjalnej kompilacji ISO, żadnej dodatkowej pozycji w menu rozruchowym — gdy taki dysk nie jest podłączony, nic się nie zmienia i dostajesz zwykłego kreatora.

Dzięki temu Omarchy świetnie nadaje się na obraz bazowy dla jednorazowych środowisk programistycznych: utwórz maszynę wirtualną w Proxmoksie albo Packerem, uruchom ją, odejdź, zaloguj się przez SSH. `cidata` to etykieta `NoCloud` z cloud-init, więc wszystkie popularne narzędzia do wirtualizacji już wiedzą, jak podłączyć taki dysk.

## Pliki konfiguracyjne

Te pliki są dokładnie tym, co zapisuje własny kreator instalatora, więc najłatwiejszym sposobem zdobycia zestawu startowego jest uruchomienie jednej instalacji interaktywnej (powiedzmy w maszynie wirtualnej) i skopiowanie tego, co zapisała w `/root`:

| Plik | Wymagany | Przeznaczenie |
|------|----------|---------|
| `user_configuration.json` | Tak | Dysk, nazwa hosta, strefa czasowa, klawiatura |
| `user_credentials.json` | Tak | Nazwa użytkownika i skrót hasła |
| `user_full_name.txt` | Nie | Pełne imię i nazwisko dla Gita |
| `user_email_address.txt` | Nie | Adres e-mail dla Gita |
| `user_encrypt_installation.txt` | Nie | `true`, gdy konfiguracja zawiera blok `disk_encryption` |
| `authorized_keys` | Nie | Klucze publiczne SSH, po jednym w wierszu |
| `tailscale_authkey` | Nie | Klucz autoryzacji Tailscale do dołączenia do twojego tailnetu przy pierwszym rozruchu |

Skrót hasła dla `user_credentials.json` wygeneruj poleceniem `openssl passwd -6 "yourpassword"`.

Zamiast `user_credentials.json` możesz też umieścić pusty plik o nazwie `defer-provisioning`. Uruchamia to tę samą [instalację przygotowaną dla innego właściciela](02-getting-started.md), którą możesz wywołać interaktywnie: komputer instaluje się bez żadnych danych osobistych, a kto uruchomi go pierwszy, wybiera swoją klawiaturę i tworzy swojego użytkownika. To tryb dla stanowisk do obrazowania dysków, gdzie dysk nie powinien zawierać niczyich danych uwierzytelniających.

## Dostęp przez SSH

Gdy `authorized_keys` jest obecny, instalacja ustawia te klucze jako `~/.ssh/authorized_keys` użytkownika, włącza `sshd` i otwiera dla niego zaporę. (Standardowa instalacja Omarchy dostarcza openssh z wyłączoną usługą i zamkniętym portem, więc nienadzorowany komputer byłby w przeciwnym razie nieosiągalny). Instalacja tylko dodaje twoje klucze — nie osłabia żadnych innych ustawień uwierzytelniania demona SSH.

Gdy `tailscale_authkey` jest obecny, komputer przy pierwszym rozruchu dołącza za to do twojego tailnetu: Tailscale jest instalowany z pakietów dołączonych do ISO, zapora przepuszcza interfejs tailnetu, a zadanie w tle uruchamia dołączanie, gdy tylko komputer faktycznie ma sieć, ponawiając próby, aż się uda. Używaj klucza wielokrotnego użytku i wstępnie autoryzowanego, aby jeden obraz dysku mógł obsłużyć wiele komputerów.

## Budowanie dysku cidata

Działa każdy system plików z właściwą etykietą. Malutkie ISO to łatwy sposób:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Potem podłącz je do maszyny wirtualnej obok obrazu ISO Omarchy. Oto pełny przykład dla Proxmoxa:

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

Kolejność rozruchu celowo wymienia dysk jako pierwszy: pusty dysk przy pierwszym rozruchu przechodzi dalej do ISO, a zainstalowany system od tej pory uruchamia się z dysku.

## Dwa zastrzeżenia

Szyfrowane instalacje nienadzorowane nie są w pełni nienadzorowane — ktoś przy pierwszym rozruchu nadal musi wpisać frazę LUKS. A blok `disk_encryption` w `user_configuration.json` zawiera tę frazę w postaci jawnego tekstu, więc traktuj dysk cidata zbudowany z zaszyfrowanej instalacji jak sekret, którym jest.
