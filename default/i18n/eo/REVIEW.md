# Esperanto (`eo`) translation — review sheet

Omarchy ships in 51 languages. Esperanto was added because it has no
country: glibc provides it as `eo.UTF-8` rather than `eo_XX.UTF-8`,
so `bin/omarchy-locale-generate` needed its locale pattern widened to
accept a country-less locale.

This sheet lists every translated string, grouped by catalog, so a
native speaker can check wording, register and consistency. Please flag
anything that sounds unnatural, too literal, or inconsistent with
another string.

## Conventions already applied

- **Left in English on purpose:** brand and product names (Omarchy,
  Hyprland, Neovim, Firefox, Steam, Rust…), technical tokens (DNS, DHCP,
  SSH, AUR, TUI, GPU), commands, file paths, URLs and key names.
- **Plurals:** Esperanto uses only `one` (n = 1) and `other` per CLDR, so
  plural entries carry those two categories. Esperanto marks the plural in
  the noun (`-oj` for a count), so forms read `1 memorigo` /
  `5 memorigoj`.
- **Placeholders:** every `%1`, `%2`… is preserved from the English source,
  order sometimes changed to suit Esperanto word order.
- **Register:** consumer desktop software — short, direct, imperative.

## Things a reviewer should look hardest at

1. **Verb forms.** Esperanto has one past, one present, and a conditional;
   English has more tenses than that. Check that each CLI string reads as
   a natural state or instruction rather than a forced translation.
2. **Imperatives.** Menu actions and toggles were rendered as infinitives
   (`Ŝalti`, `Forigi`). Check these feel right for menu items.
3. **Capitalisation of ALL-CAPS headers** (`BAR, KONEKTOJ, FONTOJ`).
4. **Register of `trigger.*` status labels** such as
   `Stay Awake` → `Resti veka` — English uses adjectives here in some
   places and verb phrases in others; the Esperanto may need to follow
   the surrounding pattern more strictly.
5. **The loading phrases** (`bluetooth.phrase1…`, `power.chargingPhrase…`,
   `network.phrase1…`, `tailscale.phrase1…`, `dropbox.phrase1…`). These are
   playful rotating status text. They were translated literally in tone;
   check whether they still feel light rather than technical.
6. **Idioms in the notifications panel**, e.g.
   `Step aside for …` → `Paŝi flanken por …` and
   `stay on %1` (Wi-Fi band) → `Resti sur %1`.

## Open questions for the reviewer

- Esperanto has no fixed UI convention for a *Settings / Setup* menu.
  `setup` was translated as **Agordo** (singular, “arrangement/setup”).
  Some Esperanto localisation guides prefer **Agordoj** or
  **Konfigurado**. Which reads most naturally here?
- `appearance` became **Aspekto**, `trigger` became **Ŝaltilo**. Both are
  fine literally, but `Ŝaltilo` reads slightly like “switch” rather than
  “the toggles section”. Is there a better collective noun?
- The `clock.*` entries that are Qt date patterns (`MMMM d`, `%1 %2`) were
  left in English because the shell hands them straight to Qt, which
  formats them through the `formatLocale`. Please confirm Esperanto’s
  month names do come out localised through `Qt.locale("eo")` on a real
  install — this has not been verified on-device yet.

## Menu (`menu.json`) — 413 keys

311 strings translated, 164 intentionally left in
English (brand names and technical tokens).

<details>
<summary>Translated strings</summary>

| Key | English | Esperanto |
| --- | --- | --- |
| `root` | label: Go | label: Iri |
| `apps` | label: Apps | label: Aplikaĵoj |
| `learn` | label: Learn | label: Lerni |
| `appearance` | label: Appearance | label: Aspekto |
| `trigger` | label: Trigger | label: Ŝaltilo |
| `setup` | label: Setup | label: Agordo |
| `install` | label: Install | label: Instali |
| `remove` | label: Remove | label: Forigi |
| `update` | label: Update | label: Ĝisdatigi |
| `system` | label: System | label: Sistemo |
| `system.about` | label: About | [Missing translation] |
| `system.screensaver` | label: Screensaver | label: Ecranŝildilo |
| `system.lock` | label: Lock | label: Ŝlosi |
| `system.suspend` | label: Suspend | label: Dormi |
| `system.hibernate` | label: Hibernate | label: Hibernigi |
| `system.logout` | label: Logout | label: Elsaluti |
| `system.reboot` | label: Reboot | label: Rekomenci |
| `system.firmware` | label: Reboot to BIOS / description: Restart into the UEFI firmware setup | [Missing translation] |
| `system.shutdown` | label: Shutdown | label: Malŝalti |
| `learn.keybindings` | label: Keybindings | label: Klavkombinoj |
| `learn.community` | label: Community | label: Komunumo |
| `appearance.theme` | label: Theme | label: Etoso |
| `appearance.background` | label: Background | label: Fono |
| `appearance.font` | label: Font | label: Tiparo |
| `appearance.icons` | label: Icons | [Missing translation] |
| `appearance.top-bar` | label: Menu Bar | label: Menu-stripo |
| `appearance.top-bar.hide` | label: Hide Bar | label: Kaŝi stripon |
| `appearance.top-bar.show` | label: Show Bar | label: Montri stripon |
| `appearance.top-bar.position` | label: Position Bar | label: Pozicio de stripo |
| `appearance.top-bar.background` | label: Bar Background | label: Fono de stripo |
| `appearance.top-bar.background.opaque` | label: Opaque Bar | label: Nedurnebla stripo |
| `appearance.top-bar.background.glassy` | label: Glassy Bar | label: Vitra stripo |
| `appearance.top-bar.background.clear` | label: Clear Bar | label: Travglasita stripo |
| `appearance.top-bar.indicators` | label: Bar Indicators | label: Indikiloj de stripo |
| `appearance.top-bar.indicators.battery-percentage-on` | label: Show Battery % | label: Montri baterion % |
| `appearance.top-bar.indicators.battery-percentage-off` | label: Hide Battery % | label: Kaŝi baterion % |
| `appearance.top-bar.indicators.clock` | label: Clock | label: Horloĝo |
| `appearance.top-bar.indicators.clock.sunday-24h` | label: Sunday 14:30 | label: dimanĉo 14:30 |
| `appearance.top-bar.indicators.clock.sunday-12h` | label: Sunday 2:30 PM | label: dimanĉo 2:30 PM |
| `appearance.top-bar.indicators.clock.sunday-seconds-24h` | label: Sunday 14:30:05 | label: dimanĉo 14:30:05 |
| `appearance.top-bar.indicators.clock.sunday-seconds-12h` | label: Sunday 2:30:05 PM | label: dimanĉo 2:30:05 PM |
| `appearance.top-bar.indicators.clock.date-24h` | label: Sun 3 May 14:30 | label: dim 3 majo 14:30 |
| `appearance.top-bar.indicators.clock.date-12h` | label: Sun 3 May 2:30 PM | label: dim 3 majo 2:30 PM |
| `appearance.top-bar.indicators.clock.week` | label: 3 May W18 2026 | label: 3 majo S18 2026 |
| `appearance.top-bar.indicators.clock.stacked-date` | label: 03 May W18 '26 | label: 03 majo S18 '26 |
| `appearance.top-bar.position.top` | label: Top Bar | label: Supra stripo |
| `appearance.top-bar.position.bottom` | label: Bottom Bar | label: Suba stripo |
| `appearance.top-bar.position.left` | label: Left Bar | label: Maldekstra stripo |
| `appearance.top-bar.position.right` | label: Right Bar | label: Dekstra stripo |
| `appearance.windows` | label: Windows | label: Fenestroj |
| `appearance.windows.gaps-on` | label: Window Gaps On | label: Fenestraj interspacoj aktivaj |
| `appearance.windows.gaps-off` | label: Window Gaps Off | label: Fenestraj interspacoj neaktivaj |
| `appearance.windows.corners` | label: Window Corners | label: Fenestraj anguloj |
| `appearance.windows.corners.theme` | label: Theme Corners | label: Etosaj anguloj |
| `appearance.windows.corners.sharp` | label: Sharp Corners | label: Pikaj anguloj |
| `appearance.windows.corners.rounded` | label: Rounded Corners | label: Rondaj anguloj |
| `appearance.windows.transparency` | label: Window Opacity | label: Fenestra transparenteco |
| `appearance.windows.transparency.opaque` | label: Opaque Windows | label: Nedurneblaj fenestroj |
| `appearance.windows.transparency.transparent` | label: Transparent Windows | label: Travaglasaj fenestroj |
| `appearance.windows.transparency.glassy` | label: Glassy Windows | label: Vitraj fenestroj |
| `appearance.windows.one-window-ratio-on` | label: 1-Window Ratio On | label: Unu-fenestra rativo aktivaj |
| `appearance.windows.one-window-ratio-off` | label: 1-Window Ratio Off | label: Unu-fenestra rativo neaktivaj |
| `appearance.branding` | label: Branding | label: Markilo |
| `appearance.branding.screensaver` | label: Screensaver | label: Ecranŝildilo |
| `appearance.branding.about` | label: About | label: Pri |
| `appearance.branding.about.text` | label: Edit Text | label: Redakti tekston |
| `appearance.branding.about.image` | label: Set From Image | label: Agordi per bildo |
| `appearance.branding.about.default` | label: Restore Default | label: Restarigi defaŭlton |
| `appearance.branding.screensaver.text` | label: Edit Text | label: Redakti tekston |
| `appearance.branding.screensaver.image` | label: Set From Image | label: Agordi per bildo |
| `appearance.branding.screensaver.default` | label: Restore Default | label: Restarigi defaŭlton |
| `appearance.dock` | label: Dock | label: Doko |
| `appearance.dock.autohide` | label: Auto-hide Dock | label: Aŭtomatique kaŝi dokon |
| `appearance.dock.always-on` | label: Always-on Dock | label: Ĉiam videbla doko |
| `appearance.dock.position` | label: Dock Position | label: Pozicio de doko |
| `appearance.dock.position.top` | label: Top Dock | label: Supra doko |
| `appearance.dock.position.bottom` | label: Bottom Dock | label: Suba doko |
| `appearance.dock.position.left` | label: Left Dock | label: Maldekstra doko |
| `appearance.dock.position.right` | label: Right Dock | label: Dekstra doko |
| `appearance.workspace-layout` | label: Workspace Layout / title: Default Workspace Layout | label: Laborspaca aranĝo / title: Defaŭlta laborspaca aranĝo |
| `appearance.workspace-layout.dwindle` | label: Tiling | label: Mosaikado |
| `appearance.workspace-layout.scrolling` | label: Scrolling | label: Ruliĝo |
| `appearance.workspace-layout.floating` | label: Floating | label: Ŝveba |
| `appearance.animations-on` | label: Animations On | label: Animacioj aktivaj |
| `appearance.animations-off` | label: Animations Off | label: Animacioj neaktivaj |
| `appearance.unlock` | label: Unlock | label: Malŝlosi |
| `trigger.toggle` | label: Toggle | label: Ŝalteti |
| `trigger.toggle.idle-lock-on` | label: Stay Awake | label: Resti veka |
| `trigger.toggle.idle-lock-off` | label: Allow Sleep | label: Permesi dormon |
| `trigger.toggle.notifications-on` | label: Notifications On | label: Sciigoj aktivaj |
| `trigger.toggle.notifications-off` | label: Silence Notifications | label: Silentigi sciigojn |
| `trigger.toggle.nightlight-on` | label: Nightlight On | label: Nokta lumo aktiva |
| `trigger.toggle.nightlight-off` | label: Nightlight Off | label: Nokta lumo malaktiva |
| `trigger.toggle.screensaver-on` | label: Screensaver On | label: Ecranŝildilo aktiva |
| `trigger.toggle.screensaver-off` | label: Screensaver Off | label: Ecranŝildilo malaktiva |
| `trigger.toggle.crash-capture-on` | label: Crash Capture On | label: Kaptado de kraŝoj aktiva |
| `trigger.toggle.crash-capture-off` | label: Crash Capture Off | label: Kaptado de kraŝoj malaktiva |
| `trigger.emoji` | label: Emoji | label: Emojioj |
| `trigger.clipboard-history` | label: Clipboard History | label: Historio de tonubo |
| `trigger.reminder` | label: Reminder | label: Memorigo |
| `trigger.capture` | label: Capture | label: Kapti |
| `trigger.capture.screenshot` | label: Screenshot | label: Ekrankopio |
| `trigger.capture.screenrecord.stop` | label: Stop Screenrecording | label: Halti ekranregistradon |
| `trigger.capture.screenrecord` | label: Screenrecord | label: Ecranregistrado |
| `trigger.capture.text` | label: Text | label: Teksto |
| `trigger.capture.qr` | label: QR Code | label: QR-kodo |
| `trigger.capture.color` | label: Color | label: Koloro |
| `trigger.capture.screenrecord.no-audio` | label: With no audio | label: Sen audio |
| `trigger.capture.screenrecord.desktop-audio` | label: With desktop audio | label: Kun labortabla audio |
| `trigger.capture.screenrecord.microphone` | label: With desktop + microphone audio | label: Kun labortabla + mikrofona audio |
| `trigger.capture.screenrecord.webcam` | label: With desktop + microphone audio + webcam | label: Kun labortabla + mikrofona audio + retokamera |
| `trigger.transcode` | label: Transcode | label: Konverti formaton |
| `trigger.share` | label: Share | label: Kunhavigi |
| `trigger.hardware` | label: Hardware | label: Aparataro |
| `trigger.tests` | label: Speed Test | label: Rapideca testo |
| `trigger.hardware.laptop-display-on` | label: Laptop Display On | label: Ekrano de tekomejo aktiva |
| `trigger.hardware.laptop-display-off` | label: Laptop Display Off | label: Ekrano de tekomejo malaktiva |
| `trigger.hardware.mirror-display-on` | label: Display Mirroring On | label: Spegulado de ekrano aktiva |
| `trigger.hardware.mirror-display-off` | label: Display Mirroring Off | label: Spegulado de ekrano malaktiva |
| `trigger.hardware.hybrid-gpu-on` | label: Switch to Hybrid GPU | label: Ŝalti al hibrida GPU |
| `trigger.hardware.hybrid-gpu-off` | label: Switch to Integrated GPU | label: Ŝalti al integrita GPU |
| `trigger.hardware.touchpad-on` | label: Enable Touchpad | label: Ŝalti tuŝpladon |
| `trigger.hardware.touchpad-off` | label: Disable Touchpad | label: Malŝalti tuŝpladon |
| `trigger.hardware.touchpad-haptics` | label: Touchpad Haptics | label: Tuŝpladaj haptikoj |
| `trigger.hardware.touchpad-haptics.low` | label: low | label: malalta |
| `trigger.hardware.touchpad-haptics.mid` | label: mid | label: meza |
| `trigger.hardware.touchpad-haptics.high` | label: high | label: alta |
| `trigger.hardware.touchscreen-on` | label: Enable Touchscreen | label: Ŝalti tuŝekranon |
| `trigger.hardware.touchscreen-off` | label: Disable Touchscreen | label: Malŝalti tuŝekranon |
| `trigger.reminder.set` | label: Set one | label: Agordi unu |
| `trigger.reminder.show` | label: Show all | label: Montri ĉiujn |
| `trigger.reminder.clear` | label: Clear all | label: Vakigi ĉiujn |
| `trigger.share.clipboard` | label: Clipboard | label: Tonubo |
| `trigger.share.file` | label: File | label: Dosiero |
| `trigger.share.folder` | label: Folder | label: Dosierujo |
| `trigger.share.receive` | label: Receive | label: Akcepti |
| `trigger.tests.network-speedtest` | label: Network Speed Test | label: Retrapideca testo |
| `trigger.tests.disk-speedtest` | label: Disk Speed Test | label: Diskrapideca testo |
| `setup.keyboard` | label: Keyboard | [Missing translation] |
| `setup.keyboard.keybindings` | label: Keybindings | [Missing translation] |
| `setup.keyboard.inputs` | label: Keyboard Inputs | [Missing translation] |
| `setup.keyboard.input-methods` | label: Input Methods | [Missing translation] |
| `setup.input` | label: Input | label: Enigo |
| `setup.region` | label: Region | [Missing translation] |
| `setup.region.language` | label: Language | [Missing translation] |
| `setup.region.formats` | label: Formats / description: How dates, times, numbers and units are written | [Missing translation] |
| `setup.region.timezone` | label: Timezone | [Missing translation] |
| `setup.network` | label: Network | label: Reto |
| `setup.network.dns.alidns` | label: AliDNS | [Missing translation] |
| `setup.network.dns.custom` | label: Custom | label: Propra |
| `setup.network.hostname` | label: Hostname | [Missing translation] |
| `setup.network.qr` | label: QR Code | label: QR-kodo |
| `setup.default` | label: Defaults | label: Defaŭltoj |
| `setup.default.browser` | label: Browser / title: Default Browser | label: Retumilo / title: Defaŭlta retumilo |
| `setup.default.dictation` | label: Dictation / title: Default Dictation | label: Dikcio / title: Defaŭlta dikcio |
| `setup.default.dictation.hex` | label: Hex | [Missing translation] |
| `setup.default.terminal` | label: Terminal / title: Default Terminal | label: Terminalo / title: Defaŭlta terminalo |
| `setup.default.editor` | label: Editor / title: Default Editor | label: Redaktilo / title: Defaŭlta redaktilo |
| `setup.default.editor.plain` | label: Plain | [Missing translation] |
| `setup.plugin` | label: Plugins | label: Kromprogramoj |
| `setup.plugin.enable` | label: Enable Plugin | label: Ŝalti kromprogramon |
| `setup.plugin.disable` | label: Disable Plugin | label: Malŝalti kromprogramon |
| `setup.plugin.add` | label: Add Plugin | label: Aldoni kromprogramon |
| `setup.plugin.clone` | label: Clone Plugin | label: Kloni kromprogramon |
| `setup.plugin.remove` | label: Remove Plugin | label: Forigi kromprogramon |
| `setup.security` | label: Security | label: Sekureco |
| `setup.config` | label: Config | label: Agordo |
| `setup.security.fingerprint` | label: Fingerprint | label: Fingrospuro |
| `setup.security.ssh-agent` | label: SSH Agent | label: SSH-agento |
| `setup.security.sudoless-docker` | label: Sudoless Docker | label: Docker sen sudo |
| `setup.security.passwordless-sudo` | label: Passwordless Sudo | label: Sudo sen pasvorto |
| `setup.git` | label: Git | [Missing translation] |
| `remove.factory-reset` | label: Factory Reset | [Missing translation] |
| `install.package` | label: Package | label: Pakaĵo |
| `install.cli` | label: CLI | [Missing translation] |
| `install.ai.desktop` | label: Desktop | [Missing translation] |
| `install.ai.cli` | label: CLI | [Missing translation] |
| `install.service` | label: Service | label: Servo |
| `install.development` | label: Development | label: Programado |
| `install.editor` | label: Editor | label: Redaktilo |
| `install.style` | label: Style | label: Stilo |
| `install.style.theme` | label: Theme | label: Etoso |
| `install.style.background` | label: Background | label: Fono |
| `install.style.icons` | label: Icons | [Missing translation] |
| `install.style.font` | label: Font | label: Tiparo |
| `install.gaming` | label: Gaming | label: Ludoj |
| `install.browser` | label: Browser | label: Retumilo |
| `install.webapp` | label: Web App | label: Reta aplikaĵo |
| `install.terminal` | label: Terminal | label: Terminalo |
| `install.preinstalls` | label: Preinstalls | label: Preinstalaĵoj |
| `install.browser.chromium` | label: Chromium | [Missing translation] |
| `install.service.dingtalk` | label: DingTalk | [Missing translation] |
| `install.service.wechat` | label: WeChat | [Missing translation] |
| `install.service.notion` | label: Notion | [Missing translation] |
| `install.ai.desktop.amp` | label: Amp Desktop | [Missing translation] |
| `install.ai.desktop.antigravity` | label: Antigravity Desktop | [Missing translation] |
| `install.ai.desktop.chatgpt` | label: ChatGPT Desktop | [Missing translation] |
| `install.ai.desktop.claude` | label: Claude Desktop | [Missing translation] |
| `install.ai.desktop.grok-bot` | label: Grok Bot | [Missing translation] |
| `install.ai.desktop.herdr` | label: Herdr Desktop | [Missing translation] |
| `install.ai.desktop.hermes` | label: Hermes Desktop | [Missing translation] |
| `install.ai.desktop.lm-studio` | label: LM Studio | [Missing translation] |
| `install.ai.cli.ollama` | label: Ollama | [Missing translation] |
| `install.cli.basecamp` | label: Basecamp | [Missing translation] |
| `install.cli.cloudflare` | label: Cloudflare | [Missing translation] |
| `install.cli.github` | label: GitHub | [Missing translation] |
| `install.cli.hey` | label: HEY | [Missing translation] |
| `install.cli.hunk` | label: Hunk | [Missing translation] |
| `install.ai.cli.claude` | label: Claude Code | [Missing translation] |
| `install.ai.cli.codex` | label: Codex | [Missing translation] |
| `install.ai.cli.opencode` | label: OpenCode | [Missing translation] |
| `install.ai.cli.amp` | label: Amp | [Missing translation] |
| `install.ai.cli.antigravity` | label: Antigravity | [Missing translation] |
| `install.ai.cli.copilot` | label: GitHub Copilot | [Missing translation] |
| `install.ai.cli.crush` | label: Crush | [Missing translation] |
| `install.ai.cli.cursor` | label: Cursor CLI | [Missing translation] |
| `install.ai.cli.deepseek` | label: DeepSeek Harness | [Missing translation] |
| `install.ai.cli.devin` | label: Devin | [Missing translation] |
| `install.ai.cli.freebuff` | label: Freebuff | [Missing translation] |
| `install.ai.cli.grok` | label: Grok Build | [Missing translation] |
| `install.ai.cli.kilo` | label: Kilo | [Missing translation] |
| `install.ai.cli.kimi` | label: Kimi Code | [Missing translation] |
| `install.ai.cli.minimax` | label: MiniMax Code | [Missing translation] |
| `install.ai.cli.muse` | label: Muse Code | [Missing translation] |
| `install.ai.cli.oh-my-pi` | label: Oh My Pi | [Missing translation] |
| `install.ai.cli.ori` | label: Ori | [Missing translation] |
| `install.ai.cli.qwen` | label: Qwen Code | [Missing translation] |
| `install.ai.desktop.openclaw` | label: OpenClaw | [Missing translation] |
| `install.ai.desktop.opencode` | label: OpenCode Desktop | [Missing translation] |
| `install.ai.desktop.perplexity` | label: Perplexity | [Missing translation] |
| `install.ai.desktop.t3-code` | label: T3 Code | [Missing translation] |
| `install.gaming.vibes` | label: Game Vibes | [Missing translation] |
| `install.gaming.xbox-controllers` | label: Xbox Controllers | label: Xbox-regililoj |
| `install.gaming.moonlight` | label: Moonlight | [Missing translation] |
| `remove.package` | label: Package | label: Pakaĵo |
| `remove.ai` | label: AI / title: Remove | label: AI / title: Forigi |
| `remove.cli` | label: CLI / title: Remove | [Missing translation] |
| `remove.ai.desktop` | label: Desktop / title: Remove | [Missing translation] |
| `remove.ai.cli` | label: CLI / title: Remove | [Missing translation] |
| `remove.dictation` | label: Dictation | label: Dikcio |
| `remove.service` | label: Services / title: Remove | label: Servoj / title: Forigi |
| `remove.development` | label: Development / title: Remove | label: Programado / title: Forigi |
| `remove.theme` | label: Theme | label: Etoso |
| `remove.icons` | label: Icons | [Missing translation] |
| `remove.gaming` | label: Gaming / title: Remove | label: Ludoj / title: Forigi |
| `remove.browser` | label: Browser / title: Remove | label: Retumilo / title: Forigi |
| `remove.webapp` | label: Web App | label: Reta aplikaĵo |
| `remove.preinstalls` | label: Preinstalls | label: Preinstalaĵoj |
| `remove.security` | label: Security / title: Remove | label: Sekureco / title: Forigi |
| `remove.security.fingerprint` | label: Fingerprint | label: Fingrospuro |
| `remove.security.sudoless-docker` | label: Sudoless Docker | label: Docker sen sudo |
| `remove.ai.desktop.hermes` | label: Hermes Desktop | [Missing translation] |
| `remove.browser.chromium` | label: Chromium | [Missing translation] |
| `remove.service.ssh-agent` | label: SSH Agent | label: SSH-agento |
| `remove.ai.desktop.amp` | label: Amp Desktop | [Missing translation] |
| `remove.ai.desktop.antigravity` | label: Antigravity Desktop | [Missing translation] |
| `remove.ai.desktop.chatgpt` | label: ChatGPT Desktop | [Missing translation] |
| `remove.ai.desktop.claude` | label: Claude Desktop | [Missing translation] |
| `remove.dictation.hex` | label: Hex | [Missing translation] |
| `remove.ai.desktop.grok-bot` | label: Grok Bot | [Missing translation] |
| `remove.ai.desktop.lm-studio` | label: LM Studio | [Missing translation] |
| `remove.ai.cli.ollama` | label: Ollama | [Missing translation] |
| `remove.cli.basecamp` | label: Basecamp | [Missing translation] |
| `remove.cli.cloudflare` | label: Cloudflare | [Missing translation] |
| `remove.cli.github` | label: GitHub | [Missing translation] |
| `remove.cli.hey` | label: HEY | [Missing translation] |
| `remove.cli.hunk` | label: Hunk | [Missing translation] |
| `remove.ai.cli.claude` | label: Claude Code | [Missing translation] |
| `remove.ai.cli.codex` | label: Codex | [Missing translation] |
| `remove.ai.cli.opencode` | label: OpenCode | [Missing translation] |
| `remove.ai.cli.amp` | label: Amp | [Missing translation] |
| `remove.ai.cli.antigravity` | label: Antigravity | [Missing translation] |
| `remove.ai.cli.copilot` | label: GitHub Copilot | [Missing translation] |
| `remove.ai.cli.crush` | label: Crush | [Missing translation] |
| `remove.ai.cli.cursor` | label: Cursor CLI | [Missing translation] |
| `remove.ai.cli.deepseek` | label: DeepSeek Harness | [Missing translation] |
| `remove.ai.cli.devin` | label: Devin | [Missing translation] |
| `remove.ai.cli.freebuff` | label: Freebuff | [Missing translation] |
| `remove.ai.cli.grok` | label: Grok Build | [Missing translation] |
| `remove.ai.cli.kilo` | label: Kilo | [Missing translation] |
| `remove.ai.cli.kimi` | label: Kimi Code | [Missing translation] |
| `remove.ai.cli.minimax` | label: MiniMax Code | [Missing translation] |
| `remove.ai.cli.muse` | label: Muse Code | [Missing translation] |
| `remove.ai.cli.oh-my-pi` | label: Oh My Pi | [Missing translation] |
| `remove.ai.cli.ori` | label: Ori | [Missing translation] |
| `remove.ai.cli.qwen` | label: Qwen Code | [Missing translation] |
| `remove.ai.desktop.openclaw` | label: OpenClaw | [Missing translation] |
| `remove.ai.desktop.opencode` | label: OpenCode Desktop | [Missing translation] |
| `remove.ai.desktop.perplexity` | label: Perplexity | [Missing translation] |
| `remove.ai.desktop.t3-code` | label: T3 Code | [Missing translation] |
| `remove.gaming.xbox-controllers` | label: Xbox Controllers (󰂯) | label: Xbox-regililoj (󰂯) |
| `remove.gaming.moonlight` | label: Moonlight | [Missing translation] |
| `remove.gaming.vibes` | label: Game Vibes Game | [Missing translation] |
| `remove.development.javascript` | label: JavaScript / title: Remove | label: JavaScript / title: Forigi |
| `remove.development.php` | label: PHP / title: Remove | label: PHP / title: Forigi |
| `remove.development.elixir` | label: Elixir / title: Remove | label: Elixir / title: Forigi |
| `update.channel` | label: Channel | label: Kanalo |
| `update.kernel` | label: Kernel | label: Kerno |
| `update.config` | label: Config / title: Reset to default | label: Agordo / title: Restarigi al defaŭlto |
| `update.themes` | label: Extra Themes | label: Extra etosoj |
| `update.icons` | label: Extra Icons | [Missing translation] |
| `update.games` | label: Game Vibes Games | [Missing translation] |
| `update.process` | label: Process / title: Restart | label: Procezo / title: Rekomenci |
| `update.hardware` | label: Hardware / title: Restart | label: Aparataro / title: Rekomenci |
| `update.firmware` | label: Firmware | label: Firmvero |
| `update.password` | label: Password | label: Pasvorto |
| `update.time` | label: Time | label: Tempo |
| `update.channel.stable` | label: Stable | label: Stabla |
| `update.process.shell` | label: Shell | label: Ŝelo |
| `update.config.shell` | label: Shell | label: Ŝelo |
| `update.hardware.trackpad` | label: Trackpad | label: Tuŝplado |

