shader_type canvas_item;


void light() {
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * 0.13, LIGHT_COLOR.a);
}
