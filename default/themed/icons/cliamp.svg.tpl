<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>cliamp</title>
  <desc>A music player seen from the front: a dark body with an equalizer on its display, a seek bar with a knob, and play controls, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The player; one hard shadow, as Hype's slides. -->
    <rect x="76" y="96" width="360" height="320" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="96" width="360" height="320" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The equalizer on its display. -->
    <rect x="100" y="120" width="312" height="156" rx="14" fill="{{ icon_shadow }}"/>
    <g fill="url(#main)">
      <rect x="124" y="210" width="24" height="46" rx="8"/>
      <rect x="160" y="168" width="24" height="88" rx="8"/>
      <rect x="196" y="140" width="24" height="116" rx="8"/>
      <rect x="232" y="186" width="24" height="70" rx="8"/>
      <rect x="268" y="152" width="24" height="104" rx="8"/>
      <rect x="304" y="196" width="24" height="60" rx="8"/>
      <rect x="340" y="174" width="24" height="82" rx="8"/>
      <rect x="376" y="220" width="12" height="36" rx="6"/>
    </g>
    <!-- Seek bar, played up to its knob. -->
    <rect x="100" y="300" width="312" height="14" rx="7" fill="{{ icon_edge }}"/>
    <rect x="100" y="300" width="180" height="14" rx="7" fill="url(#main)"/>
    <rect x="266" y="286" width="28" height="42" rx="14" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="266" y="286" width="28" height="42" rx="14" fill="{{ icon_mark }}"/>
    <!-- Play controls. -->
    <g fill="{{ icon_edge }}">
      <rect x="100" y="346" width="76" height="46" rx="12"/>
      <rect x="336" y="346" width="76" height="46" rx="12"/>
    </g>
    <rect x="188" y="346" width="136" height="46" rx="12" fill="{{ icon_paper }}"/>
    <path d="M246 356L246 382L270 369Z" fill="{{ icon_main }}" stroke="{{ icon_main }}" stroke-width="6" stroke-linejoin="round"/>
    <path d="M150 359L128 369L150 379ZM362 359L384 369L362 379Z" fill="{{ icon_ink }}" stroke="{{ icon_ink }}" stroke-width="5" stroke-linejoin="round"/>
  </g>
</svg>
