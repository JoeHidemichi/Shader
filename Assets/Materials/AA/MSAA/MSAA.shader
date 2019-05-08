Shader "Unlit/MSAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Threshold ("Threshold", Range(0,1)) = 0.01
		_SubSampleSize("Sub Sample Size", Float) = 0.25
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
				float2 depth : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			float4 _MainTex_TexelSize;
			float _Threshold;
			float _SubSampleSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }


			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = (0,0,0,0);

				float2 texel = _MainTex_TexelSize.xy;
				float2 halfHalfSize = texel * _SubSampleSize;
				const float2 kSampleOffset[4] = 
				{
					float2(-halfHalfSize.x, -halfHalfSize.y),
					float2(-halfHalfSize.x, +halfHalfSize.y),
					float2(+halfHalfSize.x, -halfHalfSize.y),
					float2(+halfHalfSize.x, +halfHalfSize.y)
				};
				
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				float4 baseColor = tex2D(_MainTex, i.uv);
				for (int loop = 0; loop < 4; ++loop)
				{
					float2 subPixelPos = i.uv + kSampleOffset[loop];
					float subDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, subPixelPos));
					float delta = abs(subDepth - depth);
					if (_Threshold <= delta)
					{
						col.rgb += tex2D(_MainTex, subPixelPos).rgb;
					}
					else
					{
						col.rgb += baseColor.rgb;
					}
				}
				col.rgb /= 4.0;
				col.a = 1.0;

				return col;
			}
            ENDCG
        }
    }
}
