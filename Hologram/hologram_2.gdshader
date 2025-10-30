// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;

uniform vec4 normal_color : source_color;

uniform vec3 base_color;
uniform vec3 fresnel_color;
uniform float fresnel_intensity;
uniform float fresnel_amount;

uniform sampler2D scanlines_texture;
uniform vec2 tile_scaling;
uniform vec2 scanlines_speed;
uniform float vertex_displacement_intensity;


vec3 fresnel_glow(float amount, vec3 normal, vec3 view, vec3 color, float intensity){
	return pow(1.0 - dot(normalize(normal), normalize(view)), amount) * color * intensity;
}
float fresnel(float amount, vec3 normal, vec3 view){
	return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), amount);
}

void vertex() {
	vec4 tex = textureLod(scanlines_texture, UV+scanlines_speed*TIME, 0);
	VERTEX += NORMAL * (tex.r) * vertex_displacement_intensity;
}

void fragment() {
	vec3 fresnel_value = fresnel_glow(fresnel_amount, NORMAL, VIEW, fresnel_color, fresnel_intensity);
	vec3 scanlines = texture(scanlines_texture, (UV+scanlines_speed*TIME) * tile_scaling).rgb;
	vec3 holoFinal = base_color + fresnel_value + scanlines;
	ALBEDO = holoFinal;
	float fresnelFinal =  fresnel(fresnel_amount, NORMAL, VIEW) + (scanlines.r) * 0.01;
	ALPHA = fresnelFinal;
}

void light() {
	vec3 N = normalize(NORMAL);
	vec3 L = normalize(LIGHT);
	vec3 V = normalize(VIEW);
	vec3 H = normalize(L + V);

	float NdotL = max(dot(N, L), 0.0);
	float NdotH = max(dot(N, H), 0.0);

	vec3 diffuse = ALBEDO * LIGHT_COLOR * NdotL;
	vec3 specular = LIGHT_COLOR * pow(NdotH, 32.0) * 0.2;

	DIFFUSE_LIGHT = diffuse * ATTENUATION;
	SPECULAR_LIGHT = specular * ATTENUATION;
}
