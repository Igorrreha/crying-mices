shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_value : hint_range(0,1);


void fragment() {
    vec4 main_color = COLOR;
    vec4 noise_texture = texture(dissolve_texture, UV);
    main_color.a -= floor(dissolve_value * (1.0 - UV.x + 1.0 * dissolve_value) + noise_texture.x);
    COLOR = main_color;
}