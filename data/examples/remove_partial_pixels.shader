// Remove Partial Pixels shader by Charles Fettinger for obs-shaderfilter plugin 8/2020
// https://github.com/Oncorporation/obs-shaderfilter
//Converted to OpenGL by Exeldro February 21, 2022
uniform int minimum_alpha_percent = 50;
uniform string notes = "Removes partial pixels, excellent for cleaning greenscreen. Default Minimum Alpha Percent is 50%, lowering will reveal more pixels";

float4 mainImage(VertData v_in) : TARGET
{
    float min_alpha = clamp(minimum_alpha_percent * .01, -1.0, 101.0);
    float4 output_color = image.Sample(textureSampler, v_in.uv);
    if (output_color.a < min_alpha)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
    else
    {
        return float4(output_color);
    }
}