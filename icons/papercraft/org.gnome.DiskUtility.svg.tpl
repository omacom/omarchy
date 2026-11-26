<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>Disks</title>
  <desc>A hard drive seen from the front with its cover off: a dark case, a platter in the main color, the arm reaching over it in the highlight, and a label, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The case; one hard shadow, as Hype's slides. -->
    <rect x="92" y="76" width="328" height="360" rx="24" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="92" y="76" width="328" height="360" rx="24" fill="{{ icon_body }}" stroke="{{ icon_edge }}" stroke-width="3"/>
    <!-- The platter, with a track and its spindle. -->
    <circle cx="256" cy="218" r="116" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <circle cx="256" cy="218" r="116" fill="url(#main)"/>
    <circle cx="256" cy="218" r="78" fill="none" stroke="{{ icon_shadow }}" stroke-width="8" opacity=".2"/>
    <circle cx="256" cy="218" r="38" fill="{{ icon_shadow }}" opacity=".35"/>
    <circle cx="256" cy="218" r="16" fill="{{ icon_paper }}"/>
    <!-- The label. -->
    <rect x="120" y="372" width="112" height="14" rx="7" fill="{{ icon_ink }}"/>
    <rect x="120" y="398" width="72" height="14" rx="7" fill="{{ icon_ink }}" opacity=".55"/>
    <!-- The arm, pivoting in the corner with its head over the platter. -->
    <g transform="translate(0 8)" fill="{{ icon_shadow }}" stroke="{{ icon_shadow }}">
      <path d="M362 378L300 268" fill="none" stroke-width="24" stroke-linecap="round"/>
      <circle cx="362" cy="378" r="28" stroke="none"/>
    </g>
    <path d="M362 378L300 268" fill="none" stroke="{{ icon_mark }}" stroke-width="24" stroke-linecap="round"/>
    <circle cx="362" cy="378" r="28" fill="{{ icon_mark }}"/>
    <circle cx="362" cy="378" r="10" fill="{{ icon_shadow }}" opacity=".35"/>
  </g>
</svg>
