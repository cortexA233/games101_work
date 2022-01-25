Shader "SDF/SDF_revert"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("主字体颜色", Color) = (1,1,1,1)
        _EdgeColor ("边缘颜色", Color) = (0,0,0,1)
        _ShadowColor ("阴影颜色", Color) = (0,0,0,1)
        _ShadowOffetX ("阴影偏移X", Range(0, 0.2)) = 0
        _ShadowOffetY ("阴影偏移Y", Range(0, 0.2)) = 0
        _EdgeWidth ("边缘宽度", Range(0, 0.2)) = 0
        _SmoothValue ("平滑系数", Range(0, 0.15)) = 0.05
        _DistanceOffset ("距离系数", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
            float4 _ShadowColor;
            float _DistanceOffset;
            float _ShadowOffetX;
            float _ShadowOffetY;
            float _SmoothValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv + float2(-_ShadowOffetX, -_ShadowOffetY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                clip(_ShadowOffetY + _ShadowOffetX - 0.001);
                fixed4 sdf = tex2D(_MainTex, i.uv);
                sdf.rgb = 1 - sdf.rgb;
                float distance = sdf.r;

                clip(distance - _DistanceOffset);

                fixed4 col = fixed4(1,1,1,1);
                col.rgb = _ShadowColor;

                return col;
            }
            ENDCG
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
            float4 _MainColor;
            float4 _EdgeColor;

            float _EdgeWidth;
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
                fixed4 sdf = tex2D(_MainTex, i.uv);
                sdf.rgb = 1 - sdf.rgb;
                float distance = sdf.r;

                // col.a = distance - _DistanceOffset;
                fixed4 col = fixed4(1, 1, 1, 1);
                col.rgb = _MainColor.rgb * (smoothstep(_DistanceOffset - _SmoothValue, _DistanceOffset + _SmoothValue, distance));
                // col.rgb = _MainColor.rgb;

                if (distance < _DistanceOffset + _EdgeWidth && _EdgeWidth > 0){
                    col.a = smoothstep(_DistanceOffset + _EdgeWidth, _DistanceOffset + _EdgeWidth, distance);
                    col.rgb = 1 * _EdgeColor.rgb;
                }
                
                
                col.rgb += (1 - smoothstep(_DistanceOffset, _DistanceOffset + _EdgeWidth, distance)) * _EdgeColor.rgb;

                col.a = smoothstep(_DistanceOffset - _SmoothValue, _DistanceOffset + _SmoothValue, distance);
                clip(col.a);
                return col;
            }
            ENDCG
        }

        
    }
}
