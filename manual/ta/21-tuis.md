# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) என்பது GitHub Desktop போன்ற ஒரு பயன்பாட்டிற்கு மகிழ்ச்சியான மாற்றாகும், மேலும் இது terminal-க்குள் இயங்குகிறது.

நீங்கள் அதை நேரடியாக இயக்கலாம், git மூலம் நிர்வகிக்கப்படும் எந்த directory-க்கும் சென்று `lazygit` ஐ இயக்குவதன் மூலம். அல்லது Neovim-க்குள் இயக்கலாம், அங்கு அதை `Space G G` கொண்டு தொடங்கலாம்.

`Tab` ஐப் பயன்படுத்தி வெவ்வேறு pane-களுக்கு இடையே நகரலாம். Files pane-இல், `Space` ஐப் பயன்படுத்தி staging-க்காகக் கோப்புகளைத் தேர்ந்தெடுக்கிறீர்கள், பின்னர் `c` ஐப் பயன்படுத்தி புதிய commit ஒன்றை உருவாக்கலாம். `?` ஐப் பயன்படுத்தி கிடைக்கக்கூடிய அனைத்து கட்டளைகளையும் காணலாம்.

## Btop

[Btop](https://github.com/aristocratos/btop) என்பது memory, CPU, disk மற்றும் network பயன்பாட்டைக் காட்டும் ஒரு அழகான resource manager ஆகும். இது செயலில் உள்ள அனைத்து process-களையும் பட்டியலிடுகிறது, மேலும் அவற்றை நிர்வகிக்கவும் உங்களை அனுமதிக்கிறது.

Omarchy இதை Activity Monitor என்று அழைக்கிறது, நீங்கள் இதை app launcher-இலிருந்து அல்லது `Super + Shift + T` ஐ அழுத்துவதன் மூலம் தொடங்கலாம். இது ஒரு floating window ஆகத் திறக்கும், அதை நீங்கள் `Super + T` கொண்டு tile செய்யலாம்.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) என்பது உங்களுக்கு workspace-கள், tab-கள் மற்றும் pane-களை வழங்கும் ஒரு terminal workspace manager ஆகும், மேலும் அவை அனைத்தையும் நீங்கள் பிரிந்து சென்று பின்னர் திரும்பி வரக்கூடிய ஒரு persistent session-இல் இயங்க வைக்கிறது.

நீங்கள் இதை (அல்லது உங்கள் தற்போதைய session உடன் மீண்டும் இணைய) app launcher-இலிருந்து அல்லது `Super + Ctrl + Return` கொண்டு தொடங்கலாம். Omarchy, அதன் Tmux config-ஐப் பிரதிபலிக்கும் ஒரு Herdr configuration-ஐ வழங்குகிறது, எனவே இங்கும் prefix key `Ctrl + Space` ஆகும். `Super + Ctrl + K` கொண்டு அனைத்து keybinding-களையும் உலாவலாம்.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) kernel version, uptime, theme, CPU, memory மற்றும் பலவற்றைப் போன்ற system தகவல்களைக் காட்டுகிறது. இது பிரபலமான neofetch tool-இன் வாரிசு ஆகும்.

Omarchy இதை Omarchy menu-வில் (`Super + Space`) _System > About_ எனத் தொகுத்துள்ளது.

## Cliamp

[Cliamp](https://www.cliamp.stream/) என்பது Winamp 2.x-ஆல் ஈர்க்கப்பட்ட ஒரு retro terminal music player ஆகும், lo-fi beats-க்கான உள்ளமைக்கப்பட்ட radio station-களுடன் முழுமையானது. இதை `Super + Shift + Alt + M` கொண்டு, அல்லது Omarchy menu-வில் _Apps_ இன் கீழ் இருந்து தொடங்கவும். முழு keybinding பட்டியலுக்கு `?` ஐ அழுத்தவும்.

## Wi-Fi மற்றும் Bluetooth பற்றி என்ன?

Wi-Fi மற்றும் Bluetooth-க்கான TUI-களை நீங்கள் காண மாட்டீர்கள் — அந்த வேலைகள் Omarchy shell-க்கு உரியவை. network-களைக் கண்டு இணைக்க மேல் பட்டியில் உள்ள Wi-Fi icon-ஐக் கிளிக் செய்யவும் (அல்லது `Super + Ctrl + N` ஐ அழுத்தவும்), மற்றும் சாதனங்களை pair செய்து இணைக்க Bluetooth icon-ஐக் கிளிக் செய்யவும் (அல்லது `Super + Ctrl + B` ஐ அழுத்தவும்). முழு கதைக்கு [வலையமைப்பு](35-networking.md) ஐப் பார்க்கவும்.

## உங்களுடையதைச் சேர்த்தல்

எந்த terminal program-உம் முழு app அந்தஸ்தைப் பெறலாம். Omarchy menu-வில் (`Super + Space`) _Install > TUI_ க்குச் செல்லவும், அதற்கு ஒரு பெயர், ஒரு launch command, ஒரு window style மற்றும் ஒரு icon-ஐக் கொடுக்கவும், அது மற்ற எந்த application போலவும் app launcher-இல் தோன்றும். _Remove > TUI_ இன் கீழ் அதை மீண்டும் நீக்கலாம்.
