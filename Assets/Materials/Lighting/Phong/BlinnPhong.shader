﻿Shader "Unlit/BlinnPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Specular ("Specular", Range(0, 1)) = 1
		_SpecularPower ("Specular Power", Float) = 10
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
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _LightColor0;
			float _Specular;
			float _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = ObjSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

				float3 N = normalize(i.normal);
				float3 V = normalize(i.viewDir);
				float3 L = normalize(_WorldSpaceLightPos0);
				float3 R = normalize(L + V);
				float diffuse = max(0, dot(L, N));
				float specular = pow(max(0, dot(N, R)), _SpecularPower) * _Specular;

                return fixed4(col.rgb * _LightColor0.rgb * diffuse + specular, 1);
            }
            ENDCG
        }
    }
}
