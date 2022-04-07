//rounded rectange shader from https://raw.githubusercontent.com/exeldro/obs-lua/master/rounded_rect.shader
//modified slightly by Surn 
//Converted to OpenGl by Q-mii & Exeldro February 21, 2022
uniform int corner_radius;
uniform int border_thickness;
uniform int minimum_alpha_percent = 50;
uniform float4 border_color;
uniform string notes = "Outlines the opaque areas with a rounded border. Default Minimum Alpha Percent is 50%, lowering will reveal more";

float4 mainImage(VertData v_in) : TARGET
{
    float min_alpha = clamp(minimum_alpha_percent * .01, -1.0, 101.0);
    float4 output_color = image.Sample(textureSampler, v_in.uv);
    if (output_color.a < min_alpha)
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
    int closedEdgeX = 0;
    if (image.Sample(textureSampler, v_in.uv + float2(corner_radius * uv_pixel_interval.x, 0)).a < min_alpha)
    {
        closedEdgeX = corner_radius;
    }
    else if (image.Sample(textureSampler, v_in.uv + float2(-corner_radius * uv_pixel_interval.x, 0)).a < min_alpha)
    {
        closedEdgeX = corner_radius;
    }
    int closedEdgeY = 0;
    if (image.Sample(textureSampler, v_in.uv + float2(0, corner_radius * uv_pixel_interval.y)).a < min_alpha)
    {
        closedEdgeY = corner_radius;
    }
    else if (image.Sample(textureSampler, v_in.uv + float2(0, -corner_radius * uv_pixel_interval.y)).a < min_alpha)
    {
        closedEdgeY = corner_radius;
    }
    if (closedEdgeX == 0 && closedEdgeY == 0)
    {
        return float4(output_color);
    }
    if (closedEdgeX != 0)
    {
        for (int x = 1; x < corner_radius; x++)
        {
            if (image.Sample(textureSampler, v_in.uv + float2(x * uv_pixel_interval.x, 0)).a < min_alpha)
            {
                closedEdgeX = x;
                break;
            }
            if (image.Sample(textureSampler, v_in.uv + float2(-x * uv_pixel_interval.x, 0)).a < min_alpha)
            {
                closedEdgeX = x;
                break;
            }
        }
    }
    if (closedEdgeY != 0)
    {
        for (int y = 1; y < corner_radius; y++)
        {
            if (image.Sample(textureSampler, v_in.uv + float2(0, y * uv_pixel_interval.y)).a < min_alpha)
            {
                closedEdgeY = y;
                break;
            }
            if (image.Sample(textureSampler, v_in.uv + float2(0, -y * uv_pixel_interval.y)).a < min_alpha)
            {
                closedEdgeY = y;
                break;
            }
        }
    }
    if (closedEdgeX == 0)
    {
        if (closedEdgeY < border_thickness)
        {
            return border_color;
        }
        else
        {
            return float4(output_color);
        }
    }
    if (closedEdgeY == 0)
    {
        if (closedEdgeX < border_thickness)
        {
            return border_color;
        }
        else
        {
            return float4(output_color);
        }
    }

    float d = distance(float2(closedEdgeX, closedEdgeY), float2(corner_radius, corner_radius));
    if (d < corner_radius)
    {
        if (corner_radius - d < border_thickness)
        {
            return border_color;
        }
        else
        {
            return output_color;
        }
    }
    return float4(0.0, 0.0, 0.0, 0.0);
}