Shader "SDF/SDF_anime"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _EdgeColor ("Edge Color", Color) = (0,0,0,1)
        _SmoothValue ("Smooth Value", Range(0, 0.1)) = 0.05
        _DistanceOffset ("Distance Mark", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            // Blend SrcAlpha OneMinusSrcAlpha
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
            sampler2D _SecondTex;
            float4 _SecondTex_ST; 

            float4 _MainColor;
            float4 _EdgeColor;
            float _SmoothValue;
            float _DistanceOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 first = tex2D(_MainTex, i.uv);
                fixed4 second = tex2D(_SecondTex, i.uv);
                first.rgb = 1 - first.rgb;
                float time = saturate(2 * sin(_Time.y / 2));
                float distance = first.r * (1 - time) + second * time;

                float alphaTestValue  = distance - _DistanceOffset;
                // float alphaTestValue = smoothstep(_DistanceOffset - _SmoothValue, _DistanceOffset + _SmoothValue, distance);
                clip(alphaTestValue);
                fixed4 col;
                col.rgb = _MainColor.rgb;
                // fixed4 resultColor = _MainColor;
                // resultColor.a = smoothstep(_DistanceOffset + 0.1, _DistanceOffset + 0.4, distance);
                // return resultColor;
                return col;
            }
            ENDCG
        }
    }
}
