//based on https://www.shadertoy.com/view/Ms3XWH converted by Exeldro  v 1.0
//updated by Charles 'Surn' Fettinger for obs-shaderfilter 9/2020
//Converted to OpenGL by Exeldro February 19, 2022
uniform float range = 0.05;
uniform float noiseQuality = 250.0;
uniform float noiseIntensity = 0.88;
uniform float offsetIntensity = 0.02;
uniform float colorOffsetIntensity = 1.3;
uniform float lumaMin = 0.01;
uniform float lumaMinSmooth = 0.04;
uniform float Alpha_Percentage = 100; //<Range(0.0,100.0)>
uniform bool Apply_To_Image;
uniform bool Replace_Image_Color;
uniform float4 Color_To_Replace;
uniform bool Apply_To_Specific_Color;

float dot(float2 a,float2 b){
    return a.x*b.x+a.y*b.y;
}

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset)
{
    float edge0 = (pos - range);
    float edge1 = (pos + range);

    float x = smoothstep(edge0, pos, uvY) * offset;
    x -= smoothstep(pos, edge1, uvY) * offset;
    return x;
}

float mod(float x, float y)
{
	return x - y * floor(x / y);
}

float dot(float4 a,float4 b){
    return a.r*b.r+a.g*b.g+a.b*b.b+a.a*b.a;
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    for (float i = 0.0; i < 0.71; i += 0.1313)
    {
        float d = mod(elapsed_time * i, 1.7);
        float o = sin(1.0 - tan(elapsed_time * 0.24 * i));
    	o *= offsetIntensity;
        uv.x += verticalBar(d, uv.y, o);
    }
    float uvY = uv.y;
    uvY *= noiseQuality;
    uvY = float(int(uvY)) * (1.0 / noiseQuality);
    float noise = rand(float2(elapsed_time * 0.00001, uvY));
    uv.x += noise * noiseIntensity / 100.0;

    float2 offsetR = float2(0.006 * sin(elapsed_time), 0.0) * colorOffsetIntensity;
    float2 offsetG = float2(0.0073 * (cos(elapsed_time * 0.97)), 0.0) * colorOffsetIntensity;

    float r = image.Sample(textureSampler, uv + offsetR).r;
    float g = image.Sample(textureSampler, uv + offsetG).g;
    float b = image.Sample(textureSampler, uv).b;

    float4 rgba = float4(r, g, b, 1.0);
    
    float4 color;
    float4 original_color;
    if (Apply_To_Image)
    {
        color = image.Sample(textureSampler, v_in.uv);
        original_color = color;
        float luma = dot(color, float4(0.30, 0.59, 0.11, 1.0));
        if (Replace_Image_Color)
            color = float4(luma,luma,luma,luma);
        rgba = lerp(original_color, rgba * color, clamp(Alpha_Percentage * .01, 0, 1.0));
		
    }
    if (Apply_To_Specific_Color)
    {
        color = image.Sample(textureSampler, v_in.uv);
        original_color = color;
        color = (distance(color.rgb, Color_To_Replace.rgb) <= 0.075) ? rgba : color;
        rgba = lerp(original_color, color, clamp(Alpha_Percentage * .01, 0, 1.0));
    }

    return rgba;
}
