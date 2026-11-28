# GUI

## Files

Files (Folio)는 그래픽 파일 관리자입니다. `Super + Shift + F`로 열 수 있고, `Super + Shift + Alt + F`로 열면 터미널이 현재 위치한 디렉터리에서 열리므로 클릭을 많이 줄일 수 있습니다. `Ctrl + L`을 누르면 경로를 입력할 수 있고, 아무 파일에서나 `Space`를 누르면 열지 않고도 전체 크기로 미리 볼 수 있습니다.

USB 스틱이나 SD 카드를 꽂으면 자동으로 마운트되어 사이드바에 바로 나타납니다. 드라이브 포맷, SMART 상태 확인, 파티션 만들기처럼 더 복잡한 작업이 필요하면 앱 실행기(`Super + Space`)에서 _Disks_를 실행하세요.

암호화된 드라이브는 꽂으면 비밀번호를 묻습니다. 드라이브가 스스로 잠금 해제되게 하려면 `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>`로 키파일을 추가하고, 그 키파일을 `~/.config/omarchy/drive-keys/<UUID>`에 두세요. 파일 이름은 암호화된 파티션에 대해 `lsblk -dno UUID /dev/sdX1`가 출력하는 UUID로 지정하고, 나만 읽을 수 있게 하세요(`chmod 600`). 그 키파일이 없거나 거부되면 평소처럼 비밀번호를 묻습니다.

더블클릭은 합리적인 기본값을 따릅니다: 사진, 동영상, 음악은 Omaview에서, PDF는 Document Viewer에서, Markdown은 Omawrite에서, 일반 텍스트는 편집기에서 열리며, _설정 > 기본값 > 편집기_에서 다른 것을 선택하지 않았다면 기본값은 Plain입니다.

## Disktree

