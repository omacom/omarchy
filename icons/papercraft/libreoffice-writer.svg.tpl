<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>LibreOffice Writer</title>
  <desc>A document seen from the front: a pale page with a heading in the main color, a picture in the highlight with text wrapped beside it, and paragraphs below, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The page; one hard shadow, as Hype's slides. -->
    <rect x="100" y="76" width="312" height="360" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="100" y="76" width="312" height="360" rx="20" fill="{{ icon_paper }}"/>
    <!-- The heading. -->
    <rect x="132" y="110" width="156" height="26" rx="13" fill="url(#main)"/>
    <!-- Text wrapped beside the picture, and the paragraphs below. -->
    <g fill="{{ icon_ink }}">
      <rect x="264" y="168" width="116" height="14" rx="7"/>
      <rect x="264" y="200" width="96" height="14" rx="7" opacity=".55"/>
      <rect x="264" y="232" width="116" height="14" rx="7" opacity=".55"/>
      <rect x="264" y="264" width="72" height="14" rx="7" opacity=".55"/>
      <rect x="132" y="312" width="248" height="14" rx="7"/>
      <rect x="132" y="344" width="224" height="14" rx="7" opacity=".55"/>
      <rect x="132" y="376" width="152" height="14" rx="7" opacity=".55"/>
    </g>
    <!-- The picture set into the text. -->
    <rect x="132" y="164" width="112" height="118" rx="14" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="132" y="164" width="112" height="118" rx="14" fill="{{ icon_mark }}"/>
    <circle cx="166" cy="198" r="13" fill="{{ icon_shadow }}" opacity=".35"/>
    <path d="M150 262L186 226L208 246L226 232V262Z" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}" stroke-width="8" stroke-linejoin="round" opacity=".35"/>
  </g>
</svg>
