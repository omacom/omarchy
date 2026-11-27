# आम छोटे बदलाव

यह Omarchy setup में किए जाने वाले आम अनुकूलनों का संग्रह है। ध्यान रखें कि system updates के लिए कभी-कभी कुछ configs को उनकी मूल स्थिति में वापस लाना ज़रूरी हो सकता है। अगर ऐसा होता है, तो आपके बदलाव खोएंगे नहीं, बल्कि मूल file के बगल में एक `.bak.<timestamp>` file में रख दिए जाएंगे।

अगर आप कुछ गड़बड़ कर दें, तो आप Omarchy मेनू में _Update > Config_ के ज़रिए अलग-अलग configs को उनके मूल setup में वापस ला सकते हैं। अगर आप _वाकई_ सब कुछ गड़बड़ कर दें, तो आप `omarchy reinstall configs` से सभी configs reset कर सकते हैं, या `omarchy reinstall` से हर default package और config फिर से install कर सकते हैं।

### सभी tray icons हर समय दिखाएं

By default, Dropbox, 1password या Steam जैसे tray icons tray expander arrow के पीछे छिपे रहते हैं, जो उन पर hover करने पर उन्हें दिखा देता है। अगर आप उन्हें हर समय सामने रखना चाहते हैं, तो tray icon manager खोलने के लिए expander arrow पर right-click करें, फिर उन icons को pin कर दें जिन्हें आप हमेशा visible रखना चाहते हैं (आप उन्हें hide भी कर सकते हैं जिन्हें आप कभी नहीं देखना चाहते)।

### गोल window कोने

Omarchy का default design चौकोर कोनों वाला है, लेकिन अगर आप इसे थोड़ा नरम करना चाहते हैं, तो Omarchy मेनू में _Appearance > Windows > Window Corners > Rounded Corners_ चुनें, या `omarchy hyprland corners rounded` चलाएं। _Theme Corners_ उस पर वापस चला जाता है जो theme उपयोग करता है। अपना खुद का radius चुनने के लिए, _Theme Corners_ (`omarchy hyprland corners theme`) पर ही रहें, क्योंकि Rounded और Sharp आपकी config के बाद load होते हैं और उसे override कर देते हैं, और `~/.config/hypr/looknfeel.lua` में rounding को uncomment करें:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Window gaps हटाएं

Laptop displays पर, कुछ लोग window gaps पर कोई pixel बर्बाद नहीं करना चाहते (या top bar पर भी नहीं, जिसे आप `Super + Shift + Space` से toggle off कर सकते हैं)। आप `Super + Shift + Backspace` से सभी gaps और borders को toggle off कर सकते हैं, या `~/.config/hypr/looknfeel.lua` के इस section में comments हटाकर उन्हें स्थायी रूप से हटा सकते हैं:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
