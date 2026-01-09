#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359
#define TAU 6.28318530718
#define PHI 1.61803398875

mat2 rot(float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }

float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f*f*(3.0-2.0*f);
    return mix(mix(hash(i), hash(i+vec2(1,0)), f.x),
               mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), f.x), f.y);
}

float sdLine(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

float sdCircle(vec2 p, vec2 c, float r) {
    return abs(length(p - c) - r);
}

// Smooth step for animation phases
float smoothPhase(float t, float start, float end) {
    return smoothstep(start, end, t);
}

// Dark gloomy palette - teals, cold blues, muted purples
vec3 gloomyPalette(float t) {
    t = fract(t);
    vec3 c0 = vec3(0.1, 0.18, 0.22);  // Dark teal
    vec3 c1 = vec3(0.15, 0.12, 0.25); // Muted purple
    vec3 c2 = vec3(0.08, 0.15, 0.2);  // Dark cyan
    vec3 c3 = vec3(0.2, 0.1, 0.15);   // Dusty mauve
    vec3 c4 = vec3(0.12, 0.2, 0.18);  // Swamp green
    
    vec3 col;
    if(t < 0.25) col = mix(c0, c1, t * 4.0);
    else if(t < 0.5) col = mix(c1, c2, (t - 0.25) * 4.0);
    else if(t < 0.75) col = mix(c2, c3, (t - 0.5) * 4.0);
    else col = mix(c3, c4, (t - 0.75) * 4.0);
    
    return col;
}

// Accent color for highlights - cold and sharp
vec3 accentColor(float t) {
    t = fract(t);
    vec3 col;
    if(t < 0.5) {
        col = mix(vec3(0.3, 0.5, 0.55), vec3(0.4, 0.25, 0.5), t * 2.0);
    } else {
        col = mix(vec3(0.4, 0.25, 0.5), vec3(0.3, 0.5, 0.55), (t - 0.5) * 2.0);
    }
    return col;
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    float t = u_time;
    
    // Animation cycle: 12 seconds up, 12 seconds down = 24 second cycle
    float cycleTime = 24.0;
    float phase = mod(t, cycleTime);
    float buildProgress;
    
    if (phase < cycleTime * 0.5) {
        // Building up (0 to 12 seconds)
        buildProgress = phase / (cycleTime * 0.5);
    } else {
        // Building down (12 to 24 seconds)
        buildProgress = 1.0 - (phase - cycleTime * 0.5) / (cycleTime * 0.5);
    }
    buildProgress = buildProgress * buildProgress * (3.0 - 2.0 * buildProgress);
    uv *= rot(t * 0.05);
    
    // Subtle breathing
    float breathe = 1.0 + 0.03 * sin(t * 0.3);
    uv *= breathe;
    
    float r = 0.12;
    float r2 = r * 2.0;
    float r3 = r * 2.0 * sqrt(3.0);
    
    // 13 circle centers
    vec2 c0 = vec2(0.0);
    vec2 c1 = vec2(cos(0.0), sin(0.0)) * r2;
    vec2 c2 = vec2(cos(TAU/6.0), sin(TAU/6.0)) * r2;
    vec2 c3 = vec2(cos(TAU/3.0), sin(TAU/3.0)) * r2;
    vec2 c4 = vec2(cos(TAU/2.0), sin(TAU/2.0)) * r2;
    vec2 c5 = vec2(cos(TAU*2.0/3.0), sin(TAU*2.0/3.0)) * r2;
    vec2 c6 = vec2(cos(TAU*5.0/6.0), sin(TAU*5.0/6.0)) * r2;
    
    vec2 c7 = vec2(cos(PI/6.0), sin(PI/6.0)) * r3;
    vec2 c8 = vec2(cos(PI/2.0), sin(PI/2.0)) * r3;
    vec2 c9 = vec2(cos(PI*5.0/6.0), sin(PI*5.0/6.0)) * r3;
    vec2 c10 = vec2(cos(PI*7.0/6.0), sin(PI*7.0/6.0)) * r3;
    vec2 c11 = vec2(cos(PI*3.0/2.0), sin(PI*3.0/2.0)) * r3;
    vec2 c12 = vec2(cos(PI*11.0/6.0), sin(PI*11.0/6.0)) * r3;
    
    vec2 centers[13];
    centers[0] = c0; centers[1] = c1; centers[2] = c2; centers[3] = c3;
    centers[4] = c4; centers[5] = c5; centers[6] = c6; centers[7] = c7;
    centers[8] = c8; centers[9] = c9; centers[10] = c10; centers[11] = c11;
    centers[12] = c12;
    
    float circleOpacity[13];
    circleOpacity[0] = smoothPhase(buildProgress, 0.0, 0.12);
    
    // Inner ring (circles 1-6) - staggered
    circleOpacity[1] = smoothPhase(buildProgress, 0.10, 0.20);
    circleOpacity[2] = smoothPhase(buildProgress, 0.14, 0.24);
    circleOpacity[3] = smoothPhase(buildProgress, 0.18, 0.28);
    circleOpacity[4] = smoothPhase(buildProgress, 0.22, 0.32);
    circleOpacity[5] = smoothPhase(buildProgress, 0.26, 0.36);
    circleOpacity[6] = smoothPhase(buildProgress, 0.30, 0.40);
    
    // Outer ring (circles 7-12) - staggered
    circleOpacity[7] = smoothPhase(buildProgress, 0.35, 0.45);
    circleOpacity[8] = smoothPhase(buildProgress, 0.39, 0.49);
    circleOpacity[9] = smoothPhase(buildProgress, 0.43, 0.53);
    circleOpacity[10] = smoothPhase(buildProgress, 0.47, 0.57);
    circleOpacity[11] = smoothPhase(buildProgress, 0.51, 0.61);
    circleOpacity[12] = smoothPhase(buildProgress, 0.55, 0.65);
    
    // Line animation phases
    float innerHexOpacity = smoothPhase(buildProgress, 0.50, 0.65);
    float spokesOpacity = smoothPhase(buildProgress, 0.55, 0.70);
    float outerHexOpacity = smoothPhase(buildProgress, 0.60, 0.75);
    float innerOuterOpacity = smoothPhase(buildProgress, 0.70, 0.85);
    float starOpacity = smoothPhase(buildProgress, 0.75, 0.90);
    float crossOpacity = smoothPhase(buildProgress, 0.85, 1.0);
    
    float radial = length(uv);
    float angle = atan(uv.y, uv.x);
    
    // === DARK BACKGROUND ===
    vec3 bg = vec3(0.02, 0.025, 0.03);
    
    // Subtle murky noise
    float n = noise(uv * 4.0 + t * 0.1);
    bg += vec3(0.01, 0.015, 0.02) * n;
    
    // Dark radial gradient
    bg *= 1.0 - radial * 0.3;
    
    vec3 col = bg;
    
    // === STYLIZED CIRCLE OUTLINES ===
    float lineWidth = 0.003;
    float circleGlow = 0.0;
    
    for(int i = 0; i < 13; i++) {
        float d = sdCircle(uv, centers[i], r);
        
        // Sharp stylized line with soft outer glow
        float sharp = smoothstep(lineWidth, 0.0, d);
        float soft = lineWidth * 2.0 / (d + lineWidth * 2.0);
        
        float pulse = 0.8 + 0.2 * sin(t * 2.0 + float(i) * 0.5);
        circleGlow += (sharp * 0.7 + soft * 0.3) * pulse * circleOpacity[i];
    }
    
    // === STYLIZED LINE CONNECTIONS ===
    float lineGlow = 0.0;
    
    // Helper macro with opacity parameter
    #define GLOW_LINE(a, b, w, op) { \
        float d = sdLine(uv, a, b); \
        float sharp = smoothstep(w, 0.0, d); \
        float soft = w * 1.5 / (d + w * 1.5); \
        lineGlow += (sharp * 0.6 + soft * 0.4) * (0.7 + 0.3 * sin(t * 1.5 + length(a+b))) * op; \
    }
    
    // Outer hexagon
    GLOW_LINE(c7, c8, lineWidth, outerHexOpacity)
    GLOW_LINE(c8, c9, lineWidth, outerHexOpacity)
    GLOW_LINE(c9, c10, lineWidth, outerHexOpacity)
    GLOW_LINE(c10, c11, lineWidth, outerHexOpacity)
    GLOW_LINE(c11, c12, lineWidth, outerHexOpacity)
    GLOW_LINE(c12, c7, lineWidth, outerHexOpacity)
    
    // Star triangles
    GLOW_LINE(c7, c9, lineWidth, starOpacity)
    GLOW_LINE(c9, c11, lineWidth, starOpacity)
    GLOW_LINE(c11, c7, lineWidth, starOpacity)
    GLOW_LINE(c8, c10, lineWidth, starOpacity)
    GLOW_LINE(c10, c12, lineWidth, starOpacity)
    GLOW_LINE(c12, c8, lineWidth, starOpacity)
    
    // Cross lines
    GLOW_LINE(c7, c10, lineWidth, crossOpacity)
    GLOW_LINE(c8, c11, lineWidth, crossOpacity)
    GLOW_LINE(c9, c12, lineWidth, crossOpacity)
    
    // Center spokes
    float spokeWidth = lineWidth * 0.6;
    GLOW_LINE(c0, c7, spokeWidth, spokesOpacity)
    GLOW_LINE(c0, c8, spokeWidth, spokesOpacity)
    GLOW_LINE(c0, c9, spokeWidth, spokesOpacity)
    GLOW_LINE(c0, c10, spokeWidth, spokesOpacity)
    GLOW_LINE(c0, c11, spokeWidth, spokesOpacity)
    GLOW_LINE(c0, c12, spokeWidth, spokesOpacity)
    
    // Inner hexagon
    float innerWidth = lineWidth * 0.5;
    GLOW_LINE(c1, c2, innerWidth, innerHexOpacity)
    GLOW_LINE(c2, c3, innerWidth, innerHexOpacity)
    GLOW_LINE(c3, c4, innerWidth, innerHexOpacity)
    GLOW_LINE(c4, c5, innerWidth, innerHexOpacity)
    GLOW_LINE(c5, c6, innerWidth, innerHexOpacity)
    GLOW_LINE(c6, c1, innerWidth, innerHexOpacity)
    
    // Inner to outer
    GLOW_LINE(c1, c7, innerWidth, innerOuterOpacity)
    GLOW_LINE(c1, c12, innerWidth, innerOuterOpacity)
    GLOW_LINE(c2, c7, innerWidth, innerOuterOpacity)
    GLOW_LINE(c2, c8, innerWidth, innerOuterOpacity)
    GLOW_LINE(c3, c8, innerWidth, innerOuterOpacity)
    GLOW_LINE(c3, c9, innerWidth, innerOuterOpacity)
    GLOW_LINE(c4, c9, innerWidth, innerOuterOpacity)
    GLOW_LINE(c4, c10, innerWidth, innerOuterOpacity)
    GLOW_LINE(c5, c10, innerWidth, innerOuterOpacity)
    GLOW_LINE(c5, c11, innerWidth, innerOuterOpacity)
    GLOW_LINE(c6, c11, innerWidth, innerOuterOpacity)
    GLOW_LINE(c6, c12, innerWidth, innerOuterOpacity)
    
    // === APPLY COLORS ===
    
    // Circles - cold teal/cyan tint
    vec3 circleCol = accentColor(t * 0.05 + radial * 0.3);
    col += circleGlow * circleCol * 0.6;
    
    // Lines - slightly different hue, muted purple
    vec3 lineCol = accentColor(t * 0.05 + 0.3 + radial * 0.2);
    col += lineGlow * lineCol * 0.4;
    
    // === DARK ENERGY PULSES ===
    float pulseIntensity = buildProgress * 0.3;
    for(int i = 0; i < 4; i++) {
        float fi = float(i);
        float pulseTime = mod(t * 0.4 + fi * 0.5, 3.0);
        float pulseR = pulseTime * 0.25;
        float pulse = exp(-abs(radial - pulseR) * 10.0);
        pulse *= 1.0 - pulseTime / 3.0;
        pulse *= pulseIntensity;
        col += pulse * gloomyPalette(fi * 0.25 + t * 0.02);
    }
    
    // === NODE POINTS - subtle highlights ===
    for(int i = 0; i < 13; i++) {
        float d = length(uv - centers[i]);
        float node = 0.008 / (d + 0.008);
        node = pow(node, 2.0);
        node *= 0.6 + 0.4 * sin(t * 1.5 + float(i) * 0.7);
        node *= circleOpacity[i];
        col += node * accentColor(float(i) / 13.0) * 0.2;
    }
    
    // === CENTER GLOW - dim and cold ===
    float centerGlow = 0.04 / (radial + 0.04);
    centerGlow = pow(centerGlow, 2.5);
    centerGlow *= 0.7 + 0.3 * sin(t * 0.8);
    centerGlow *= circleOpacity[0];
    col += centerGlow * vec3(0.15, 0.25, 0.3) * 0.3;
    
    // === SPARSE PARTICLES ===
    float particleIntensity = buildProgress;
    for(int i = 0; i < 15; i++) {
        float fi = float(i);
        float pAngle = fi * PHI * TAU + t * 0.1;
        float pDist = mod(fi * 0.12 + t * 0.08, 0.6);
        vec2 pPos = vec2(cos(pAngle), sin(pAngle)) * pDist;
        
        float particle = 0.001 / (length(uv - pPos) + 0.001);
        particle = pow(particle, 1.8);
        particle *= 0.3 + 0.7 * sin(t * 1.5 + fi * 3.0);
        
        col += particle * accentColor(fi / 15.0) * 0.08 * particleIntensity;
    }
    
    // === POST PROCESSING - DARK STYLIZED ===
    
    // Subtle vignette
    float vig = 1.0 - 0.5 * pow(radial, 2.0);
    col *= vig;
    
    // Crush blacks slightly
    col = max(col - 0.02, 0.0);
    
    // Matte tone mapping
    col = col / (col + 0.4);
    
    // Desaturate for gloomy feel
    float luma = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luma), col, 0.7);
    
    // Slight contrast boost
    col = pow(col, vec3(1.1));
    
    // Very subtle grain
    col += (hash(uv + fract(t)) - 0.5) * 0.015;
    
    gl_FragColor = vec4(col, 1.0);
}
