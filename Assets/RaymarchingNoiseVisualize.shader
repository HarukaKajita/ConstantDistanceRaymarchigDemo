Shader "ConstantDistanceRaymarchig/NoiseVisualize"
{
	Properties
	{
		_Iteration ("Iteration", range(1,64)) = 16
		_DeltaLength ("Delta Length", range(0,1)) = 0.1
		_NoiseScale ("Noise Scale", range(0,5)) = 10.0
		_OuterColor ("Outer Color", color) = (1,0,0,1)
		_InnerColor ("Inner Color", color) = (0,0,1,1)
		_Threshold ("Threshold", range(0,1)) = 0.5
		_ColorLoopNum ("Color Loop Num", range(1,50)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Noise.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 oPos : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.oPos = v.vertex.xyz;
				return o;
			}

			int _Iteration;
			float _DeltaLength;
			float _NoiseScale;
			float3 _OuterColor;
			float3 _InnerColor;
			float _Threshold;
			float _ColorLoopNum;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0,0,0,0);
				float3 oPos = i.oPos;//フラグメントのオブジェクト座標
				float3 oCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
				float3 rayDir = normalize(oPos - oCameraPos);
				float deltaNorm = _DeltaLength;
				float3 delta = deltaNorm * rayDir;
				float3 currentPos = oPos;
				float maxlength = deltaNorm*_Iteration;

				[loop]
				for(int i = 0; i < _Iteration; i++){
					float len = maxlength - abs(currentPos.y);
					//値取得
					float noiseValue = valNoise(currentPos*_NoiseScale);
					//閾値以上の値なら色を付けてbreak
					if(noiseValue > _Threshold){
						//色加算
						float3 color = lerp(_InnerColor, _OuterColor, sin(len/maxlength * UNITY_TWO_PI * _ColorLoopNum)*0.5+0.5);
						col.rgb = color;
						col.a = 1;

						//currentPos + float3(0.00001, 0, 0)
						break;
					}
					
					//レイの行進
					currentPos += delta;
				}
				return col;
			}
			ENDCG
		}
	}
}
