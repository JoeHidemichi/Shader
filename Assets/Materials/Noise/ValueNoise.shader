Shader "Unlit/ValueNoise"
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

			float random(fixed2 p)
			{
				return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 43758.5453);
			}

			float noise(fixed2 st)
			{
				// floorで整数部分(n.0のような)の点にする
				fixed2 p = floor(st);
				return random(p);
			}

			float valueNoise(fixed2 st)
			{
				fixed2 i = floor(st);	// 整数部分
				fixed2 f = frac(st);	// 小数部分

				float v00 = random(i + fixed2(0, 0));	// 四隅の色
				float v10 = random(i + fixed2(1, 0));	// 四隅の色
				float v01 = random(i + fixed2(0, 1));	// 四隅の色
				float v11 = random(i + fixed2(1, 1));	// 四隅の色

				// 線形補間
				fixed2 u = f * f * (3.0 - 2.0 * f);

				//float v0010 = lerp(v00, v10, u.x);
				//float v0111 = lerp(v01, v11, u.x);
				//return lerp(v0010, v0111, u.y);

				return lerp(v00, v10, u.x) + (v01 - v00)* u.y * (1.0 - u.x) + (v11 - v10) * u.x * u.y;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float n = valueNoise(i.uv * 8);
				fixed4 col = fixed4(n, n, n, 1);
                return col;
            }
            ENDCG
        }
    }
}
