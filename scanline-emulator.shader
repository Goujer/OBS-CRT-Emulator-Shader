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
	float2 step = {0.01, 0.01};
> = {0.9, 1.0};

uniform float _3_Timescale<
	string name = "Refresh Rate";
	string widget_type = "slider";
	float minimum = 0.01;
	float maximum = 100.;
	float step = 0.01;
> = 29.97;

uniform float _4_ColorMultiplier<
	string name = "Color Multiplier";
	string widget_type = "slider";
	float minimum = 0.;
	float maximum = 1.;
	float step = 0.01;
> = 0.5;

float4 mainImage(VertData v_in) : TARGET
{
	//Get Pixel Coord
	float2 pixelCoord = v_in.uv * uv_size;

	// Which Y Scanline we're on and how far into it
	int int_scanline_index = int((1.0-v_in.uv.y) * _0_Scanlines);
	float scanline_index = ((1.0-v_in.uv.y) * _0_Scanlines) + (1.0-v_in.uv.x);

	// Get seconds per refresh (Probably doesn't need to be calculated every frame)
	float spr = 1.0/_3_Timescale;

	//Find which part of the TVL we are on
	//Horizontally a TVL will be 10 pixels bRRbGGbBBb
	uint column = uint(pixelCoord.x) % 10;

	//Are we on a support wire location?
	int trine_size = int(uv_size.y / 3);
	bool on_trine_border = (int(pixelCoord.y) == trine_size || int(pixelCoord.y) == trine_size*2);

	// Sample the original input
	float4 rgb = image.Sample(textureSampler, v_in.uv);
	
	switch (column) {
		case 0:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g*_4_ColorMultiplier, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
		case 1:
		case 2:
			rgb = float4(rgb.r, rgb.g*_4_ColorMultiplier, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
		case 3:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g*_4_ColorMultiplier, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
		case 4:
		case 5:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
		case 6:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g*_4_ColorMultiplier, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
		case 7:
		case 8:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g*_4_ColorMultiplier, rgb.b, rgb.a);
			break;
		case 9:
			rgb = float4(rgb.r*_4_ColorMultiplier, rgb.g*_4_ColorMultiplier, rgb.b*_4_ColorMultiplier, rgb.a);
			break;
	}

	// Calculate Position of Electron Beam
	float beam_position = fmod(elapsed_time, spr) * _3_Timescale * _0_Scanlines;

	// Find intensity at current location
	float intensity = 0.0;
	
	//Lessen Intensity Slightly because of support wire
	if (on_trine_border) {
		intensity -= 0.1;
	}

	if (!_1_Interlaced) {	// Progressive scan
		intensity += 1.0 - fmod(scanline_index + beam_position, _0_Scanlines) / _0_Scanlines;
	} else {	// Interlaced
		if (int_scanline_index % 2 == 0) {
			intensity += 1.0 - fmod(scanline_index*0.5 + beam_position, _0_Scanlines) / _0_Scanlines;
		} else {
			intensity += 1.0 - fmod(scanline_index*0.5 + beam_position + _0_Scanlines*0.5, _0_Scanlines) / _0_Scanlines;
		}
	}

	// Clamp and Scale Intensity
	float intensity_scaled = lerp(_2_Intensity.x, _2_Intensity.y, clamp(intensity, 0.0, 1.0));

	// Multiply Intensity
	rgb.rgb *= intensity_scaled;

	return rgb;
}