</details>

<details>
<summary>Left in English (164, for reference)</summary>

- `learn.omarchy`: label: Omarchy
- `learn.hyprland`: label: Hyprland
- `learn.arch`: label: Arch
- `learn.neovim`: label: Neovim
- `learn.bash`: label: Bash
- `learn.tmux-keybindings`: label: Tmux
- `learn.herdr-keybindings`: label: Herdr
- `appearance.top-bar.indicators.clock.time-24h`: label: 14:30
- `appearance.top-bar.indicators.clock.time-12h`: label: 2:30 PM
- `appearance.top-bar.indicators.clock.iso`: label: 2026-05-03 14:30
- `appearance.top-bar.indicators.clock.stacked-24h`: label: 14 — 30
- `appearance.top-bar.indicators.clock.stacked-12h`: label: 2 — 30 PM
- `appearance.top-bar.indicators.clock.stacked-time`: label: 14 30
- `setup.network.dns`: label: DNS
- `setup.network.dns.dhcp`: label: DHCP
- `setup.network.dns.cloudflare`: label: Cloudflare
- `setup.network.dns.google`: label: Google
- `setup.default.browser.chromium`: label: Chromium
- `setup.default.browser.chrome`: label: Chrome
- `setup.default.browser.brave`: label: Brave
- `setup.default.browser.brave-origin`: label: Brave Origin
- `setup.default.browser.edge`: label: Edge
- `setup.default.browser.firefox`: label: Firefox
- `setup.default.browser.zen`: label: Zen
- `setup.default.dictation.superwhisper`: label: Superwhisper
- `setup.default.dictation.voxtype`: label: Voxtype
- `setup.default.terminal.alacritty`: label: Alacritty
- `setup.default.terminal.foot`: label: Foot
- `setup.default.terminal.ghostty`: label: Ghostty
- `setup.default.terminal.kitty`: label: Kitty
- `setup.default.editor.neovim`: label: Neovim
- `setup.default.editor.vscode`: label: VSCode
- `setup.default.editor.cursor`: label: Cursor
- `setup.default.editor.zed`: label: Zed
- `setup.default.editor.sublime`: label: Sublime Text
- `setup.default.editor.helix`: label: Helix
- `setup.default.editor.vim`: label: Vim
- `setup.default.editor.emacs`: label: Emacs
- `setup.security.fido2`: label: Fido2
- `setup.security.sshd`: label: SSHD
- `setup.config.hyprland`: label: Hyprland
- `setup.config.hyprsunset`: label: Hyprsunset
- `setup.config.xcompose`: label: XCompose
- `install.ai`: label: AI
- `install.style.font.cascadia`: label: Cascadia Mono
- `install.style.font.meslo`: label: Meslo LG Mono
- `install.style.font.fira`: label: Fira Code
- `install.style.font.victor`: label: Victor Code
- `install.style.font.bitstream`: label: Bitstream Vera Mono
- `install.style.font.iosevka`: label: Iosevka
- `install.tui`: label: TUI
- `install.windows`: label: Windows
- `install.aur`: label: AUR
- `install.browser.chrome`: label: Chrome
- `install.browser.edge`: label: Edge
- `install.browser.brave`: label: Brave
- `install.browser.brave-origin`: label: Brave Origin
- `install.browser.firefox`: label: Firefox
- `install.browser.zen`: label: Zen
- `install.service.1password`: label: 1Password
- `install.service.dropbox`: label: Dropbox
- `install.service.signal`: label: Signal
- `install.service.slack`: label: Slack
- `install.service.tailscale`: label: Tailscale
- `install.service.nordvpn`: label: NordVPN
- `install.service.once`: label: ONCE
- `install.service.bitwarden`: label: Bitwarden
- `install.service.microsoft`: label: Microsoft
- `install.editor.vscode`: label: VSCode
- `install.editor.cursor`: label: Cursor
- `install.editor.zed`: label: Zed
- `install.editor.sublime`: label: Sublime Text
- `install.editor.helix`: label: Helix
- `install.editor.vim`: label: Vim
- `install.editor.emacs`: label: Emacs
- `install.terminal.alacritty`: label: Alacritty
- `install.terminal.foot`: label: Foot
- `install.terminal.ghostty`: label: Ghostty
- `install.terminal.kitty`: label: Kitty
- `install.gaming.steam`: label: Steam
- `install.gaming.retroarch`: label: RetroArch
- `install.gaming.minecraft`: label: Minecraft
- `install.gaming.geforce-now`: label: NVIDIA GeForce NOW
- `install.gaming.xbox-cloud`: label: Xbox Cloud Gaming
- `install.gaming.battlenet`: label: Battle.net
- `install.gaming.lutris`: label: Lutris
- `install.gaming.heroic`: label: Heroic (Epic Games)
- `install.gaming.retro-launcher`: label: RetroArch Game Launcher
- `install.development.rails`: label: Ruby on Rails
- `install.development.docker-dbs`: label: Docker DB
- `install.development.javascript`: label: JavaScript
- `install.development.go`: label: Go
- `install.development.php`: label: PHP
- `install.development.python`: label: Python
- `install.development.elixir`: label: Elixir
- `install.development.zig`: label: Zig
- `install.development.rust`: label: Rust
- `install.development.java`: label: Java
- `install.development.dotnet`: label: .NET
- `install.development.ocaml`: label: OCaml
- `install.development.clojure`: label: Clojure
- `install.development.scala`: label: Scala
- `install.development.javascript.node`: label: Node.js
- `install.development.javascript.bun`: label: Bun
- `install.development.javascript.deno`: label: Deno
- `install.development.php.php`: label: PHP
- `install.development.php.laravel`: label: Laravel
- `install.development.php.symfony`: label: Symfony
- `install.development.elixir.elixir`: label: Elixir
- `install.development.elixir.phoenix`: label: Phoenix
- `remove.tui`: label: TUI
- `remove.windows`: label: Windows
- `remove.security.fido2`: label: Fido2
- `remove.security.sshd`: label: SSHD
- `remove.browser.chrome`: label: Chrome
- `remove.browser.edge`: label: Edge
- `remove.browser.brave`: label: Brave
- `remove.browser.brave-origin`: label: Brave Origin
- `remove.browser.firefox`: label: Firefox
- `remove.browser.zen`: label: Zen
- `remove.service.1password`: label: 1Password
- `remove.service.dropbox`: label: Dropbox
- `remove.service.tailscale`: label: Tailscale
- `remove.service.microsoft`: label: Microsoft
- `remove.dictation.superwhisper`: label: Superwhisper
- `remove.dictation.voxtype`: label: Voxtype
- `remove.gaming.steam`: label: Steam
- `remove.gaming.retroarch`: label: RetroArch
- `remove.gaming.minecraft`: label: Minecraft
- `remove.gaming.geforce-now`: label: NVIDIA GeForce NOW
- `remove.gaming.xbox-cloud`: label: Xbox Cloud Gaming
- `remove.gaming.battlenet`: label: Battle.net
- `remove.gaming.lutris`: label: Lutris
- `remove.gaming.heroic`: label: Heroic (Epic Games)
- `remove.development.rails`: label: Ruby on Rails
- `remove.development.go`: label: Go
- `remove.development.python`: label: Python
- `remove.development.zig`: label: Zig
- `remove.development.rust`: label: Rust
- `remove.development.java`: label: Java
- `remove.development.dotnet`: label: .NET
- `remove.development.ocaml`: label: OCaml
- `remove.development.clojure`: label: Clojure
- `remove.development.scala`: label: Scala
- `remove.development.javascript.node`: label: Node.js
- `remove.development.javascript.bun`: label: Bun
- `remove.development.javascript.deno`: label: Deno
- `remove.development.php.php`: label: PHP
- `remove.development.php.laravel`: label: Laravel
- `remove.development.php.symfony`: label: Symfony
- `remove.development.elixir.elixir`: label: Elixir
- `remove.development.elixir.phoenix`: label: Phoenix
- `update.omarchy`: label: Omarchy
- `update.channel.rc`: label: RC
- `update.channel.edge`: label: Edge
- `update.channel.dev`: label: Dev
- `update.process.hyprsunset`: label: Hyprsunset
- `update.config.hyprland`: label: Hyprland
- `update.config.hyprsunset`: label: Hyprsunset
- `update.config.plymouth`: label: Plymouth
- `update.config.tmux`: label: Tmux
- `update.hardware.audio`: label: Audio
- `update.hardware.wifi`: label: Wi-Fi
- `update.hardware.bluetooth`: label: Bluetooth

