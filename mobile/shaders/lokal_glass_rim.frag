// Specular rim for LokalGlass: light catching the edge of the glass.
//
// Ported from Kyant0/backdrop's default highlight
// (https://github.com/Kyant0/AndroidLiquidGlass, Copyright 2025 Kyant,
// Apache License 2.0). Drawn as the shader of a thin stroke along the shape;
// the rim is brightest where its normal faces the light, and its opposite.

#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform float u_radius;
uniform vec4 u_color;
// Light direction in radians (screen space, y down) and how sharply the
// brightness falls off away from it.
uniform float u_angle;
uniform float u_falloff;

out vec4 frag_color;

vec2 gradSdRoundedRect(vec2 coord, vec2 halfSize, float radius) {
    vec2 cornerCoord = abs(coord) - (halfSize - vec2(radius));
    if (cornerCoord.x >= 0.0 || cornerCoord.y >= 0.0) {
        return sign(coord) * normalize(max(cornerCoord, 0.0) + 1e-5);
    }
    float gradX = step(cornerCoord.y, cornerCoord.x);
    return sign(coord) * vec2(gradX, 1.0 - gradX);
}

void main() {
    vec2 halfSize = u_size * 0.5;
    vec2 centered = FlutterFragCoord().xy - halfSize;
    float radius = min(u_radius, min(halfSize.x, halfSize.y));
    float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
    vec2 grad = gradSdRoundedRect(centered, halfSize, gradRadius);
    float d = dot(grad, vec2(cos(u_angle), sin(u_angle)));
    float intensity = pow(abs(d), u_falloff);
    frag_color = vec4(u_color.rgb * u_color.a, u_color.a) * intensity;
}
