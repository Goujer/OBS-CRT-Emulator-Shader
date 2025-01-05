uniform int _0_Scanlines<
	string name = "Scanlines";
	string widget_type = "slider";
	int minimum = 60;
	int maximum = 2160;
	int step = 1;
> = 480;

uniform bool _1_Interlaced<
	string name = "Enable Interlacing";
> = true;

uniform float2 _2_Intensity<
	string name = "Scanline Brightness Min/Max";
	string widget_type = "slider";
	float2 minimum = {0., 0.};
	float2 maximum = {2., 2.};
	float2 step = {0.001, 0.001};
> = {0.5, 1.0};

uniform float _3_Timescale<
	string name = "Refresh Rate";
	string widget_type = "slider";
	float minimum = 0.01;
	float maximum = 100.;
	float step = 0.01;
> = 29.97;

float4 mainImage(VertData v_in) : TARGET
{
	// Find Max size of image (Probably doesn't need to be calculated every frame)
	float max_index = uv_size.x * _0_Scanlines;

	// Which Y Scanline we're on
	int scanline_index = int(floor((1.0-v_in.uv.y) * _0_Scanlines));

	// Get seconds per refresh (Probably doesn't need to be calculated every frame)
	float spr = 1.0/_3_Timescale;

	// Sample the original input
	float4 rgb = image.Sample(textureSampler, v_in.uv);

	// Calculate Position of Electron Beam
	float beam_position = (fmod(elapsed_time, spr)/spr) * max_index;

	// Find intensity at current location
	float intensity = 0.0;

	if (!_1_Interlaced) {	// Progressive scan
		intensity = 1.0-fmod(((scanline_index * uv_size.x) + ((1.0-v_in.uv.x) * uv_size.x)) + beam_position, max_index) / max_index;
	} else {	// Interlaced
		if (scanline_index % 2 == 0) {
			intensity = 1.0-fmod(((scanline_index * 0.5 * uv_size.x) + ((1.0-v_in.uv.x) * uv_size.x)) + beam_position, max_index) / max_index;
		} else {
			intensity = 1.0-fmod(((scanline_index * 0.5 * uv_size.x) + ((1.0-v_in.uv.x) * uv_size.x)) + beam_position + max_index*0.5, max_index) / max_index;
		}
	}

	// Scale Intensity
	float intensity_scaled = lerp(_2_Intensity.x, _2_Intensity.y, intensity);

	// Multiply Intensity
	rgb.rgb *= intensity_scaled;

	return rgb;
}
