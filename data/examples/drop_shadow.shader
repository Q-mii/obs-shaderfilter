// Drop Shadow shader modified by Charles Fettinger 
// impose a limiter to keep from crashing the system
//Converted to OpenGL by Exeldro February 19, 2022
uniform int shadow_offset_x = 5;
uniform int shadow_offset_y = 5;
uniform int shadow_blur_size = 3;
uniform string notes = "blur size is limited to a max of 15 to ensure GPU";

uniform float4 shadow_color;

uniform bool is_alpha_premultiplied;

float4 mainImage(VertData v_in) : TARGET
{
    int shadow_blur_size_limited = max(0, min(15, shadow_blur_size));
    int shadow_blur_samples = int(pow(float(shadow_blur_size_limited * 2 + 1), 2.0));
    
    float4 color = image.Sample(textureSampler, v_in.uv);
    float2 shadow_uv = float2(v_in.uv.x - uv_pixel_interval.x * float(shadow_offset_x), 
                              v_in.uv.y - uv_pixel_interval.y * float(shadow_offset_y));
    
    float sampled_shadow_alpha = 0.0;
    
    for (int blur_x = -shadow_blur_size_limited; blur_x <= shadow_blur_size_limited; blur_x++)
    {
        for (int blur_y = -shadow_blur_size_limited; blur_y <= shadow_blur_size_limited; blur_y++)
        {
            float2 blur_uv = shadow_uv + float2(uv_pixel_interval.x * float(blur_x), uv_pixel_interval.y * float(blur_y));
            sampled_shadow_alpha += image.Sample(textureSampler, blur_uv).a / float(shadow_blur_samples);
        }
    }
    
    float4 final_shadow_color = float4(shadow_color.r, shadow_color.g, shadow_color.b, shadow_color.a * sampled_shadow_alpha);
    return final_shadow_color * (1.0-color.a) + color * (is_alpha_premultiplied?color.a:1.0);
}
