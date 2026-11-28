# සංවර්ධන මෙවලම්

## විකල්ප සංස්කාරක

Omarchy නව ස්ථාපනවලදී පෙරනිමි සංස්කාරකය ලෙස Plain සමඟ එන අතර [Neovim](https://neovim.io/) ද පෙර-ස්ථාපනය කර ඇත, නමුත් ඔබට තව ටිකක් ප්‍රධාන ධාරාවේ සහ හුරුපුරුදු දෙයක් අවශ්‍ය නම්, ඔබට Omarchy Menu (`Super + Space`) ක්‍රියාත්මක කර _Install > Editor_ යටතේ ඇති විකල්ප බැලිය හැකිය. එහි VSCode, Cursor, Zed, Sublime Text, Helix, Vim සහ Emacs ලැයිස්තුගත කර ඇත. ඔබ සොයන දෙය ඔබට සොයාගත නොහැකි නම්, _Install > Package_ බලන්න, එය Arch පැකේජයක නැද්දැයි බලන්න (නැතිනම්, AUR පරීක්ෂා කිරීමට _Install > AUR_ උත්සාහ කරන්න).

මුල් `vi` සංස්කාරකය ද පෙට්ටියෙන් එළියට ගත් වහාම භාවිතයට ඇත. terminal එකේ ගොනුවක් සංස්කරණය කිරීමට `vi filename` ධාවනය කරන්න.

තේමා ගැලපීම `VSCode`, `Cursor`, `VSCodium` සහ `Helix` සඳහා පිරිනැමේ.

ඔබට පද්ධතිය පුරා පෙරනිමි සංස්කාරකය `Setup > Defaults > Editor` යටතේ සැකසිය හැකිය.

## පරිසරය

Omarchy, Omarchy Menu (`Super + Space`) එකේ _Install > Development_ අංශය හරහා සංවර්ධන පරිසර රාශියක්ම පිහිටුවීමට සහාය දක්වයි. ඇත්ත වශයෙන්ම ඔබට _Ruby on Rails_ සොයාගත හැකි වනු ඇත, නමුත් JavaScript සඳහා ප්‍රධාන runtimes තුනම (Node.js, Bun, Deno), මෙන්ම Laravel සහ Symfony වැනි ජනප්‍රිය PHP frameworks ද ඇත. ඔව්, තව Go, Rust, Python, Java, Elixir (Phoenix සමඟ), .NET, OCaml, Zig, Clojure සහ Scala ද ඇත. එය ඉතා පුළුල් තේරීමක්!

මෙම පරිසරවලින් බහුතරය කළමනාකරණය කරනු ලබන්නේ [Mise](https://mise.jdx.dev/) විසිනි. එය එකම යන්ත්‍රයේ ක්‍රමලේඛන භාෂාවක බහු අනුවාද ස්ථාපනය කිරීමට සහ ධාවනය කිරීමට ඔබට ඉඩ දෙන මෙවලමකි. එය Ruby සඳහා rbenv හෝ rvm මෙන් හෝ Python සඳහා virtualenv මෙන්, නමුත් එය විවිධ පරිසර රාශියක් සඳහා ක්‍රියා කරයි.

උදාහරණයක් ලෙස, Ruby ස්ථාපනය කිරීමට, ඔබ `mise use -g ruby` ධාවනය කරනු ඇත, එමඟින් Ruby ස්ථාපනය කිරීම සහ එය ගෝලීය පෙරනිමිය ලෙස සැකසීම යන දෙකම සිදු කරයි. නැතහොත්, ඔබේ ව්‍යාපෘතියේ .ruby-version ගොනුවක් තිබේ නම්, එම ව්‍යාපෘතියේ root එකේ `mise i` ධාවනය කිරීමෙන් පමණක් ප්‍රමාණවත් වේ.

## පෙර-ස්ථාපිත CLI මෙවලම්

`uv`, Node.js සහ `playwright-cli` (agents ලට browser එකක් ධාවනය කිරීමට, ස්ථාපිත Chrome භාවිතා කරමින්) පැකේජ ලෙස ස්ථාපනය කර එන අතර, `omarchy update` ඒවා පද්ධතියේ ඉතිරිය සමඟ යාවත්කාලීනව තබා ගනී. [Hunk](https://github.com/modem-dev/hunk) සහ GitHub, Basecamp, Cloudflare සහ HEY CLIs _Install > CLI_ යටතේ එක් තේරීමකින් ලබාගත හැකි අතර, [කේතීකරණ agents](17-ai.md) _Install > AI > CLI_ යටතේ ඇත.

mise කළමනාකරණය කරන්නේ ඔබ _Install > Development_ වෙතින් පිහිටුවන runtimes පමණි; Omarchy තනිවම එය හරහා කිසිවක් ස්ථාපනය නොකරයි. Omarchy හි ඉතිරිය සමඟ ඒවා යාවත්කාලීන කිරීමට `omarchy update` ධාවනය කරන්න; `mup` alias එක mise විසින් කළමනාකරණය කරන මෙවලම් පමණක් යාවත්කාලීන කරයි. ඔබේම වින්‍යාසයට තවත් මෙවලමක් එක් කිරීමට, `mise use -g <tool>` භාවිතා කරන්න.

## Docker

[Docker](https://www.docker.com/) ගැන හැඳින්වීමක් අවශ්‍ය වන්නේම නැති තරම්ය. එය හුදකලා containers ධාවනය කිරීමට ඔබට ඉඩ දෙන අතර, Omarchy එය හොඳින් ධාවනය කිරීමට අවශ්‍ය සියල්ල ස්ථාපනය කරයි, Docker ම සහ [Docker Compose](https://docs.docker.com/compose/) ද ඇතුළුව.

පෙරනිමියෙන් ඔබේ පරිශීලකයා `docker` group එකේ *නැත*. එම group එක ඵලදායී ලෙස මුරපදයක් නැති root වේ — එහි ඇති ඕනෑම දෙයකට `docker run -v /:/host` ධාවනය කර යන්ත්‍රය අත්පත් කර ගත හැකිය — එබැවින් ඔබ ලෙස ධාවනය වන එක් අයාලේ යන script එකක් හෝ dependency එකක්, එසේ නොමැති නම්, root වෙත විධානයක් දුරින් සිටිනු ඇත. එබැවින් command line එකේ ඔබ Docker `sudo` සමඟ ධාවනය කරයි (`sudo docker ps`, `sudo docker compose up`), සහ daemon එක සමඟ කතා කරන චිත්‍රක මෙවලම් — Windows VM එක — ඒවාට අවශ්‍ය වූ විට අවසරය ඉල්ලා සිටී. ඔබට groupless සැකසුමේ පහසුව නැවත අවශ්‍ය නම් සහ එහි හුවමාරුව තේරුම් ගනී නම්, **Setup > Security > Sudoless Docker** වෙතින් එය සබල කරන්න (හෝ `omarchy-setup-security-sudoless-docker` ධාවනය කරන්න), එය අනතුරු ඇඟවීමකින් පසු ඔබව `docker` group එකට එක් කරයි; ඉන්පසු සරල `docker` සහ `d` alias එක `sudo` නොමැතිව නැවත ක්‍රියා කරයි.

ඔබට Omarchy menu එකේ _Install > Development > Docker DB_ භාවිතා කර Docker තුළ දේශීය සංවර්ධනය සඳහා පොදු databases පිහිටුවිය හැකිය.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) යනු `gh` වන අතර, terminal එකෙන් repositories, issues සහ pull requests සමඟ වැඩ කිරීමටය. ඔබ එහි GitHub වෙත sign in වීමට තෝරා ගන්නා විට _Setup > Git_ එය ස්ථාපනය කරයි, නැතහොත් _Install > CLI > GitHub_ වෙතින් එය තනිවම ස්ථාපනය කරන්න. ඉන්පසු `gh repo clone org/repo` මඟින් repository එකක් clone කරයි; එහි විධාන ගවේෂණය කිරීමට `gh --help` ධාවනය කරන්න.

[Lazygit](https://github.com/jesseduffield/lazygit) Git සමඟම වැඩ කිරීම සඳහා පෙර-ස්ථාපනය කර ඇත.
