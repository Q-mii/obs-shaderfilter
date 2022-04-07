// pixelation shader by Charles Fettinger for obs-shaderfilter plugin 3/2019
// with help from SkeltonBowTV
// https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGL by Exeldro February 15, 2022
uniform float Target_Width = 320.0;
uniform float Target_Height = 180.0;
uniform string notes = "adjust width and height to your screen dimension";

float4 mainImage(VertData v_in) : TARGET
{
	float targetWidth = Target_Width;
	if(targetWidth < 2.0)
		targetWidth = 2.0;
	float targetHeight = Target_Height;
	if(targetHeight < 2.0)
		targetHeight = 2.0;
	float2 tex1;
	int pixelSizeX = int(uv_size.x / targetWidth);
	int pixelSizeY = int(uv_size.y / targetHeight);

	int pixelX = int(v_in.uv.x * uv_size.x);
	int pixelY = int(v_in.uv.y * uv_size.y);

	tex1.x = ((float(pixelX / pixelSizeX)*float(pixelSizeX)) / uv_size.x) + (float(pixelSizeX) / uv_size.x)/2.0;
	tex1.y = ((float(pixelY / pixelSizeY)*float(pixelSizeY)) / uv_size.y) + (float(pixelSizeY) / uv_size.y)/2.0;

	float4 c1 = image.Sample(textureSampler, tex1 );

	return c1;
}
