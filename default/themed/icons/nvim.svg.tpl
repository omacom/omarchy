<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Neovim</title>
  <desc>A modal editor seen from the front: a dark window with indented lines of code, a block cursor in the highlight, and a status line whose mode is picked out in the main color, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The editor; one hard shadow, as Hype's slides. -->
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="100" width="360" height="312" rx="20" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- Lines of code, indented. -->
    <rect x="108" y="134" width="88" height="24" rx="12" fill="url(#main)"/>
    <rect x="208" y="138" width="124" height="16" rx="8" fill="{{ icon_paper }}"/>
    <rect x="144" y="182" width="176" height="16" rx="8" fill="{{ icon_ink }}"/>
    <rect x="144" y="222" width="64" height="24" rx="12" fill="url(#main)"/>
    <rect x="220" y="226" width="96" height="16" rx="8" fill="{{ icon_paper }}"/>
    <rect x="194" y="274" width="132" height="16" rx="8" fill="{{ icon_ink }}"/>
    <rect x="108" y="318" width="64" height="16" rx="8" fill="{{ icon_ink }}" opacity=".55"/>
    <!-- The block cursor, sitting on a character. -->
    <rect x="144" y="258" width="38" height="48" rx="8" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="144" y="258" width="38" height="48" rx="8" fill="{{ icon_mark }}"/>
    <rect x="155" y="274" width="16" height="16" rx="8" fill="{{ icon_shadow }}" opacity=".35"/>
    <!-- The status line, with the mode at its start. -->
    <rect x="96" y="352" width="320" height="40" rx="12" fill="{{ icon_edge }}"/>
    <rect x="96" y="352" width="112" height="40" rx="12" fill="url(#main)"/>
    <rect x="116" y="366" width="72" height="12" rx="6" fill="{{ icon_shadow }}" opacity=".45"/>
    <rect x="340" y="366" width="56" height="12" rx="6" fill="{{ icon_paper }}" opacity=".55"/>
  </g>
</svg>
