Shader "Custom/Front"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_HiddenColor ("Hidden Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"
				"Queue"="Transparent"
				"IgnoreProjector"="True"}
        LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		// 重なっているところ(Stencilが1)を描画
		Pass
		{
			Stencil
			{
				Ref 1		// 参照する値
				Comp Equal	// Refが等しいところを描画
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
			fixed4 _HiddenColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f_img i) : SV_Target
			{
				float alpha = tex2D(_MainTex, i.uv).a;
				fixed4 col = fixed4(_HiddenColor.rgb, alpha);
				return col;
			}
			ENDCG
		}

		// Stencilの値で重なっているところは描画されない
		Pass
		{
			Stencil
			{
				Ref 0		// 参照する値
				Comp Equal	// Refが等しいところ描画
			}

			CGPROGRAM
			#pragma vertex vert_img
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

			fixed4 frag(v2f_img i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
				return col;
			}

			ENDCG
		}
    }
}
