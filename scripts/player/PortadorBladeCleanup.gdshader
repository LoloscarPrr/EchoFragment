shader_type canvas_item;

// Only the red blade on the *forward* edge is suppressed for other weapons.
// The crimson cape on the hero's back and his black/gold armor remain intact.
// This is an interim mask until each pose has a dedicated full-body painting.
uniform bool remove_forward_blade = false;
uniform vec2 atlas_origin = vec2(0.0, 0.0);
uniform vec2 frame_pivot = vec2(201.0, 323.0);

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (remove_forward_blade) {
		vec2 frame_pixel = UV / TEXTURE_PIXEL_SIZE - atlas_origin;
		vec2 from_body = frame_pixel - frame_pivot;
		bool forward_tip = from_body.x > 68.0 && from_body.x < 170.0
			&& from_body.y > -155.0 && from_body.y < 42.0;
		bool red_edge = pixel.r > 0.32 && pixel.r > pixel.g * 1.55
			&& pixel.r > pixel.b * 1.24;
		if (forward_tip && red_edge) {
			pixel.a = 0.0;
		}
	}
	COLOR = pixel;
}
