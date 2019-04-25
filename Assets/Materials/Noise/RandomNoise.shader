Shader "Unlit/RandomNoise"
{
    Properties
    {
		_MainTex("Main Tex", 2D) = "white"{}
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

            fixed4 frag (v2f i) : SV_Target
            {
				float r = random(i.uv);
				fixed4 col = fixed4(r, r, r, 1);
                return col;
            }
            ENDCG
        }
    }
}
