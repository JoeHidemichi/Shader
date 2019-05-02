Shader "Unlit/SimplePhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Specular("Specular", Range(0, 1)) = 1.0
		_SpecularPower ("Specular Power", Float) = 10.0
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
				// 通常のPhong
				// R：法線を中心とした光の反射ベクトル
				//    Lをそのまま直進させ法線を２倍にしたベクトルを足すことで表現
				// spec：視線ベクトルと光の反射ベクトルを内積で取ることで視線ベクトルに平行なほど白くする（足し合わせる）
				float3 N = normalize(i.normal);
				float3 L = normalize(_WorldSpaceLightPos0);
				float3 V = normalize(i.viewDir);
				float NdotL = max(0, dot(N, L));						// Lembert反射
				float3 R = normalize(-L + 2.0 * N * NdotL);				// スペキュラ用の光の反射ベクトル
				float3 spec = pow(max(0, dot(R, V)), _SpecularPower) * _Specular;	// 視線ベクトルと光の反射ベクトルが内積を取る
                return fixed4(col.rgb * _LightColor0.rgb * NdotL + spec, 1.0);
            }
            ENDCG
        }
    }
}