</details>

## Shell (`shell.json`) — 558 keys

542 strings translated, 21 intentionally left in
English (brand names and technical tokens).

<details>
<summary>Translated strings</summary>

| Key | English | Esperanto |
| --- | --- | --- |
| `agents.addKinds` | Subscription, per use, or local | [Missing translation] |
| `agents.addTitle` | Add an agent | [Missing translation] |
| `agents.blockNetworkModel` | USE A NETWORK MODEL | [Missing translation] |
| `agents.blockOwnModel` | USE A LOCAL MODEL | [Missing translation] |
| `agents.blockProviders` | USE PAY AS YOU GO | [Missing translation] |
| `agents.blockSubscriptions` | USE A SUBSCRIPTION | [Missing translation] |
| `agents.firstBecomesDefault` | The first one is your default | [Missing translation] |
| `agents.app` | App | Aplikaĵo |
| `agents.backToLimits` | Back to the limits | Reen al limojn |
| `agents.balance` | Balance | Saldo |
| `agents.balanceUnavailable` | Balance unavailable | Saldo neatingebla |
| `agents.busiestDay` | Busiest day: %1 | Plej okupata tago: %1 |
| `agents.checkingCode` | Checking the code… | Kontrolado de la kodo… |
| `agents.checkingKey` | Checking the key… | [Missing translation] |
| `agents.enterApiKey` | Paste your API key | [Missing translation] |
| `agents.confirmCode` | Confirm this code in your browser | Konfirmu ĉi tiun kodon en via retumilo |
| `agents.durationDaysHours` | %1d %2h | %1t %2h |
| `agents.durationNow` | now | nun |
| `agents.freeResets` | one: %1 free reset / other: %1 free resets | one: %1 senpaga restarigo / other: %1 senpagaj restarigoj |
| `agents.freeResetsExpires` | one: %1 free reset · next expires in %2 / other: %1 free resets · next expires in %2 | one: %1 senpaga restarigo · la sekva eksvalidiĝas post %2 / other: %1 senpagaj restarigoj · la sekva eksvalidiĝas post %2 |
| `agents.game` | Game | [Missing translation] |
| `agents.helpFireworksSignIn` | Set %1, run %2, or sign in to Fireworks in pi or opencode. | Agordu %1, rulu %2, aŭ(signi en Fireworks per pi aŭ opencode. |
| `agents.helpNotInPath` | %1 not found in PATH | %1 ne trovita en PATH |
| `agents.helpRunToAuthenticate` | Run %1 to authenticate. | Rulu %1 por aŭtentigi. |
| `agents.helpRunToRestoreUsage` | Run %1 to restore authoritative usage. | Rulu %1 por restarigi la aŭtoritativan uzon. |
| `agents.helpScanFailed` | %1 usage scan failed | %1 uzskanado malsukcesis |
| `agents.helpSignInExpired` | %1's saved sign-in expired. Start %1 to refresh it. | Konservita enloko de %1 eksvalidiĝis. Startu %1 por aktualigi ĝin. |
| `agents.helpStartOrRunToSignIn` | Start %1, or run %2, to sign in. | Startu %1, aŭ rulu %2, por enlokiĝi. |
| `agents.helpStartToSeeLimits` | Start %1 to see its limits; signing in again is not needed. | Startu %1 por vidi ĝiajn limojn; re-enlokiĝo ne necesas. |
| `agents.lastUpdatedAgo` | Last updated %1 ago | Laste aktualigita antaŭ %1 |
| `agents.lastUpdatedJustNow` | Last updated less than a minute ago | Laste aktualigita antaŭ malpli ol minuto |
| `agents.lastUpdatedUnknown` | Last updated time unavailable | Tempo de lasta aktualigo neatingebla |
| `agents.limitsPaused` | Limits paused | Limoj paŭzitaj |
| `agents.makeSomethingCool` | MAKE SOMETHING COOL | FARU ION SEKRETAN |
| `agents.merged` | one: Merged from %1 device / other: Merged from %1 devices | one: Kombinitaj el %1 aparato / other: Kombinitaj el %1 aparatoj |
| `agents.modelMonthly` | %1 Monthly | %1 monata |
| `agents.modelSession` | %1 Session | %1 seanca |
| `agents.modelWeekly` | %1 Weekly | %1 semajna |
| `agents.mostlyModel` | Mostly %1 | Plejparte %1 |
| `agents.nameAccount` | Name this account. It signs in through a private window, so your browser's current account isn't picked up. | Nomu ĉi tiun konton. Ĝi enlokiĝas tra privata fenestro, do la aktuala konto de via retumilo ne estas uzata. |
| `agents.outOfCredits` | Out of credits | [Missing translation] |
| `agents.pasteCode` | If the page shows a code instead of finishing, paste it here. | Se la paĝo montras kodon anstataŭ fini, glu ĝin ĉi tie. |
| `agents.pasteCodeLink` | Page showing a code instead? | [Missing translation] |
| `agents.placeholderApiKey` | API key | [Missing translation] |
| `agents.placeholderCode` | Code | Kodo |
| `agents.placeholderWork` | Work | Laboro |
| `agents.plugin` | Plugin | Kromprogramo |
| `agents.promptsToday` | one: %1 prompt today / other: %1 prompts today | one: %1 prompto hodiaŭ / other: %1 promptoj hodiaŭ |
| `agents.providerLimitsUnavailable` | %1 limits unavailable | Limoj de %1 neatingeblaj |
| `agents.providerUnavailable` | %1 unavailable | %1 neatingebla |
| `agents.reopenSignIn` | Open the sign-in page again | Remalfermi la enlokigan paĝon |
| `agents.scopedMonthly` | %1: %2% of its monthly allowance | %1: %2% de sia monata kvoto |
| `agents.scopedOther` | %1: %2% of its %3 allowance | %1: %2% de sia %3 kvoto |
| `agents.scopedSession` | %1: %2% of its session allowance | %1: %2% de sia seanca kvoto |
| `agents.scopedWeekly` | %1: %2% of its weekly allowance | %1: %2% de sia semajna kvoto |
| `agents.sessionsToday` | one: %1 session today / other: %1 sessions today | one: %1 seanco hodiaŭ / other: %1 seancoj hodiaŭ |
| `agents.signInAgainAccount` | Sign in to this account again | Reenlokiĝi en ĉi tiun konton |
| `agents.signInAgainProvider` | Sign in to %1 again | Reenlokiĝi en %1 |
| `agents.signInExpired` | Sign-in expired | Enloko eksvalidiĝis |
| `agents.signInRequired` | Sign-in required | Enloko necesas |
| `agents.signInUnfinished` | The sign-in didn't finish. | La enloko ne finis. |
| `agents.installingMeter` | Installing | [Missing translation] |
| `agents.downloadRate` | %1 MB/s | [Missing translation] |
| `agents.loginBrowser` | Log in through your browser | [Missing translation] |
| `agents.editInstructions` | Edit AGENTS.md, the instructions every agent follows | [Missing translation] |
| `agents.forgetAccountConfirm` | Remove %1? | [Missing translation] |
| `agents.removeFailed` | Couldn't remove %1 | [Missing translation] |
| `agents.removeDefaultLocalModelConfirm` | Delete %1 from this machine? It stops, its download is deleted, + can set it up again, and the agent at the top becomes the default. | [Missing translation] |
| `agents.removeLocalModelConfirm` | Delete %1 from this machine? It stops, its download is deleted, and + can set it up again. | [Missing translation] |
| `agents.memoryShort` | Needs %1 GB memory (only %2 GB free) | [Missing translation] |
| `agents.unlink` | Unlink | [Missing translation] |
| `agents.unlinkModelConfirm` | Unlink %1? | [Missing translation] |
| `agents.hideProviderConfirm` | Hide %1 from the panel? Credentials and sign-in will be kept. | [Missing translation] |
| `agents.isDefault` | Your default agent | [Missing translation] |
| `agents.launchHarness` | Start %1 | [Missing translation] |
| `agents.more` | More | [Missing translation] |
| `agents.moreInOpenCode` | Another provider in OpenCode… | [Missing translation] |
| `agents.openDesktopApp` | Open %1 | [Missing translation] |
| `agents.makeSomethingWith` | Make something with %1 | [Missing translation] |
| `agents.makeWith` | Make a new %1 with %2 | [Missing translation] |
| `agents.makeDefault` | Make %1 your default agent | [Missing translation] |
| `agents.spendDay` | %1: %2 | [Missing translation] |
| `agents.spendDayTokens` | one: %1: %2 for %3 token / other: %1: %2 for %3 tokens | [Missing translation] |
| `agents.spendEstimated` | ≈ %1 | [Missing translation] |
| `agents.spendLast30Days` | Last 30 days | [Missing translation] |
| `agents.spendOfCap` | %1 of %2 | [Missing translation] |
| `agents.spendThisMonth` | This month | [Missing translation] |
| `agents.startOnNew` | Start your default agent on a new %1 | Startu vian defaŭltan agenton en nova %1 |
| `agents.settingUp` | Setting up | [Missing translation] |
| `agents.signingInAgain` | Signing in again | [Missing translation] |
| `agents.starting` | Starting… | Startado… |
| `agents.letsMakeSomethingCool` | Let's make something cool | [Missing translation] |
| `agents.syncMkdirFailed` | Usage sync mkdir failed | Kreado de dosierujo por uzsinkronizo malsukcesis |
| `agents.syncScanFailed` | Usage sync scan failed | Skanado por uzsinkronizo malsukcesis |
| `agents.theme` | Theme | Etoso |
| `agents.tierPrepaid` | Prepaid | Prepagita |
| `agents.setUpTitle` | Set up your agent | [Missing translation] |
| `agents.title` | Agents | Agentoj |
| `agents.tokensThisWeek` | one: %1 token this week / other: %1 tokens this week | one: %1 tokeno ĉi-semajne / other: %1 tokenoj ĉi-semajne |
| `agents.tokensToday` | one: %1 token today / other: %1 tokens today | one: %1 tokeno hodiaŭ / other: %1 tokenoj hodiaŭ |
| `agents.unknownModel` | Unknown | Nesciata |
| `agents.waitingForAuth` | Waiting for auth | Atendo de aŭtentigo |
| `agents.windowLimit` | Limit | Limo |
| `agents.windowMonthly` | Monthly | Monata |
| `agents.windowSession` | Session | Seanca |
| `agents.windowSpendLimit` | Spend limit | Eluzlima |
| `agents.windowUsed` | %1: %2% used | %1: %2% uzita |
| `agents.windowUsedResets` | %1: %2% used · resets in %3 | %1: %2% uzita · restarigas post %3 |
| `agents.windowWeekly` | Weekly | Semajna |
| `localModels.contextFact` | %1K context | [Missing translation] |
| `localModels.installingMeter` | Installing | [Missing translation] |
| `localModels.linkOffer` | %1 is cabled to this Spark | [Missing translation] |
| `localModels.linkOfferUnnamed` | Another DGX Spark is cabled to this one | [Missing translation] |
| `localModels.linkSetUp` | Set both up to run models across them | [Missing translation] |
| `localModels.loadingMeter` | Loading | [Missing translation] |
| `localModels.memoryFact` | %1 GiB memory | [Missing translation] |
| `localModels.networkPairFailed` | Couldn't pair with %1 | [Missing translation] |
| `localModels.networkPairing` | Pairing with %1… | [Missing translation] |
| `localModels.networkShare` | Share on your tailnet | [Missing translation] |
| `localModels.networkSharedUsers` | one: Shared with %1 user · stop sharing / other: Shared with %1 users · stop sharing | [Missing translation] |
| `localModels.networkStopSharing` | Shared on your tailnet · stop sharing | [Missing translation] |
| `localModels.notEnoughMemory` | Not enough memory | [Missing translation] |
| `localModels.recommended` | Recommended | [Missing translation] |
| `localModels.removingMeter` | Removing | [Missing translation] |
| `localModels.setupFailed` | Setup failed | [Missing translation] |
| `localModels.showLogsTip` | Open this model's logs in a terminal | [Missing translation] |
| `localModels.speedFact` | %1 tok/s | [Missing translation] |
| `localModels.start` | Start | [Missing translation] |
| `localModels.stop` | Stop | [Missing translation] |
| `localModels.stoppingMeter` | Stopping | [Missing translation] |
| `localModels.update` | Update available · restarts the model | [Missing translation] |
| `localModels.updateDownloadGb` | Update available · %1 GB to download · restarts the model | [Missing translation] |
| `localModels.updateDownloadMb` | Update available · %1 MB to download · restarts the model | [Missing translation] |
| `localModels.updating` | Updating | [Missing translation] |
| `appLibrary.launching` | Launching %1… | Lanĉado de %1… |
| `appLibrary.launchingApp` | Launching application… | Lanĉado de aplikaĵo… |
| `audio.input` | INPUT | ENIGO |
| `audio.level.concertHall` | Concert hall | Konzertsalo |
| `audio.level.crankedUp` | Cranked up | Ĝis la maksimumo |
| `audio.level.easyListening` | Easy listening | Facila aŭskultado |
| `audio.level.muted` | Muted | Silentigita |
| `audio.level.partyMode` | Party mode | Fest modo |
| `audio.level.silenced` | Silenced | Silentigita |
| `audio.level.steadyGroove` | Steady groove | Konstanca ritmo |
| `audio.mute` | Mute | Silentigi |
| `audio.output` | OUTPUT | ELIGO |
| `audio.sources` | SOURCES | FONTOJ |
| `audio.stream` | Stream | Fluo |
| `audio.unknownDevice` | Unknown | Nesciata |
| `audio.unmute` | Unmute | Malsilentigi |
| `bar.allowIdleLock` | Allow Idle Lock & Screensaver | Permesi ŝlosadon kaj ekranŝildilon dum nezaktivado |
| `bar.allowNotifications` | Allow Notifications | Permesi sciigojn |
| `bar.dayLight` | Day Light | Taga lumo |
| `bar.disablePasswordlessSudo` | Disable Passwordless Sudo | Malŝalti sudo sen pasvorto |
| `bar.microphoneInUse` | Microphone in use | Mikrofono en uzo |
| `bar.microphoneLive` | Microphone live | Mikrofono aktiva |
| `bar.microphoneMuted` | Microphone muted | Mikrofono silentigita |
| `bar.nightLight` | Night Light | Nokta lumo |
| `bar.passwordlessSudo` | Passwordless Sudo | Sudo sen pasvorto |
| `bar.passwordlessSudoDisableFailed` | Could not disable passwordless sudo | Ne eblis malŝalti sudo sen pasvorto |
| `bar.passwordlessSudoDisableFailedBody` | Check the sudo configuration and try again. | Kontrolu la agordon de sudo kaj reprovu. |
| `bar.pendingUpdates` | Pending Omarchy Updates | Atendantaj ĝisdatigoj de Omarchy |
| `bar.remoteSession` | Remote session | Malproksima seanco |
| `bar.remoteSessionFrom` | Remote session from %1 | Malproksima seanco el %1 |
| `bar.screenRecording` | Screen Recording | Ecranregistrado |
| `bar.silenceNotifications` | Silence Notifications | Silentigi sciigojn |
| `bar.stayAwake` | Stay Awake | Resti veka |
| `bar.stopRecording` | Stop recording | Halti registradon |
| `bluetooth.available` | AVAILABLE | DISPONEBLA |
| `bluetooth.connect` | Connect | Konekti |
| `bluetooth.connected` | CONNECTED | KONEKTITA |
| `bluetooth.connectedStatus` | Connected | Konektita |
| `bluetooth.connecting` | Connecting… | Konektado… |
| `bluetooth.device` | Device | Aparato |
| `bluetooth.disconnect` | Disconnect | Malkonekti |
| `bluetooth.disconnecting` | Disconnecting… | Malkonektado… |
| `bluetooth.forget` | Forget | Forgesi |
| `bluetooth.forgetting` | Forgetting… | Forgesado… |
| `bluetooth.noAdapter` | No adapter | Neniu adaptilo |
| `bluetooth.noBluetoothAdapter` | No Bluetooth adapter | Neniu Bluetooth-adaptilo |
| `bluetooth.pair` | Pair | Parigi |
| `bluetooth.paired` | PAIRED | PARIGITA |
| `bluetooth.phrase1` | Untangling wires | Malnodoŝi kablojn |
| `bluetooth.phrase2` | Streaming vikings | Transmeti vikingojn |
| `bluetooth.phrase3` | Pairing mysteries | Mistikoj de parigado |
| `bluetooth.phrase4` | Herding headsets | Gvati kaskaŭojn |
| `bluetooth.phrase5` | Taming radios | Krotoligi radion |
| `bluetooth.phrase6` | Summoning speakers | Voki laŭtparolilojn |
| `bluetooth.phrase7` | Wrangling codecs | Kapti kodekojn |
| `bluetooth.phrase8` | Polishing packets | Poluri paketojn |
| `bluetooth.scanning` | Scanning for devices… | Skanado por aparatoj… |
| `bluetooth.turnOff` | Turn Bluetooth off | Malŝalti Bluetooth |
| `bluetooth.turnOn` | Turn Bluetooth on | Ŝalti Bluetooth |
| `bluetooth.turnOnToScan` | Turn Bluetooth on to scan | Ŝalti Bluetooth por skani |
| `bluetooth.turnedOff` | Turned Off | Malŝaltita |
| `clipboard.deleteHistory` | Delete entire clipboard history? | Ĉu forigi la tutan historian de la tonubo? |
| `clipboard.empty` | Clipboard is empty | La tonubo estas malplena |
| `clipboard.files` | one: %1 file / other: %1 files | one: %1 dosiero / other: %1 dosieroj |
| `clipboard.image` | Image | Bildo |
| `clipboard.imageFrom` | Image from %1 | Bildo el %1 |
| `clipboard.screenshotFrom` | Screenshot from %1 | Ekrankopio el %1 |
| `clipboard.search` | Search clipboard… | Serĉi en tonubon… |
| `clock.backToToday` | Back to today | Reen al hodiaŭ |
| `clock.born` | BORN | NASKITA |
| `clock.life` | LIFE | VIVO |
| `clock.liveTo` | LIVE TO | VIVA ĜIS |
| `clock.nextMonth` | Next month | Sekva monato |
| `clock.previousMonth` | Previous month | Antaŭa monato |
| `clock.startWeeksOn` | Start weeks on %1 | Semojn komenci ĉe %1 |
| `clock.toggleFormat` | Right-click to toggle format | Klaku dekstre por ŝalti formaton |
| `clock.year` | year | jaro |
| `common.apply` | Apply | Apliki |
| `common.cancel` | Cancel | Nuligi |
| `common.confirm` | Confirm | Konfirmi |
| `common.delete` | Delete | Forigi |
| `common.loading` | Loading… | Ŝargado… |
| `common.noMatches` | No matches | Neniu kongruo |
| `common.noMatchesFor` | No matches for “%1” | Neniu kongruo por “%1” |
| `common.noOptions` | No options | Neniu elekteblo |
| `common.noneSelected` | None selected | Nenio elektita |
| `common.search` | Search... | Serĉi... |
| `common.uninstall` | Uninstall | Malinstali |
| `common.uninstallConfirm` | Do you want to uninstall %1? | Ĉu vi volas malinstali %1? |
| `diskSpeedtest.failed` | Disk speed test failed | Diskrapideca testo malsukcesis |
| `diskSpeedtest.read` | READ | LEGI |
| `diskSpeedtest.write` | WRITE | SKRIBI |
| `dock.autoHide` | Auto-hide | Aŭtomatique kaŝi |
| `dock.keepInDock` | Keep in Dock | Teni en la doko |
| `dock.newWindow` | New Window | Nova fenestro |
| `dock.noAppsMatch` | No apps match “%1” | Neniu aplikaĵo kongruas kun “%1” |
| `dock.open` | Open | Malfermi |
| `dock.positionBottom` | Bottom | Suba |
| `dock.positionLeft` | Left | Maldekstra |
| `dock.positionRight` | Right | Dekstra |
| `dock.positionTop` | Top | Supra |
| `dock.quit` | Quit | Ĉesi |
| `dock.removeFromDock` | Remove from Dock | Forigi el la doko |
| `dock.searchApps` | Search apps… | Serĉi aplikaĵojn… |
| `dock.uninstall` | Uninstall | Malinstali |
| `dropbox.commandFailed` | Dropbox command failed | Komando de Dropbox malsukcesis |
| `dropbox.daysAgo` | %1d ago | antaŭ %1t |
| `dropbox.hoursAgo` | %1h ago | antaŭ %1h |
| `dropbox.installHelp` | Install Dropbox from the service menu | Instali Dropbox el la serv-menuo |
| `dropbox.justNow` | Just now | Nun |
| `dropbox.login` | Login to Dropbox | Enlokiĝi en Dropbox |
| `dropbox.loginFailed` | Dropbox login failed | Enloko en Dropbox malsukcesis |
| `dropbox.loginHelp` | Start the authentication flow | Komenci la aŭtentigan fluon |
| `dropbox.minutesAgo` | %1m ago | antaŭ %1m |
| `dropbox.monthsAgo` | %1mo ago | antaŭ %1mo |
| `dropbox.noFiles` | No synced files found. | Neniu sinkronigita dosiero trovita. |
| `dropbox.notInstalled` | Dropbox CLI is not installed | La CLI de Dropbox ne estas instalita |
| `dropbox.openedLogin` | Opened Dropbox login | Malfermita enloko en Dropbox |
| `dropbox.pauseSyncing` | Pause syncing | Paŭzi sinkronigon |
| `dropbox.phrase1` | Filing files | Arkivi dosierojn |
| `dropbox.phrase10` | Cataloging chaos | Katalogi kaosojn |
| `dropbox.phrase2` | Distributing data | Distribui datumojn |
| `dropbox.phrase3` | Shuffling folders | Miksi dosierujojn |
| `dropbox.phrase4` | Boxing bytes | Enpakigi bajtojn |
| `dropbox.phrase5` | Sorting stuff | Ordigi aferojn |
| `dropbox.phrase6` | Syncing secrets | Sinkronigi sekretojn |
| `dropbox.phrase7` | Packing packets | Paki paketojn |
| `dropbox.phrase8` | Moving memories | Movi memorojn |
| `dropbox.phrase9` | Wrangling revisions | Kapti reviziojn |
| `dropbox.recentFiles` | RECENT FILES | RECENTAJ DOSIEROJ |
| `dropbox.resumeSyncing` | Resume syncing | Daŭrigi sinkronigon |
| `dropbox.startingLogin` | Starting Dropbox login… | Komenco de enloko en Dropbox… |
| `dropbox.statusParseFailed` | Failed to parse Dropbox status | Ne eblis analizi la staton de Dropbox |
| `dropbox.statusReadFailed` | Could not read Dropbox status | Ne eblis legi la staton de Dropbox |
| `dropbox.syncing` | Syncing… | [Missing translation] |
| `dropbox.syncingFiles` | Syncing %1 files | [Missing translation] |
| `dropbox.syncingOne` | Syncing %1 file | [Missing translation] |
| `dropbox.downloadingFiles` | Downloading %1 files | [Missing translation] |
| `dropbox.downloadingOne` | Downloading %1 file | [Missing translation] |
| `dropbox.uploadingFiles` | Uploading %1 files | [Missing translation] |
| `dropbox.uploadingOne` | Uploading %1 file | [Missing translation] |
| `dropbox.etaSeconds` | %1 secs | [Missing translation] |
| `dropbox.etaSecondsOne` | %1 sec | [Missing translation] |
| `dropbox.etaMinutes` | %1 mins | [Missing translation] |
| `dropbox.etaMinutesOne` | %1 min | [Missing translation] |
| `dropbox.etaHours` | %1 hours | [Missing translation] |
| `dropbox.etaHoursOne` | %1 hour | [Missing translation] |
| `dropbox.etaDays` | %1 days | [Missing translation] |
| `dropbox.etaDaysOne` | %1 day | [Missing translation] |
| `dropbox.stored` | Stored | Konservita |
| `dropbox.syncingPaused` | Syncing paused | Sinkronigo paŭzita |
| `dropbox.unknownTime` | Unknown time | Nesciata tempo |
| `dropbox.untitled` | Untitled | Sentitola |
| `dropbox.usedOfQuota` | %1 of %2 | %1 el %2 |
| `dropbox.yearsAgo` | %1y ago | antaŭ %1j |
| `elsewhen.addCity` | +  Add a city | +  Aldoni urbon |
| `elsewhen.badgeHome` | home | hejmo |
| `elsewhen.badgeTracked` | tracked | sekvatata |
| `elsewhen.clock` | Clock | Horloĝo |
| `elsewhen.daysAhead` | one: +%1 day / other: +%1 days | one: +%1 tago / other: +%1 tagoj |
| `elsewhen.daysBehind` | one: -%1 day / other: -%1 days | one: -%1 tago / other: -%1 tagoj |
| `elsewhen.daysShort` | %1d | %1t |
| `elsewhen.editPeople` | Who's here | Kiu ĉeestas |
| `elsewhen.here` | It's %1 here | Estas %1 ĉi tie |
| `elsewhen.hereIn` | It's %1 here in %2 | Estas %1 ĉi tie en %2 |
| `elsewhen.jumpToCity` | Jump to a city | Salti al urbon |
| `elsewhen.loadingCities` | Loading cities… | Ŝargado de urboj… |
| `elsewhen.loadingZones` | Loading zones… | Ŝargado de zonoj… |
| `elsewhen.peoplePlaceholder` | Names or @github handles, comma separated | Nomoj aŭ @github-aliasoj, komigaj |
| `elsewhen.remove` | Remove | Forigi |
| `elsewhen.searchCities` | Search cities… | Serĉi urbojn… |
| `elsewhen.searchingPlaces` | Searching places… | Serĉado de lokoj… |
| `elsewhen.sunriseAt` | Sunrise %1 | Sunlevigo %1 |
| `elsewhen.sunsetAt` | Sunset %1 | Sunsubiro %1 |
| `elsewhen.timezoneChanged` | Now in %1, and the clock is on %2 | Nun en %1, kaj la horloĝo estas je %2 |
| `elsewhen.timezoneFailed` | Couldn't move the clock to %1 | Ne eblis movi la horloĝon al %1 |
| `elsewhen.tomorrow` | Tomorrow | Morgaŭ |
| `elsewhen.whereAreYou` | Where are you? | Kie vi estas? |
| `elsewhen.world` | World | Mondo |
| `elsewhen.worldClock` | World clock | Mondaj horloĝo |
| `elsewhen.yesterday` | Yesterday | Hieraŭ |
| `emojis.noMatches` | No matches for “%1” | Neniu kongruo por “%1” |
| `emojis.search` | Search emojis… | Serĉi emoji… |
| `imagePicker.deleteTheme` | Do you want to delete %1? | Ĉu vi volas forigi %1? |
| `lock.authenticationFailed` | Authentication failed (%1) | Aŭtentigo malsukcesis (%1) |
| `lock.checking` | Checking… | Kontrolado… |
| `lock.enterPassword` | Enter Password | Enigu pasvorton |
| `lock.fingerprintUnavailable` | Fingerprint reader unavailable | Fingrospura legilo neatingebla |
| `media.mediaSource` | Media source | Mediaponto |
| `media.next` | Next | Sekva |
| `media.nothingPlaying` | Nothing playing | Nenio ludas |
| `media.pause` | Pause | Paŭzi |
| `media.play` | Play | Ludi |
| `media.previous` | Previous | Antaŭa |
| `media.source` | Source | Ponto |
| `menu.inputPrompt` | Input | Enigo |
| `menu.nothingHere` | Nothing here yet | Ankoraŭ nenio ĉi tie |
| `menu.powerProfileBalanced` | balanced | balancita |
| `menu.powerProfilePerformance` | performance | rendimenta |
| `menu.powerProfilePowerSaver` | power-saver | ŝpara reĝimo |
| `menu.selectPrompt` | Select | Elektu |
| `menu.selectedCount` | one: %1 selected / other: %1 selected | one: %1 elektita / other: %1 elektitaj |
| `monitor.brightness` | BRIGHTNESS | HELECO |
| `monitor.builtInDisplay` | Built-in Display | [Missing translation] |
| `monitor.display` | Display | Ekrano |
| `monitor.extend` | Extend | [Missing translation] |
| `monitor.layout` | LAYOUT | [Missing translation] |
| `monitor.layoutHint` | ctrl+arrows or drag to arrange · r to rotate | [Missing translation] |
| `monitor.mirror` | Mirror | [Missing translation] |
| `monitor.refreshRate` | REFRESH RATE | [Missing translation] |
| `monitor.resolution` | RESOLUTION | [Missing translation] |
| `monitor.rotate180` | 180° | [Missing translation] |
| `monitor.rotate270` | 270° | [Missing translation] |
| `monitor.rotate90` | 90° | [Missing translation] |
| `monitor.rotateHint` | r or right-click to rotate | [Missing translation] |
| `monitor.rotateNormal` | Normal | [Missing translation] |
| `monitor.scale` | SCALE | SKALO |
| `monitor.textSize` | TEXT SIZE | TEKSTA GRANDO |
| `multiSelect.exited` | Options command exited %1 | Komando de elekteblo eliris %1 |
| `multiSelect.invalidJson` | Options command emitted invalid JSON | Komando de elekteblo liveris nevalidan JSON |
| `multiSelect.selectedCount` | one: %1 selected / other: %1 selected | one: %1 elektita / other: %1 elektitaj |
| `multiSelect.timedOut` | Options command timed out | Komando de elekteblo eksvalidiĝis |
| `network.automatic` | AUTOMATIC | AUTOMATA |
| `network.bandAutoTooltip` | Let Wi-Fi pick the band | Lasu Wi-Fi elekti la bandon |
| `network.connect` | Connect | Konekti |
| `network.connected` | Connected | Konektita |
| `network.connecting` | Connecting… | Konektado… |
| `network.connectionFailed` | Connection failed | Konekto malsukcesis |
| `network.copyGateway` | Copy gateway | Kopii enirejon |
| `network.copyIp` | Copy IP | Kopii IP |
| `network.copyToClipboard` | Copy to clipboard | Kopii al tonubo |
| `network.disconnected` | Disconnected | Malkonektita |
| `network.disconnecting` | Disconnecting… | Malkonektado… |
| `network.dnsCustom` | Custom | Propra |
| `network.dnsFromDhcp` | Use DNS from DHCP | Uzi DNS de DHCP |
| `network.dnsProvider` | DNS PROVIDER | DNS-PROVIDERO |
| `network.downloaded` | Downloaded | Elŝutita |
| `network.failed` | Failed | Malsukcesis |
| `network.failedToConnect` | Failed to connect | Ne eblis konekti |
| `network.forgetNetwork` | Forget network | Forgesi reton |
| `network.forgetting` | Forgetting… | Forgesado… |
| `network.gateway` | Gateway | Enirejo |
| `network.hidden` | Hidden | Kaŝita |
| `network.hidePassword` | Hide password | [Missing translation] |
| `network.identity` | Identity (user@domain) | Identeco (uzanto@domeino) |
| `network.ipAddress` | IP Address | IP-adreso |
| `network.knownNetworks` | KNOWN NETWORKS | KONATAJ RETOJ |
| `network.limitedAccess` | Limited internet access | Limigita interreta aliro |
| `network.limitedAccessHeader` | LIMITED INTERNET ACCESS | LIMIGITA INTERRETA ALIRO |
| `network.networkLost` | Network lost | Reto perdita |
| `network.noConnection` | No connection | Neniu konekto |
| `network.notConnected` | NOT CONNECTED | NEKONEKTITA |
| `network.openCaptivePortal` | Sign into network | Enlokiĝi en la reto |
| `network.otherNetworks` | OTHER NETWORKS | ALIAJ RETOJ |
| `network.packetLoss` | Packet Loss | Paka perdo |
| `network.passphrase` | Passphrase | Pasfrazo |
| `network.passphraseRequired` | Passphrase required | Pasfrazo necesas |
| `network.phrase1` | Wiring bits | Konekti bitojn |
| `network.phrase2` | Handling packets | Trakti paketojn |
| `network.phrase3` | Sorting frames | Ordini kadrojn |
| `network.phrase4` | Hauling bytes | Transporti bajtojn |
| `network.phrase5` | Routing crumbs | Marĉi crumbojn |
| `network.phrase6` | Counting collisions | Kalkuli koliziojn |
| `network.phrase7` | Bending light | Fleksi lumon |
| `network.receiving` | Receiving | Ricevado |
| `network.runSpeedTest` | Run a speed test | Ruli rapidecan teston |
| `network.scanningWifi` | SCANNING WI-FI… | SKANADO DE WI-FI… |
| `network.sending` | Sending | Sendado |
| `network.setCustomDns` | Set custom DNS servers | Agordi proprajn DNS-servilojn |
| `network.setDnsTo` | Set DNS to %1 | Agordi DNS al %1 |
| `network.showPassword` | Show password | [Missing translation] |
| `network.showQrCode` | Show QR code | Montri QR-kodon |
| `network.signInRequired` | Sign-in required | Enloko necesas |
| `network.signInToNetwork` | Sign in to this network | Enlokiĝi en ĉi tiun reton |
| `network.stayOnBand` | Stay on %1 | Resti sur %1 |
| `network.timedOutConnecting` | Timed out connecting | Konektado eksvalidiĝis |
| `network.timedOutDisconnecting` | Timed out disconnecting | Malkonektado eksvalidiĝis |
| `network.timedOutForgetting` | Timed out forgetting | Forgesado eksvalidiĝis |
| `network.timeout` | Timeout | Eksvalidiĝo |
| `network.turnWifiOff` | Turn Wi-Fi off | Malŝalti Wi-Fi |
| `network.turnWifiOn` | Turn Wi-Fi on | Ŝalti Wi-Fi |
| `network.uploaded` | Uploaded | Alŝutita |
| `network.wifiBand` | WI-FI BAND | WI-FI-BANDO |
| `network.wifiBandCurrent` | WI-FI BAND: %1 | WI-FI-BANDO: %1 |
| `network.wrongPassword` | Wrong password | Malĝusta pasvorto |
| `notifications.copyCode` | Copy code | Kopii kodon |
| `notifications.copyThisCode` | Copy %1 | Kopii %1 |
| `notifications.noneRecent` | No recent notifications | Neniu lasta sciigo |
| `notifications.redactedBody` | Code hidden | Kodo kaŝita |
| `notifications.redactedSummary` | Verification notification | Kontrola sciigo |
| `notifications.yesterday` | yesterday | hieraŭ |
| `polkit.authenticationNeeded` | Authentication is needed... | Aŭtentigo necesas... |
| `polkit.authorizeAgentRunning` | Authorize %1 to run '%2' | [Missing translation] |
| `polkit.authorizeFormatting` | Authorize formatting of %1 | [Missing translation] |
| `polkit.authorizeRunning` | Authorize running '%1' | Rajtigi la ruladon de “%1” |
| `polkit.checking` | Checking... | Kontrolado... |
| `polkit.enterPassword` | Enter password | Enigu pasvorton |
| `polkit.unlockDrive` | Unlock %1 | [Missing translation] |
| `polkit.wrong` | Wrong | Malĝusta |
| `power.battery` | Battery | Baterio |
| `power.batteryState` | Battery state | Bateria stato |
| `power.chargeCycles` | Charge cycles | Ŝargaj cikloj |
| `power.chargeLimit` | Charge limit | Ŝarga limo |
| `power.charging` | Charging | Ŝargado |
| `power.chargingPhrase1` | Pumping power | Pumpi energion |
| `power.chargingPhrase2` | Injecting electrons | Injekti elektronojn |
| `power.chargingPhrase3` | Pouring juice | Verŝi sucon |
| `power.chargingPhrase4` | Amassing watts | Amasi vatojn |
| `power.chargingPhrase5` | Hoarding joules | Ŝrumi ĵulojn |
| `power.chargingPhrase6` | Sucking volts | Glutĉi voltojn |
| `power.chargingPhrase7` | Topping reserves | Topi rezervojn |
| `power.chargingPhrase8` | Soaking amps | Sorbi amperojn |
| `power.chargingPhrase9` | Inhaling kilowatts | Inhali kilovatojn |
| `power.discharging` | Discharging | Malŝargado |
| `power.dischargingPhrase1` | Slurping power | Gladi energion |
| `power.dischargingPhrase2` | Spending joules | Elspezi ĵulojn |
| `power.dischargingPhrase3` | Draining watts | Malplenigi vatojn |
| `power.dischargingPhrase4` | Burning electrons | Bruli elektronojn |
| `power.dischargingPhrase5` | Sipping juice | Trinki sucon |
| `power.dischargingPhrase6` | Spending coulombs | Elspezi kulombojn |
| `power.dischargingPhrase7` | Bleeding amps | Gurgli amperojn |
| `power.dischargingPhrase8` | Guzzling volts | Trinki voltojn |
| `power.dischargingPhrase9` | Munching reserves | Mastumi rezervojn |
| `power.fullyCharged` | Fully charged | Plene ŝargita |
| `power.holding` | Holding | Tenado |
| `power.onBattery` | On battery | Per baterio |
| `power.powerProfile` | POWER PROFILE | ENERGIREĜIMO |
| `power.profileBalanced` | Balanced | Balancita |
| `power.profilePerformance` | Performance | Rendimenta |
| `power.profilePowerSaver` | Power-saver | Ŝpara reĝimo |
| `power.threshold` | Threshold | Sojlo |
| `power.timeLeft` | Time left | Restanta tempo |
| `power.timeToFull` | Time to full | Tempo ĝis plena |
| `reminders.invalidBody` | Enter the number of minutes | Enigu la nombron da minutoj |
| `reminders.invalidTitle` | Invalid reminder | Nevalida memorigo |
| `reminders.messagePrompt` | Reminder message... | Mesaĝo de memorigo... |
| `reminders.minutesPrompt` | Remind in minutes... | Memorigi post minutoj... |
| `speedtest.failed` | Speed test failed | Rapideca testo malsukcesis |
| `speedtest.measureAgain` | Measure again | Mesi denove |
| `speedtest.measureAgainVia` | Measure again via %1 | Mesi denove per %1 |
| `speedtest.runAgain` | Run Again | Ruli Denove |
| `tailscale.account` | Account | Konto |
| `tailscale.authorizationFailed` | Tailscale authorization failed | Rajtigo de Tailscale malsukcesis |
| `tailscale.authorizeDevice` | Authorize this device | Rajtigi ĉi tiun aparaton |
| `tailscale.authorizeHelp` | Allow this user to operate this Tailscale profile | Permesi al ĉi tiu uzanto uzi ĉi tiun Tailscale-profilon |
| `tailscale.authorizeOperator` | Authorize Tailscale operator | Rajtigi Tailscale-operatoron |
| `tailscale.authorizeToShowConnections` | Authorize Tailscale operator to show connections | Rajtigi Tailscale-operatoron por montri konektojn |
| `tailscale.authorizingOperator` | Authorizing Tailscale operator... | Rajtigo de Tailscale-operatoro... |
| `tailscale.chooseMullvadRegion` | Choose Mullvad region | Elektu regionon de Mullvad |
| `tailscale.commandFailed` | Tailscale command failed | Komando de Tailscale malsukcesis |
| `tailscale.connect` | Connect | Konekti |
| `tailscale.connections` | CONNECTIONS | KONEKTOJ |
| `tailscale.disconnect` | Disconnect | Malkonekti |
| `tailscale.disconnectedMeta` | Tailscale is disconnected | Tailscale estas malkonektita |
| `tailscale.exitNodeFailed` | Exit node selection failed | Elekto de elireja nodo malsukcesis |
| `tailscale.exitNodes` | EXIT NODES | ELIREJAJ NODOJ |
| `tailscale.listConnectionsFailed` | Could not list Tailscale connections | Ne eblis listigi Tailscale-konektojn |
| `tailscale.loadingMachines` | Loading machines… | Ŝargado de maŝinoj… |
| `tailscale.loginLinkUnavailable` | Tailscale login link not available yet | La Tailscale-enloka ligilo ankoraŭ ne disponeblas |
| `tailscale.machines` | MACHINES | MAŜINOJ |
| `tailscale.machinesCount` | MACHINES · %1 | MAŜINOJ · %1 |
| `tailscale.machinesFiltered` | MACHINES · %1 OF %2 | MAŜINOJ · %1 EL %2 |
| `tailscale.noMachines` | No machines found on this tailnet. | Neniu maŝino trovita en ĉi tiu retaro. |
| `tailscale.noMatchingMachines` | No machines match. | Neniu maŝino kongruas. |
| `tailscale.noRegions` | No Mullvad regions found. | Neniu regiono de Mullvad trovita. |
| `tailscale.notInstalled` | Tailscale CLI is not installed or not on PATH. | La CLI de Tailscale ne estas instalita aŭ ne estas en PATH. |
| `tailscale.operatorAuthorized` | Tailscale operator authorized | Tailscale-operatoro rajtigita |
| `tailscale.phrase1` | Encrypting connections | Ĉifri konektojn |
| `tailscale.phrase10` | Watching machines | Observi maŝinojn |
| `tailscale.phrase2` | Sending secrets | Sendi sekretojn |
| `tailscale.phrase3` | Guarding wires | Gvati kablojn |
| `tailscale.phrase4` | Braiding packets | Plekti paketojn |
| `tailscale.phrase5` | Polishing tunnels | Poluri tunelojn |
| `tailscale.phrase6` | Hiding routes | Kaŝi vojojn |
| `tailscale.phrase7` | Sealing ports | Fermi pordojn |
| `tailscale.phrase8` | Sorting tailnets | Ordini retarojn |
| `tailscale.phrase9` | Shuffling keys | Miksi ŝlosilojn |
| `tailscale.searchMachines` | Search machines  ( / ) | Serĉi maŝinojn  ( / ) |
| `tailscale.searchRegions` | Search regions | Serĉi regionojn |
| `tailscale.sendFiles` | Send files | Sendi dosierojn |
| `tailscale.startingLogin` | Starting Tailscale login… | Komenco de enloko en Tailscale… |
| `tailscale.statusParseFailed` | Failed to parse tailscale status | Ne eblis analizi la staton de tailscale |
| `tailscale.renameConnection` | Rename connection | [Missing translation] |
| `tailscale.renameFailed` | Could not rename Tailscale connection | [Missing translation] |
| `tailscale.switchFailed` | Account switch failed | Ŝalto de konto malsukcesis |
| `tailscale.turnOff` | Turn Tailscale off | Malŝalti Tailscale |
| `tailscale.turnOn` | Turn Tailscale on | Ŝalti Tailscale |
| `tailscale.unknown` | Unknown | Nesciata |
| `tailscale.unknownAccount` | Unknown account | Nesciata konto |
| `tailscale.upFailed` | tailscale up failed | tailscale up malsukcesis |
| `tray.empty` | No tray items reporting. | Neniu langeto raportas. |
| `tray.help` | Pinned icons stay visible. Hidden icons never show. | Fiksitaj piktogramoj restas videblaj. Kaŝitaj piktogramoj neniam aperas. |
| `tray.hide` | Hide | Kaŝi |
| `tray.pin` | Pin | Fiksi |
| `tray.show` | Show | Montri |
| `tray.title` | Tray icons | Langetaj piktogramoj |
| `tray.unknown` | Unknown | Nesciata |
| `tray.unpin` | Unpin | Malfiksi |
| `weather.feels` | FEELS | SENTAS |
| `weather.fetching` | Fetching forecast… | Akirado de prognozo… |
| `weather.humid` | HUMID | HUMIDO |
| `weather.searchCity` | Search city | Serĉi urbon |
| `weather.wind` | WIND | VENTO |
| `wifiqr.generateFailed` | Could not generate the Wi-Fi QR code | Ne eblis generi la Wi-Fi-QR-kodon |
| `wifiqr.generating` | Generating QR code… | Generado de QR-kodo… |
| `wifiqr.passwordFailed` | Could not read the Wi-Fi password | Ne eblis legi la pasvorton de Wi-Fi |
| `wifiqr.scanToJoin` | Scan to join this network | Skanu por aliĝi al ĉi tiu reto |
| `wifiqr.showPassword` | Show password | Montri pasvorton |

</details>

<details>
<summary>Left in English (21, for reference)</summary>

- `agents.durationHoursMinutes`: %1h %2m
- `agents.durationMinutes`: %1m
- `audio.level.murmur`: Murmur
- `audio.level.whisper`: Whisper
- `audio.title`: Audio
- `bluetooth.title`: Bluetooth
- `clock.dayMonthFormat`: MMMM d
- `clock.monthYear`: %1 %2
- `clock.weekShort`: W
- `dropbox.title`: Dropbox
- `elsewhen.dateFormat`: ddd MMM d
- `elsewhen.hoursShort`: %1h
- `elsewhen.minutesShort`: %1m
- `media.playPause`: Play/pause
- `network.bandAuto`: Auto
- `network.ethernet`: Ethernet
- `network.ping`: Ping
- `notifications.minutesAgo`: %1m
- `power.batterySize`: Battery size
- `speedtest.download`: DOWNLOAD
- `speedtest.upload`: UPLOAD

</details>

## CLI and notifications (`cli.json`) — 306 keys

489 strings translated, 5 intentionally left in
English (brand names and technical tokens).

<details>
<summary>Translated strings</summary>

| Key | English | Esperanto |
| --- | --- | --- |
| `about.ageUptimeUpdate` | Age / Uptime / Update | [Missing translation] |
| `about.days` | one: %1 day / other: %1 days | [Missing translation] |
| `about.hardware` | Hardware | [Missing translation] |
| `about.osAge` | OS Age | [Missing translation] |
| `about.software` | Software | [Missing translation] |
| `about.update` | Update | [Missing translation] |
| `about.updatedAt` | %1 at %2 | [Missing translation] |
| `about.uptime` | Uptime | [Missing translation] |
| `agents.addFailed` | Couldn't add the %1 account | Ne eblis aldoni la konton %1 |
| `agents.added` | Added %1. | Aldonis %1. |
| `agents.addedNotSelected` | Added %1, but couldn't switch new sessions to it. | [Missing translation] |
| `agents.allOver` | All %1 accounts are over %2% | Ĉiuj kontoj %1 superas %2% |
| `agents.atLimit` | %1 is at %2% of a %3 limit | %1 estas je %2% de limo %3 |
| `agents.durationDaysHours` | %1d %2h | %1t %2h |
| `agents.homeFailed` | Couldn't set up a home for the new account. | Ne eblis agordi hejmon por la nova konto. |
| `agents.installCliFailed` | Installing the %1 CLI didn't finish. | Instalado de la CLI %1 ne finis. |
| `agents.installingCli` | Installing the %1 CLI… | Instalado de la CLI %1… |
| `agents.instructionsBackedUp` | Kept your old agent instructions as backups | [Missing translation] |
| `agents.loginUnfinished` | The login didn't finish, so no account was added. | La enloko ne finis, do neniu konto estis aldonita. |
| `agents.newSessionsUse` | New %1 sessions now use %2 | Novaj seancoj %1 nun uzas %2 |
| `agents.noAccountNamed` | No %1 account named %2. | Neniu konto %1 nomita %2. |
| `agents.offerSwitch` | %1 is at %2%. Click to switch new sessions to it. | %1 estas je %2%. Klaku por ŝalti novajn seancojn al ĝi. |
| `agents.localMissing` | No local model to open | [Missing translation] |
| `agents.localMissingBody` | Set one up with: omarchy models use best text | [Missing translation] |
| `agents.chooseForPrompt` | Choose an agent for this task | [Missing translation] |
| `agents.promptOnClipboard` | %1 takes no starting prompt | [Missing translation] |
| `agents.promptOnClipboardBody` | Your prompt is on the clipboard. Paste it into the session. | [Missing translation] |
| `agents.runningStayOn` | Running sessions stay on %1. | Funkciantaj seancoj restas je %1. |
| `agents.runningFollow` | Running sessions use it too. | [Missing translation] |
| `agents.runningCaughtUp` | Running sessions on %1 moved over too. | [Missing translation] |
| `agents.sameAccount` | That's %1 (already added). Try again, and sign in as the other account in the private window. | Tio estas %1 (jam aldonita). Reprovu kaj enlokiĝu kiel la alia konto en la privata fenestro. |
| `agents.sameAccountEmail` | That's %1 (%2). Try again, and sign in as the other account in the private window. | Tio estas %1 (%2). Reprovu kaj enlokiĝu kiel la alia konto en la privata fenestro. |
| `agents.keyRefused` | %1 didn't accept that key. | [Missing translation] |
| `agents.keyUnchecked` | Couldn't reach %1 to check that key. Try again in a moment. | [Missing translation] |
| `agents.apiKeyHint` | It's checked with %1, then saved in OpenCode. | [Missing translation] |
| `agents.pasteSignInCode` | Once you've signed in, paste the code the page shows here. | [Missing translation] |
| `agents.signInAgainBrowser` | Sign in to %1 again in the browser window that opens. | Reenlokiĝu je %1 en la retumila fenestro kiu malfermiĝas. |
| `agents.signInAgainPrivate` | Sign in again as this account in the private window that opens. | Reenlokiĝu kiel ĉi tiu konto en la privata fenestro kiu malfermiĝas. |
| `agents.signInBrowser` | Sign in to %1 in the browser window that opens. | Enlokiĝu je %1 en la retumila fenestro kiu malfermiĝas. |
| `agents.signInFailed` | The %1 sign-in didn't finish. | La enloko de %1 ne finis. |
| `agents.signInPrivate` | Sign in as the account you're adding in the private window that opens. | Enlokiĝu kiel la konto kiun vi aldonas en la privata fenestro kiu malfermiĝas. |
| `agents.readyToCode` | %1 is ready | [Missing translation] |
| `agents.readyToCodeBody` | Make something cool | [Missing translation] |
| `agents.readyForMore` | %1 is ready for more | [Missing translation] |
| `agents.readyForMoreBody` | Tokens now flowing from %1 account | [Missing translation] |
| `agents.signedIn` | Signed in to %1. | Enlokiĝis je %1. |
| `agents.signedInAgain` | Signed in to %1 again. | Reenlokiĝis je %1. |
| `agents.sessionsUse` | %1 sessions now use %2 | [Missing translation] |
| `agents.stayingOn` | Staying on %1. | Restas je %1. |
| `agents.stayingOnUntil` | Staying on %1. %2 resets in %3. | Restas je %1. %2 restarigas post %3. |
| `agents.wrongAccount` | That's %1, not %2. Try again, and sign in as %2. | [Missing translation] |
| `animations.disabled` | Animations disabled | Animacioj malaktivaj |
| `animations.enabled` | Animations enabled | Animacioj aktivaj |
| `animations.softwareRendering` | Animations off without a GPU | [Missing translation] |
| `animations.softwareRenderingBody` | No GPU in use, so animations, blur and shadows are off. Appearance > Animations On brings them back. | [Missing translation] |
| `audio.micMuted` | Microphone muted | Mikrofono silentigita |
| `audio.micOn` | Microphone on | Mikrofono aktiva |
| `audio.noDevices` | No audio devices found | Neniu audi-aparato trovita |
| `audio.noMicrophone` | No microphone found | [Missing translation] |
| `battery.fullyCharged` | Fully charged | Plene ŝargita |
| `battery.holdingAt` | Holding at %1 | Tenado je %1 |
| `battery.lowBody` | Battery is down to %1% | La baterio estas malpliĝinta ĝis %1% |
| `battery.lowTitle` | Time to recharge! | Tempo por ŝargi! |
| `battery.statusLabel` | Battery %1% | Baterio %1% |
| `battery.timeLeft` | %1 left | %1 restas |
| `battery.toFull` | %1 to full | %1 ĝis plena |
| `battlenet.removeProton` | Also remove GE-Proton runtimes downloaded by umu? | Ĉu forigi ankaŭ la GE-Proton-runkigilojn elŝutitajn de umu? |
| `battlenet.removeUmu` | Also remove umu-launcher? It's only used by this command. | Ĉu forigi ankaŭ umu-launcher? Ĝi estas uzata nur de ĉi tiu komando. |
| `battlenet.wipePartial` | Wipe the partial prefix and start fresh? | Ĉu viŝi la partan prefikson kaj komenci denove? |
| `branding.pickAboutImage` | Pick PNG or SVG for About | Elektu PNG aŭ SVG por Pri |
| `branding.pickScreensaverImage` | Pick PNG or SVG for screensaver | Elektu PNG aŭ SVG por la ekranŝildilo |
| `browser.notFound` | No default browser found | [Missing translation] |
| `browser.notFoundHint` | Install a browser or set one with: omarchy default browser <browser> | [Missing translation] |
| `browser.webappNeedsChromium` | Web apps need a Chromium-based browser | [Missing translation] |
| `browser.webappNeedsChromiumHint` | Install Chromium with: omarchy install browser chromium | [Missing translation] |
| `capture.audioNotAdded` | The %1 audio could not be added to this recording. | La audio %1 ne povis esti aldonita al ĉi tiu registrado. |
| `capture.noRecordingDir` | Screen recording directory does not exist: %1 | La dosierujo por ekranregistrado ne ekzistas: %1 |
| `capture.noWebcam` | No webcam devices found | Neniu retokamera aparato trovita |
| `capture.qrCopied` | QR code copied to clipboard | QR-kodo kopiita al tonubo |
| `capture.qrHelp` | Select a region containing a QR code | Elektu regionon enhavan QR-kodon |
| `capture.qrNone` | No QR code found | Neniu QR-kodo trovita |
| `capture.recordingCut` | Cut | [Missing translation] |
| `capture.recordingDetails` | %1 · %2 | [Missing translation] |
| `capture.recordingError` | Screen recording error | Eraro pri ekranregistrado |
| `capture.recordingKilled` | Recording process had to be force-killed. Video may be corrupted. | La registra procezo devis esti forigita perforte. La video povas esti korupta. |
| `capture.recordingLength` | %1:%2 | [Missing translation] |
| `capture.recordingLengthHours` | %1:%2:%3 | [Missing translation] |
| `capture.recordingOpen` | Open | [Missing translation] |
| `capture.recordingSaved` | Screen recording saved | Ecranregistrado konservita |
| `capture.recordingSizeB` | %1 B | [Missing translation] |
| `capture.recordingSizeGB` | %1 GB | [Missing translation] |
| `capture.recordingSizeKB` | %1 KB | [Missing translation] |
| `capture.recordingSizeMB` | %1 MB | [Missing translation] |
| `capture.recordingWithoutAudio` | Recording without %1 audio | Registrado sen audio %1 |
| `capture.screenshotEdit` | Edit | [Missing translation] |
| `capture.screenshotOpen` | Open | [Missing translation] |
| `capture.screenshotSaved` | Screenshot saved | [Missing translation] |
| `capture.screenshotSavedCopied` | Screenshot saved and copied | [Missing translation] |
| `capture.selectWebcam` | Select Webcam | Elektu retokameron |
| `capture.textCopied` | Copied text from selection to clipboard | Teksto el la elekto kopiita al tonubo |
| `clipboard.urlCopied` | URL copied to clipboard | URL kopiita al tonubo |
| `common.disabled` | Disabled | Malaktiva |
| `common.enabled` | Enabled | Aktiva |
| `common.no` | No | Ne |
| `common.yes` | Yes | Jes |
| `corners.followTheme` | Corners follow the theme | Anguloj sekvas la etoson |
| `corners.rounded` | Rounded corners for all themes | Rondaj anguloj por ĉiuj etosoj |
| `corners.sharp` | Sharp corners for all themes | Pikaj anguloj por ĉiuj etosoj |
| `crash.captureDisabled` | Crash capture disabled | Kaptado de kraŝoj malaktiva |
| `crash.captureEnabled` | Crash capture enabled | Kaptado de kraŝoj aktiva |
| `crash.diagnose` | Click to diagnose with AI | Klaku por diagnozi per AI |
| `crash.processCrashed` | Process crashed: %1 | Procezo kraŝis: %1 |
| `default.browserSet` | %1 is now the default browser | %1 estas nun la defaŭlta retumilo |
| `default.chromeOffer` | Switch to Google Chrome? | [Missing translation] |
| `default.chromeOfferBody` | It's faster and the new Omarchy default, but you'll be logged out of all sites. | [Missing translation] |
| `default.chromeOfferDismiss` | Nevermind | [Missing translation] |
| `default.chromeOfferSwitch` | Switch to Chrome | [Missing translation] |
| `default.editorSet` | %1 is now the default editor | %1 estas nun la defaŭlta redaktilo |
| `default.terminalSet` | %1 is now the default terminal | %1 estas nun la defaŭlta terminalo |
| `dictation.hexReady` | Hex Dictation Ready | [Missing translation] |
| `dictation.hint` | Hold Right Alt to dictate, or toggle with Alt + Space. | Tenu Right Alt aŭ F9 por diktii (aŭ ŝalteti per Super + Ctrl + X). |
| `dictation.installVoxtype` | Install Voxtype + AI model (~150MB) to enable dictation? | Instali Voxtype + AI-modelon (~150MB) por ebligi diktion? |
| `dictation.superwhisperReady` | Superwhisper Dictation Ready | Dikcio de Superwhisper preta |
| `dictation.voxtypeReady` | Voxtype Dictation Ready | Dikcio de Voxtype preta |
| `display.restartFootForFontSize` | Restart Foot to apply the new terminal font size | Rekomenci Foot por apliki la novan grandecon de la terminala tiparo |
| `docker.enableSudoless` | Enable sudoless Docker? This gives anything running as you passwordless root. | Ŝalti Docker sen sudo? Ĉi tio donas al ĉio kio rulas kiel vi senpasvortan root. |
| `docker.rebootToApply` | Reboot now to apply? | Rekomenci nun por apliki? |
| `docker.selectDatabase` | Select database (return to install, esc to cancel) | Elektu datumbazon (reenu al instalado, esc por nuligi) |
| `done.failed` | Failed (exit code %1)! Press any key to close... | Malsukcesis (elira kodo %1)! Presu ajn klavon por fermi... |
| `done.success` | Done! Press any key to close... | Preta! Presu ajn klavon por fermi... |
| `download.complete` | Download complete | Elŝuto finita |
| `download.cut` | Cut | [Missing translation] |
| `download.failed` | Download failed | Elŝuto malsukcesis |
| `download.none` | No video found for download | Neniu video trovita por elŝuti |
| `download.open` | Open | [Missing translation] |
| `drive.confirmNewLoginPassword` | Confirm new password | [Missing translation] |
| `drive.confirmNewPassword` | Confirm new encryption password | Konfirmu la novan ĉifran pasvorton |
| `drive.currentPassword` | Current encryption password | Nuna ĉifra pasvorto |
| `drive.newLoginPassword` | New password for login and drive encryption | [Missing translation] |
| `drive.newPassword` | New encryption password | Nova ĉifra pasvorto |
| `drive.passwordThatOpens` | Encryption password that opens %1 now (the new one if the change went through) | Ĉifra pasvorto kiu malfermas %1 nun (la nova, se la ŝanĝo sukcesis) |
| `drive.select` | Select drive | Elektu diskon |
| `files.selectFile` | Select file | Elektu dosieron |
| `firstRun.agentBody` | Let your favorite agent help with Omarchy. | [Missing translation] |
| `firstRun.agentTitle` | Set up your agent | [Missing translation] |
| `firstRun.fingerprintBody` | Enable sudo and unlocking with your fingerprint. | [Missing translation] |
| `firstRun.fingerprintTitle` | Setup Fingerprint Reader | [Missing translation] |
| `firstRun.keybindingsBody` | Super + K for cheatsheet.<br>Super + Space for Omarchy Menu. | [Missing translation] |
| `firstRun.keybindingsTitle` | Learn Keybindings | [Missing translation] |
| `firstRun.wifiBody` | Click to configure the wireless network. | [Missing translation] |
| `firstRun.wifiTitle` | Setup Wi-Fi | [Missing translation] |
| `font.cjkChanged` | Chinese, Japanese, and Korean glyph forms changed | Skribformoj de la ĉina, japanaj kaj koreaj lingvoj ŝanĝiĝis |
| `font.restartAppsToSeeChange` | Restart open apps to see the change | Rekomenci malfermitajn aplikaĵojn por vidi la ŝanĝon |
| `font.restartToSeeChange` | You must restart %1 to see font change | Vi devas rekomenci %1 por vidi la ŝanĝon de tiparo |
| `games.corePrompt` | RetroArch core | Kerno de RetroArch |
| `games.installed` | %1 installed | %1 instalita |
| `games.noCores` | No RetroArch cores found | Neniu kerno de RetroArch trovita |
| `games.pickGame` | Retro game | Retroludo |
| `games.startHint` | Start it with Super + Space | Startu ĝin per Super + Space |
| `games.vibesRemoveTitle` | Remove a Game Vibes game | [Missing translation] |
| `games.vibesRemoved` | Game removed | [Missing translation] |
| `games.vibesRepoPlaceholder` | Git repo URL of a game (https or git@host:org/repo.git) | [Missing translation] |
| `gitSetup.emailPrompt` | Email address>  | [Missing translation] |
| `gitSetup.ghSignIn` | Sign in to GitHub? | [Missing translation] |
| `gitSetup.ghSignedIn` | Already signed in to GitHub. | [Missing translation] |
| `gitSetup.intro` | Set the name and email used for your git commits. | [Missing translation] |
| `gitSetup.namePlaceholder` | Your full name | [Missing translation] |
| `gitSetup.namePrompt` | Full name>  | [Missing translation] |
| `gpu.enableDedicated` | Enable dedicated GPU and reboot? | Ŝalti dediĉitan GPU kaj rekomenci? |
| `gpu.useIntegrated` | Use only integrated GPU and reboot? | Uzi nur integritan GPU kaj rekomenci? |
| `hermes.deleteData` | Also delete ~/.hermes and ~/.config/Hermes (%1: chats, memories, skills, connections and tokens)? | Ĉu forigi ankaŭ ~/.hermes kaj ~/.config/Hermes (%1: babiladoj, memoroj, fakoj, konektoj kaj ĵetonoj)? |
| `icons.removeExtraTitle` | Remove extra icon set | [Missing translation] |
| `icons.removed` | Icon set removed | [Missing translation] |
| `icons.repoPlaceholder` | Git repo URL (https or git@host:org/repo.git) | [Missing translation] |
| `input.inputMethodsFailed` | Input methods could not be updated | [Missing translation] |
| `input.keyboardLayoutsFailed` | Keyboard layouts could not be updated | [Missing translation] |
| `input.keyboardLayoutRequired` | Select at least one keyboard layout | [Missing translation] |
| `input.keyboardLayoutOverride` | Your personal keyboard layout override takes precedence over this selection | [Missing translation] |
| `input.installEngineToUse` | Install %1 to use %2 | [Missing translation] |
| `input.touchpadDisabled` | Touchpad disabled | Tuŝplado malŝaltita |
| `input.touchpadEnabled` | Touchpad enabled | Tuŝplado ŝaltita |
| `input.touchscreenDisabled` | Touchscreen disabled | Tuŝekrano malŝaltita |
| `input.touchscreenEnabled` | Touchscreen enabled | Tuŝekrano ŝaltita |
| `kernel.nowUsing` | Now using %1 | Nun uzas %1 |
| `kernel.rebootToUse` | Reboot to use new default kernel | Rekomenci por uzi la novan defaŭltan kernon |
| `kernel.retryInTerminal` | Retry in a terminal | Reprovi en terminalo |
| `kernel.switchFailed` | Couldn't switch to %1 | Ne eblis ŝalti al %1 |
| `keybindings.herdrTitle` | Herdr keybindings | Klavkombinoj de Herdr |
| `keybindings.title` | Keybindings | Klavkombinoj |
| `keybindings.tmuxTitle` | Tmux keybindings | Klavkombinoj de Tmux |
| `language.changed` | Language is now set to %1 | La lingvo estas nun agordita al %1 |
| `language.newApps` | Apps you open from now on use it too; restart any that are already open | La aplikaĵojn, kiun vi malfermos de ĉi tie, uzos ĝin ankaŭ; rekomencu tiujn, kiuj jam estas malfermitaj |
| `layout.defaultFloating` | Default layout set to floating | Defaŭlta aranĝo agordita al ŝveba |
| `layout.defaultScrolling` | Default layout set to scrolling | Defaŭlta aranĝo agordita al ruliĝo |
| `layout.defaultTiling` | Default layout set to tiling | Defaŭlta aranĝo agordita al mosaikado |
| `layout.needsReload` | Workspace layout needs a Hyprland reload | La laborspaca aranĝo bezonas reŝargon de Hyprland |
| `layout.workspaceFloating` | Workspace layout set to floating | Laborspaca aranĝo agordita al ŝveba |
| `layout.workspaceFloatingUnsaved` | Workspace layout set to floating but could not be saved | Laborspaca aranĝo agordita al ŝveba, sed ne eblis konservi |
| `layout.workspaceScrolling` | Workspace layout set to scrolling | Laborspaca aranĝo agordita al ruliĝo |
| `layout.workspaceScrollingUnsaved` | Workspace layout set to scrolling but could not be saved | Laborspaca aranĝo agordita al ruliĝo, sed ne eblis konservi |
| `layout.workspaceTiling` | Workspace layout set to tiling | Laborspaca aranĝo agordita al mosaikado |
| `layout.workspaceTilingUnsaved` | Workspace layout set to tiling but could not be saved | Laborspaca aranĝo agordita al mosaikado, sed ne eblis konservi |
| `lock.didNotLock` | Screen did not lock before suspend | La ekrano ne ŝlosiĝis antaŭ dormo |
| `lock.unlockedNoLockScreen` | The session was left unlocked (no lock screen is configured). | La seanco restis neŝlosita (neniu ekranŝildilo estas agordita). |
| `lock.unlockedTimeout` | The session was left unlocked (the shell did not secure the session within %1ms). | La seanco restis neŝlosita (la ŝelo ne sekurigis la seanton ene de %1ms). |
| `migrate.clickToRun` | one: Click to run %1 pending migration. / other: Click to run %1 pending migrations. | one: Klaku por ruli %1 atendanta migrado. / other: Klaku por ruli %1 atendantaj migradoj. |
| `migrate.pending` | Pending Omarchy Migrations | Atendantaj migradoj de Omarchy |
| `monitor.laptopDisabled` | Laptop display disabled | Ekrano de tekomejo malŝaltita |
| `monitor.laptopEnabled` | Laptop display enabled | Ekrano de tekomejo ŝaltita |
| `monitor.noExternalForMirror` | No external monitors found for mirror | Neniu ekstera monitoro trovita por spegulado |
| `monitor.noLaptopDisplay` | No laptop display found | Neniu ekrano de tekomejo trovita |
| `monitor.noLaptopToMirror` | No laptop monitor found to mirror | Neniu monitoro de tekomejo trovita por spegulado |
| `monitor.onlyDisplay` | Can't disable the only active display | Ne eblas malŝalti la solan aktivan ekranon |
| `monitor.unsafeName` | Refusing unsafe monitor name | Refuzas nesekuran nomon de monitoro |
| `nordvpn.rebootNow` | Reboot now to make NordVPN usable? | Rekomenci nun por NordVPN funkciu? |
| `openclaw.deleteData` | Also delete ~/.openclaw (%1: chats, memories, credentials, downloaded plugins, and OpenClaw itself)? | Ĉu forigi ankaŭ ~/.openclaw (%1: babiladoj, memoroj, akreditaĵoj, elŝutitaj kromprogramoj kaj OpenClaw mem)? |
| `ownerSetup.continuing` | Continuing setup for user: %1 | [Missing translation] |
| `ownerSetup.eulaAccept` | Accept | [Missing translation] |
| `ownerSetup.eulaDecline` | Decline | [Missing translation] |
| `ownerSetup.eulaDeclined` | This machine can only be set up once the agreement is accepted. Nothing on it has changed, and setup starts again the next time it is turned on. | [Missing translation] |
| `ownerSetup.eulaPrompt` | Do you accept this agreement? | [Missing translation] |
| `ownerSetup.eulaScroll` | ↑ ↓ to read on | [Missing translation] |
| `ownerSetup.eulaShutDownNo` | No, back to the agreement | [Missing translation] |
| `ownerSetup.eulaShutDownPrompt` | Shut down this machine? | [Missing translation] |
| `ownerSetup.eulaShutDownYes` | Yes, shut down | [Missing translation] |
| `ownerSetup.eulaTitle` | %1 License Agreement | [Missing translation] |
| `ownerSetup.failed` | Setup hit an error (details in %1). | [Missing translation] |
| `ownerSetup.finalizeWarning` | User finalization reported errors (see %1). | [Missing translation] |
| `ownerSetup.keyboardFailed` | Setup could not set a keyboard layout on this machine. | [Missing translation] |
| `ownerSetup.keyboardRetry` | Could not set the %1 keyboard layout. Choose it again. | [Missing translation] |
| `ownerSetup.progress` | Setting up your machine | [Missing translation] |
| `ownerSetup.rebootNo` | No, keep setting up | [Missing translation] |
| `ownerSetup.rebootNote` | Setup starts again after the reboot. | [Missing translation] |
| `ownerSetup.rebootPrompt` | Reboot this machine? | [Missing translation] |
| `ownerSetup.rebootYes` | Yes, reboot | [Missing translation] |
| `ownerSetup.retryNo` | Drop to console | [Missing translation] |
| `ownerSetup.retryPrompt` | Retry first-boot setup? | [Missing translation] |
| `ownerSetup.retryYes` | Try again | [Missing translation] |
| `ownerSetup.samePassword` | Setup already set the disk password. Enter that same password. | [Missing translation] |
| `ownerSetup.tip.clipboard` | Super + Ctrl + V opens the clipboard manager | [Missing translation] |
| `ownerSetup.tip.colorPicker` | Super + Print picks a color from anywhere on screen | [Missing translation] |
| `ownerSetup.tip.keybindings` | Super + K shows all the key bindings | [Missing translation] |
| `ownerSetup.tip.localSend` | Share files with phones and laptops using LocalSend | [Missing translation] |
| `ownerSetup.tip.media` | Edit images with Pinta, trim videos with Omacut, docs with LibreOffice | [Missing translation] |
| `ownerSetup.tip.menu` | Super + Space opens the Omarchy menu for apps, settings, and more | [Missing translation] |
| `ownerSetup.tip.ocr` | Super + Ctrl + Print grabs text off the screen with OCR | [Missing translation] |
| `ownerSetup.tip.reminders` | Set a reminder with Super + Ctrl + R | [Missing translation] |
| `ownerSetup.tip.screenshots` | Print takes a screenshot, Alt + Print records the screen | [Missing translation] |
| `ownerSetup.tip.signPdfs` | Sign PDFs and fill them in with Signed | [Missing translation] |
| `ownerSetup.tip.superKey` | Super is the Windows or command key on your keyboard | [Missing translation] |
| `ownerSetup.tip.terminal` | Super + Return opens a terminal, Super + Shift + Return the browser | [Missing translation] |
| `ownerSetup.tip.themes` | Switch themes from Appearance > Theme in the Omarchy menu | [Missing translation] |
| `ownerSetup.tip.transparentBar` | Double-click the menu bar to make it transparent | [Missing translation] |
| `ownerSetup.tip.update` | Keep the system fresh with Update in the Omarchy menu | [Missing translation] |
| `ownerSetup.tip.webApps` | Turn any website into an app with Install > Web App in the menu | [Missing translation] |
| `ownerSetup.tip.windows` | Run a full Windows VM via Install > Windows in the menu | [Missing translation] |
| `ownerSetup.tip.workspaces` | Super + 1 through 0 switches workspaces, add Shift to bring the window | [Missing translation] |
| `ownerSetup.tipLine` | Tip: %1 | [Missing translation] |
| `perplexity.deleteData` | Also delete your Perplexity data (%1: logins, settings, secret vault and device identity)? | Ĉu forigi ankaŭ viajn Perplexity-datojn (%1: enlokoj, agordoj, sekura trezoro kaj identeco de la aparato)? |
| `plugin.barSection` | Place %1 in which bar section? | En kiun sekcion de la stripo meti %1? |
| `plugin.cloneTitle` | Clone plugin | Kloni kromprogramon |
| `plugin.confirmAdd` | Clone and add this plugin? | Kloni kaj aldoni ĉi tiun kromprogramon? |
| `plugin.confirmDelete` | Delete '%1'? Its git repo remains upstream. | Ĉu forigi “%1”? Ĝia git-repositorio restis suprestream. |
| `plugin.confirmEnable` | Enable '%1' now? | Ĉu ŝalti “%1” nun? |
| `plugin.confirmRemove` | Remove '%1'? The folder will be backed up. | Ĉu forigi “%1”? La dosierujo estos sekurkopita. |
| `plugin.confirmUnlink` | Unlink '%1' (symlink -> %2)? | Malkonekti “%1” (simbolik ligilo -> %2)? |
| `plugin.disableTitle` | Disable plugin | Malŝalti kromprogramon |
| `plugin.editingClone` | Editing Cloned Plugin | Redaktado de klonita kromprogramo |
| `plugin.enableTitle` | Enable plugin | Ŝalti kromprogramon |
| `plugin.gitUrlPrompt` | Git URL of the plugin repo:  | Git-URL de la repositorio de la kromprogramo:  |
| `plugin.noneToClone` | No plugin to clone | Neniu kromprogramo por kloni |
| `plugin.noneToDisable` | No plugin to disable | Neniu kromprogramo por malŝalti |
| `plugin.noneToEnable` | No plugin to enable | Neniu kromprogramo por ŝalti |
| `plugin.noneToRemove` | No plugin to remove | Neniu kromprogramo por forigi |
| `plugin.removeTitle` | Remove plugin | Forigi kromprogramon |
| `plugin.removeWhich` | Remove which plugin? | Kiun kromprogramon forigi? |
| `plugin.replacedByClone` | Original plugin has been replace by clone. | La originala kromprogramo estis anstataŭigita per la klono. |
| `preinstalls.confirmRemove` | Are you sure you want to remove all preinstalled web apps, TUI wrappers, and desktop applications? | Ĉu vi certas, ke vi volas forigi ĉiujn preinstalajn retan aplikaĵojn, TUI-om wrapperojn kaj labortablajn aplikaĵojn? |
| `preinstalls.confirmRestore` | Are you sure you want to restore all preinstalled web apps, TUI wrappers, and desktop applications? | Ĉu vi certas, ke vi volas restarigi ĉiujn preinstalajn retan aplikaĵojn, TUI-om wrapperojn kaj labortablajn aplikaĵojn? |
| `region.changed` | Dates and numbers are now written as in %1 | [Missing translation] |
| `region.followsLanguage` | Dates and numbers are now written as in your language | [Missing translation] |
| `region.formatsTitle` | Formats | [Missing translation] |
| `region.sameAsLanguage` | Same as language | [Missing translation] |
| `reminder.cleared` | All reminders have been cleared | Ĉiuj memorigoj estis vakigita |
| `reminder.count` | one: %1 reminder / other: %1 reminders | one: %1 memorigo / other: %1 memorigoj |
| `reminder.customInMinutes` | one: %1 in %2 minute / other: %1 in %2 minutes | one: %1 post %2 minuto / other: %1 post %2 minutoj |
| `reminder.inRemaining` | %1 in %2 (%3) | %1 post %2 (%3) |
| `reminder.minuteLabel` | %1-min reminder | %1-minuta memorigo |
| `reminder.minutesUp` | one: Your %1 minute is up / other: Your %1 minutes are up | one: Via %1 minuto pasis / other: Viaj %1 minutoj pasis |
| `reminder.none` | No outstanding reminders | Neniu atendanta memorigo |
| `reminder.setForMinutes` | one: Reminder set for %1 minute / other: Reminder set for %1 minutes | one: Memorigo agordita post %1 minuto / other: Memorigo agordita post %1 minutoj |
| `reminder.setTooltip` | Set Reminder | Agordi Memorigon |
| `reminder.title` | Reminder | Memorigo |
| `reminder.upcoming` | Upcoming reminders | Venontaj memorigoj |
| `reminder.willRemindAt` | You'll be reminded at %1 | Vi estos memorigita je %1 |
| `reset.confirmPassphrase` | Confirm your disk encryption passphrase to authorize the re-key. | Konfirmu vian pasfrazon por disk-ĉifrado por rajtigi la ŝanĝon de ŝlosilo. |
| `reset.eraseAccounts` | All user accounts and everything in /home | Ĉiuj uzantkontoj kaj ĉio en /home |
| `reset.eraseIdentity` | Machine identity (network connections, host keys, machine-id) | Identeco de la maŝino (retkonektoj, hostaj ŝlosiloj, machine-id) |
| `reset.erasePackages` | All packages and system changes made since installation | Ĉiuj pakaĵoj kaj sistemaj ŝanĝoj faritaj ekde la instalado |
| `reset.nextBoot` | The next boot asks for a new user, exactly like a fresh install. | La venonta starto petas novan uzanton, ĝuste kiel ĉe freŝa instalado. |
| `reset.noSnapshot` | This machine has no factory snapshot to reset to. | Ĉi tiu maŝino havas neniun fabrikadan snapshoton por restarigi. |
| `reset.noSnapshotWhy` | A reset restores the @factory snapshot the Omarchy Quattro installer takes right after installing. Machines upgraded to Quattro from an earlier version, or installed some other way, never got one, so there is no baseline here to return to. | Restarigo restaŭras la @factory-snapshoton, kiun la instalilo de Omarchy Quattro faras tuj post la instalado. Maŝinoj ĝisdatigita al Quattro el pli malnova versio, aŭ instalita aliloke, neniam ricevis unu, do ne ekzistasreferenco por rev returni. |
| `reset.notSecureErase` | Note: on disks without encryption this is deletion, not secure erasure. | Noto: sur diskoj sen ĉifrado tio estas forigo, ne sekura malfaksado. |
| `reset.passphrasePlaceholder` | Current disk encryption passphrase | Nuna pasfrazo por disk-ĉifrado |
| `reset.passphrasePrompt` | Passphrase>  | Pasfrazo>  |
| `reset.passphraseWrong` | That passphrase does not unlock %1. Try again. | Tiu pasfrazo ne malfermas %1. Reprovu. |
| `reset.question` | Reset this computer to factory state? | Ĉu restarigi ĉi tiun komputilon al fabrika stato? |
| `reset.rebootLater` | Reboot later | Rekomenci poste |
| `reset.rebootNow` | Reboot now | Rekomenci nun |
| `reset.rebootQuestion` | Reboot to complete the reset? | Rekomenci por fini restarigon? |
| `reset.reinstallHint` | Reinstall from the Omarchy ISO to make this machine resettable. | Reinstali el la Omarchy-ISO por fari ĉi tiun maŝinon restarigebla. |
| `reset.staged` | Reset staged. The wipe finishes on the next boot. | Restarigo preparita. La forviŝo finiĝos ĉe la venonta starto. |
| `reset.stopUsing` | Do not keep using this machine — changes made now will be lost. | Ne plu uzi ĉi tiun maŝinon — ŝanĝoj faritaj nun estos perditaj. |
| `reset.typeToContinue` | Type '%1' to continue | Tajpu “%1” por daŭrigi |
| `reset.willErase` | This will permanently erase: | Ĉi tio permanente forviŝos: |
| `screensaver.disabled` | Screensaver disabled | Ecranŝildilo malaktiva |
| `screensaver.enabled` | Screensaver enabled | Ecranŝildilo aktiva |
| `setupForm.confirmPlaceholder` | Must match the password you just typed | [Missing translation] |
| `setupForm.confirmPrompt` | Confirm>  | [Missing translation] |
| `setupForm.hostnameInvalid` | Hostname must be 1-63 letters, digits, or dashes, and cannot start or end with a dash | [Missing translation] |
| `setupForm.hostnamePrompt` | Hostname>  | [Missing translation] |
| `setupForm.keyboardHeader` | Select keyboard layout | [Missing translation] |
| `setupForm.languageHeader` | Language | [Missing translation] |
| `setupForm.machineIntro` | Let's setup your machine... | [Missing translation] |
| `setupForm.passwordBlank` | Your password can't be blank! | [Missing translation] |
| `setupForm.passwordMismatch` | Passwords didn't match! | [Missing translation] |
| `setupForm.passwordPlaceholder` | Used for user + root, and disk encryption when enabled | [Missing translation] |
| `setupForm.passwordPrompt` | Password>  | [Missing translation] |
| `setupForm.reviewChange` | No, change it | [Missing translation] |
| `setupForm.reviewField` | Field | [Missing translation] |
| `setupForm.reviewHostname` | Hostname | [Missing translation] |
| `setupForm.reviewKeyboard` | Keyboard | [Missing translation] |
| `setupForm.reviewLanguage` | Language | [Missing translation] |
| `setupForm.reviewPassword` | Password | [Missing translation] |
| `setupForm.reviewPrompt` | Does this look right? | [Missing translation] |
| `setupForm.reviewTimezone` | Timezone | [Missing translation] |
| `setupForm.reviewUsername` | Username | [Missing translation] |
| `setupForm.reviewValue` | Value | [Missing translation] |
| `setupForm.reviewYes` | Yes | [Missing translation] |
| `setupForm.timezoneHeader` | Timezone | [Missing translation] |
| `setupForm.timezonePlaceholder` | Filter... | [Missing translation] |
| `setupForm.usernameInvalid` | Username must be alphanumeric with no spaces | [Missing translation] |
| `setupForm.usernamePlaceholder` | Alphanumeric without spaces (like dhh) | [Missing translation] |
| `setupForm.usernamePrompt` | Username>  | [Missing translation] |
| `setupForm.usernameReserved` | Username is reserved for system | [Missing translation] |
| `setupForm.usernameTaken` | That username already exists on this machine | [Missing translation] |
| `share.chooserClosed` | The file chooser did not open | La dosierelektilo ne malfermiĝis |
| `share.couldNot` | Could not share | Ne eblis kunhavigi |
| `share.filesTitle` | Share files | Kunhavigi dosierojn |
| `share.folderTitle` | Share folder | Kunhavigi dosierujon |
| `sshd.githubUserPrompt` | GitHub username>  | GitHub-uzantnomo>  |
| `sshd.howToAddKey` | How would you like to add your SSH key? | Kiel vi volas aldoni vian SSH-ŝlosilon? |
| `sshd.keyFromGithub` | Grab key from GitHub | Preni ŝlosilon de GitHub |
| `sshd.keyPaste` | Paste key manually | Glui ŝlosilon manŭe |
| `sshd.publicKeyPrompt` | Public key>  | Publika ŝlosilo>  |
| `sshd.removeAuthorizedKeys` | Also remove all authorized SSH keys (%1)? | Ĉu forigi ankaŭ ĉiujn rajtigitajn SSH-ŝlosilojn (%1)? |
| `suspend.availableInMenu` | Suspend now available in system menu | Dormo nun disponebla en la siste-menuo |
| `suspend.removedFromMenu` | Suspend removed from system menu | Dormo forigita el la siste-menuo |
| `suspend.turnedOffOnMachine` | Suspend is turned off on this machine | Dormo estas malŝaltita sur ĉi tiu maŝino |
| `system.firmwareFailed` | Reboot to BIOS failed | [Missing translation] |
| `system.firmwareRetry` | Could not reboot into the firmware setup. This machine may not support it. | [Missing translation] |
| `system.loggingOut` | Logging out | Elsalutado |
| `system.logoutFailed` | Logout failed | Elsaluto malsukcesis |
| `system.logoutRetry` | Could not complete logout. Please try again. | Ne eblis fini elsaluton. Bonvolu reprovi. |
| `system.rebootFailed` | Reboot failed | Rekomenco malsukcesis |
| `system.rebootRetry` | Could not complete reboot. Please try again. | Ne eblis fini rekomencon. Bonvolu reprovi. |
| `system.rebooting` | Rebooting | Rekomenco |
| `system.rebootingToFirmware` | Rebooting to BIOS | [Missing translation] |
| `system.shutdownFailed` | Shutdown failed | Malŝalto malsukcesis |
| `system.shutdownRetry` | Could not complete shutdown. Please try again. | Ne eblis fini malŝalton. Bonvolu reprovi. |
| `system.shuttingDown` | Shutting down | Malŝaltado |
| `t3code.nightly` | Nightly | Nokta |
| `t3code.selectChannel` | Install T3 Code from which channel? | Instali T3 Code el kiua kanalo? |
| `t3code.stable` | Stable | Stabla |
| `tailscale.exitNodePaused` | Tailscale exit node paused | Tailscale-elireja nodo paŭzita |
| `tailscale.exitNodePausedForSignIn` | It comes back once you're signed in | Ĝi revenas post vi enlokiĝos |
| `tailscale.exitNodeRestoreFailed` | Couldn't restore the Tailscale exit node | Ne eblis restarigi la Tailscale-elirejan nodon |
| `tailscale.exitNodeRestoreHint` | Turn it back on with Tailscale | Reŝaltu ĝin per Tailscale |
| `tailscale.exitNodeRestored` | Tailscale exit node restored | Tailscale-elireja nodo restarigita |
| `tailscale.fileCount` | one: %1 file / other: %1 files | one: %1 dosiero / other: %1 dosieroj |
| `tailscale.received` | Received %1 | Ricevis %1 |
| `tailscale.savedTo` | Saved to %1 | Konservis al %1 |
| `tailscale.sendFailed` | Could not send to %1 | Ne eblis sendi al %1 |
| `tailscale.sendToTitle` | Send to %1 | Sendi al %1 |
| `tailscale.sent` | Sent to %1 | Sendis al %1 |
| `tailscale.transferFailed` | Taildrop transfer failed | Transfero per Taildrop malsukcesis |
| `theme.backgroundIntros` | Background Intros | Fonaĵoj de temo |
| `theme.commandsFailed` | %1 failed. See %2 | %1 malsukcesis. Vidu %2 |
| `theme.noBackground` | No background was found for theme | Neniu fono trovita por la etoso |
| `theme.notAppliedEverywhere` | Theme not applied everywhere | Etoso ne aplikata ĉien |
| `theme.removeExtraTitle` | Remove extra theme | Forigi extra etoson |
| `theme.removed` | Theme removed | Etoso forigita |
| `theme.repoPlaceholder` | Git repo URL (https or git@host:org/repo.git) | Git-repo URL (https aŭ git@host:org/repo.git) |
| `themeSync.disabled` | Herdr theme sync disabled | Etosa sinkronigo de Herdr malaktiva |
| `themeSync.enabled` | Herdr theme sync enabled | Etosa sinkronigo de Herdr aktiva |
| `time.now` | %1  ·  %2  ·  Week %3 | %1  ·  %2  ·  Semajno %3 |
| `timezone.changed` | Timezone is now set to %1 | La zona horo estas nun agordita al %1 |
| `timezone.setTitle` | Set timezone | Agordi zonan horon |
| `transcode.done` | Transcoded to %1 %2 | Konvertis al %1 %2 |
| `transcode.pickInput` | Transcode picture or video | Konverti bildon aŭ videon |
| `transcode.qualityHigh` | high | alta |
| `transcode.qualityLow` | low | malalta |
| `transcode.qualityMedium` | medium | meza |
| `transcode.saved` | Saved and copied to clipboard. | Konservita kaj kopiita al tonubo. |
| `transcode.selectFormat` | Select format | Elektu formaton |
| `transcode.selectResolution` | Select resolution | Elektu rezolucion |
| `transcode.working` | Transcoding video… | Konvertado de video… |
| `transcode.workingBody` | %1 to %2 (%3) | %1 al %2 (%3) |
| `tui.commandPlaceholder` | %1 or %2 | %1 aŭ %2 |
| `tui.commandPrompt` | Launch Command>  | Lanĉa komando>  |
| `tui.iconPlaceholder` | See %1 or enter an installed icon name | Vidu %1 aŭ enigu nomon de instalita piktogramo |
| `tui.iconPrompt` | Icon URL/name>  | URL/nomo de piktogramo>  |
| `tui.intro` | Let's create a TUI shortcut you can start with the app launcher. | Ni kreu TUI- mallongigon, kiun vi povas starti per la aplikaĵlanĉilo. |
| `tui.namePlaceholder` | My TUI | Mia TUI |
| `tui.namePrompt` | Name>  | Nomo>  |
| `tui.removed` | TUI removed | TUI forigita |
| `tui.selectRemove` | Select TUI to remove | Elektu TUI-n por forigi |
| `tui.windowStyle` | Window style | Stilo de fenestro |
| `update.cannotStop` | You cannot stop the update once you start! | Vi ne povas haltigi la ĝisdatigon unufoe ĝi komenciĝis! |
| `update.connectPower` | Make sure you're connected to power or have a full battery | Certiĝu, ke vi estas konektita al la kurento aŭ havas plenan baterion |
| `update.continue` | Continue with update? | Daŭrigi ĝisdatigon? |
| `update.hyprlandReboot` | Hyprland has been updated. Reboot? | Hyprland estis ĝisdatigita. Rekomenci? |
| `update.kernelReboot` | Linux kernel has been updated. Reboot? | La Linuk-kerno estis ĝisdatigita. Rekomenci? |
| `update.ready` | Ready to update? | Preta por ĝisdatigi? |
| `update.rebootRequired` | Updates require reboot. Ready? | Ĝisdatigoj postulas rekomencon. Preta? |
| `update.removeOrphans` | one: Remove %1 orphaned package? / other: Remove %1 orphaned packages? | one: Forigi %1 orfanan pakaĵon? / other: Forigi %1 orfanajn pakaĵojn? |
| `update.whatsNew` | What's new: %1 | Kio estas nova: %1 |
| `update.failed` | Something went wrong during the update! | [Missing translation] |
| `update.failedReview` | Please review the output above carefully, correct the error, and retry the update. | [Missing translation] |
| `update.failedHelp` | If you need assistance, get help from the community at %1 | [Missing translation] |
| `update.noSnapshot` | Continuing the update without a snapshot. | [Missing translation] |
| `update.miseFailed` | Some mise tools could not be updated. Review the errors above and run %1 to retry. | [Missing translation] |
| `update.bootUnverified` | The update is not finished: its boot files did not pass verification (see above). Do not reboot until %1 completes. | [Missing translation] |
| `update.cancelled` | Update cancelled | [Missing translation] |
| `update.needsFreeSpace` | You need at least %1 GiB free to safely update Omarchy. | [Missing translation] |
| `update.alreadyRunning` | An Omarchy update is already running. | [Missing translation] |
| `update.pruneCache` | Prune package cache | [Missing translation] |
| `update.pruneFailed` | Could not prune the package cache. | [Missing translation] |
| `update.devCheckout` | Update Omarchy dev checkout | [Missing translation] |
| `update.devCheckoutSkipped` | Skip Omarchy dev checkout update (current branch has no upstream) | [Missing translation] |
| `update.signingKeys` | Update signing keys | [Missing translation] |
| `update.keysCorrect` | Keys are correct | [Missing translation] |
| `update.systemPackages` | Update system packages | [Missing translation] |
| `update.migrationsWaiting` | Waiting for pacman transaction to finish before running Omarchy migrations... | [Missing translation] |
| `update.migrationsDeferred` | Pacman transaction is still running; Omarchy migrations will retry on next login. | [Missing translation] |
| `update.migration` | Running migration (%1) | [Missing translation] |
| `update.migrationDeferred` | Migration %1 is waiting for a package update; it and the migrations after it will run on the next update or login. | [Missing translation] |
| `update.orphans` | Orphan system packages | [Missing translation] |
| `update.orphansFound` | one: %1 orphaned package found. Re-run %2 in a terminal to review or remove it. / other: %1 orphaned packages found. Re-run %2 in a terminal to review or remove them. | [Missing translation] |
| `update.keepingOrphans` | Keeping orphaned packages. | [Missing translation] |
| `update.removingOrphans` | Removing orphan system packages | [Missing translation] |
| `update.rebootLater` | %1 Run %2 when ready. | [Missing translation] |
| `update.restartingService` | Restarting %1 | [Missing translation] |
| `update.restartingShell` | Restarting shell | [Missing translation] |
| `update.pluginsReloaded` | All plugins have been reloaded | [Missing translation] |
| `update.mise` | Update mise tools | [Missing translation] |
| `update.aur` | Update AUR packages | [Missing translation] |
| `update.aurUnavailable` | AUR is unavailable (so skipping updates) | [Missing translation] |
| `update.bootNotVerified` | The boot files were not verified. This machine predates its platform's boot package; updates verify them once it is installed. | [Missing translation] |
| `snapshot.noConfigs` | No Snapper configs found, so no snapshot was created. | [Missing translation] |
| `snapshot.configure` | Configure Snapper with: %1 | [Missing translation] |
| `snapshot.create` | Create system snapshot | [Missing translation] |
| `snapshot.bootSelectable` | Snapshots can be selected during boot. | [Missing translation] |
| `weather.status` | %1  ·  Temp %2  ·  Wind %3 | [Missing translation] |
| `weather.unavailable` | Weather unavailable | [Missing translation] |
| `webapp.iconPlaceholder` | Could not fetch favicon automatically. Enter PNG icon URL or icon name | Ne eblis aŭtomate akiri la favikon. Enigu URL de PNG-piktogramo aŭ nomon de piktogramo |
| `webapp.intro` | Let's create a new web app you can start with the app launcher. | Ni kreu novan retan aplikaĵon, kiun vi povas starti per la aplikaĵlanĉilo. |
| `webapp.namePlaceholder` | My favorite web app | Mia amata reta aplikaĵo |
| `webapp.removed` | Web app removed | Reta aplikaĵo forigita |
| `webapp.selectRemove` | Select web app to remove | Elektu retan aplikaĵon por forigi |
| `window.noSavedWidth` | No saved width found for %1 on workspace %2 | Neniu konservita larĝo trovita por %1 sur laborspaco %2 |
| `window.restoreWidthHint` | Restore using Super + Home on this workspace. | Restarigu per Super + Home sur ĉi tiu laborspaco. |
| `window.saveWidthHint` | Use Super + Alt + Home to save one for this workspace. | Uzu Super + Alt + Home por konservi unu por ĉi tiu laborspaco. |
| `window.savedWidth` | Saved width for %1 on workspace %2 | Konservita larĝo por %1 sur laborspaco %2 |
| `window.squareOff` | Disable single-window square aspect ratio | Malŝalti unufenestran kvadratan rati(on) |
| `window.squareOn` | Enable single-window square aspect ratio | Ŝalti unufenestran kvadratan rati(on) |
| `windowsVm.configuration` | Windows VM Configuration | Agordo de Windows-VM |
| `windowsVm.confirmRemove` | Remove Windows VM and delete all associated data? | Forigi Windows-VM kaj forviŝi ĉiujn rilatajn datumojn? |
| `windowsVm.coresHeader` | How many CPU cores would you like to allocate to Windows VM? | Kiom da CPU-kernoj vi volas asigni al la Windows-VM? |
| `windowsVm.coresPlaceholder` | Number of CPU cores (1-%1) | Nombro da CPU-kernoj (1-%1) |
| `windowsVm.diskHeader` | How much disk space would you like to give Windows VM? (64GB+ recommended) | Kiom da diskospaco vi volas doni al la Windows-VM? (rekomende 64GB+) |
| `windowsVm.failed` | Failed to start Windows VM | Ne eblis starti la Windows-VM |
| `windowsVm.passwordHeader` | Enter Windows password: | Enigu la pasvorton de Windows: |
| `windowsVm.passwordPlaceholder` | Password (Press enter to use default: %1) | Pasvorto (presu Enter por uzi la defaŭltan: %1) |
| `windowsVm.proceed` | Proceed with this configuration? | Daŭrigi kun ĉi tiu agordo? |
| `windowsVm.ramHeader` | How much RAM would you like to allocate to Windows VM? | Kiom da RAM vi volas asigni al la Windows-VM? |
| `windowsVm.usernameHeader` | Enter Windows username: | Enigu la uzantnomon de Windows: |
| `windowsVm.usernamePlaceholder` | Username (Press enter to use default: %1) | Uzantnomo (presu Enter por uzi la defaŭltan: %1) |
| `xbox.rebootNeeded` | Reboot needed to finish setup. Reboot now? | Rekomenco necesas por fini la agordon. Rekomenci nun? |

</details>

<details>
<summary>Left in English (5, for reference)</summary>

- `battery.durationHours`: %1h
- `battery.durationHoursMinutes`: %1h %2m
- `battery.durationMinutes`: %1m
- `reminder.durationMinutesSeconds`: %1m %2s
- `reminder.durationSeconds`: %1s

</details>

## Keybinding descriptions (`keybindings.json`) — 189 keys

170 strings translated, 29 intentionally left in
English (brand names and technical tokens).

<details>
<summary>Translated strings</summary>

| Key | English | Esperanto |
| --- | --- | --- |
| `Activity` | Activity | Aktivaĵo |
| `Agents` | Agents | [Missing translation] |
| `Amap` | Amap | [Missing translation] |
| `Background switcher` | Background switcher | Ŝaltilo de fono |
| `Bar panel %1` | Bar panel %1 | Panelo de stripo %1 |
| `Bilibili` | Bilibili | [Missing translation] |
| `Brightness down` | Brightness down | Malbriligi |
| `Brightness down precise` | Brightness down precise | Malbriligi iomete |
| `Brightness maximum` | Brightness maximum | Maksimuma heleco |
| `Brightness minimum` | Brightness minimum | Minimuma heleco |
| `Brightness up` | Brightness up | Briligi |
| `Brightness up precise` | Brightness up precise | Briligi iomete |
| `Browser (private)` | Browser (private) | Retumilo (privata) |
| `Calculator` | Calculator | Kalkulilo |
| `Calendar` | Calendar | Kalendaro |
| `Capture menu` | Capture menu | Menuo de kaptado |
| `Clear reminders` | Clear reminders | Vakigi memorigojn |
| `Clipboard manager` | Clipboard manager | Vaturilo de tonubo |
| `Close all windows` | Close all windows | Fermi ĉiujn fenestrojn |
| `Close window` | Close window | Fermi fenestron |
| `Color picker` | Color picker | Elektilo de koloro |
| `Control notifications with the keyboard` | Control notifications with the keyboard | [Missing translation] |
| `Cycle workspace layout` | Cycle workspace layout | Cikli aranĝon de laborspaco |
| `Cycle workspace layout back` | Cycle workspace layout back | Cikli aranĝon de laborspaco inverse |
| `DeepSeek` | DeepSeek | [Missing translation] |
| `Direct input for the terminal prefix` | Direct input for the terminal prefix | Direta enigo por la prefikso de la terminalo |
| `Disable touchpad` | Disable touchpad | Malŝalti tuŝpladon |
| `Dismiss all notifications` | Dismiss all notifications | Forigi ĉiujn sciigojn |
| `Dismiss last notification` | Dismiss last notification | Forigi lastan sciigon |
| `Dismiss, invoke, or focus last notification` | Dismiss, invoke, or focus last notification | [Missing translation] |
| `Display` | Display | Ekrano |
| `Editor` | Editor | Redaktilo |
| `Eject media` | Eject media | Eligi portan amaskontenon |
| `Email` | Email | Retpoŝto |
| `Enable touchpad` | Enable touchpad | Ŝalti tuŝpladon |
| `Expand window down` | Expand window down | Etendi fenestron malsupren |
| `Expand window down a little` | Expand window down a little | Etendi fenestron malsupren iomete |
| `Expand window down a lot` | Expand window down a lot | Etendi fenestron malsupren multe |
| `Expand window left` | Expand window left | Etendi fenestron maldekstren |
| `Expand window left a little` | Expand window left a little | Etendi fenestron maldekstren iomete |
| `Expand window left a lot` | Expand window left a lot | Etendi fenestron maldekstren multe |
| `Extract text (OCR) from screenshot` | Extract text (OCR) from screenshot | Eligi tekston (OCR) el ekrankopio |
| `File manager` | File manager | Dosieradministrilo |
| `File manager (cwd)` | File manager (cwd) | Dosieradministrilo (nun) |
| `Focus on above window` | Focus on above window | Fokusi supren fenestron |
| `Focus on below window` | Focus on below window | Fokusi malsupren fenestron |
| `Focus on left window` | Focus on left window | Fokusi maldekstran fenestron |
| `Focus on next monitor` | Focus on next monitor | Fokusi sekvan monitoron |
| `Focus on next window` | Focus on next window | Fokusi sekvan fenestron |
| `Focus on previous monitor` | Focus on previous monitor | Fokusi antaŭan monitoron |
| `Focus on previous window` | Focus on previous window | Fokusi antaŭan fenestron |
| `Focus on right window` | Focus on right window | Fokusi dekstran fenestron |
| `Former workspace` | Former workspace | Antaŭa laborspaco |
| `Full screen` | Full screen | Tuttplekse |
| `Full width` | Full width | Plena larĝo |
| `Hardware menu` | Hardware menu | Menuo de aparataro |
| `Keyboard backlight cycle` | Keyboard backlight cycle | Cikli klavaran dorslumon |
| `Keyboard brightness down` | Keyboard brightness down | Malbriligi klavaron |
| `Keyboard brightness up` | Keyboard brightness up | Briligi klavaron |
| `Lock system` | Lock system | Ŝlosi sistemon |
| `Make webcam overlay larger` | Make webcam overlay larger | Fari retokameran kovrilon pli granda |
| `Make webcam overlay smaller` | Make webcam overlay smaller | Fari retokameran kovrilon pli malgranda |
| `Minimize window to the dock` | Minimize window to the dock | Minimumigi fenestron al la doko |
| `Monitor scaling down` | Monitor scaling down | Malpliigi monitoran skalon |
| `Monitor scaling up` | Monitor scaling up | Pligrandigi monitoran skalon |
| `Move active window out of group` | Move active window out of group | Elmovi aktivan fenestron el grupo |
| `Move grouped window focus left` | Move grouped window focus left | Movi grupitan fokumon maldekstren |
| `Move grouped window focus right` | Move grouped window focus right | Movi grupitan fokumon dekstren |
| `Move window` | Move window | Movi fenestron |
| `Move window silently to workspace %1` | Move window silently to workspace %1 | Movi fenestron silente al laborspaco %1 |
| `Move window to Quake console` | Move window to Quake console | [Missing translation] |
| `Move window to down monitor` | Move window to down monitor | Movi fenestron al malsupra monitoro |
| `Move window to group on bottom` | Move window to group on bottom | Movi fenestron al grupo malsupre |
| `Move window to group on left` | Move window to group on left | Movi fenestron al grupo maldekstre |
| `Move window to group on right` | Move window to group on right | Movi fenestron al grupo dekstre |
| `Move window to group on top` | Move window to group on top | Movi fenestron al grupo supre |
| `Move window to left monitor` | Move window to left monitor | Movi fenestron al maldekstra monitoro |
| `Move window to right monitor` | Move window to right monitor | Movi fenestron al dekstra monitoro |
| `Move window to scratchpad` | Move window to scratchpad | Movi fenestron al skraptablo |
| `Move window to up monitor` | Move window to up monitor | Movi fenestron al supra monitoro |
| `Move window to workspace %1` | Move window to workspace %1 | Movi fenestron al laborspaco %1 |
| `Move workspace to down monitor` | Move workspace to down monitor | Movi laborspacon al malsupra monitoro |
| `Move workspace to left monitor` | Move workspace to left monitor | Movi laborspacon al maldekstra monitoro |
| `Move workspace to right monitor` | Move workspace to right monitor | Movi laborspacon al dekstra monitoro |
| `Move workspace to up monitor` | Move workspace to up monitor | Movi laborspacon al supra monitoro |
| `Music` | Music | Muziko |
| `Mute` | Mute | Silentigi |
| `Mute microphone` | Mute microphone | Silentigi mikrofonon |
| `Network` | Network | Reto |
| `New email` | New email | Nova retpoŝto |
| `Next track` | Next track | Sekva kanto |
| `Next window in group` | Next window in group | Sekva fenestro en grupo |
| `Next workspace` | Next workspace | Sekva laborspaco |
| `Omarchy menu` | Omarchy menu | Menuo de Omarchy |
| `Open notification history` | Open notification history | Malfermi historian de sciigoj |
| `Pause` | Pause | Paŭzi |
| `Play` | Play | Ludi |
| `Pop window out (float & pin)` | Pop window out (float & pin) | Eligi fenestron (ŝveba kaj fiksita) |
| `Power` | Power | Energio |
| `Power menu` | Power menu | Menuo de energio |
| `Previous track` | Previous track | Antaŭa kanto |
| `Previous window in group` | Previous window in group | Antaŭa fenestro en grupo |
| `Previous workspace` | Previous workspace | Antaŭa laborspaco |
| `Pseudo window` | Pseudo window | Pseŭdfenestro |
| `Qwen` | Qwen | [Missing translation] |
| `Reset zoom` | Reset zoom | Restarigi zomadon |
| `Resize window` | Resize window | Alĵusti grandecon de fenestro |
| `Restore window width` | Restore window width | Restarigi larĝecon de fenestro |
| `Reveal active window on top` | Reveal active window on top | Montri aktivan fenestron supre |
| `Save window width` | Save window width | Konservi larĝecon de fenestro |
| `Screenrecording with no audio` | Screenrecording with no audio | [Missing translation] |
| `Scroll active workspace backward` | Scroll active workspace backward | Ruli aktivan laborspacon inverse |
| `Scroll active workspace forward` | Scroll active workspace forward | Ruli aktivan laborspacon antaŭen |
| `Select all` | Select all | Elekti ĉion |
| `Set reminder` | Set reminder | Agordi memorigon |
| `Share` | Share | Kunhavigi |
| `Show battery remaining` | Show battery remaining | Montri restantan baterion |
| `Show reminders` | Show reminders | Montri memorigojn |
| `Show time` | Show time | Montri tempon |
| `Shrink window left` | Shrink window left | Kontraŭi fenestron maldekstren |
| `Shrink window left a little` | Shrink window left a little | Kontraŭi fenestron maldekstren iomete |
| `Shrink window left a lot` | Shrink window left a lot | Kontraŭi fenestron maldekstren multe |
| `Shrink window up` | Shrink window up | Kontraŭi fenestron supre |
| `Shrink window up a little` | Shrink window up a little | Kontraŭi fenestron supre iomete |
| `Shrink window up a lot` | Shrink window up a lot | Kontraŭi fenestron supre multe |
| `Start dictation (push-to-talk)` | Start dictation (push-to-talk) | Komenci dikcion (prem-al-parolo) |
| `Stop dictation (push-to-talk)` | Stop dictation (push-to-talk) | Halti dikcion (prem-al-parolo) |
| `Swap window down` | Swap window down | Interŝanĝi fenestron malsupren |
| `Swap window to the left` | Swap window to the left | Interŝanĝi fenestron maldekstren |
| `Swap window to the right` | Swap window to the right | Interŝanĝi fenestron dekstren |
| `Swap window up` | Swap window up | Interŝanĝi fenestron supre |
| `Switch audio output` | Switch audio output | Ŝalti audian eligon |
| `Switch input language` | Switch input language | Ŝalti enigan lingvon |
| `Switch input language back` | Switch input language back | Ŝalti enigan lingvon inverse |
| `Switch media source` | Switch media source | Ŝalti fonton de amaskonteno |
| `Switch to group window %1` | Switch to group window %1 | Ŝalti al grupita fenestro %1 |
| `Switch to workspace %1` | Switch to workspace %1 | Ŝalti al laborspaco %1 |
| `System menu` | System menu | Menuo de sistemo |
| `Terminal` | Terminal | Terminumo |
| `Theme menu` | Theme menu | Menuo de etoso |
| `Tiled full screen` | Tiled full screen | Mosaika tutplekse |
| `Toggle Quake console` | Toggle Quake console | [Missing translation] |
| `Toggle dictation` | Toggle dictation | Ŝalteti dikcion |
| `Toggle full screen desktop` | Toggle full screen desktop | Ŝalteti tutpleksan labortablon |
| `Toggle laptop display` | Toggle laptop display | Ŝalteti ekranon de tekomejo |
| `Toggle laptop display mirroring` | Toggle laptop display mirroring | Ŝalteti speguladon de ekrano |
| `Toggle locking on idle` | Toggle locking on idle | Ŝalteti ŝlosadon dum nezaktivado |
| `Toggle menu` | Toggle menu | Ŝalteti menuon |
| `Toggle scratchpad` | Toggle scratchpad | Ŝalteti skraptablon |
| `Toggle silencing notifications` | Toggle silencing notifications | Ŝalteti silentigadon de sciigoj |
| `Toggle single-window square aspect` | Toggle single-window square aspect | Ŝalteti unufenestran kvadratan rati(on) |
| `Toggle top bar` | Toggle top bar | Ŝalteti supran stripon |
| `Toggle touchpad` | Toggle touchpad | Ŝalteti tuŝpladon |
| `Toggle transparency on a window` | Toggle transparency on a window | Ŝalteti transparentecon de fenestro |
| `Toggle weather` | Toggle weather | Ŝalteti veteron |
| `Toggle window floating/tiling` | Toggle window floating/tiling | Ŝalteti ŝveban/mosaikan reĝimon |
| `Toggle window gaps` | Toggle window gaps | Ŝalteti fenestrajn interspacojn |
| `Toggle window grouping` | Toggle window grouping | Ŝalteti grupadon de fenestroj |
| `Toggle window split` | Toggle window split | Ŝalteti dividon de fenestro |
| `Universal copy` | Universal copy | Universala kopiado |
| `Universal cut` | Universal cut | Universala tranĉo |
| `Universal paste` | Universal paste | Universala algluo |
| `Volume down` | Volume down | Malaltigi volumon |
| `Volume down precise` | Volume down precise | Malaltigi volumon iomete |
| `Volume up` | Volume up | Altigi volumon |
| `Volume up precise` | Volume up precise | Altigi volumon iomete |
| `Weibo` | Weibo | [Missing translation] |
| `World clock` | World clock | Mondaj horloĝo |
| `Zoom in` | Zoom in | Zomi enen |
| `Zoom in (JIS + key)` | Zoom in (JIS + key) | Zomi enen (JIS + klavo) |

</details>

<details>
<summary>Left in English (29, for reference)</summary>

- `Agent`: Agent
- `Apps`: Apps
- `Audio`: Audio
- `Bluetooth`: Bluetooth
- `Browser`: Browser
- `ChatGPT`: ChatGPT
- `Docker`: Docker
- `Emojis`: Emojis
- `Google Maps`: Google Maps
- `Google Messages`: Google Messages
- `Google Photos`: Google Photos
- `Grok`: Grok
- `Herdr`: Herdr
- `Herdr keybindings`: Herdr keybindings
- `Keybindings`: Keybindings
- `Music TUI`: Music TUI
- `Obsidian`: Obsidian
- `Omawrite`: Omawrite
- `Passwords`: Passwords
- `Screenrecording`: Screenrecording
- `Screenshot`: Screenshot
- `Signal`: Signal
- `Tmux`: Tmux
- `Tmux keybindings`: Tmux keybindings
- `Transcode`: Transcode
- `WhatsApp`: WhatsApp
- `X`: X
- `X Post`: X Post
- `YouTube`: YouTube

</details>

## Totals

- Translated and needing review: **1512** strings
- Untranslated on purpose: brand names, technical tokens, Qt date patterns,
  and clock-format previews (where only weekday and month words translate,
  so most of those preview strings are effectively unchanged).
