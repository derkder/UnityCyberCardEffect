Shader "Custom/UI/UIBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)

        // 故障效果属性
        _BlockLayer1_U ("Block Layer 1 U", Float) = 10.0
        _BlockLayer1_V ("Block Layer 1 V", Float) = 10.0
        _BlockLayer2_U ("Block Layer 2 U", Float) = 5.0
        _BlockLayer2_V ("Block Layer 2 V", Float) = 5.0
        _BlockLayer1_Intensity ("Block Layer 1 Intensity", Float) = 1.0
        _BlockLayer2_Intensity ("Block Layer 2 Intensity", Float) = 1.0
        _RGBSplit_Intensity ("RGB Split Intensity", Float) = 0.5
        _Offset ("Offset", Float) = 1.0
        _Fade ("Fade", Range(0,1)) = 0.5
    }
    SubShader
    { 
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
        }
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;

            // 故障效果属性
            float _BlockLayer1_U;
            float _BlockLayer1_V;
            float _BlockLayer2_U;
            float _BlockLayer2_V;
            float _BlockLayer1_Intensity;
            float _BlockLayer2_Intensity;
            float _RGBSplit_Intensity;
            float _Offset;
            float _Fade;

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _Color;
                o.texcoord.x = v.texcoord.x;
                o.texcoord.y = 1 - v.texcoord.y;
                return o;
            }

            float randomNoise(float2 seed)
            {
                return frac(sin(dot(seed * floor(_Time.x * 30.0), float2(127.1, 311.7))) * 43758.5453123);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.texcoord;
                return tex2D(_MainTex, uv);
                //return float4(_Fade, 0, 0, 0);
                //float4 color = tex2D(_MainTex, uv);

                //return float4(color.rgb, 1);

                // 故障效果计算
                float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
                float2 blockLayer2 = floor(uv * float2(_BlockLayer2_U, _BlockLayer2_V));

                float lineNoise1 = pow(randomNoise(blockLayer1), _BlockLayer1_Intensity);
                float lineNoise2 = pow(randomNoise(blockLayer2), _BlockLayer2_Intensity);
                float RGBSplitNoise = pow(randomNoise(5.1379), 7.1) * _RGBSplit_Intensity;
                float lineNoise = lineNoise1 * lineNoise2 * _Offset - RGBSplitNoise;

                //return float4(lineNoise, lineNoise, lineNoise, lineNoise);

                //把下面的0.05改成0.1变化会大一点
                float4 colorR = tex2D(_MainTex, uv);
                float4 colorG = tex2D(_MainTex, uv + float2(lineNoise * 0.05 * randomNoise(7.0), 0));
                float4 colorB = tex2D(_MainTex, uv - float2(lineNoise * 0.05 * randomNoise(23.0), 0));
                //float4 colorG = tex2D(_MainTex, uv + float2(0.01, 0.01));
                //float4 colorB = tex2D(_MainTex, uv - float2(0.01, 0.01));

                //return float4(colorR.rgb, 1);
                // 组合RGB通道以创建故障效果
                float4 glitchResult = float4(colorR.r, colorG.g, colorB.b, 1);
                //glitchResult = lerp(colorR, glitchResult, _Fade);

                return glitchResult;
            }
            ENDCG
        }
    }
}
