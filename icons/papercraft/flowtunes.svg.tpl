<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Flowtunes</title>
  <desc>A tune's shape in upright bars: the part already played in the highlight, the rest in the main color, each bar with a hard shadow, on a transparent background.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -254)">
    <!-- The tune, loud and quiet from start to end. -->
    <g fill="{{ icon_shadow }}" transform="translate(0 8)">
      <rect x="88" y="214" width="22" height="72" rx="11"/>
      <rect x="119" y="180" width="22" height="140" rx="11"/>
      <rect x="151" y="132" width="22" height="236" rx="11"/>
      <rect x="182" y="166" width="22" height="168" rx="11"/>
      <rect x="214" y="110" width="22" height="280" rx="11"/>
      <rect x="245" y="154" width="22" height="192" rx="11"/>
      <rect x="276" y="100" width="22" height="300" rx="11"/>
      <rect x="308" y="172" width="22" height="156" rx="11"/>
      <rect x="339" y="140" width="22" height="220" rx="11"/>
      <rect x="371" y="198" width="22" height="104" rx="11"/>
      <rect x="402" y="220" width="22" height="60" rx="11"/>
    </g>
    <g fill="url(#main)">
      <rect x="214" y="110" width="22" height="280" rx="11"/>
      <rect x="245" y="154" width="22" height="192" rx="11"/>
      <rect x="276" y="100" width="22" height="300" rx="11"/>
      <rect x="308" y="172" width="22" height="156" rx="11"/>
      <rect x="339" y="140" width="22" height="220" rx="11"/>
      <rect x="371" y="198" width="22" height="104" rx="11"/>
      <rect x="402" y="220" width="22" height="60" rx="11"/>
    </g>
    <g fill="{{ icon_mark }}">
      <rect x="88" y="214" width="22" height="72" rx="11"/>
      <rect x="119" y="180" width="22" height="140" rx="11"/>
      <rect x="151" y="132" width="22" height="236" rx="11"/>
      <rect x="182" y="166" width="22" height="168" rx="11"/>
    </g>
  </g>
</svg>
