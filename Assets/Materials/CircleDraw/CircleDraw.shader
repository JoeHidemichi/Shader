Shader "Unlit/CircleDraw"
{
    Properties
    {
		_Radius ("Radius", Float) = 2
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_CircleColor ("Circle Color", Color) = (1,1,0.4,1)
		_RingWidth ("Ring Width", Float) = 0.2
		[MaterialToggle] _IsDrawRing ("Is draw ring", Float) = 0				// リングを描画
		[MaterialToggle] _IsDrawManyRings("Is draw many rings", Float) = 0		// リングを複数描画
		[MaterialToggle] _IsDrawMoveRings("Is draw move rings", Float) = 0		// 複数リングを移動
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 pos : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Radius;
			fixed4 _BaseColor;
			fixed4 _CircleColor;
			float _RingWidth;
			bool _IsDrawRing;
			bool _IsDrawManyRings;
			bool _IsDrawMoveRings;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = _BaseColor;

				if (_IsDrawRing)
				{
					// リングを描画
					float dist = distance(fixed3(0, 0, 0), i.pos);
					if (_Radius < dist && dist < _Radius + _RingWidth)
					{
						col = fixed4(_CircleColor.rgb, 1);
					}
				}
				else if (_IsDrawManyRings)
				{
					// リングを複数描画
					float dist = distance(fixed3(0, 0, 0), i.pos);
					float val = abs(sin(dist * 3));
					if (val > 0.98)
					{
						col = _CircleColor;
					}
					else
					{
						col = _BaseColor;
					}
				}
				else if (_IsDrawMoveRings)
				{
					// 複数リングを移動
					float dist = distance(fixed3(0, 0, 0), i.pos);
					float val = abs(sin(dist * 3 - _Time * 100));
					if (val > 0.98)
					{
						col = _CircleColor;
					}
				}
				else
				{
					// 円を描画
					float dist = distance(fixed3(0, 0, 0), i.pos);
					if (dist < _Radius)
					{
						col = fixed4(_CircleColor.rgb, 1);
					}
				}
				return col;
            }
            ENDCG
        }
    }
}
