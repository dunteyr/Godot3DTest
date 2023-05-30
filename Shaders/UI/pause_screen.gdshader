shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	COLOR = textureLod(screen, SCREEN_UV, blur_amount);
}
