﻿Shader "Custom/Back"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass
		{
			Stencil
			{
				Ref 1			// 参照する値
				Comp Always		// 常に書き込む
				Pass Replace	// Refの値を書き込む
			}

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
			float4 _MainTex_ST;
			fixed4 _BaseColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f_img i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				return col;
			}
			ENDCG
		}
    }
}
