// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;


uniform vec3 base_color;
uniform vec3 fresnel_color;
uniform float fresnel_intensity;
uniform float fresnel_amount;

vec3 fresnel_glow(float amount, vec3 normal, vec3 view, vec3 color, float intensity){
	return pow(1.0 - dot(normalize(normal), normalize(view)), amount) * color * intensity;
}

void vertex() {
	
}

void fragment() {
	vec3 fresnel_value = fresnel_glow(fresnel_amount, NORMAL, VIEW, fresnel_color, fresnel_intensity);
	ALBEDO = base_color + fresnel_value;
	
	METALLIC = 0.0;
	SPECULAR = 0.0;
}

