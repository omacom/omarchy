<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Activity Monitor</title>
  <desc>btop seen from the front: a dark window split into boxed panels the way btop draws them, a dotted CPU graph on top, memory meters and a process list with one row picked below, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
    <!-- The graph is drawn in dots, as btop draws it in braille. -->
    <pattern id="dots" width="16" height="16" patternUnits="userSpaceOnUse" x="112" y="4">
      <rect x="2" y="2" width="12" height="12" rx="4" fill="#fff"/>
    </pattern>
    <mask id="graph">
      <path d="M112 244V212H128V196H160V180H176V148H192V164H208V196H224V212H240V196H256V164H272V132H288V148H304V180H320V196H336V180H352V164H368V180H384V196H400V244Z" fill="url(#dots)"/>
    </mask>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The window; one hard shadow, as Hype's slides. -->
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="76" y="92" width="360" height="328" rx="22" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The boxes, each with its title set into the top border. -->
    <g fill="none" stroke="{{ icon_edge }}" stroke-width="5">
      <rect x="94" y="112" width="324" height="148" rx="12"/>
      <rect x="94" y="276" width="140" height="126" rx="12"/>
      <rect x="250" y="276" width="168" height="126" rx="12"/>
    </g>
    <g fill="{{ icon_body }}">
      <rect x="108" y="104" width="64" height="16"/>
      <rect x="108" y="268" width="48" height="16"/>
      <rect x="264" y="268" width="56" height="16"/>
    </g>
    <g fill="{{ icon_mark }}">
      <rect x="114" y="106" width="52" height="12" rx="6"/>
      <rect x="114" y="270" width="36" height="12" rx="6"/>
      <rect x="270" y="270" width="44" height="12" rx="6"/>
    </g>
    <!-- CPU: the load over time. -->
    <rect x="112" y="128" width="288" height="116" fill="url(#main)" mask="url(#graph)"/>
    <!-- Memory: one meter per kind, on its track. -->
    <g fill="{{ icon_shadow }}">
      <rect x="110" y="300" width="108" height="14" rx="7"/>
      <rect x="110" y="330" width="108" height="14" rx="7"/>
      <rect x="110" y="360" width="108" height="14" rx="7"/>
    </g>
    <g fill="url(#main)">
      <rect x="110" y="300" width="80" height="14" rx="7"/>
      <rect x="110" y="330" width="44" height="14" rx="7"/>
      <rect x="110" y="360" width="96" height="14" rx="7"/>
    </g>
    <!-- Processes: one row picked, as btop highlights it. -->
    <g fill="{{ icon_ink }}">
      <rect x="266" y="296" width="96" height="10" rx="5"/>
      <rect x="376" y="296" width="26" height="10" rx="5"/>
      <rect x="266" y="348" width="80" height="10" rx="5"/>
      <rect x="376" y="348" width="26" height="10" rx="5"/>
      <rect x="266" y="372" width="104" height="10" rx="5"/>
      <rect x="384" y="372" width="18" height="10" rx="5"/>
    </g>
    <rect x="258" y="314" width="152" height="26" rx="8" fill="url(#main)"/>
    <g fill="{{ icon_shadow }}">
      <rect x="268" y="322" width="84" height="10" rx="5"/>
      <rect x="370" y="322" width="30" height="10" rx="5"/>
    </g>
  </g>
</svg>
