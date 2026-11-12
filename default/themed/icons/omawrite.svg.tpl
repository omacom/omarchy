<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Omawrite</title>
  <desc>A sheet of paper seen from the front: a pale page with a title bar and muted lines of text, and a text cursor at the end of the last line, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="title" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The page; one hard shadow, as Hype's slides. -->
    <rect x="106" y="96" width="300" height="320" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="106" y="96" width="300" height="320" rx="20" fill="{{ icon_paper }}"/>
    <!-- Title. -->
    <rect x="142" y="134" width="176" height="36" rx="12" fill="url(#title)"/>
    <!-- Body text. -->
    <g fill="{{ icon_ink }}">
      <rect x="142" y="204" width="228" height="16" rx="8"/>
      <rect x="142" y="240" width="200" height="16" rx="8"/>
      <rect x="142" y="276" width="156" height="16" rx="8"/>
      <rect x="142" y="332" width="112" height="16" rx="8"/>
    </g>
    <!-- The cursor, at the end of the line being written. -->
    <rect x="268" y="302" width="26" height="76" rx="13" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="268" y="302" width="26" height="76" rx="13" fill="{{ icon_mark }}"/>
    <rect x="278" y="325" width="6" height="30" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
