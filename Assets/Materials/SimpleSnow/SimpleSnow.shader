Shader "Unlit/SimpleSnow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SnowColor ("Snow Color", Color) = (1,1,1,1)
		_SnowColorDepth ("Snow Color Dpeth", Float) = 1
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _SnowColor;
			float _SnowColorDepth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				float3 N = i.normal;
				float3 Up = float3(0, 1, 0);
				float d = dot(N, Up);
				col = lerp(col, _SnowColor, d * _SnowColorDepth);
                return col;
            }
            ENDCG
        }
    }
}
