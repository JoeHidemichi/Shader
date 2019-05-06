Shader "Unlit/SSAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SubSample("Sub Sample (n*2)", Int) = 1
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
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			int _SubSample;

            v2f vert (appdata v)
            {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = fixed4(0,0,0,0);
				float2 pixelPos = i.uv - _MainTex_TexelSize * 0.5;
				float2 lenXY = _MainTex_TexelSize / _SubSample;
				for (int y = 0; y < _SubSample; ++y)
				{
					for (int x = 0; x < _SubSample; ++x)
					{
						float2 subPixelPos = pixelPos + float2(y, x) * lenXY.xy;
						col.rgb += tex2D(_MainTex, subPixelPos).rgb;
					}
				}

				col.rgb /= float(_SubSample * _SubSample);
				col.a = 1.0;
				return col;
			}
            ENDCG
        }
    }
}