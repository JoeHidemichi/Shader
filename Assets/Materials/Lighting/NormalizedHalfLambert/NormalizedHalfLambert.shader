Shader "Unlit/NormalizedHalfLambert"
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
			#define PI 3.1415926535

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float3 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

			fixed3 NormalizedHalfLambert(float3 diffuse, float3 lightDir, float3 normal)
			{
				float val = max(dot(normal, lightDir), 0.0) * 0.5 + 0.5;
				return diffuse * val * val * (3.0 / (4.0 * PI));
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				float3 N = i.normal;
				float3 L = _WorldSpaceLightPos0;
				float Id = 3.0; // 光の強さ
				float3 diffuse = NormalizedHalfLambert(col.rgb * Id, L, N);
				return fixed4(diffuse * _LightColor0.rgb, 1.0);
            }
            ENDCG
        }
    }
}
