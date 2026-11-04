# GUI

## 파일

Files(Nautilus)는 그래픽 파일 관리자다. `Super + Shift + F`를 누르면 열리고, `Super + Shift + Alt + F`를 누르면 터미널이 현재 머물러 있는 디렉터리에서 열리므로 클릭을 많이 하지 않아도 된다. `Ctrl + L`을 누르면 경로를 입력할 수 있고, 어떤 파일에서든 `Space`를 누르면 아무것도 열지 않고 빠르게 미리 볼 수 있다.

USB 스틱이나 SD 카드를 꽂으면 자동으로 마운트되어 사이드바에 바로 나타난다. 드라이브 포맷, SMART 상태 확인, 파티션 만들기처럼 더 복잡한 작업이 필요하면 앱 런처(`Super + Space`)에서 _Disks_를 실행해라.

더블클릭은 합리적인 기본값을 따른다: 이미지는 imv에서, 비디오는 mpv에서, PDF는 Document Viewer에서, 일반 텍스트는 Neovim에서 열린다.

## Disktree

드라이브가 가득 찼는데 뭐가 공간을 잡아먹고 있는지 모르겠다면 앱 런처(`Super + Space`)에서 [Disktree](https://github.com/tobi/disktree)를 실행해라. 홈 디렉터리를 그래픽 트리맵으로 보여준다. 블록이 클수록 더 많은 공간을 차지한다; 키보드나 마우스로 디렉터리를 돌아다니고, 지울 항목을 표시한 뒤, 아무것도 제거하기 전에 선택 항목을 검토해라. 전체 디스크를 스캔하려면 `disktree --disk`를 실행해라.

## Obsidian

[Obsidian](https://obsidian.md/)은 저장소에 단순한 Markdown 파일을 사용하는 무료이고 확장성이 뛰어난 노트 작성 애플리케이션이다.

Obsidian은 개인, 상업, 비영리 사용을 포함해 모든 목적에 무료다.

Obsidian은 iOS와 Android 모바일 앱과 동기화할 수 있는 [상용 애드온](https://obsidian.md/sync)도 제공한다. (https://obsidian.md/pricing).

`Super + Shift + O`로 Obsidian을 시작한다. 테마 동기화를 사용하려면 설정에서 `Omarchy` 테마를 선택해야 한다.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite)는 Omarchy 자체의 아주 단순한 Markdown 글쓰기 앱이다. 볼트도, 플러그인도 없다. 그냥 당신과 단어뿐이다.

`Super + Shift + W`로 Omawrite를 시작한다.

## Pinta

[Pinta](https://www.pinta-project.com/)는 자르기, 크기 조정, 그 밖의 기본적인 편집에 좋은 기본 이미지 편집 도구다. Photoshop 대안을 기대하지는 마라. 그래도 Magic Wand와 레이어는 있다!

앱 런처(`Super + Space`)를 통해 Pinta를 시작한다.

## Aether

[Aether](https://github.com/bjarneo/aether)는 배경 이미지에서 색상을 추출해 완전하고 조화로운 테마로 바꿔주는 테마 애플리케이션이다. [나만의 테마 만들기](43-making-your-own-theme.md)를 하는 가장 쉬운 방법이다.

앱 런처(`Super + Space`)를 통해 Aether를 시작한다.

## LocalSend

[LocalSend](https://localsend.org/)를 사용하면 Apple의 AirDrop처럼 같은 네트워크에서 앱을 실행 중인 다른 기기로 파일을 보낼 수 있다. 다만 크로스 플랫폼이라 Windows, macOS, Android, iOS는 물론 Linux와도 파일을 주고받을 수 있다.

`Super + Ctrl + S`를 누르거나 Omarchy 메뉴의 _Trigger > Share_에서 Share 메뉴를 열 수 있다. 네 가지 옵션이 제공된다:

- **Clipboard** 복사한 것을 텍스트 파일로 보낸다. 자신에게 이메일을 보내지 않고 링크나 코드 조각을 휴대폰으로 옮기기에 좋다.
- **File** 한 번에 여러 개를 선택할 수 있는 파일 선택기를 연다.
- **Folder** 디렉터리 전체를 보낸다.
- **Receive** LocalSend 본체를 열어 다른 기기가 당신에게 무언가를 보낼 수 있게 한다.

터미널에서도 `omarchy share clipboard`, `omarchy share file [path]`, `omarchy share folder [path]`로 똑같이 할 수 있다. 경로를 생략하면 선택기가 열린다.

파일 관리자에서 바로 보낼 수도 있다: Nautilus에서 선택 항목을 마우스 오른쪽 버튼으로 클릭하고 _Send via LocalSend_를 선택해라.

Omarchy 방화벽은 LocalSend 포트만 제외하고 기본적으로 닫혀 있어서, 새로 설치한 상태에서도 바로 작동한다. [보안](48-security.md)을 참고해라.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/)는 워드 프로세서, 스프레드시트, 프레젠테이션, 그리기 애플리케이션 등을 갖춘 완전한 오피스 패키지다. Microsoft Office 파일과 호환되므로, Word 문서를 열 수 있는 좋은 방법이다.

앱 런처(`Super + Space`)를 통해 LibreOffice를 시작한다.

## Hype

[Hype](https://github.com/omacom/hype)는 Omarchy 자체의 아주 단순한 프레젠테이션 앱이다. 당신의 덱은 이미지와 비디오가 옆에 있는 단일 Markdown 파일이다: 라이브 미리보기 아래에 각 슬라이드를 작성하고, 슬라이드를 드래그해 순서를 정한 뒤, 전체 화면으로 프레젠테이션하거나 PDF와 PowerPoint로 내보내라. Omarchy 테마도 자동으로 가져온다.

앱 런처(`Super + Space`)를 통해 Hype를 시작한다. 안에서 `?`를 누르면 모든 단축키를 볼 수 있다.

## Signed

[Signed](https://github.com/omacom/signed)는 PDF에 서명하고 채워 넣는 Omarchy 자체의 아주 단순한 방법이다. 저장된 서명, 텍스트, 오늘 날짜를 페이지 어디에든 놓고, 원본 옆에 서명된 사본을 저장해라. 방법은 [PDF 작성하기](27-filling-out-pdfs.md)를 참고해라.

앱 런처(`Super + Space`)를 통해 Signed를 시작하거나, 파일 관리자에서 PDF를 이 앱으로 열어라.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc)는 떠 있는 창에서 열리는 Omarchy 자체의 아주 단순한 계산기다.

`Super + Shift + Q`로 Omacalc를 시작한다 (또는 키보드에 계산기 키가 있으면 그 키로).

## Signal

[Signal](https://signal.org/)은 E2E 암호화 메시징의 선구자이며, 빅테크 대기업 중 하나를 거치고 싶지 않은 누구에게나 좋은 커뮤니케이션 옵션이다.

`Super + Shift + G`로 Signal을 시작한다. 기본 설치에는 포함되어 있지 않으므로, 처음 그 키를 누르면 Omarchy가 설치할지 제안한다 (Omarchy 메뉴의 _Install > Service_에도 있다).

## mpv

[mpv](https://mpv.io/)는 거의 모든 소스의 거의 모든 것을 재생할 수 있는 단순하고 빠른 미디어 플레이어다. 비디오를 보기에 좋다.

앱 런처(`Super + Space`)를 통해 mpv를 시작하거나, 파일 관리자에서 비디오를 더블클릭하면 된다.

## Omacut

[Omacut](https://github.com/omacom-io/omacut)은 Omarchy 자체의 아주 단순한 비디오 트리머다. 클립의 시작과 끝을 잘라내기만 하면 될 때는, 완전한 비디오 편집기를 실행하는 것보다 낫다.

앱 런처(`Super + Space`)를 통해 Omacut을 시작한다.

## Monologue

[Monologue](https://github.com/omacom/monologue)는 Omarchy 자체의 아주 단순한 웹캠 레코더다. 카메라와 마이크를 한 번 선택한 뒤, `Space`를 눌러 녹화하고, 다시 눌러 같은 테이크를 일시 정지했다가 재개해라. 항상 카메라의 최고 해상도로 녹화하며, 라이브 마이크 미터가 있어 시작하기 전에 레벨을 확인할 수 있다.

테이크를 중지하면 내장 편집기에서 바로 열린다. 클립을 더블클릭해 나누고, 핸들을 드래그해 각 조각을 다듬고, 원하지 않는 부분을 제거해라. 그런 다음 MP4로 저장해라. 원본 녹화는 버릴 때까지 보관되므로, 언제든 돌아와 다르게 잘라낼 수 있다.

앱 런처(`Super + Space`)를 통해 Monologue를 시작한다.
