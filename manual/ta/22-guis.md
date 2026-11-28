# GUIகள்

## Files

Files (Folio) என்பது வரைகலை கோப்பு மேலாளர். `Super + Shift + F` இதைத் திறக்கும், மேலும் `Super + Shift + Alt + F` உங்கள் terminal அமர்ந்திருக்கும் directory-இல் இதைத் திறக்கும், இது நிறைய clicking-ஐ மிச்சப்படுத்தும். `Ctrl + L` ஒரு path-ஐ type செய்ய உங்களை அனுமதிக்கும், மேலும் எந்தக் கோப்பின் மீதும் `Space` அழுத்தினால் அதைத் திறக்காமலேயே முழு அளவில் அதை preview செய்யும்.

USB stick அல்லது SD card-ஐச் செருகினால் அது தானாகவே mount ஆகிவிடும், எனவே அது sidebar-இல் அப்படியே தோன்றும். இன்னும் சிக்கலான எதற்கும் — drive-ஐ format செய்வது, SMART health-ஐச் சரிபார்ப்பது, partitions உருவாக்குவது — app launcher-இலிருந்து (`Super + Space`) _Disks_-ஐத் தொடங்குங்கள்.

Encrypted drive ஒன்று செருகப்படும்போது அதன் password-ஐக் கேட்கும். ஒன்று தானாகவே unlock ஆக வேண்டுமென்றால், `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` கொண்டு அதில் ஒரு keyfile-ஐச் சேர்த்து, அந்த keyfile-ஐ `~/.config/omarchy/drive-keys/<UUID>` இல் வையுங்கள், encrypted partition-க்காக `lsblk -dno UUID /dev/sdX1` அச்சிடும் UUID-ஆல் பெயரிட்டு, நீங்கள் மட்டுமே படிக்கக்கூடியதாக (`chmod 600`) வையுங்கள். அந்த keyfile இல்லாவிட்டால் அல்லது மறுக்கப்பட்டால், வழக்கம்போல் உங்களிடம் password கேட்கப்படும்.

Double-click செய்வது நியாயமான இயல்புநிலைகளைப் பின்பற்றுகிறது: pictures, videos மற்றும் music ஆகியவை Omaview-இல் திறக்கும், PDFs Document Viewer-இல், Markdown Omawrite-இல், மேலும் plain text உங்கள் editor-இல் திறக்கும், _Setup > Defaults > Editor_-இன் கீழ் நீங்கள் வேறொன்றைத் தேர்ந்தெடுக்காவிட்டால் Plain-இல் திறக்கும்.

## Disktree

