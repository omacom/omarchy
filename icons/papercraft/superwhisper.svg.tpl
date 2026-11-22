<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Superwhisper</title>
  <desc>A voice seen from the front as a sound wave: seven upright bars in the main color rising to the loudest in the highlight, each with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The wave; one hard shadow per bar, as Hype's slides. -->
    <g fill="{{ icon_shadow }}" transform="translate(0 8)">
      <rect x="70" y="216" width="36" height="80" rx="18"/>
      <rect x="126" y="168" width="36" height="176" rx="18"/>
      <rect x="182" y="124" width="36" height="264" rx="18"/>
      <rect x="294" y="140" width="36" height="232" rx="18"/>
      <rect x="350" y="184" width="36" height="144" rx="18"/>
      <rect x="406" y="212" width="36" height="88" rx="18"/>
    </g>
    <g fill="url(#main)">
      <rect x="70" y="216" width="36" height="80" rx="18"/>
      <rect x="126" y="168" width="36" height="176" rx="18"/>
      <rect x="182" y="124" width="36" height="264" rx="18"/>
      <rect x="294" y="140" width="36" height="232" rx="18"/>
      <rect x="350" y="184" width="36" height="144" rx="18"/>
      <rect x="406" y="212" width="36" height="88" rx="18"/>
    </g>
    <!-- The loudest bar. -->
    <rect x="238" y="84" width="36" height="344" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="238" y="84" width="36" height="344" rx="18" fill="{{ icon_mark }}"/>
    <rect x="253" y="216" width="6" height="80" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
