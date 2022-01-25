Shader "SDF/FirstSDF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;


            fixed4 SDFBox(fixed3 coord, fixed3 size){
                fixed2 sdf = length(max(abs(coord) - size, 0));
                // sdf = -sdf;
                // int finalSDF = sdf.x + sdf.y;
                int finalSDF = (max(sdf, 0.0) - min(max(sdf.x, sdf.y), 0)) * 111;
                // fixed2 sdf = sign(size/2 - abs(coord));
                return saturate(fixed4(finalSDF, finalSDF, finalSDF, 0));
            }


            fixed4 SDFCircle(fixed2 coord, fixed radius, fixed2 center = fixed2(0.5, 0.5)){
                coord = coord - center;
                float sdf = -(length(coord) - radius);
                int finalSDF = int(sdf * 10000007);
                // float finalSDF = sdf * 1;
                fixed4 color = fixed4(1, 1, 1, 1) * finalSDF;
                return saturate(color);
            }


            fixed4 SDFRect(fixed2 coord, fixed2 size, fixed2 center = fixed2(0.5, 0.5)){
                coord = coord - center;
                fixed2 sdf = abs(coord) - size;
                fixed finalSDF = -(length(max(sdf, 0)) + min(max(sdf.x, sdf.y), 0)) * 10000007;
                fixed4 color = fixed4(1, 1, 1, 1) * finalSDF;
                return saturate(color);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                fixed2 eyesLeft = fixed2(0.35, 0.6);
                fixed2 eyesRight = fixed2(0.65, 0.6);
                fixed2 mouthPos = fixed2(0.5, 0.3);
                // fixed2 mouthPos = curPosition;
                // col = SDFRect(i.uv, fixed2(0.2, 0.05), mouthPos);
                col = SDFCircle(i.uv, 0.4) - SDFCircle(i.uv, 0.07, eyesLeft) - SDFCircle(i.uv, 0.07, eyesRight);
                col -= SDFRect(i.uv, fixed2(0.12, 0.03), mouthPos);
                // col = fixed4(tempCol, tempCol, tempCol, 1);
                // col = 0.2;
                // col = testRect(i.uv, fixed2(0.5, 0.5), fixed2(0.2, 0.2));
                // clip(col);
                // col = SDFCircle(i.uv, 0.4);
                // col = SDFRect(i.uv, fixed2(0.4, 0.2));
                return col;
            }
            ENDCG
        }
    }
}
