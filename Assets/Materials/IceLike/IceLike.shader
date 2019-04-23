Shader "Unlit/IceLike"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Base Color", Color) = (1,1,1,1)
		_AdjustAlpha("Adjust Alpha", Float) = 1.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100

        Pass
        {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

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
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
			float _AdjustAlpha;

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
				col *= _Color;
				float3 N = i.normal;	// 法線ベクトル
				float3 V = i.viewDir;	// 視線ベクトル
				// 内積を取る
				// 裏のポリゴンの内積も含めたいので(半透明なので)絶対値を取る
				// 内積の値が０で不透明、１だと透明にしたいので 1- で反転させる
				float alpha = 1 - abs( dot(V,N) );
				// 不透明のところを大きくして強調させたいのでAlpha値を調整
				col.a = alpha * _AdjustAlpha;

                return col;
            }
            ENDCG
        }
    }
}
