# GUI

## 파일

파일(Nautilus)은 그래픽 파일 관리자입니다. `Super + Shift + F`로 열고, `Super + Shift + Alt + F`로 터미널이 있는 디렉터리에서 열어 클릭을 크게 줄일 수 있습니다. `Ctrl + L`로 경로를 입력할 수 있으며, 아무 파일에서 `Space`를 누르면 아무것도 열지 않고 빠르게 미리볼 수 있습니다.

USB 스틱이나 SD 카드를 꽂으면 자동으로 마운트되어 사이드바에 나타납니다. 드라이브 포맷, SMART 상태 확인, 파티션 생성처럼 좀 더 복잡한 작업에는 앱 실행 프로그램(`Super + Space`)에서 _디스크_를 실행하세요.

더블클릭하면 합리적인 기본값을 따릅니다. 이미지는 imv로, 비디오는 mpv로, PDF는 Document Viewer로, 일반 텍스트는 Neovim으로 열립니다.

## Disktree

드라이브가 가득 차서 무엇이 잡아먹는지 모를 때는 앱 실행 프로그램(`Super + Space`)에서 [Disktree](https://github.com/tobi/disktree)를 실행하세요. 홈 디렉터리의 그래픽 트리맵을 보여줍니다. 큰 블록일수록 더 많은 공간을 차지합니다. 키보드나 마우스로 디렉터리를 탐색하고, 지울 것을 표시한 뒤, 아무것도 제거하기 전에 선택 사항을 검토하세요. 전체 디스크를 스캔하려면 `disktree --disk`를 실행하세요.

## Obsidian

[Obsidian](https://obsidian.md/)은 저장에 간단한 Markdown 파일을 사용하는 무료이고 확장성이 높은 노트 작성 애플리케이션입니다.

Obsidian은 개인, 상업, 비영리 사용을 포함해 모든 목적으로 무료입니다.

Obsidian은 iOS와 Android 모바일 앱과의 [동기화를 위한 상용 애드온](https://obsidian.md/sync)도 제공합니다. (https://obsidian.md/pricing).

`Super + Shift + O`로 Obsidian을 시작합니다. 테마 동기화를 사용하려면 설정에서 `Omarchy` 테마를 선택해야 합니다.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite)는 Omarchy 자체의 아주 간단한 Markdown 글쓰기 앱입니다. 볼트도, 플러그인도 없습니다. 당신과 단어만이 있습니다.

`Super + Shift + W`로 Omawrite를 시작합니다.

## Pinta

[Pinta](https://www.pinta-project.com/)는 자르기, 크기 조절, 기타 기본 조작에 훌륭한 기본 이미지 편집 도구입니다. Photoshop 대안을 기대하지는 마세요. 하지만 Magic Wand와 레이어도 있습니다!

애플리케이션 실행 프로그램(`Super + Space`)에서 Pinta를 시작합니다.

## Aether

[Aether](https://github.com/bjarneo/aether)는 배경 이미지에서 색상을 추출해 완전하고 응집력 있는 테마로 만들 수 있는 테마 애플리케이션입니다. [자체 테마 만들기](43-making-your-own-theme.md)의 가장 쉬운 방법입니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 Aether를 시작합니다.

## LocalSend

[LocalSend](https://localsend.org/)는 Apple의 AirDrop처럼 같은 네트워크에서 앱을 실행 중인 다른 장치로 파일을 보낼 수 있게 해줍니다. 다만 크로스 플랫폼이므로 Windows, macOS, Android, iOS는 물론 Linux와도 파일을 주고받을 수 있습니다.

`Super + Ctrl + S`에서 또는 Omarchy 메뉴의 _실행 > 공유_에서 공유 메뉴를 열 수 있습니다. 네 가지 옵션을 제공합니다:

- **클립보드**는 복사한 것을 텍스트 파일로 보냅니다. 자신에게 이메일을 보내지 않고 링크나 스니펫을 휴대폰으로 가져가기에 좋습니다.
- **파일**은 여러 개를 한 번에 선택할 수 있는 파일 선택기를 엽니다.
- **폴더**는 전체 디렉터리를 보냅니다.
- **수신**은 다른 장치가 당신에게 무언가를 보낼 수 있도록 LocalSend 자체를 엽니다.

같은 작업을 터미널에서 `omarchy share clipboard`, `omarchy share file [path]`, `omarchy share folder [path]`로 할 수도 있습니다. 경로를 생략하면 선택기가 나타납니다.

파일 관리자에서 바로 보낼 수도 있습니다. Nautilus에서 아무 선택 항목을 마우스 오른쪽 버튼으로 클릭하고 _LocalSend로 보내기_를 고르세요.

Omarchy의 방화벽은 기본적으로 LocalSend 포트를 제외하고 닫혀 있으므로, 새로 설치한 상태에서도 바로 동작합니다. [보안](48-security.md)을 참고하세요.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/)는 워드 프로세서, 스프레드시트, 프레젠테이션, 드로잉 애플리케이션 등을 갖춘 완전한 오피스 패키지입니다. Microsoft Office 파일과 호환되므로, Word 문서를 여는 좋은 방법입니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 LibreOffice를 시작합니다.

## Hype

[Hype](https://github.com/omacom/hype)는 Omarchy 자체의 아주 간단한 프레젠테이션 앱입니다. 덱은 이미지와 비디오가 옆에 있는 단일 Markdown 파일입니다. 실시간 미리보기 아래에 각 슬라이드를 작성하고, 슬라이드를 드래그해 순서대로 정렬한 뒤, 전체 화면으로 프레젠테이션하거나 PDF와 PowerPoint로 내보내세요. Omarchy 테마도 따라옵니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 Hype를 시작합니다. 안에서 `?`를 누르면 모든 단축키를 볼 수 있습니다.

## Signed

[Signed](https://github.com/omacom/signed)는 Omarchy 자체의 아주 간단한 PDF 서명 및 작성 방법입니다. 저장한 서명, 텍스트, 오늘 날짜를 페이지 어디에든 넣은 뒤, 서명한 사본을 원본 옆에 저장하세요. 방법은 [PDF 작성하기](27-filling-out-pdfs.md)를 참고하세요.

애플리케이션 실행 프로그램(`Super + Space`)에서 Signed를 시작하거나, 파일 관리자에서 PDF를 Signed로 여세요.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc)는 Omarchy 자체의 아주 간단한 계산기로, 떠 있는 창에서 열립니다.

`Super + Ctrl + Q`로 Omacalc를 시작합니다(키보드에 계산기 키가 있다면 그것도 됩니다).

## Signal

[Signal](https://signal.org/)은 종단 간 암호화 메시징의 선구자이며, 대기업 기술 기업을 거치지 않기를 선호하는 사람들에게 좋은 통신 옵션입니다.

`Super + Shift + G`로 Signal을 시작합니다. 기본 설치에는 포함되어 있지 않으므로, 처음 누르면 Omarchy가 설치할 것을 제안합니다(Omarchy 메뉴의 _설치 > 서비스_에도 있습니다).

## mpv

[mpv](https://mpv.io/)는 거의 모든 소스에서 거의 모든 것을 재생하는 간단하고 빠른 미디어 플레이어입니다. 비디오 시청에 좋습니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 mpv를 시작하거나, 파일 관리자에서 비디오를 더블클릭하면 됩니다.

## Omacut

[Omacut](https://github.com/omacom-io/omacut)은 Omarchy 자체의 아주 간단한 비디오 트리머입니다. 클립의 시작과 끝만 잘라내면 될 때는 완전한 비디오 편집기를 실행하는 것보다 낫습니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 Omacut을 시작합니다.

## Monologue

[Monologue](https://github.com/omacom/monologue)는 Omarchy 자체의 아주 간단한 웹캠 레코더입니다. 카메라와 마이크를 한 번 선택한 뒤 `Space`를 눌러 녹화하고, 다시 눌러 같은 테이크를 일시정지하고 재개하세요. 항상 카메라의 최고 해상도로 녹화하며, 시작하기 전에 레벨을 확인할 수 있도록 실시간 마이크 미터가 있습니다.

테이크를 중지하면 내장 편집기에서 바로 열립니다. 클립을 더블클릭해 나누고, 핸들을 드래그해 각 조각을 다듬고, 원하지 않는 부분을 제거하세요. 그런 다음 MP4로 저장합니다. 원래 녹화는 버릴 때까지 유지되므로, 언제든 돌아와 다르게 편집할 수 있습니다.

애플리케이션 실행 프로그램(`Super + Space`)에서 Monologue를 시작합니다.
