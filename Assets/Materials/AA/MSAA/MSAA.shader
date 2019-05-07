Shader "Unlit/MSAA"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		//_SubSample ("Sub Sample", Int) = 1
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
			//int _SubSample;
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

				//float2 pixelPos = i.uv - _MainTex_TexelSize.xy * 0.5;
				//float2 lenXY = _MainTex_TexelSize.y / _SubSample;
				//float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				//for (int y = 0; y < _SubSample; ++y)
				//{
				//	for (int x = 0; x < _SubSample; ++x)
				//	{
				//		float2 subPixelPos = pixelPos + float2(y, x) * lenXY.xy;
				//		float subDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, subPixelPos));
				//		float delta = abs(subDepth - depth);
				//		col.rgb += tex2D(_MainTex, subPixelPos) * (1.0 + delta);
				//	}
				//}
				//col.rgb /= float(_SubSample * _SubSample);

				return col;
			}


			//vec3 shadingMSAA(ivec2 pixelPos) {
			//	// Edge test
			//	float zValue = imageLoad(positionMap, pixelPos * u_subsample).w;
			//	bool isEdge = false;
			//	for (int i = 0; i < u_subsample; i++) {
			//		for (int j = 0; j < u_subsample; j++) {
			//			ivec2 subpixel = pixelPos * u_subsample + ivec2(i, j);
			//			float zSub = imageLoad(positionMap, subpixel).w;
			//			if (abs(zValue - zSub) > 1.0e-4) {
			//				isEdge = true;
			//				break;
			//			}
			//		}
			//
			//		if (isEdge) {
			//			break;
			//		}
			//	}
			//
			//	// Shading
			//	if (isEdge) {
			//		return shadingSSAA(pixelPos);
			//	}
			//	else {
			//		return shading(pixelPos * u_subsample);
			//	}
			//}
			/*
			float4 RenderDeferredMSAAPS(OutputVS inPixel) : SV_TARGET
			{
				// 基準ピクセルの深度とカラーを取得する
				float3 normal;
				float depth;
				DecodeNormalDepthLambert8888(normal, depth, texNormalDepth.Sample(samPoint, inPixel.texCoord));

				float4 baseColor = texFinal.Sample(samPoint, inPixel.texCoord);
				int2 uv_for_ms = (int2)(inPixel.texCoord * screenSize);

				const float2 kSampleOffset[] =
				{
					float2(0.380 - 0.5, 0.141 - 0.5),
					float2(0.859 - 0.5, 0.380 - 0.5),
					float2(0.141 - 0.5, 0.620 - 0.5),
					float2(0.620 - 0.5, 0.859 - 0.5)
				};
				float3 outColor = 0;
				for (int i = 0; i < 4; ++i)
				{
					float msDepth = texMSDepth.Load(uv_for_ms, i);
					float delta = abs(msDepth - depth);
					if (delta >= threshold.x)
					{
						float2 uv = inPixel.texCoord + kSampleOffset[i] / screenSize;
						outColor += texFinal.Sample(samLinear, uv).rgb;
					}
					else
					{
						outColor += baseColor.rgb;
					}
				}
				outColor /= 4.0;

				return float4(outColor, baseColor.a);
			}
			*/
            ENDCG
        }
    }
}