드라이브가 가득 찼는데 무엇이 공간을 잡아먹고 있는지 모르겠다면 앱 실행기(`Super + Space`)에서 [Disktree](https://github.com/tobi/disktree)를 실행하세요. 홈 디렉터리를 그래픽 트리맵으로 보여줍니다. 블록이 클수록 더 많은 공간을 차지합니다; 키보드나 마우스로 디렉터리 안으로 들어가 지울 대상을 표시하고, 아무것도 제거하기 전에 선택 항목을 검토하세요. 전체 디스크를 스캔하려면 `disktree --disk`를 실행하세요.

## Obsidian

[Obsidian](https://obsidian.md/)은 단순한 Markdown 파일을 저장소로 사용하는 무료이면서 확장성이 뛰어난 노트 작성 애플리케이션입니다.

Obsidian은 개인, 상업, 비영리 등 모든 용도로 무료입니다.

Obsidian은 iOS와 Android의 모바일 앱과 동기화할 수 있는 [동기화용 상용 애드온](https://obsidian.md/sync)도 제공합니다. (https://obsidian.md/pricing).

Obsidian은 `Super + Shift + O`로 시작합니다. 테마 동기화를 사용하려면 설정에서 `Omarchy` 테마를 선택해야 합니다.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite)는 Omarchy 자체의 아주 단순한 Markdown 글쓰기 앱입니다. 보관함도, 플러그인도 없고, 오직 당신과 글만 있습니다.

Omawrite는 `Super + Shift + W`로 시작합니다.

## Pinta

[Pinta](https://www.pinta-project.com/)는 자르기, 크기 조정, 그 밖의 기본적인 편집에 좋은 기본 이미지 편집 도구입니다. Photoshop 대안을 기대하지는 마세요. 그래도 Magic Wand와 레이어는 있습니다!

Pinta는 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다.

## Aether

[Aether](https://github.com/bjarneo/aether)는 배경 이미지에서 색상을 추출해 완성도 있고 조화로운 테마로 바꿔주는 테마 애플리케이션입니다. [나만의 테마를 만드는](43-making-your-own-theme.md) 가장 쉬운 방법입니다.

Aether는 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다.

## LocalSend

[LocalSend](https://localsend.org/)를 사용하면 Apple의 AirDrop처럼 같은 네트워크에서 앱을 실행 중인 다른 기기로 파일을 보낼 수 있습니다. 다만 크로스 플랫폼이므로 Windows, macOS, Android, iOS, 그리고 물론 Linux와도 파일을 주고받을 수 있습니다.

공유 메뉴는 `Super + Ctrl + S`로 열거나 Omarchy 메뉴의 _실행 > 공유_에서 열 수 있습니다. 네 가지 옵션이 제공됩니다:

- **Clipboard**는 복사한 내용을 텍스트 파일로 보냅니다. 링크나 코드 조각을 자신에게 이메일로 보내지 않고 휴대폰으로 옮기기에 좋습니다.
- **File**은 한 번에 여러 개를 선택할 수 있는 파일 선택기를 엽니다.
- **Folder**는 디렉터리 전체를 보냅니다.
- **Receive**는 LocalSend 자체를 열어 다른 기기가 당신에게 무언가를 보낼 수 있게 합니다.

터미널에서도 `omarchy share clipboard`, `omarchy share file [path]`, `omarchy share folder [path]`로 같은 작업을 할 수 있습니다. 경로를 생략하면 선택기가 나타납니다.

파일 관리자에서 바로 보낼 수도 있습니다: Files에서 선택 항목을 마우스 오른쪽 버튼으로 클릭하고 LocalSend로 공유하세요.

Omarchy의 방화벽은 기본적으로 닫혀 있지만 LocalSend 포트만 예외이므로, 새로 설치한 상태에서도 바로 작동합니다. [보안](48-security.md)을 참조하세요.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/)는 워드 프로세서, 스프레드시트, 프레젠테이션, 드로잉 애플리케이션 등을 갖춘 완전한 오피스 패키지입니다. Microsoft Office 파일과 호환되므로, 그런 Word 문서를 열 수 있는 좋은 방법입니다.

LibreOffice는 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다.

## Hype

[Hype](https://github.com/omacom/hype)는 Omarchy 자체의 아주 단순한 프레젠테이션 앱입니다. 덱은 이미지와 동영상이 옆에 있는 단일 Markdown 파일입니다: 실시간 미리보기 아래에 각 슬라이드를 작성하고, 슬라이드를 드래그해 순서를 정한 뒤, 전체 화면으로 프레젠테이션하거나 PDF와 PowerPoint로 내보내세요. Omarchy 테마도 반영합니다.

Hype는 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다. 안에서 `?`를 누르면 모든 단축키를 볼 수 있습니다.

## Signed

[Signed](https://github.com/omacom/signed)는 PDF에 서명하고 내용을 채우는 Omarchy 자체의 아주 단순한 방법입니다. 페이지 원하는 곳에 저장된 서명, 텍스트, 오늘 날짜를 놓고, 원본 옆에 서명된 사본을 저장하세요. 방법은 [PDF 작성하기](27-filling-out-pdfs.md)를 참조하세요.

Signed는 애플리케이션 실행기(`Super + Space`)를 통해 시작하거나, 파일 관리자에서 PDF를 이 앱으로 열 수 있습니다.

## Game Vibes

애플리케이션 실행기(`Super + Space`)에 있는 Game Vibes는 Omarchy의 작은 게임들이 있는 곳입니다: 친구나 내장된 상대와 대결하는 3D 체스 게임 Checkmate; Klondike 솔리테어인 Cards; 가시와 톱으로 가득한 방 열 개로 이루어진 픽셀 단위로 정밀한 플랫폼 게임 Death Wish; 그리고 아케이드 슈팅 게임 Neon Swarm이 있습니다. 각 게임은 테마를 따르는 단일 웹 페이지입니다. 화살표 키와 `Enter`로 하나를 선택하고, 게임 제목 화면에서는 `Esc`로, 일시 정지 중에는 `Q`로 목록으로 돌아오세요. 전체 화면으로 열립니다: `Super + F`를 누르면 창이 되고, `Super + W`를 누르면 닫힙니다.

에이전트로 만든 게임도 여기에 나타납니다: 에이전트 패널에서 _멋진 것 만들기 → 게임_을 선택하고 게임을 설명하거나, Game Vibes에 이미 있는 게임을 이름으로 지정해 계속 작업하세요. 에이전트는 게임을 `~/Games/vibes`로 복사하는데, 그곳에서는 당신이 자유롭게 바꿀 수 있으며, 완성되면 열어줍니다. `omarchy games vibes copy <game>`으로 직접 그 사본을 만들 수도 있습니다. 다른 사람이 공유한 게임은 테마처럼 설치합니다: _설치 > 게임 > Game Vibes_를 선택하고 git 주소를 붙여넣거나, `omarchy games vibes install <git-repo-url>`을 실행하세요. _제거 > 게임_으로 다시 제거하고, _업데이트 > Game Vibes 게임_으로 새 버전을 가져옵니다. 게임은 웹에서 three.js를 불러오므로, 시작하려면 연결이 필요합니다.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc)는 떠 있는 창으로 열리는 Omarchy 자체의 아주 단순한 계산기입니다.

Omacalc는 `Super + Shift + Q`로 시작합니다(또는 키보드에 계산기 키가 있다면 그 키로도 됩니다).

## Signal

[Signal](https://signal.org/)은 E2E 암호화 메시징의 선구자이며, 거대 기술 대기업을 거치고 싶지 않은 누구에게나 훌륭한 커뮤니케이션 선택지입니다.

Signal은 `Super + Shift + G`로 시작합니다. 기본 설치에는 포함되어 있지 않으므로, 처음 그 키를 누르면 Omarchy가 설치를 제안합니다(Omarchy 메뉴의 _설치 > 서비스_에도 있습니다).

## Omaview

[Omaview](https://github.com/omacom/omaview)는 사진, 동영상, 음악을 하나의 창에서 볼 수 있는 Omarchy 자체의 아주 단순한 사진 뷰어이자 미디어 플레이어입니다. 사진을 열면 화살표 키로 같은 폴더의 나머지 항목을 차례로 볼 수 있고, `N`과 `P`는 어떤 파일에서든 그렇게 하며, `Ctrl + M`은 폴더 전체를 격자로 보여줍니다. HEIC, AVIF, JPEG XL 사진도 보여주고, 긴 콘텐츠에서는 중단했던 지점부터 이어서 재생합니다.

`F`를 누르면 전체 화면, `E`를 누르면 Omasnap에서 사진을 편집하거나 Omacut에서 동영상을 다듬고, `Ctrl + P`를 누르면 사진을 인쇄하고, `Delete`를 누르면 파일을 휴지통으로 이동합니다(`Ctrl + Z`를 누르면 되돌립니다). 안에서 `?`를 누르면 모든 단축키를 볼 수 있습니다.

Omaview는 애플리케이션 실행기(`Super + Space`)에서 _미디어 뷰어_로 시작하거나, 파일 관리자에서 사진, 동영상, 노래를 더블클릭하면 됩니다.

## Omacut

[Omacut](https://github.com/omacom-io/omacut)은 Omarchy 자체의 아주 단순한 동영상 트리머입니다. 클립의 시작과 끝만 잘라내면 될 때는 완전한 동영상 편집기를 실행하는 것보다 낫습니다.

Omacut은 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다.

## Monologue

[Monologue](https://github.com/omacom/monologue)는 Omarchy 자체의 아주 단순한 웹캠 레코더입니다. 카메라와 마이크를 한 번 선택한 뒤 `Space`를 눌러 녹화하고, 다시 눌러 같은 촬영을 일시 정지했다가 재개하세요. 항상 카메라의 최고 해상도로 녹화하며, 실시간 마이크 미터가 있어 시작 전에 레벨을 확인할 수 있습니다.

촬영을 중단하면 내장 편집기에서 바로 열립니다. 클립을 더블클릭해 분할하고, 핸들을 드래그해 각 조각을 다듬고, 원하지 않는 부분을 제거하세요. 그런 다음 MP4로 저장합니다. 원본 녹화는 버리기 전까지 유지되므로, 언제든 돌아와 다르게 편집할 수 있습니다.

Monologue는 애플리케이션 실행기(`Super + Space`)를 통해 시작합니다.
