package shaders;

import flixel.system.FlxAssets.FlxShader;

class CoolBaldiEffect extends FlxShader
{
	@:glFragmentSource('
    #pragma header

    #define round(a) floor(a + 0.5)
    #define iResolution vec3(openfl_TextureSize, 0.)
    uniform float iTime;
    #define iChannel0 bitmap
    uniform sampler2D iChannel1;
    uniform sampler2D iChannel2;
    uniform sampler2D iChannel3;
    #define texture flixel_texture2D
    
    // third argument fix
    vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
        vec4 color = texture2D(bitmap, coord, bias);
        if (!hasTransform)
        {
            return color;
        }
        if (color.a == 0.0)
        {
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
        if (!hasColorTransform)
        {
            return color * openfl_Alphav;
        }
        color = vec4(color.rgb / color.a, color.a);
        mat4 colorMultiplier = mat4(0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
        color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
        if (color.a > 0.0)
        {
            return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        }
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    // variables which is empty, they need just to avoid crashing shader
    uniform float iTimeDelta;
    uniform float iFrameRate;
    uniform int iFrame;
    #define iChannelTime float[4](iTime, 0., 0., 0.)
    #define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
    uniform vec4 iMouse;
    uniform vec4 iDate;
    
        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
            vec2 uv = fragCoord / iResolution.xy; 
            mat4 bayer = mat4(
                0.0000, 0.5000, 0.1250, 0.6250,
                0.7500, 0.2500, 0.8750, 0.3750,
                0.1875, 0.6875, 0.0625, 0.5625,
                0.9375, 0.4375, 0.8125, 0.3125
            );
        
            uv += vec2(iTime * .0);
            vec3 col = texture(iChannel0, uv).rgb;
            
            // greyscale pixel by calculating average of all channels
            float avg = (col.r + col.g + col.b) / 2.;
            
            // calculate coord in bayer matrix using modulo (4 as size of matrix)
            // if greyscale darker than threshold in matrix use black else white
            fragColor = vec4(bayer[int(fragCoord.x) % 4][int(fragCoord.y) % 4] < avg);
        }
    
    void main() {
        mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
    }
    ')
	public function new()
	{
		super();
	}
}