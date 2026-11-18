# 무인 설치

Omarchy ISO는 키보드 앞에 아무도 없어도 스스로 설치할 수 있다. 설치 프로그램이 설정 파일을 담은 `cidata`라는 레이블의 두 번째 드라이브를 발견하면, 그 파일을 복사하고, 설정 마법사를 완전히 건너뛰고, 완성된 시스템으로 스스로 재부팅한다. 특별한 ISO 빌드도, 추가 부팅 메뉴 항목도 없다 — 그런 드라이브가 연결되어 있지 않으면 아무것도 달라지지 않고 평소처럼 마법사가 실행된다.

덕분에 Omarchy는 일회용 개발 환경의 베이스 이미지로 훌륭하다: Proxmox나 Packer로 VM을 만들고, 부팅한 뒤, 자리를 비우고, SSH로 접속하면 된다. `cidata`는 cloud-init의 `NoCloud` 레이블이므로, 일반적인 가상화 도구는 모두 그런 드라이브를 연결하는 방법을 이미 알고 있다.

## 설정 파일

이 파일들은 설치 프로그램의 마법사가 직접 쓰는 것과 정확히 같으므로, 시작 세트를 얻는 가장 쉬운 방법은 대화형 설치를 한 번 실행하고(예를 들어 VM에서) `/root`에 쓴 내용을 복사하는 것이다:

| 파일 | 필수 | 용도 |
|------|----------|---------|
| `user_configuration.json` | Yes | 디스크, 호스트 이름, 시간대, 키보드 |
| `user_credentials.json` | Yes | 사용자 이름 및 비밀번호 해시 |
| `user_encrypt_installation.txt` | No | 구성에 `disk_encryption` 블록이 포함된 경우 `true` |
| `authorized_keys` | No | SSH 공개 키, 한 줄에 하나씩 |
| `tailscale_authkey` | No | 첫 부팅 시 tailnet에 참여하기 위한 Tailscale 인증 키 |

`user_credentials.json`용 비밀번호 해시는 `openssl passwd -6 "yourpassword"`로 생성한다.

git 커밋용 이름과 이메일은 설치에 포함되지 않는다. 컴퓨터가 부팅된 뒤, 예를 들어 SSH를 통해 `omarchy setup git --name "Jane Doe" --email jane@example.com`으로 설정한다.

`user_credentials.json` 대신 `defer-provisioning`이라는 이름의 빈 파일을 넣을 수도 있다. 그러면 대화형으로도 실행할 수 있는 [다른 소유자를 위해 준비하는 설치](02-getting-started.md)와 같은 설치가 실행된다: 개인 정보 없이 컴퓨터가 설치되고, 처음 부팅하는 사람이 키보드를 선택하고 사용자를 만든다. 드라이브에 누구의 자격 증명도 담겨서는 안 되는 이미징 장비용 모드가 바로 이것이다.

## SSH 액세스

`authorized_keys`가 있으면 설치 과정에서 그 키를 사용자의 `~/.ssh/authorized_keys`로 설정하고, `sshd`를 활성화하고, 방화벽에서 이를 허용한다. (기본 Omarchy 설치는 서비스가 비활성화되고 포트가 닫힌 openssh를 제공하므로, 그렇지 않으면 무인 컴퓨터에 접근할 수 없다.) 설치 과정에서는 키만 추가한다 — SSH 데몬의 다른 인증 설정은 전혀 완화하지 않는다.

`tailscale_authkey`가 있으면 컴퓨터는 대신 첫 부팅 시 tailnet에 참여한다: Tailscale은 ISO에 포함된 패키지에서 설치되고, 방화벽은 tailnet 인터페이스를 허용하며, 백그라운드 작업이 컴퓨터에 실제로 네트워크가 연결되는 즉시 참여를 실행하고 성공할 때까지 재시도한다. 하나의 드라이브 이미지로 여러 컴퓨터에 사용할 수 있도록 재사용 가능하고 사전 승인된 키를 사용한다.

## cidata 드라이브 만들기

레이블만 맞으면 어떤 파일 시스템이든 작동한다. 작은 ISO가 쉬운 방법이다:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

그런 다음 Omarchy ISO와 함께 VM에 연결한다. 다음은 Proxmox 전체 예시다:

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

부팅 순서에 디스크를 먼저 나열한 것은 의도적이다: 빈 디스크는 첫 부팅에서 ISO로 넘어가고, 그 이후로는 설치된 시스템이 항상 디스크에서 부팅된다.

## 두 가지 주의 사항

암호화된 무인 설치는 완전히 무인은 아니다 — 첫 부팅 시 누군가가 여전히 LUKS 암호를 입력해야 한다. 그리고 `user_configuration.json`의 `disk_encryption` 블록에는 그 암호가 평문으로 담겨 있으므로, 암호화된 설치로 만든 cidata 드라이브는 비밀 그 자체로 취급해야 한다.
