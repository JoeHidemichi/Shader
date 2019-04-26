Shader "Unlit/PerlinNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			fixed2 random2(fixed2 st) {
				st = fixed2( dot(st, fixed2(127.1, 311.7)),
					dot(st, fixed2(269.5, 183.3)) );
				return -1.0 + 2.0*frac(sin(st)*43758.5453123);
			}


			float4 mod289(float4 x)
			{
				return x - floor(x / 289.0) * 289.0;
			}

			float4 permute(float4 x)
			{
				return mod289(((x*34.0) + 1.0)*x);
			}

			float4 taylorInvSqrt(float4 r)
			{
				return (float4)1.79284291400159 - r * 0.85373472095314;
			}

			float2 fade(float2 t) {
				return t * t*t*(t*(t*6.0 - 15.0) + 10.0);
			}

			float perlinNoise(fixed2 st)
			{
				//fixed2 p = floor(st);
				//fixed2 f = frac(st);
				//fixed2 u = f * f * (3.0 - 2.0 * f);
				//
				//float v00 = random2(p + fixed2(0, 0));
				//float v10 = random2(p + fixed2(1, 0));
				//float v01 = random2(p + fixed2(0, 1));
				//float v11 = random2(p + fixed2(1, 1));
				//
				//return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
				//			lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
				//			u.y)
				//			+ 0.5f;

				// reference: https://github.com/keijiro/NoiseShader/blob/master/Assets/HLSL/ClassicNoise2D.hlsl
				float4 Pi = floor(st.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
				float4 Pf = frac(st.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
				Pi = mod289(Pi); // To avoid truncation effects in permutation
				float4 ix = Pi.xzxz;
				float4 iy = Pi.yyww;
				float4 fx = Pf.xzxz;
				float4 fy = Pf.yyww;

				float4 i = permute(permute(ix) + iy);

				float4 gx = frac(i / 41.0) * 2.0 - 1.0;
				float4 gy = abs(gx) - 0.5;
				float4 tx = floor(gx + 0.5);
				gx = gx - tx;

				float2 g00 = float2(gx.x, gy.x);
				float2 g10 = float2(gx.y, gy.y);
				float2 g01 = float2(gx.z, gy.z);
				float2 g11 = float2(gx.w, gy.w);

				float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
				g00 *= norm.x;
				g01 *= norm.y;
				g10 *= norm.z;
				g11 *= norm.w;

				float n00 = dot(g00, float2(fx.x, fy.x));
				float n10 = dot(g10, float2(fx.y, fy.y));
				float n01 = dot(g01, float2(fx.z, fy.z));
				float n11 = dot(g11, float2(fx.w, fy.w));

				float2 fade_xy = fade(Pf.xy);
				float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
				float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
				return 2.3 * n_xy;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed c = perlinNoise(i.uv * 8);

				return fixed4(c, c, c, 1);
            }
            ENDCG
        }
    }
}
