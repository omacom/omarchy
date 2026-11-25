<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>LibreOffice Calc</title>
  <desc>A spreadsheet seen from the front: a pale sheet with a header row in the main color, row labels, a grid of cells, and the selected cell in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The sheet; one hard shadow, as Hype's slides. -->
    <rect x="72" y="100" width="368" height="312" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="72" y="100" width="368" height="312" rx="20" fill="{{ icon_paper }}"/>
    <!-- The header row. -->
    <rect x="96" y="124" width="320" height="48" rx="12" fill="url(#main)"/>
    <rect x="188" y="141" width="64" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="312" y="141" width="48" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
    <!-- Row labels. -->
    <g fill="{{ icon_ink }}">
      <rect x="96" y="184" width="60" height="42" rx="10"/>
      <rect x="96" y="238" width="60" height="42" rx="10"/>
      <rect x="96" y="292" width="60" height="42" rx="10"/>
      <rect x="96" y="346" width="60" height="42" rx="10"/>
    </g>
    <!-- Cells. -->
    <g fill="{{ icon_ink }}" opacity=".3">
      <rect x="168" y="184" width="118" height="42" rx="10"/>
      <rect x="298" y="184" width="118" height="42" rx="10"/>
      <rect x="298" y="238" width="118" height="42" rx="10"/>
      <rect x="168" y="292" width="118" height="42" rx="10"/>
      <rect x="298" y="292" width="118" height="42" rx="10"/>
      <rect x="168" y="346" width="118" height="42" rx="10"/>
      <rect x="298" y="346" width="118" height="42" rx="10"/>
    </g>
    <!-- The selected cell, raised off the sheet. -->
    <rect x="164" y="234" width="126" height="50" rx="12" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="164" y="234" width="126" height="50" rx="12" fill="{{ icon_mark }}"/>
    <rect x="182" y="252" width="56" height="14" rx="7" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
