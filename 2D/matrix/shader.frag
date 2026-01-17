#version 450

layout(location = 0) in vec3 fragNormal;  // Match vertex shader output
layout(location = 1) in vec2 fragUV;
layout(location = 0) out vec4 outColor;

layout(push_constant) uniform PushConstants {
    mat4 mvp;
    vec4 color;
    float time;
} pc;

// Pseudo-random function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float hash1(float p) {
    return fract(sin(p * 127.1) * 43758.5453);
}

// 4x5 bitmap font for hex digits (0-9, A-F)
float getHexDigit(int digit, vec2 p) {
    if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0) return 0.0;

    int x = int(p.x * 3.0);
    int y = int((1.0 - p.y) * 5.0);

    // Bitmap patterns for hex digits (3x5 grid encoded as bits)
    int patterns[16] = int[16](
        0x7B6F,  // 0: 111 101 101 101 111
        0x2C97,  // 1: 010 110 010 010 111
        0x73E7,  // 2: 111 001 111 100 111
        0x73CF,  // 3: 111 001 111 001 111
        0x5BC9,  // 4: 101 101 111 001 001
        0x79CF,  // 5: 111 100 111 001 111
        0x79EF,  // 6: 111 100 111 101 111
        0x7249,  // 7: 111 001 010 010 010
        0x7BEF,  // 8: 111 101 111 101 111
        0x7BCF,  // 9: 111 101 111 001 111
        0x7BED,  // A: 111 101 111 101 101
        0x4F6E,  // B: 100 111 101 101 110
        0x7924,  // C: 111 100 100 100 111
        0x6B6E,  // D: 110 101 101 101 110
        0x79E7,  // E: 111 100 111 100 111
        0x79E4   // F: 111 100 111 100 100
    );

    int bit = y * 3 + x;
    return float((patterns[digit] >> bit) & 1);
}

void main() {
    vec2 uv = fragUV;
    float t = pc.time;

    // Grid parameters
    float cols = 60.0;
    float rows = 35.0;
    float cellW = 1.0 / cols;
    float cellH = 1.0 / rows;

    // Which cell are we in
    vec2 cell = floor(uv * vec2(cols, rows));
    vec2 cellUV = fract(uv * vec2(cols, rows));

    // Glitch offset - horizontal tear
    float glitchLine = floor(hash(vec2(floor(t * 8.0), 0.0)) * rows);
    float glitchStrength = step(0.92, hash(vec2(t * 3.0, cell.y)));
    if (abs(cell.y - glitchLine) < 2.0 && hash(vec2(t * 15.0, 1.0)) > 0.7) {
        cell.x += floor((hash(vec2(cell.y, floor(t * 12.0))) - 0.5) * 10.0);
        glitchStrength = 1.0;
    }

    // Column-based scrolling speed (each column scrolls at different rate)
    float colSeed = hash(vec2(cell.x, 0.0));
    float scrollSpeed = 1.5 + colSeed * 4.0;
    float scroll = t * scrollSpeed;

    // Column brightness variation (some columns brighter = "active")
    float colBrightness = 0.3 + 0.7 * pow(hash(vec2(cell.x, floor(t * 0.5))), 2.0);

    // Random character at this cell (changes with scroll)
    float charSeed = hash(vec2(cell.x, cell.y + floor(scroll)));
    int hexDigit = int(charSeed * 16.0);

    // Head of the stream (brightest)
    float streamPos = fract(scroll + colSeed);
    float distFromHead = abs(fract(cell.y / rows + colSeed * 0.3) - streamPos);
    float headGlow = smoothstep(0.15, 0.0, distFromHead);

    // Fade out based on position in stream
    float fade = 1.0 - smoothstep(0.0, 0.5, distFromHead);
    fade *= fade;

    // Get character pixel
    vec2 charUV = cellUV * vec2(0.7, 0.8) + vec2(0.15, 0.1);
    float pixel = getHexDigit(hexDigit, charUV);

    // Random character flicker
    float flicker = step(0.97, hash(vec2(cell.x + cell.y, floor(t * 20.0))));
    if (flicker > 0.5) {
        hexDigit = int(hash(vec2(cell.x, t * 30.0)) * 16.0);
        pixel = getHexDigit(hexDigit, charUV);
    }

    // Color: green matrix style with white head
    vec3 green = vec3(0.0, 0.9, 0.3);
    vec3 white = vec3(0.85, 1.0, 0.9);
    vec3 charColor = mix(green, white, headGlow * 0.8);

    // Apply brightness and fade
    float brightness = pixel * fade * colBrightness;
    brightness += headGlow * pixel * 0.5;

    // Glitch color aberration
    if (glitchStrength > 0.5) {
        brightness *= 1.5;
        charColor.r += 0.3;
    }

    // Scanline effect
    float scanline = 0.9 + 0.1 * sin(uv.y * rows * 3.14159 * 2.0);
    brightness *= scanline;

    // CRT vignette
    vec2 vignetteUV = uv * 2.0 - 1.0;
    float vignette = 1.0 - dot(vignetteUV * 0.5, vignetteUV * 0.5);
    brightness *= vignette;

    // Background glow
    float bgGlow = 0.02 * fade * colBrightness;

    vec3 finalColor = charColor * brightness + vec3(0.0, 0.05, 0.02) * bgGlow;

    // Subtle noise
    finalColor += (hash(uv + t) - 0.5) * 0.02;

    outColor = vec4(finalColor, 1.0);
}
