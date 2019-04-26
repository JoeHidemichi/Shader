Shader "Unlit/SimpleToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_RampTex ("Ramp", 2D) = "white"{}
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
				float3 lightDir : TEXCOORD1;
				float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _RampTex;
			fixed4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				o.normal = v.normal;
                return o;
            }

			fixed4 LightingToon(float2 uv, float3 lightDir, float3 normal)
			{
				float3 L = lightDir;
				float3 N = normal;
				half d = dot(N, L) * 0.5 + 0.5;
				float3 ramp = tex2D(_RampTex, fixed2(d, 0.5)).rgb;
				fixed4 c;
				c.rgb = _LightColor0.rgb * ramp;
				c.a = 0;
				return c;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 toon = LightingToon(i.uv, i.lightDir, i.normal);
				col *= toon;
				col.a = 1;
                return col;
            }
            ENDCG
        }
    }
}