Drive நிரம்பிவிடும்போது, எது அதைத் தின்றுகொண்டிருக்கிறது என்று உங்களுக்குக் கொஞ்சமும் தெரியாதபோது, app launcher-இலிருந்து (`Super + Space`) [Disktree](https://github.com/tobi/disktree)-ஐத் தொடங்குங்கள். இது உங்கள் home directory-இன் வரைகலை treemap-ஐக் காட்டும். பெரிய blocks அதிக இடத்தை எடுக்கும்; keyboard அல்லது mouse கொண்டு directories-க்குள் நடந்து செல்லுங்கள், போக வேண்டியவற்றைக் குறியுங்கள், மேலும் எதையும் அகற்றுவதற்கு முன் உங்கள் தேர்வுகளை மதிப்பாய்வு செய்யுங்கள். முழு disk-ஐயும் scan செய்ய `disktree --disk` ஐ இயக்குங்கள்.

## Obsidian

[Obsidian](https://obsidian.md/) என்பது சேமிப்பிற்கு எளிய Markdown கோப்புகளைப் பயன்படுத்தும், இலவசமான மற்றும் மிகவும் விரிவாக்கக்கூடிய குறிப்பு எடுக்கும் application ஆகும்.

Obsidian தனிப்பட்ட, வணிக மற்றும் இலாப நோக்கற்ற பயன்பாடு உட்பட அனைத்து நோக்கங்களுக்கும் இலவசம்.

Obsidian iOS மற்றும் Android-இல் உள்ள mobile apps உடன் sync செய்வதற்கான [வணிக add-on](https://obsidian.md/sync)-ஐயும் வழங்குகிறது. (https://obsidian.md/pricing).

நீங்கள் `Super + Shift + O` கொண்டு Obsidian-ஐத் தொடங்குகிறீர்கள். Theme syncing-ஐப் பயன்படுத்த, settings-இன் கீழ் `Omarchy` theme-ஐ நீங்கள் தேர்ந்தெடுக்க வேண்டும்.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) என்பது Omarchy-இன் சொந்த, மிக எளிய Markdown எழுதும் app. Vaults இல்லை, plugins இல்லை, நீங்களும் வார்த்தைகளும் மட்டுமே.

நீங்கள் `Super + Shift + W` கொண்டு Omawrite-ஐத் தொடங்குகிறீர்கள்.

## Pinta

[Pinta](https://www.pinta-project.com/) என்பது cropping, resizing மற்றும் பிற அடிப்படை கையாளுதல்களுக்குச் சிறந்த ஒரு அடிப்படை image editing கருவி. Photoshop-க்கு மாற்றாக இருக்கும் என்று மட்டும் எதிர்பார்க்காதீர்கள். ஆனால் இதில் இன்னும் Magic Wand-உம் layers-உம் உள்ளன!

நீங்கள் application launcher (`Super + Space`) வழியாக Pinta-ஐத் தொடங்குகிறீர்கள்.

## Aether

[Aether](https://github.com/bjarneo/aether) என்பது ஒரு background image-இலிருந்து வண்ணங்களைப் பிரித்தெடுத்து அவற்றை முழுமையான, ஒத்திசைவான theme ஆக மாற்றக்கூடிய ஒரு theming application. [உங்கள் சொந்த theme-ஐ உருவாக்க](43-making-your-own-theme.md) இதுவே எளிதான வழி.

நீங்கள் application launcher (`Super + Space`) வழியாக Aether-ஐத் தொடங்குகிறீர்கள்.

## LocalSend

[LocalSend](https://localsend.org/) Apple-இன் AirDrop-ஐப் போல, அதே network-இல் app-ஐ இயக்கும் பிற devices-க்குக் கோப்புகளை அனுப்ப உங்களை அனுமதிக்கிறது. இருப்பினும் இது cross-platform, எனவே நீங்கள் Windows, macOS, Android, iOS மற்றும் நிச்சயமாக Linux-க்கு இடையே கோப்புகளை அனுப்பலாம்.

நீங்கள் `Super + Ctrl + S` இல் அல்லது Omarchy menu-இல் _Trigger > Share_-இன் கீழ் Share menu-ஐத் திறக்கலாம். இது உங்களுக்கு நான்கு விருப்பங்களைத் தருகிறது:

- **Clipboard** நீங்கள் copy செய்த எதையும் ஒரு text file ஆக அனுப்புகிறது. உங்களுக்கே email அனுப்பிக்கொள்ளாமல் ஒரு link-ஐ அல்லது snippet-ஐ உங்கள் phone-க்குக் கொண்டு செல்லச் சிறந்தது.
- **File** ஒரே நேரத்தில் பலவற்றைத் தேர்ந்தெடுக்கக்கூடிய file picker-ஐத் திறக்கிறது.
- **Folder** ஒரு முழு directory-ஐயும் அனுப்புகிறது.
- **Receive** மற்றொரு device உங்களுக்கு ஏதாவது அனுப்பும் வகையில் LocalSend-ஐயே திறக்கிறது.

Terminal-இலிருந்தும் அதே விஷயம் `omarchy share clipboard`, `omarchy share file [path]` மற்றும் `omarchy share folder [path]` கொண்டு வேலை செய்கிறது. Path-ஐ விட்டுவிடுங்கள், உங்களுக்கு picker கிடைக்கும்.

File manager-இலிருந்தும் நீங்கள் நேரடியாக அனுப்பலாம்: Files-இல் எந்தத் தேர்வையும் right-click செய்து அதை LocalSend கொண்டு share செய்யுங்கள்.

Omarchy-இன் firewall LocalSend-இன் port-ஐத் தவிர இயல்பாக மூடப்பட்டிருக்கும், எனவே இது புதிய install-இல் உடனடியாக வேலை செய்கிறது. [security](48-security.md)-ஐப் பார்க்கவும்.

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) என்பது word processor, spreadsheet, presentations, drawing application மற்றும் பலவற்றைக் கொண்ட ஒரு முழுமையான office package. இது Microsoft Office-இலிருந்து வரும் கோப்புகளுடன் compatible, எனவே அந்த Word documents-ஐத் திறக்க முடிவதற்கு இது ஒரு சிறந்த வழி.

நீங்கள் application launcher (`Super + Space`) வழியாக LibreOffice-ஐத் தொடங்குகிறீர்கள்.

## Hype

[Hype](https://github.com/omacom/hype) என்பது Omarchy-இன் சொந்த, மிக எளிய presentation app. உங்கள் deck என்பது அதன் images மற்றும் videos அருகில் இருக்கும் ஒரே ஒரு Markdown கோப்பு: ஒவ்வொரு slide-ஐயும் live preview-இன் கீழ் எழுதுங்கள், slides-ஐ வரிசைக்கு drag செய்யுங்கள், பின்னர் fullscreen-இல் present செய்யுங்கள் அல்லது PDF மற்றும் PowerPoint-க்கு export செய்யுங்கள். இது உங்கள் Omarchy theme-ஐக் கூட எடுத்துக்கொள்கிறது.

நீங்கள் application launcher (`Super + Space`) வழியாக Hype-ஐத் தொடங்குகிறீர்கள். ஒவ்வொரு shortcut-ஐயும் பார்க்க அதற்குள் `?` அழுத்துங்கள்.

## Signed

[Signed](https://github.com/omacom/signed) என்பது PDFs-இல் கையொப்பமிடவும் அவற்றை நிரப்பவும் Omarchy-இன் சொந்த, மிக எளிய வழி. உங்கள் சேமித்த signature, text மற்றும் இன்றைய தேதியை ஒரு page-இல் எங்கு வேண்டுமானாலும் வையுங்கள், பின்னர் அசலுக்கு அருகில் கையொப்பமிட்ட copy-ஐச் சேமியுங்கள். எப்படி என்பதற்கு [PDFs-ஐ நிரப்புதல்](27-filling-out-pdfs.md)-ஐப் பார்க்கவும்.

நீங்கள் application launcher (`Super + Space`) வழியாக Signed-ஐத் தொடங்குகிறீர்கள், அல்லது file manager-இலிருந்து ஒரு PDF-ஐ இதைக் கொண்டு திறக்கிறீர்கள்.

## Game Vibes

Application launcher-இல் (`Super + Space`) உள்ள Game Vibes என்பதில் Omarchy-இன் சிறிய games வாழ்கின்றன: Checkmate, ஒரு நண்பருக்கு எதிராக அல்லது உள்ளமைக்கப்பட்ட opponent-க்கு எதிராக விளையாடும் 3D chess game; Cards, Klondike solitaire; Death Wish, spikes மற்றும் saws நிறைந்த பத்து rooms கொண்ட pixel-precise platformer; மற்றும் Neon Swarm, ஒரு arcade shooter. ஒவ்வொன்றும் உங்கள் theme-ஐப் பின்பற்றும் ஒரே ஒரு web page. Arrows மற்றும் `Enter` கொண்டு ஒன்றைத் தேர்ந்தெடுங்கள், மேலும் ஒரு game-இன் title screen-இலிருந்து `Esc` கொண்டும் அது paused ஆக இருக்கும்போது `Q` கொண்டும் list-க்குத் திரும்பி வாருங்கள். இது full screen-இல் திறக்கும்: `Super + F` இதை ஒரு window ஆக்கும், மேலும் `Super + W` இதை மூடும்.

நீங்கள் agent கொண்டு உருவாக்கும் games-உம் இங்கே தோன்றும்: agents panel-இல் _Make something cool → Game_-ஐத் தேர்ந்தெடுத்து ஒன்றை விவரியுங்கள், அல்லது அதில் தொடர்ந்து வேலை செய்ய Game Vibes-இல் ஏற்கனவே உள்ள ஒரு game-ஐப் பெயரிடுங்கள். Agent அதை `~/Games/vibes`-க்கு copy செய்கிறது, அங்கு அது நீங்கள் மாற்றுவதற்கு உங்களுடையது, மேலும் அது முடிந்ததும் அதைத் திறக்கிறது. `omarchy games vibes copy <game>` கொண்டு அந்த copy-ஐ நீங்களே உருவாக்கலாம். வேறு யாராவது share செய்யும் game ஒரு theme-ஐப் போல install ஆகிறது: _Install > Gaming > Game Vibes_-ஐத் தேர்ந்தெடுத்து அதன் git address-ஐ paste செய்யுங்கள், அல்லது `omarchy games vibes install <git-repo-url>` ஐ இயக்குங்கள். _Remove > Gaming_ ஒன்றை மீண்டும் அகற்றுகிறது, மேலும் _Update > Game Vibes Games_ புதிய versions-ஐ fetch செய்கிறது. Games three.js-ஐ web-இலிருந்து load செய்கின்றன, எனவே தொடங்குவதற்கு அவற்றுக்கு ஒரு connection தேவை.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) என்பது floating window-இல் திறக்கும் Omarchy-இன் சொந்த, மிக எளிய calculator.

நீங்கள் `Super + Shift + Q` கொண்டு (அல்லது உங்கள் keyboard-இல் ஒன்று இருந்தால் calculator key கொண்டு) Omacalc-ஐத் தொடங்குகிறீர்கள்.

## Signal

[Signal](https://signal.org/) என்பது E2E encrypted messaging-இன் முன்னோடி, மேலும் பெரிய tech conglomerates ஒன்றின் வழியாகச் செல்ல விரும்பாத எவருக்கும் ஒரு சிறந்த communication விருப்பம்.

நீங்கள் `Super + Shift + G` கொண்டு Signal-ஐத் தொடங்குகிறீர்கள். இது base install-இன் பகுதி அல்ல, எனவே நீங்கள் முதல் முறை அதை அழுத்தும்போது, Omarchy அதை உங்களுக்காக install செய்ய முன்வரும் (இது Omarchy menu-இல் _Install > Service_-இன் கீழும் உள்ளது).

## Omaview

[Omaview](https://github.com/omacom/omaview) என்பது Omarchy-இன் சொந்த, மிக எளிய picture viewer மற்றும் media player: உங்கள் photos, videos மற்றும் music-க்கு ஒரே ஒரு window. ஒரு photo-ஐத் திறந்தால் arrow keys அதன் folder-இன் மீதமுள்ளவற்றின் வழியாகப் படிப்படியாகச் செல்லும், `N` மற்றும் `P` எதற்கும் அதையே செய்யும், மேலும் `Ctrl + M` முழு folder-ஐயும் ஒரு grid ஆகக் காட்டும். இது HEIC, AVIF மற்றும் JPEG XL photos-ஐயும் காட்டும், மேலும் நீளமான எதிலும் நீங்கள் விட்ட இடத்திலிருந்து தொடரும்.

Fullscreen-க்கு `F` அழுத்துங்கள், ஒரு picture-ஐ Omasnap-இல் edit செய்ய அல்லது ஒரு video-ஐ Omacut-இல் trim செய்ய `E` அழுத்துங்கள், ஒரு picture-ஐ print செய்ய `Ctrl + P` அழுத்துங்கள், மேலும் ஒரு file-ஐ Trash-க்கு நகர்த்த `Delete` அழுத்துங்கள் (`Ctrl + Z` அதைத் திரும்பக் கொண்டு வரும்). ஒவ்வொரு shortcut-ஐயும் பார்க்க அதற்குள் `?` அழுத்துங்கள்.

நீங்கள் application launcher (`Super + Space`) வழியாக _Media Viewer_ ஆக Omaview-ஐத் தொடங்குகிறீர்கள், அல்லது file manager-இல் ஒரு picture, video அல்லது song-ஐ double-click செய்யுங்கள்.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) என்பது Omarchy-இன் சொந்த, மிக எளிய video trimmer. ஒரு clip-இன் தொடக்கத்தையும் முடிவையும் வெட்டுவது மட்டுமே உங்களுக்குத் தேவைப்படும்போது, இது ஒரு முழு video editor-ஐத் தொடங்குவதை வெல்கிறது.

நீங்கள் application launcher (`Super + Space`) வழியாக Omacut-ஐத் தொடங்குகிறீர்கள்.

## Monologue

[Monologue](https://github.com/omacom/monologue) என்பது Omarchy-இன் சொந்த, மிக எளிய webcam recorder. உங்கள் camera மற்றும் microphone-ஐ ஒருமுறை தேர்ந்தெடுங்கள், பின்னர் record செய்ய `Space` அழுத்துங்கள், மேலும் அதே take-ஐ pause செய்து resume செய்ய மீண்டும் அழுத்துங்கள். இது எப்போதும் உங்கள் camera-இன் மிக உயர்ந்த resolution-இல் record செய்கிறது, நீங்கள் தொடங்குவதற்கு முன் உங்கள் levels-ஐச் சரிபார்க்க live microphone meter உடன்.

Take-ஐ நிறுத்துங்கள், அது உடனடியாக உள்ளமைக்கப்பட்ட editor-இல் திறக்கும். ஒரு clip-ஐப் பிரிக்க அதை double-click செய்யுங்கள், ஒவ்வொரு பகுதியையும் trim செய்ய handles-ஐ drag செய்யுங்கள், மேலும் உங்களுக்கு வேண்டாத பகுதிகளை அகற்றுங்கள். பின்னர் அதை MP4 ஆகச் சேமியுங்கள். நீங்கள் அதை discard செய்யும் வரை உங்கள் அசல் recording வைக்கப்படும், எனவே நீங்கள் எப்போதும் திரும்பி வந்து அதை வித்தியாசமாக வெட்டலாம்.

நீங்கள் application launcher (`Super + Space`) வழியாக Monologue-ஐத் தொடங்குகிறீர்கள்.
