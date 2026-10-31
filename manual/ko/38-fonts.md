# 글꼴

Omarchy는 기본적으로 JetBrainsMono Nerd Font를 터미널 글꼴이자 시스템 글꼴로 사용한다.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

Omarchy 메뉴(`Super + Space`)의 _Appearance > Font_ 메뉴에서 이를 변경할 수 있다. 그러면 터미널, 바, 그리고 고정폭 글꼴을 요청하는 모든 곳에 해당 글꼴이 설정된다.

Omarchy 메뉴의 _Install > Style > Font_를 통해 다른 인기 프로그래밍 글꼴도 설치할 수 있다: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono, Iosevka가 모두 클릭 한 번으로 설치되며, 바와 터미널의 글리프가 계속 작동하도록 Nerd Font 버전으로 제공된다. 하나를 설치한 뒤에는 _Appearance > Font_에서 선택하면 된다.

## 중국어, 일본어, 한국어

중국어, 일본어, 한국어는 많은 문자를 공유하지만 일부 문자는 다르게 그리기 때문에, 같은 문자라도 한 독자에게는 올바르게 보이고 다른 독자에게는 낯설게 보일 수 있다. _Setup > Language_에서 이들 언어 중 하나를 선택하거나 해당 입력 방식을 선택하면 그에 맞는 형태가 설정된다. 직접 선택하려면 터미널에서 `omarchy font cjk jp`, `kr`, `sc`, `tc`(대만), 또는 `hk`(홍콩)를 실행하면 된다; `omarchy font cjk default`는 시스템의 선택으로 되돌아가는데, 이는 일본어 형태이다. 웹 페이지나 문서가 자체 언어로 표시한 텍스트는 그 언어의 형태를 유지하고, 데스크톱이 이들 언어 중 하나로 설정되어 있는 동안 데스크톱 전체도 해당 언어의 형태를 유지한다.
