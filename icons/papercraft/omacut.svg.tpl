<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Omacut</title>
  <desc>A strip of film seen from the front: dark film with sprocket holes, two dimmed frames at the ends, two bright frames between a pair of trim handles, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="frame" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The strip of film; one hard shadow, as Hype's slides. -->
    <rect x="64" y="146" width="384" height="220" rx="18" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="64" y="146" width="384" height="220" rx="18" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <g fill="{{ icon_edge }}">
      <rect x="86" y="162" width="28" height="16" rx="6"/>
      <rect x="146" y="162" width="28" height="16" rx="6"/>
      <rect x="206" y="162" width="28" height="16" rx="6"/>
      <rect x="278" y="162" width="28" height="16" rx="6"/>
      <rect x="338" y="162" width="28" height="16" rx="6"/>
      <rect x="398" y="162" width="28" height="16" rx="6"/>
      <rect x="86" y="334" width="28" height="16" rx="6"/>
      <rect x="146" y="334" width="28" height="16" rx="6"/>
      <rect x="206" y="334" width="28" height="16" rx="6"/>
      <rect x="278" y="334" width="28" height="16" rx="6"/>
      <rect x="338" y="334" width="28" height="16" rx="6"/>
      <rect x="398" y="334" width="28" height="16" rx="6"/>
    </g>
    <!-- Frames outside the cut, dimmed. -->
    <rect x="82" y="194" width="62" height="124" rx="10" fill="{{ icon_ink }}" opacity=".55"/>
    <rect x="368" y="194" width="62" height="124" rx="10" fill="{{ icon_ink }}" opacity=".55"/>
    <!-- Frames inside the cut. -->
    <rect x="176" y="194" width="74" height="124" rx="10" fill="url(#frame)"/>
    <rect x="262" y="194" width="74" height="124" rx="10" fill="url(#frame)"/>
    <!-- Trim handles bracketing the cut. -->
    <rect x="148" y="118" width="24" height="276" rx="12" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="148" y="118" width="24" height="276" rx="12" fill="{{ icon_mark }}"/>
    <rect x="340" y="118" width="24" height="276" rx="12" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="340" y="118" width="24" height="276" rx="12" fill="{{ icon_mark }}"/>
    <rect x="157" y="238" width="6" height="36" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
    <rect x="349" y="238" width="6" height="36" rx="3" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
