<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Omacalc</title>
  <desc>A calculator seen from the front: a dark body with a display, a grid of muted keys and a tall equals key, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="display" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The body; one hard shadow, as Hype's slides. -->
    <rect x="116" y="76" width="280" height="360" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="116" y="76" width="280" height="360" rx="24" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- Display, with the result right-aligned. -->
    <rect x="140" y="100" width="232" height="84" rx="14" fill="url(#display)"/>
    <rect x="268" y="150" width="82" height="16" rx="8" fill="{{ icon_shadow }}" opacity=".35"/>
    <!-- Keys. -->
    <g fill="{{ icon_edge }}">
      <rect x="140" y="208" width="52" height="46" rx="10"/>
      <rect x="200" y="208" width="52" height="46" rx="10"/>
      <rect x="260" y="208" width="52" height="46" rx="10"/>
      <rect x="320" y="208" width="52" height="46" rx="10"/>
      <rect x="140" y="264" width="52" height="46" rx="10"/>
      <rect x="200" y="264" width="52" height="46" rx="10"/>
      <rect x="260" y="264" width="52" height="46" rx="10"/>
      <rect x="140" y="320" width="52" height="46" rx="10"/>
      <rect x="200" y="320" width="52" height="46" rx="10"/>
      <rect x="260" y="320" width="52" height="46" rx="10"/>
      <rect x="140" y="376" width="112" height="36" rx="10"/>
      <rect x="260" y="376" width="52" height="36" rx="10"/>
    </g>
    <!-- Equals, in the accent, standing out as Omacut's trim handles do. -->
    <rect x="320" y="264" width="52" height="148" rx="12" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="320" y="264" width="52" height="148" rx="12" fill="{{ icon_mark }}"/>
    <rect x="334" y="324" width="24" height="7" rx="3.5" fill="{{ icon_shadow }}" opacity=".45"/>
    <rect x="334" y="341" width="24" height="7" rx="3.5" fill="{{ icon_shadow }}" opacity=".45"/>
  </g>
</svg>
