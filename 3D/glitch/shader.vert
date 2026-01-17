#version 450

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inUV;

layout(location = 0) out vec3 fragPos;
layout(location = 1) out vec3 fragNormal;
layout(location = 2) out vec2 fragUV;
layout(location = 3) out float fragGlow;

layout(push_constant) uniform PushConstants {
    mat4 mvp;
    vec4 color;
    float time;
} pc;

void main() {
    vec3 pos = inPosition;

    // Subtle vertex breathing - gentle organic swell
    float breathe = sin(pc.time * 1.5 + pos.y * 2.0) * 0.015;
    pos *= 1.0 + breathe;

    gl_Position = pc.mvp * vec4(pos, 1.0);
    fragPos = pos;
    fragNormal = inNormal;
    fragUV = inUV;

    // Glow intensity based on vertex height
    fragGlow = smoothstep(-0.5, 0.5, pos.y);
}
