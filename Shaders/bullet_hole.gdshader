shader_type spatial;

uniform float hole_size : hint_range(0.01, 0.5) = 0.2;
uniform float hole_rim_size : hint_range(0.0, 0.5) = 0.1;

uniform vec3 hole_color : source_color;
uniform vec3 rim_color : source_color;

void fragment() {
	float dist = distance(vec2(0.5), UV);
	float hole = step(hole_size, dist);
	float hole_rim = step(hole_size + hole_rim_size, dist);
	float rim = (1.0 - hole_rim) - (1.0 - hole);
	vec3 colored_rim = rim * rim_color;
	vec3 colored_hole = (1.0 - hole) * hole_color;
	vec3 total = colored_hole + colored_rim;
	ALBEDO = total;
	ALPHA = (1.0 - hole_rim);
}
