#define PI 3.14159265359
#define TAU 6.28318530718
#define PHI 1.61803398875

mat2 rot(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec3 palette1(float t) {
    vec3 a = vec3(0.12, 0.08, 0.18);
    vec3 b = vec3(0.4, 0.35, 0.3);
    vec3 c = vec3(0.6, 0.8, 0.7);
    vec3 d = vec3(0.85, 0.25, 0.6);
    return a + b * cos(TAU * (c * t + d));
}

vec3 palette2(float t) {
    vec3 a = vec3(0.15, 0.1, 0.08);
    vec3 b = vec3(0.45, 0.3, 0.35);
    vec3 c = vec3(0.7, 0.5, 0.3);
    vec3 d = vec3(0.1, 0.7, 0.85);
    return a + b * cos(TAU * (c * t + d));
}

vec3 palette3(float t) {
    vec3 a = vec3(0.08, 0.18, 0.2);
    vec3 b = vec3(0.3, 0.35, 0.4);
    vec3 c = vec3(0.9, 0.6, 0.5);
    vec3 d = vec3(0.7, 0.85, 0.95);
    return a + b * cos(TAU * (c * t + d));
}

vec3 dmtColor(float t, vec2 p, float time) {
    float zone = sin(length(p) * 2.5 + time * 0.15) * 0.5 + 0.5;
    float zone2 = sin(atan(p.y, p.x) * 1.5 + time * 0.08) * 0.5 + 0.5;
    
    vec3 c1 = palette1(t);
    vec3 c2 = palette2(t + 0.33);
    vec3 c3 = palette3(t + 0.66);
    
    vec3 col = mix(c1, c2, zone);
    col = mix(col, c3, zone2 * 0.6);
    
    return col;
}

vec2 kaleido(vec2 p, float segments) {
    float angle = TAU / segments;
    float a = atan(p.y, p.x);
    a = mod(a, angle);
    a = abs(a - angle * 0.5);
    return length(p) * vec2(cos(a), sin(a));
}

vec2 spiral(vec2 p, float twist, float expansion) {
    float r = length(p);
    float a = atan(p.y, p.x);
    a += twist * r;
    r = pow(r, expansion);
    return vec2(cos(a), sin(a)) * r;
}

float meshPattern(vec2 p, float scale, float time) {
    p *= scale;
    p += vec2(sin(p.y * 1.5 + time), cos(p.x * 1.5 + time)) * 0.15;
    
    vec2 g = abs(fract(p) - 0.5);
    float lines = min(g.x, g.y);
    
    vec2 pg = p * rot(PI * 0.25);
    vec2 g2 = abs(fract(pg) - 0.5);
    lines = min(lines, min(g2.x, g2.y));
    
    return lines;
}

float lacePattern(vec2 p, float scale, float time) {
    float d = 1.0;
    
    for(int i = 0; i < 4; i++) {
        float fi = float(i);
        vec2 q = p * scale * (1.0 + fi * 0.4);
        q *= rot(time * 0.08 * (fi + 1.0));
        
        float a = atan(q.y, q.x);
        float r = length(q);
        float petals = sin(a * (5.0 + fi * 2.0) + time * 0.5 + fi) * 0.25 + 0.65;
        float flower = abs(r - petals * (0.25 - fi * 0.04));
        
        d = min(d, flower);
    }
    
    return d;
}

float hexLattice(vec2 p, float scale) {
    p *= scale;
    vec2 r = vec2(1.0, 1.732);
    vec2 h = r * 0.5;
    vec2 a = mod(p, r) - h;
    vec2 b = mod(p - h, r) - h;
    return min(dot(a, a), dot(b, b));
}

float entityFace(vec2 p, float time) {
    float d = 1.0;
    
    p.x = abs(p.x);
    
    vec2 faceP = p * vec2(1.2, 1.0);
    float face = length(faceP) - 0.35;
    
    vec2 crownP = p - vec2(0.0, 0.25);
    crownP.y *= 0.7;
    float crown = length(crownP) - 0.2;
    face = min(face, crown);
    
    vec2 eyeP = p - vec2(0.12, 0.08);
    eyeP *= rot(0.2);
    eyeP *= vec2(1.0, 2.0);
    float eye = length(eyeP) - 0.06;
    
    vec2 pupilP = p - vec2(0.12, 0.08);
    float pupil = length(pupilP) - 0.025;
    
    vec2 thirdEyeP = p - vec2(0.0, 0.22);
    float thirdEye = length(thirdEyeP) - 0.04;
    
    vec2 noseP = p - vec2(0.0, -0.02);
    noseP.x *= 3.0;
    float nose = length(noseP) - 0.02;
    
    vec2 mouthP = p - vec2(0.0, -0.18);
    mouthP *= vec2(1.5, 1.0);
    float mouth = length(mouthP) - 0.08;
    
    d = face;
    
    return d;
}

float entityEyes(vec2 p, float time) {
    p.x = abs(p.x);
    
    vec2 eyeP = p - vec2(0.11, 0.06);
    eyeP *= rot(0.15);
    
    float r = length(eyeP * vec2(1.0, 2.5));
    float eye = smoothstep(0.08, 0.06, r);
    
    float pupil = smoothstep(0.03, 0.02, length(eyeP));
    
    vec2 thirdP = p - vec2(0.0, 0.2);
    float third = smoothstep(0.05, 0.03, length(thirdP));
    
    float rings = 0.0;
    for(int i = 0; i < 3; i++) {
        float fi = float(i);
        float ringR = 0.04 + fi * 0.025;
        rings += smoothstep(0.008, 0.0, abs(length(eyeP) - ringR)) * (1.0 - fi * 0.2);
        rings += smoothstep(0.006, 0.0, abs(length(thirdP) - ringR * 1.2)) * (1.0 - fi * 0.15);
    }
    
    return eye + pupil * 2.0 + third + rings * 0.5;
}

float fractalPattern(vec2 p, float time) {
    float pattern = 0.0;
    float scale = 1.0;
    float intensity = 1.0;
    
    for(int i = 0; i < 5; i++) {
        float fi = float(i);
        
        vec2 kp = kaleido(p * scale, 6.0 + fi * 2.0);
        kp *= rot(time * 0.08 * (1.0 + fi * 0.2));
        kp = spiral(kp, sin(time * 0.15 + fi) * 0.4, 1.0 + sin(time * 0.08) * 0.08);
        
        float mesh = meshPattern(kp, 2.5 + fi, time);
        float lace = lacePattern(kp, 1.8 + fi * 0.4, time);
        float hex = hexLattice(kp, 3.5 + fi * 1.5);
        
        pattern += smoothstep(0.08, 0.0, mesh) * intensity;
        pattern += smoothstep(0.04, 0.0, lace) * intensity * 0.6;
        pattern += smoothstep(0.015, 0.0, hex) * intensity * 0.25;
        
        scale *= 1.7;
        intensity *= 0.55;
    }
    
    return pattern;
}

float borderSpirals(vec2 p, float time) {
    float d = 0.0;
    
    for(int corner = 0; corner < 4; corner++) {
        float fc = float(corner);
        vec2 cornerPos = vec2(
            (mod(fc, 2.0) - 0.5) * 1.4,
            (floor(fc / 2.0) - 0.5) * 0.9
        );
        
        vec2 cp = p - cornerPos;
        float cornerDist = length(cp);
        
        float angle = atan(cp.y, cp.x);
        for(int arm = 0; arm < 3; arm++) {
            float fa = float(arm);
            float spiralAngle = angle + fa * TAU / 3.0 + cornerDist * 5.0 - time * 0.4;
            float spiralLine = abs(sin(spiralAngle * 3.0)) * cornerDist;
            d += smoothstep(0.04, 0.0, spiralLine) * smoothstep(0.7, 0.15, cornerDist);
        }
    }
    
    return d;
}

float wingPatterns(vec2 p, float time) {
    float d = 0.0;
    
    for(int side = 0; side < 2; side++) {
        float s = side == 0 ? -1.0 : 1.0;
        vec2 wp = p - vec2(s * 0.55, -0.08);
        
        for(int f = 0; f < 7; f++) {
            float ff = float(f);
            float featherAngle = s * (0.25 + ff * 0.12);
            vec2 fp = wp * rot(featherAngle);
            fp.x *= 0.25;
            
            float featherY = fp.y + 0.04 * ff;
            float feather = abs(fp.x) + abs(featherY * 0.4);
            feather = abs(feather - 0.08 - ff * 0.025);
            
            d += smoothstep(0.015, 0.0, feather) * (1.0 - ff * 0.12);
        }
    }
    
    return d;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    
    float time = iTime;
    float buildUp = smoothstep(0.0, 8.0, time);
    
    vec2 p = uv;
    float breathe = 1.0 + sin(time * 0.4) * 0.02;
    p *= breathe;
    p *= rot(sin(time * 0.08) * 0.04);
    
    // === DARK BASE ===
    float bgAngle = atan(uv.y, uv.x);
    float bgDist = length(uv);
    vec3 col = vec3(0.015, 0.01, 0.025);
    
    col += palette1(bgAngle / TAU + time * 0.03) * 0.03 * smoothstep(0.2, 0.6, bgDist);
    
    // === LAYER 1: Background mesh ===
    float bgBuild = smoothstep(0.0, 2.0, time);
    vec2 meshP = p * rot(time * 0.03);
    float bgMesh = meshPattern(meshP, 6.0, time * 0.4);
    float meshLine = smoothstep(0.035, 0.0, bgMesh);
    vec3 meshCol = dmtColor(length(meshP) * 1.5 + time * 0.08, meshP, time);
    col += meshCol * meshLine * 0.12 * bgBuild * smoothstep(0.15, 0.4, bgDist);
    
    // === LAYER 2: Kaleidoscopic fractal ===
    float fractalBuild = smoothstep(0.5, 4.0, time);
    vec2 kp = kaleido(p, 6.0);
    kp *= rot(time * 0.07);
    kp = spiral(kp, 0.8 + sin(time * 0.2) * 0.3, 1.0);
    
    float fractal = fractalPattern(kp, time);
    vec3 fractalCol = dmtColor(fractal * 0.4 + time * 0.06 + length(kp) * 0.8, kp, time);
    float centerMask = smoothstep(0.1, 0.35, length(p));
    col += fractalCol * fractal * 0.22 * fractalBuild * (0.4 + centerMask * 0.6);
    
    // === LAYER 3: Secondary spiral layer ===
    float spiral2Build = smoothstep(2.0, 5.0, time);
    vec2 sp2 = kaleido(p * 1.3, 8.0);
    sp2 *= rot(-time * 0.1);
    sp2 = spiral(sp2, -1.5, 0.95);
    
    float spiral2 = lacePattern(sp2, 2.5, time);
    vec3 spiral2Col = palette2(spiral2 * 1.5 + time * 0.1);
    col += spiral2Col * smoothstep(0.06, 0.0, spiral2) * 0.18 * spiral2Build * (0.5 + centerMask * 0.5);
    
    // === LAYER 4: Border spirals ===
    float borderBuild = smoothstep(1.0, 4.0, time);
    float borders = borderSpirals(p, time);
    vec3 borderCol = dmtColor(borders + time * 0.12 + length(p) * 0.6, p, time);
    col += borderCol * borders * 0.3 * borderBuild;
    
    // === LAYER 5: Wing patterns ===
    float wingBuild = smoothstep(3.0, 6.0, time);
    float wings = wingPatterns(p, time);
    vec3 wingCol = palette3(wings * 0.25 + p.y * 1.5 + time * 0.08);
    col += wingCol * wings * 0.35 * wingBuild;
    
    // === LAYER 6: Central entity ===
    float entityBuild = smoothstep(5.0, 9.0, time);
    vec2 faceP = p * 1.15;
    faceP.y += 0.03;
    
    float faceAura = entityFace(faceP, time);
    float auraGlow = smoothstep(0.12, -0.08, faceAura);
    vec3 auraCol = palette1(faceAura * 2.0 + time * 0.15);
    col += auraCol * auraGlow * 0.15 * entityBuild;
    
    float faceLines = smoothstep(0.018, 0.0, abs(faceAura));
    vec3 faceLineCol = palette3(time * 0.08 + faceP.y * 0.8);
    col += faceLineCol * faceLines * 0.5 * entityBuild;
    
    float eyes = entityEyes(faceP, time);
    vec3 eyeCol = mix(vec3(0.1, 0.5, 0.45), vec3(0.7, 0.35, 0.12), sin(time * 2.0) * 0.4 + 0.5);
    col += eyeCol * eyes * 0.35 * entityBuild;
    
    // === LAYER 7: Radiating lines ===
    float rayBuild = smoothstep(2.0, 5.0, time);
    float rays = 0.0;
    for(int i = 0; i < 18; i++) {
        float fi = float(i);
        float rayAngle = fi * TAU / 18.0 + time * 0.06;
        vec2 rayDir = vec2(cos(rayAngle), sin(rayAngle));
        float rayDist = abs(dot(p, vec2(-rayDir.y, rayDir.x)));
        rays += smoothstep(0.006, 0.0, rayDist) * smoothstep(0.7, 0.25, length(p)) * smoothstep(0.12, 0.2, length(p));
    }
    vec3 rayCol = palette2(rays * 0.3 + time * 0.1);
    col += rayCol * rays * 0.12 * rayBuild;
    
    // === LAYER 8: Fine hex overlay ===
    float hexBuild = smoothstep(6.0, 10.0, time);
    vec2 detailP = kaleido(p * 2.5, 12.0);
    detailP *= rot(time * 0.12);
    float detail = hexLattice(detailP, 8.0);
    float detailLine = smoothstep(0.008, 0.0, detail);
    col += palette1(detail * 3.0 + time * 0.12) * detailLine * 0.1 * hexBuild * centerMask;
    
    // === LAYER 9: Energy waves ===
    float waveBuild = smoothstep(4.0, 8.0, time);
    float waves = 0.0;
    for(int i = 0; i < 4; i++) {
        float fi = float(i);
        float waveR = mod(fi * 0.25 + time * 0.2, 1.2) * 0.8;
        float wave = abs(length(p) - waveR);
        waves += smoothstep(0.025, 0.0, wave) * (1.0 - waveR / 1.0) * 0.7;
    }
    col += palette3(waves * 1.5 + time * 0.15) * waves * 0.2 * waveBuild;
    
    // === LAYER 10: Particles ===
    float particleBuild = smoothstep(3.0, 7.0, time);
    float particles = 0.0;
    for(int i = 0; i < 35; i++) {
        float fi = float(i);
        float angle = fi * PHI * TAU;
        float radius = 0.15 + mod(fi * 0.08 + time * 0.06, 0.75);
        vec2 particlePos = vec2(cos(angle + time * 0.15), sin(angle + time * 0.15)) * radius;
        particlePos *= rot(fi * 0.3);
        
        float particle = length(p - particlePos);
        particles += smoothstep(0.012, 0.004, particle);
    }
    vec3 particleCol = mix(vec3(0.15, 0.65, 0.6), vec3(0.85, 0.4, 0.15), sin(time * 0.8 + particles) * 0.5 + 0.5);
    col += particleCol * particles * 0.35 * particleBuild;
    
    // === POST PROCESSING ===
    
    float centerDarken = smoothstep(0.3, 0.0, length(uv));
    col *= 1.0 - centerDarken * 0.3;
    
    col = pow(col, vec3(1.05));
    
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(lum), col, 1.4);
    
    float vignette = 1.0 - length(uv) * 0.6;
    vignette = smoothstep(0.0, 0.9, vignette);
    col *= vignette;
    
    col += max(col - 0.6, 0.0) * 0.2;
    
    col = col / (col + 0.45) * 1.15;
    
    col = max(col, vec3(0.008, 0.005, 0.012));
    
    col = pow(col, vec3(1.0 / 2.2));
    
    col = clamp(col, 0.0, 1.0);
    
    fragColor = vec4(col, 1.0);
}
