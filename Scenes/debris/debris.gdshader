shader_type spatial;

uniform vec3 concrete_color : source_color = vec3(0.38, 0.37, 0.34);
uniform vec3 dark_color : source_color = vec3(0.16, 0.16, 0.15);
uniform vec3 light_color : source_color = vec3(0.55, 0.53, 0.48);

uniform float noise_scale = 10;
uniform float roughness_value = 0.95;
uniform float damage_amount = 0.7;

varying vec3 local_pos;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	return mix(
		mix(
			mix(hash(i), hash(i + vec3(1,0,0)), f.x),
			mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x),
			f.y
		),
		mix(
			mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
			mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x),
			f.y
		),
		f.z
	);
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec3 p = local_pos * noise_scale;

	float n1 = noise(p);
	float n2 = noise(p * 3.0);
	float n3 = noise(p * 8.0);

	float damage = noise(p * 2.0 + vec3(13.0));

	vec3 color = mix(dark_color, light_color, n1);
	color = mix(color, concrete_color, 0.5);

	// Surface weathering
	color *= mix(0.7, 1.15, n2);

	// Damaged concrete variation
	color = mix(color, dark_color, damage * damage_amount * 0.5);

	// Fine surface grain
	color += (n3 - 0.5) * 0.12;

	ALBEDO = color;
	ROUGHNESS = roughness_value;
	METALLIC = 0.0;
}