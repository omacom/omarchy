<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Checkmate</title>
  <desc>A chessboard seen from the front: a dark board of main and muted squares with a king in the highlight standing before it, each piece with a hard shadow, on a transparent background.</desc>
  <defs>
    <linearGradient id="square" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -252)">
    <!-- The board; one hard shadow, as Hype's slides. -->
    <rect x="96" y="76" width="320" height="320" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="96" y="76" width="320" height="320" rx="24" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- Sixteen squares stand in for sixty-four. -->
    <g>
      <rect x="116" y="96" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="188" y="96" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="260" y="96" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="332" y="96" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="116" y="168" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="188" y="168" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="260" y="168" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="332" y="168" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="116" y="240" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="188" y="240" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="260" y="240" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="332" y="240" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="116" y="312" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="188" y="312" width="64" height="64" rx="10" fill="url(#square)"/>
      <rect x="260" y="312" width="64" height="64" rx="10" fill="{{ icon_edge }}"/>
      <rect x="332" y="312" width="64" height="64" rx="10" fill="url(#square)"/>
    </g>
    <!-- The king, in the accent, standing out as Omacut's trim handles do. -->
    <g fill="{{ icon_shadow }}" transform="translate(0 8)">
      <rect x="247" y="118" width="18" height="60" rx="7"/>
      <rect x="230" y="134" width="52" height="18" rx="7"/>
      <path d="M220 172H292Q304 172 301 184L289 228H223L211 184Q208 172 220 172Z"/>
      <rect x="208" y="224" width="96" height="22" rx="11"/>
      <path d="M230 240H282L300 350H212Z"/>
      <rect x="196" y="342" width="120" height="26" rx="13"/>
      <rect x="180" y="362" width="152" height="44" rx="16"/>
    </g>
    <g fill="{{ icon_mark }}">
      <rect x="247" y="118" width="18" height="60" rx="7"/>
      <rect x="230" y="134" width="52" height="18" rx="7"/>
      <path d="M220 172H292Q304 172 301 184L289 228H223L211 184Q208 172 220 172Z"/>
      <rect x="208" y="224" width="96" height="22" rx="11"/>
      <path d="M230 240H282L300 350H212Z"/>
      <rect x="196" y="342" width="120" height="26" rx="13"/>
      <rect x="180" y="362" width="152" height="44" rx="16"/>
    </g>
    <rect x="226" y="380" width="60" height="9" rx="4.5" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
