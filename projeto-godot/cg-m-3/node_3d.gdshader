shader_type spatial;
render_mode unshaded, depth_prepass_alpha, cull_disabled;

// Pass the local coordinates from vertex to fragment
varying vec3 local_pos;

// Our 3D data texture from R
uniform sampler3D climate_volume_tex : filter_linear;

// Controls for the visualization
uniform float threshold : hint_range(0.0, 1.0) = 0.40; // 40% probability isosurface
uniform float transparency_scale : hint_range(0.0, 5.0) = 1.0;
uniform int max_steps : hint_range(10, 200) = 100;     // Higher = smoother, lower = faster

// Simple function to check if a 3D position is inside our texture bounds (0.0 to 1.0)
bool is_inside(vec3 pos) {
    return pos.x >= 0.0 && pos.x <= 1.0 && 
           pos.y >= 0.0 && pos.y <= 1.0 && 
           pos.z >= 0.0 && pos.z <= 1.0;
}

void vertex() {
    // Standard Godot BoxMesh ranges from -0.5 to 0.5 on all axes.
    // We remap VERTEX to a clean 0.0 to 1.0 range so it maps perfectly to our texture coordinates.
    local_pos = VERTEX + vec3(0.5);
}

void fragment() {
    // 1. Find where the camera ray enters the box boundary using our calculated local position
    vec3 ray_origin = local_pos; 
    
    // Calculate the camera ray direction using the Inverse View Matrix
    vec3 view_dir_world = (INV_VIEW_MATRIX * vec4(0.0, 0.0, -1.0, 0.0)).xyz;
    
    // Transform ray direction from world space into the local box space orientation
    vec3 ray_dir = normalize(mat3(MODEL_MATRIX) * view_dir_world);

    // 2. Setup the raymarching step size
    float step_length = 1.73 / float(max_steps); // 1.73 is approx sqrt(3), the max diagonal of a unit cube
    vec3 current_pos = ray_origin;
    
    vec4 accumulated_color = vec4(0.0);

    // 3. March through the 3D volume
    for (int i = 0; i < max_steps; i++) {
        current_pos += ray_dir * step_length;
        
        // Break out if the ray has exited the data cube boundaries
        if (!is_inside(current_pos)) {
            break;
        }
        
        // 4. Sample the scalar climate value from our 3D R dataset (Red channel)
        float value = texture(climate_volume_tex, current_pos).r;
        
        // 5. Apply your visualization logic!
        if (value >= threshold) {
            // Calculate a transparency based on how high the value is
            float alpha = (value - threshold) * transparency_scale * step_length;
            
            // Map color dynamically: Higher concentrations look redder (like the paper)
            vec3 voxel_color = mix(vec3(1.0, 1.0, 1.0), vec3(0.9, 0.9, 0.2), value);
            
            // Accumulate color using front-to-back alpha blending
            accumulated_color.rgb += (1.0 - accumulated_color.a) * voxel_color * alpha;
            accumulated_color.a += (1.0 - accumulated_color.a) * alpha;
            
            // If the visualization becomes fully opaque, we can stop marching to optimize performance
            if (accumulated_color.a >= 0.95) {
                accumulated_color.a = 1.0;
                break;
            }
        }
    }
    
    // 6. Output the final pixel color to the screen
    ALBEDO = accumulated_color.rgb;
    ALPHA = accumulated_color.a;
}