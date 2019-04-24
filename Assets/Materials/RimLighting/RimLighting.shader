Shader "Unlit/RimLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1,1,1,1)
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimDecay("Rim Decay", Float) = 3
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
				float3 viewDir : TEXCOORD1;
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
			float4 _BaseColor;
			float4 _RimColor;		// リムの色
			float _RimDecay;		// リムの減衰量

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= _BaseColor;
				float3 N = i.normal;
				float3 V = i.viewDir;
				// 内積して値を0~1に収める(saturate)
				// 1-をして値を反転
				float rim = 1 - saturate(dot(V, N));
				// リムの色に乗算してどれくらい色を反映するか計算
				float emission = _RimColor * pow(rim, _RimDecay);
				// 色を加算
				col += emission;

                return col;
            }
            ENDCG
        }
    }
}
