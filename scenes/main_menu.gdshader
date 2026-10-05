shader_type canvas_item;

uniform bool useHologram = true;

uniform vec4 baseColor : source_color = vec4(0.3058, 0.835, 0.960, 1.0);
uniform float speed = 0.5;

uniform vec4 linesColor : source_color = vec4(0.633232, 0.910156, 0.555693, 1.0);
uniform float linesColorIntensity = 5.0;

uniform sampler2D hologramTexture : filter_linear, repeat_enable;
uniform vec2 hologramTextureTiling = vec2(1.0, 5.0);

vec2 tilingAndOffset(vec2 uv, vec2 tiling, vec2 offset) {
    return mod(uv * tiling + offset, 1.0);
}

void fragment() {

    // Always sample the base texture
    vec4 baseTex = texture(TEXTURE, UV);
    vec4 finalColor = baseTex;

    if (useHologram) {
        vec2 offset = vec2(TIME * speed);
        vec2 tiling = tilingAndOffset(UV, hologramTextureTiling, offset);

        vec4 noise = texture(hologramTexture, tiling);

        float fresnel = 0.71;
        vec4 colorLines = linesColor * vec4(vec3(linesColorIntensity), 1.0);
        vec4 emission = colorLines * fresnel * noise;

        vec4 albedo = baseColor;
        float alpha = dot(noise.rgb, vec3(1.0));

        vec4 hologram;
        hologram.rgb = emission.rgb + (1.0 - emission.rgb) * albedo.rgb * albedo.a;
        hologram.a   = emission.a + (1.0 - emission.a) * alpha;
        hologram.a   = hologram.a + (1.0 - hologram.a) * albedo.a;
        hologram.a   = clamp(hologram.a, 0.0, 1.0);

        finalColor.rgb = baseTex.rgb + (1.0 - baseTex.rgb) * hologram.rgb;
        finalColor.a   = min(baseTex.a, hologram.a);
    }

    COLOR = finalColor;
}
