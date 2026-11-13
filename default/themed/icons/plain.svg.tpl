<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Plain</title>
  <desc>A config file open in an editor, seen from the front: a dark window with a gutter of line numbers, keys with pale values, and a text cursor, each piece with a hard shadow.</desc>
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
    <!-- Line numbers. -->
    <g fill="{{ icon_edge }}">
      <rect x="100" y="140" width="24" height="16" rx="8"/>
      <rect x="100" y="188" width="24" height="16" rx="8"/>
      <rect x="100" y="236" width="24" height="16" rx="8"/>
      <rect x="100" y="284" width="24" height="16" rx="8"/>
      <rect x="100" y="332" width="24" height="16" rx="8"/>
    </g>
    <!-- Keys and their values. -->
    <rect x="148" y="136" width="96" height="24" rx="12" fill="url(#main)"/>
    <rect x="256" y="140" width="128" height="16" rx="8" fill="{{ icon_paper }}"/>
    <rect x="148" y="184" width="128" height="24" rx="12" fill="url(#main)"/>
    <rect x="288" y="188" width="72" height="16" rx="8" fill="{{ icon_paper }}"/>
    <rect x="148" y="236" width="196" height="16" rx="8" fill="{{ icon_ink }}"/>
    <rect x="148" y="280" width="72" height="24" rx="12" fill="url(#main)"/>
    <rect x="232" y="284" width="96" height="16" rx="8" fill="{{ icon_paper }}"/>
    <rect x="148" y="328" width="112" height="24" rx="12" fill="url(#main)"/>
    <!-- The cursor, at the end of the line being written. -->
    <rect x="274" y="306" width="24" height="68" rx="12" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="274" y="306" width="24" height="68" rx="12" fill="{{ icon_mark }}"/>
    <rect x="283" y="326" width="6" height="28" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
