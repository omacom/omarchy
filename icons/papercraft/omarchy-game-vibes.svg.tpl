<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Game Vibes</title>
  <desc>A game cartridge seen from the front: a dark shell with grip ridges, a label in the main color showing a pixel invader, and a connector edge with contacts, with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <clipPath id="edge">
      <rect x="122" y="392" width="268" height="72"/>
    </clipPath>
  </defs>
  <!-- The shell, stepping in to the connector edge; one hard shadow, as Hype's slides. -->
  <path d="M106 30H406Q436 30 436 60V368Q436 392 412 392H390V456Q390 470 376 470H136Q122 470 122 456V392H100Q76 392 76 368V60Q76 30 106 30Z" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
  <path d="M106 30H406Q436 30 436 60V368Q436 392 412 392H390V456Q390 470 376 470H136Q122 470 122 456V392H100Q76 392 76 368V60Q76 30 106 30Z" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
  <!-- Grip ridges. -->
  <rect x="108" y="54" width="296" height="14" rx="7" fill="{{ icon_ink }}"/>
  <rect x="108" y="78" width="296" height="14" rx="7" fill="{{ icon_ink }}" opacity=".55"/>
  <!-- Label, with the invader cut out to the shell on a grid of 16 unit pixels. -->
  <rect x="108" y="110" width="296" height="208" rx="16" fill="url(#main)"/>
  <path d="M200 150h16v16h-16zM296 150h16v16h-16zM216 166h16v16h-16zM280 166h16v16h-16zM200 182h112v16h-112zM184 198h32v16h-32zM232 198h48v16h-48zM296 198h32v16h-32zM168 214h176v16h-176zM168 230h16v16h-16zM200 230h112v16h-112zM328 230h16v16h-16zM168 246h16v16h-16zM200 246h16v16h-16zM296 246h16v16h-16zM328 246h16v16h-16zM216 262h32v16h-32zM264 262h32v16h-32z" fill="{{ icon_body }}" stroke="{{ icon_body }}" shape-rendering="crispEdges"/>
  <rect x="216" y="348" width="80" height="14" rx="7" fill="{{ icon_ink }}" opacity=".55"/>
  <!-- Contacts, in the accent, standing out as Omacut's trim handles do. -->
  <g fill="{{ icon_mark }}" clip-path="url(#edge)">
    <rect x="145" y="410" width="22" height="60" rx="5"/>
    <rect x="185" y="410" width="22" height="60" rx="5"/>
    <rect x="225" y="410" width="22" height="60" rx="5"/>
    <rect x="265" y="410" width="22" height="60" rx="5"/>
    <rect x="305" y="410" width="22" height="60" rx="5"/>
    <rect x="345" y="410" width="22" height="60" rx="5"/>
  </g>
</svg>
