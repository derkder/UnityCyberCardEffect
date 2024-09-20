Shader "Custom/ScrollDoggy"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        _ScrollLightTex("Scroll Light Texture", 2D) = "black" {}
        _ScrollLightMaskTex("Scroll Light Mask Texture", 2D) = "black" {}
        _ScrollLightMoveSpeed("Scroll Light Move Speed", FLOAT) = 0
        [HDR]_Color("Color", COLOR) = (1, 1, 1, 1)

        _Offset("Offset", Float) = 1.0
        _Fade("Fade", Range(0, 1)) = 1.0
        _BlockLayer1_U("Block Layer 1 U", Float) = 10.0
        _BlockLayer1_V("Block Layer 1 V", Float) = 10.0
        _BlockLayer1_Indensity("Block Layer 1 Intensity", Float) = 1.0
        _BlockLayer2_U("Block Layer 2 U", Float) = 5.0
        _BlockLayer2_V("Block Layer 2 V", Float) = 5.0
        _BlockLayer2_Indensity("Block Layer 2 Intensity", Float) = 1.0
        _RGBSplit_Indensity("RGB Split Intensity", Float) = 1.0
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

            sampler2D _MainTex, _ScrollLightTex, _ScrollLightMaskTex;
            float4 _Color, _MainTex_ST, _ScrollLightTex_ST, _ScrollLightMaskTex_ST;
            float _ScrollLightMoveSpeed;

            float _Offset;
            float _Fade;
            float _BlockLayer1_U, _BlockLayer1_V, _BlockLayer1_Indensity;
            float _BlockLayer2_U, _BlockLayer2_V, _BlockLayer2_Indensity;
            float _RGBSplit_Indensity;

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
                float4 texcoord : TEXCOORD0; // xy: main, zw: scroll light
                float4 texcoord1 : TEXCOORD1; // xy: scroll light mask
            };

            float randomNoise(float2 seed)
            {
                return frac(sin(dot(seed * floor(_Time.x * 30.0), float2(127.1, 311.7))) * 43758.5453123);
            }

            float randomNoise(float seed)
            {
                return randomNoise(float2(seed, 1.0));
            }

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.texcoord.zw = TRANSFORM_TEX(v.texcoord, _ScrollLightTex);
                o.texcoord1.xy = TRANSFORM_TEX(v.texcoord, _ScrollLightMaskTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.texcoord.xy;

                // 获取原始颜色
                fixed4 col = tex2D(_MainTex, uv);

                // 滚动光效
                float4 scrollCol = tex2D(_ScrollLightTex, i.texcoord.zw + _ScrollLightMoveSpeed * _Time.y);
                float4 scrollColMask = tex2D(_ScrollLightMaskTex, i.texcoord1.xy);
                float whiteThreshold = 0.95;
                float maskFactor = smoothstep(whiteThreshold, 1.0, dot(scrollColMask.rgb, float3(0.333, 0.333, 0.333)));
                fixed4 scrollEffect = lerp(col, col + scrollCol * _Color * scrollColMask, maskFactor);
                return scrollEffect;

                // 故障效果
                //float2 blockLayer1 = floor(uv * float2(_BlockLayer1_U, _BlockLayer1_V));
                //float2 blockLayer2 = floor(uv * float2(_BlockLayer2_U, _BlockLayer2_V));

                //float lineNoise1 = pow(randomNoise(blockLayer1), _BlockLayer1_Indensity);
                //float lineNoise2 = pow(randomNoise(blockLayer2), _BlockLayer2_Indensity);
                //float RGBSplitNoise = pow(randomNoise(5.1379), 7.1) * _RGBSplit_Indensity;
                //float lineNoise = lineNoise1 * lineNoise2 * _Offset - RGBSplitNoise;

                //float4 colorR = tex2D(_MainTex, uv);
                //float4 colorG = tex2D(_MainTex, uv + float2(lineNoise * 0.05 * randomNoise(7.0), 0));
                //float4 colorB = tex2D(_MainTex, uv - float2(lineNoise * 0.05 * randomNoise(23.0), 0));
                //float temp = lineNoise * 0.1 * randomNoise(7.0);

                //return float4(temp, temp, temp, 1);

                //float4 glitchResult = float4(colorR.r, colorG.g, colorB.b, colorR.a + colorG.a + colorB.a);
                //return glitchResult;
                //glitchResult = lerp(colorR, glitchResult, _Fade);

                // 最终颜色，混合滚动光效和故障效果
                //fixed4 finalColor = lerp(scrollEffect, glitchResult, _Fade);

                //return finalColor;
            }

            ENDCG
        }
    }
}
