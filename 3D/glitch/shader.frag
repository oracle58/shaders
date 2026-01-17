#version 450

layout(location = 0) in vec3 fragPos;
layout(location = 1) in vec3 fragNormal;
layout(location = 2) in vec2 fragUV;
layout(location = 3) in float fragGlow;

layout(location = 0) out vec4 outColor;

layout(push_constant) uniform PushConstants {
    mat4 mvp;
    vec4 color;
    float time;
} pc;

void main() {
    float t = pc.time;
    vec3 baseColor = pc.color.rgb;

    // Soft directional lighting
    vec3 lightDir = normalize(vec3(0.3, 1.0, 0.4));
    vec3 normal = normalize(fragNormal);
    float diffuse = max(dot(normal, lightDir), 0.0);

    // Soft ambient and diffuse
    float ambient = 0.25;
    float lighting = ambient + diffuse * 0.65;

    // Fresnel edge glow (rim lighting)
    vec3 viewDir = normalize(vec3(0.0, 0.3, 1.0));
    float fresnel = 1.0 - max(dot(normal, viewDir), 0.0);
    fresnel = pow(fresnel, 2.5);

    // Vaporwave gradient based on position
    float gradientT = (fragPos.y + 1.0) * 0.5;
    vec3 gradientLow = vec3(0.3, 0.0, 0.5);   // Deep purple
    vec3 gradientHigh = vec3(1.0, 0.5, 0.8);  // Pink
    vec3 gradient = mix(gradientLow, gradientHigh, gradientT);

    // Blend base color with gradient
    vec3 surfaceColor = mix(baseColor, gradient, 0.25);

    // Apply lighting
    vec3 litColor = surfaceColor * lighting;

    // Chromatic aberration inspired color split on edges
    vec3 edgeColor = vec3(0.4, 0.9, 1.0);  // Cyan edge
    litColor += edgeColor * fresnel * 0.5;

    // Soft pulsing glow
    float pulse = sin(t * 2.0) * 0.5 + 0.5;
    float glowIntensity = fragGlow * pulse * 0.15;
    litColor += baseColor * glowIntensity;

    // Subtle color shift over time
    float colorShift = sin(t * 0.5 + fragPos.x * 2.0) * 0.05;
    litColor.r += colorShift;
    litColor.b -= colorShift;

    // Very subtle scanlines (optional vaporwave touch)
    float scanline = 0.97 + 0.03 * sin(gl_FragCoord.y * 0.8);
    litColor *= scanline;

    // Soft vignette
    vec2 screenUV = gl_FragCoord.xy / vec2(1280.0, 720.0);
    vec2 vigUV = screenUV * 2.0 - 1.0;
    float vig = 1.0 - dot(vigUV * 0.3, vigUV * 0.3);
    litColor *= vig;

    // Boost saturation slightly
    float luma = dot(litColor, vec3(0.299, 0.587, 0.114));
    litColor = mix(vec3(luma), litColor, 1.15);

    // Gentle tone mapping
    litColor = litColor / (litColor + vec3(1.0));
    litColor = pow(litColor, vec3(0.95));

    outColor = vec4(litColor, 1.0);
}
