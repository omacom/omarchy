# GUI

## Files

Files(Nautilus)는 그래픽 파일 관리자입니다. `Super + Shift + F`로 열고, `Super + Shift + Alt + F`로 터미널이 현재 위치한 디렉터리에서 열 수 있어 클릭을 많이 아낄 수 있습니다. `Ctrl + L`을 누르면 경로를 입력할 수 있고, 아무 파일에서나 `Space`를 누르면 아무것도 열지 않고 빠르게 미리 볼 수 있습니다.

USB 스틱이나 SD 카드를 꽂으면 자동으로 마운트되어 사이드바에 바로 나타납니다. 드라이브 포맷, SMART 상태 확인, 파티션 생성처럼 더 손이 가는 작업은 앱 런처(`Super + Space`)에서 _Disks_를 실행하세요.

더블 클릭은 합리적인 기본값을 따릅니다: 사진, 동영상, 음악은 Omaview로, PDF는 Document Viewer로, Markdown은 Omawrite로, 일반 텍스트는 _Setup > Default > Editor_에서 선택한 편집기로 열립니다.

## Disktree

드라이브가 가득 찼는데 뭐가 용량을 잡아먹는지 전혀 모르겠다면 앱 런처(`Super + Space`)에서 [Disktree](https://github.com/tobi/disktree)를 실행하세요. 홈 디렉터리를 그래픽 트리맵으로 보여줍니다. 블록이 클수록 차지하는 공간도 큽니다. 키보드나 마우스로 디렉터리를 들어가고, 지울 항목을 표시한 뒤, 무엇도 제거하기 전에 선택한 항목을 검토하세요. 전체 디스크를 스캔하려면 `disktree --disk`를 실행하세요.

## Obsidian

[Obsidian](https://obsidian.md/)은 저장용으로 단순한 Markdown 파일을 사용하는 무료이면서 확장성이 매우 높은 노트 작성 애플리케이션입니다.

Obsidian은 개인, 상업, 비영리 등 모든 용도로 무료입니다.

Obsidian은 iOS와 Android의 모바일 앱과 동기화할 수 있는 [상용 동기화 애드온](https://obsidian.md/sync)도 제공합니다. (https://obsidian.md/pricing).

Obsidian은 `Super + Shift + O`로 시작합니다. 테마 동기화를 사용하려면 설정에서 `Omarchy` 테마를 선택해야 합니다.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite)는 Omarchy 자체의 극도로 단순한 Markdown 글쓰기 앱입니다. 볼트도, 플러그인도 없습니다. 오직 당신과 글만 있습니다.

Omawrite는 `Super + Shift + W`로 시작합니다.

## Pinta

[Pinta](https://www.pinta-project.com/)는 자르기, 크기 조절, 그 밖의 기본적인 조작에 훌륭한 기본 이미지 편집 도구입니다. 다만 Photoshop 대안까지는 기대하지 마세요. 그래도 Magic Wand와 레이어는 있습니다!

Pinta는 애플리케이션 런처(`Super + Space`)에서 시작합니다.

## Aether

[Aether](https://github.com/bjarneo/aether)는 배경 이미지에서 색상을 추출해 완전하고 통일감 있는 테마로 바꿔주는 테마 애플리케이션입니다. [나만의 테마 만들기](43-making-your-own-theme.md)를 하는 가장 쉬운 방법입니다.

Aether는 애플리케이션 런처(`Super + Space`)에서 시작합니다.

## LocalSend

[LocalSend](https://localsend.org/)를 사용하면 Apple의 AirDrop처럼 같은 네트워크에서 앱을 실행 중인 다른 기기로 파일을 보낼 수 있습니다. 다만 크로스 플랫폼이라 Windows, macOS, Android, iOS, 그리고 물론 Linux와도 파일을 주고받을 수 있습니다.

Share 메뉴는 `Super + Ctrl + S`로, 또는 Omarchy 메뉴의 _Trigger > Share_에서 열 수 있습니다. 네 가지 옵션이 제공됩니다:

- **Clipboard**는 복사한 내용을 텍스트 파일로 보냅니다. 자신에게 이메일을 보내지 않고도 링크나 코드 조각을 휴대폰으로 옮기기에 훌륭합니다.
- **File**은 한 번에 여러 개를 선택할 수 있는 파일 선택기를 엽니다.
- **Folder**는 디렉터리 전체를 보냅니다.
- **Receive**는 다른 기기가 당신에게 무언가를 보낼 수 있도록 LocalSend 본체를 엽니다.

터미널에서도 `omarchy share clipboard`, `omarchy share file [path]`, `omarchy share folder [path]`로 똑같이 할 수 있습니다. 경로를 생략하면 선택기가 열립니다.

파일 관리자에서 바로 보낼 수도 있습니다: Nautilus에서 선택한 항목을 마우스 오른쪽 버튼으로 클릭하고 _Send via LocalSend_를 선택하세요.

Omarchy의 방화벽은 LocalSend 포트만 제외하고 기본적으로 닫혀 있어, 새로 설치한 상태에서도 바로 작동합니다. [보안](48-security.md)을 참조하세요.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/)는 워드 프로세서, 스프레드시트, 프레젠테이션, 드로잉 애플리케이션 등을 갖춘 완전한 오피스 패키지입니다. Microsoft Office 파일과 호환되므로, 그 Word 문서들을 열 수 있는 훌륭한 방법입니다.

LibreOffice는 애플리케이션 런처(`Super + Space`)에서 시작합니다.

## Hype

[Hype](https://github.com/omacom/hype)는 Omarchy 자체의 극도로 단순한 프레젠테이션 앱입니다. 덱은 이미지와 동영상이 옆에 있는 단일 Markdown 파일입니다: 실시간 미리보기 아래에 각 슬라이드를 작성하고, 슬라이드를 드래그해 순서를 정한 뒤, 전체 화면으로 프레젠테이션하거나 PDF와 PowerPoint로 내보내세요. Omarchy 테마까지 반영합니다.

Hype는 애플리케이션 런처(`Super + Space`)에서 시작합니다. 안에서 `?`를 누르면 모든 단축키를 볼 수 있습니다.

## Signed

[Signed](https://github.com/omacom/signed)는 PDF에 서명하고 내용을 채워 넣는 Omarchy 자체의 극도로 단순한 방법입니다. 페이지 어디에든 저장된 서명, 텍스트, 오늘 날짜를 넣은 뒤 원본 옆에 서명된 사본을 저장하세요. 방법은 [PDF 작성하기](27-filling-out-pdfs.md)를 참조하세요.

Signed는 애플리케이션 런처(`Super + Space`)에서 시작하거나, 파일 관리자에서 PDF를 이 앱으로 열 수 있습니다.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc)는 플로팅 창으로 열리는 Omarchy 자체의 극도로 단순한 계산기입니다.

Omacalc는 `Super + Shift + Q`로 시작합니다(키보드에 계산기 키가 있다면 그 키로도 됩니다).

## Signal

[Signal](https://signal.org/)은 E2E 암호화 메시징의 선구자이며, 거대 기술 대기업 중 하나를 거치고 싶지 않은 누구에게나 훌륭한 커뮤니케이션 옵션입니다.

Signal은 `Super + Shift + G`로 시작합니다. 기본 설치에는 포함되어 있지 않으므로 처음 그 키를 누르면 Omarchy가 대신 설치해주겠다고 제안합니다(Omarchy 메뉴의 _Install > Service_에도 있습니다).

## Omaview

[Omaview](https://github.com/omacom/omaview)는 Omarchy 자체의 극도로 단순한 사진 뷰어이자 미디어 플레이어입니다: 사진, 동영상, 음악을 하나의 창으로 봅니다. 사진을 열면 화살표 키로 그 폴더의 나머지를 차례로 넘길 수 있고, `N`과 `P`는 무엇에서든 그렇게 하며, `Ctrl + M`은 폴더 전체를 그리드로 보여줍니다. HEIC, AVIF, JPEG XL 사진도 보여주고, 긴 콘텐츠에서는 중단한 지점부터 이어서 재생합니다.

전체 화면은 `F`, 사진을 Omasnap에서 편집하거나 동영상을 Omacut에서 다듬으려면 `E`, 사진을 인쇄하려면 `Ctrl + P`, 파일을 Trash로 옮기려면 `Delete`를 누르세요(`Ctrl + Z`로 되돌릴 수 있습니다). 안에서 `?`를 누르면 모든 단축키를 볼 수 있습니다.

Omaview는 애플리케이션 런처(`Super + Space`)에서 _Media Viewer_로 시작하거나, 파일 관리자에서 사진, 동영상, 노래를 더블 클릭하면 됩니다.

## Omacut

[Omacut](https://github.com/omacom-io/omacut)은 Omarchy 자체의 극도로 단순한 동영상 트리머입니다. 클립의 시작과 끝만 잘라내면 될 때는 본격적인 동영상 편집기를 실행하는 것보다 훨씬 낫습니다.

Omacut은 애플리케이션 런처(`Super + Space`)에서 시작합니다.

## Monologue

[Monologue](https://github.com/omacom/monologue)은 Omarchy 자체의 극도로 단순한 웹캠 레코더입니다. 카메라와 마이크를 한 번 선택한 뒤 `Space`를 눌러 녹화하고, 다시 눌러 같은 테이크를 일시 정지했다가 이어서 녹화하세요. 항상 카메라의 최고 해상도로 녹화하며, 실시간 마이크 미터가 있어 시작 전에 레벨을 확인할 수 있습니다.

테이크를 중지하면 내장 편집기에서 바로 열립니다. 클립을 더블 클릭해 분할하고, 핸들을 드래그해 각 조각을 다듬고, 원하지 않는 부분을 제거하세요. 그런 다음 MP4로 저장하세요. 원본 녹화는 버리기 전까지 보관되므로 언제든 돌아와 다르게 편집할 수 있습니다.

Monologue는 애플리케이션 런처(`Super + Space`)에서 시작합니다.
