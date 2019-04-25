Shader "Unlit/BlockNoise"
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
				return frac(sin(dot(p, fixed2(12.9898, 78.233))) * 42758.5453);
			}

			float noise(fixed2 st)
			{
				// floorで整数部分(n.0のような)の点にする
				fixed2 p = floor(st);
				return random(p);
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float n = noise(i.uv * 8);
				fixed4 col = fixed4(n, n, n, 1);
                return col;
            }
            ENDCG
        }
    }
}
