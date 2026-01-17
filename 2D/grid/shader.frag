#version 450

layout(location = 0) in vec3 fragNormal;
layout(location = 1) in vec2 fragUV;
layout(location = 0) out vec4 outColor;

layout(push_constant) uniform PushConstants {
    mat4 mvp;
    vec4 color;
    float time;
} pc;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    vec2 uv = fragUV * 2.0 - 1.0;  // Center UV
    float t = pc.time;

    // Scale for world-space grid
    vec2 worldUV = uv * 50.0;

    // Multi-scale grid
    float gridSize1 = 4.0;   // Main grid
    float gridSize2 = 1.0;   // Sub grid
    float gridSize3 = 0.25;  // Fine grid

    // Grid line functions
    vec2 grid1 = abs(fract(worldUV / gridSize1 - 0.5) - 0.5) * gridSize1;
    vec2 grid2 = abs(fract(worldUV / gridSize2 - 0.5) - 0.5) * gridSize2;
    vec2 grid3 = abs(fract(worldUV / gridSize3 - 0.5) - 0.5) * gridSize3;

    float line1 = min(grid1.x, grid1.y);
    float line2 = min(grid2.x, grid2.y);
    float line3 = min(grid3.x, grid3.y);

    // Distance from center for radial effects
    float dist = length(uv);
    float distFade = 1.0 - smoothstep(0.3, 1.0, dist);

    // Line intensities with distance fade
    float lineWidth1 = 0.06;
    float lineWidth2 = 0.03;
    float lineWidth3 = 0.015;

    float intensity1 = smoothstep(lineWidth1, 0.0, line1);
    float intensity2 = smoothstep(lineWidth2, 0.0, line2) * 0.4;
    float intensity3 = smoothstep(lineWidth3, 0.0, line3) * 0.15 * distFade;

    // Glow around main lines
    float glow1 = smoothstep(lineWidth1 * 8.0, 0.0, line1) * 0.3;
    float glow2 = smoothstep(lineWidth2 * 4.0, 0.0, line2) * 0.1;

    // Animated pulse along grid
    float pulseSpeed = 3.0;
    float pulse1 = sin(worldUV.x * 0.5 - t * pulseSpeed) * 0.5 + 0.5;
    float pulse2 = sin(worldUV.y * 0.5 - t * pulseSpeed) * 0.5 + 0.5;
    float pulse = max(pulse1 * intensity1, pulse2 * intensity1);

    // Radial pulse from center synced to beat (150 BPM = 2.5 Hz)
    float beatPulse = sin(dist * 10.0 - t * 15.708) * 0.5 + 0.5;
    beatPulse = pow(beatPulse, 3.0) * distFade;

    // Color palette
    vec3 lineColor = vec3(0.0, 0.85, 1.0);      // Cyan
    vec3 glowColor = vec3(0.0, 0.4, 0.8);       // Blue glow
    vec3 pulseColor = vec3(0.5, 0.0, 1.0);      // Purple pulse
    vec3 accentColor = vec3(1.0, 0.0, 0.5);     // Magenta accent

    // Combine layers
    vec3 color = vec3(0.0);

    // Base glow
    color += glowColor * (glow1 + glow2);

    // Grid lines
    color += lineColor * intensity1;
    color += lineColor * intensity2 * 0.6;
    color += lineColor * intensity3 * 0.3;

    // Animated pulse
    color += pulseColor * pulse * 0.5;
    color += accentColor * beatPulse * intensity1 * 0.8;

    // Center glow
    float centerGlow = exp(-dist * 3.0) * 0.3;
    color += lineColor * centerGlow;

    // Horizon fade (fade out at edges)
    float horizonFade = 1.0 - smoothstep(0.6, 1.0, dist);
    color *= horizonFade;

    // Add subtle noise/grain
    float noise = (hash(fragUV * 1000.0 + t) - 0.5) * 0.03;
    color += noise;

    // Scanlines (subtle)
    float scanline = 0.95 + 0.05 * sin(gl_FragCoord.y * 1.5);
    color *= scanline;

    // Background - very dark blue instead of pure black
    vec3 bgColor = vec3(0.01, 0.01, 0.03);
    color = max(color, bgColor);

    // Boost overall brightness slightly
    color *= 1.2;

    outColor = vec4(color, 1.0);
}
