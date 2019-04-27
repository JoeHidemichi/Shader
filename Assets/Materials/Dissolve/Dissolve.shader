Shader "Unlit/Dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_Threshold ("Threshold", Range(0,1)) = 1
		_DissolveColor ("Dissolve Color", Color) = (1,1,1,1)
		_DissolveWidth ("Dissolve Width", Float) = 0.03
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
            };

            sampler2D _MainTex;
			fixed4 _BaseColor;
            float4 _MainTex_ST;
			sampler2D _MaskTex;
			float _Threshold;
			fixed4 _DissolveColor;
			float _DissolveWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= _BaseColor;
				fixed4 mask = tex2D(_MaskTex, i.uv);
				float gray = mask.r * 0.3 + mask.g * 0.6 + mask.b * 0.1;
				if (gray < _Threshold)
				{
					discard;
				}
				else if (gray < (_Threshold + _DissolveWidth))
				{
					col = _DissolveColor;
				}

                return col;
            }
            ENDCG
        }
    }
}
