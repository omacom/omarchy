<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <title>LibreOffice Impress</title>
  <desc>A presentation seen from the front: a pale slide on a tripod with a title in the main color, bullet points, and a bar chart whose tallest bar is in the highlight, each piece with a hard shadow.</desc>
  <defs>
    <linearGradient id="main" x1="0" y1="0" x2="1" y2="1">
      <stop stop-color="{{ icon_main }}"/>
      <stop offset="1" stop-color="{{ icon_main_end }}"/>
    </linearGradient>
  </defs>
  <g transform="translate(256 256) scale(1.2) translate(-256 -256)">
    <!-- The tripod behind the slide. -->
    <path d="M256 340V396M256 392L196 440M256 392L316 440" fill="none" stroke="{{ icon_ink }}" stroke-width="20" stroke-linecap="round" stroke-linejoin="round"/>
    <!-- The slide; one hard shadow, as Hype's slides. -->
    <rect x="64" y="84" width="384" height="272" rx="20" fill="{{ icon_shadow }}" transform="translate(0 8)"/>
    <rect x="64" y="84" width="384" height="272" rx="20" fill="{{ icon_paper }}"/>
    <!-- The title and its bullet points. -->
    <rect x="96" y="118" width="148" height="26" rx="13" fill="url(#main)"/>
    <g fill="{{ icon_ink }}">
      <rect x="96" y="184" width="128" height="14" rx="7"/>
      <rect x="96" y="220" width="104" height="14" rx="7" opacity=".55"/>
      <rect x="96" y="256" width="128" height="14" rx="7" opacity=".55"/>
      <rect x="96" y="292" width="80" height="14" rx="7" opacity=".55"/>
    </g>
    <!-- The chart. -->
    <rect x="268" y="244" width="40" height="80" rx="10" fill="{{ icon_ink }}"/>
    <rect x="320" y="196" width="40" height="128" rx="10" fill="url(#main)"/>
    <rect x="372" y="132" width="40" height="192" rx="10" fill="{{ icon_shadow }}" transform="translate(0 6)"/>
    <rect x="372" y="132" width="40" height="192" rx="10" fill="{{ icon_mark }}"/>
  </g>
</svg>
