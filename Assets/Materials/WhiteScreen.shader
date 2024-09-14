Shader "Custom/UI/UIBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
        _Threshold ("Bloom Threshold", Range(0, 1)) = 0.8
        _SoftKnee ("Soft Knee", Range(0, 1)) = 0.5
        _Intensity ("Bloom Intensity", Range(0, 10)) = 1.0
        _BlurSize ("Blur Size", Range(1, 10)) = 4
        _Speed ("Intensity Speed", Range(0.1, 10)) = 1.0
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
            float4 _MainTex_TexelSize;
            fixed4 _Color;

            float _Threshold;
            float _SoftKnee;
            float _Intensity;
            int _BlurSize;
            float _Speed;

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
                o.texcoord = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1. 获取原始颜色
                fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;

                // 2. 提取高亮部分
                float luminance = dot(col.rgb, float3(0.2126, 0.7152, 0.0722));
                float knee = _Threshold * _SoftKnee;
                float soft = luminance - _Threshold + knee;
                soft = saturate(soft / (2.0 * knee));
                float bloomFactor = max(soft, step(_Threshold, luminance));

                fixed3 bloom = col.rgb * bloomFactor;

                // 3. 模糊处理
                fixed3 blurredBloom = fixed3(0, 0, 0);
                int samples = (_BlurSize * 2 + 1) * (_BlurSize * 2 + 1);
                for (int x = -_BlurSize; x <= _BlurSize; x++)
                {
                    for (int y = -_BlurSize; y <= _BlurSize; y++)
                    {
                        float2 offset = float2(x, y) * _MainTex_TexelSize.xy;
                        blurredBloom += tex2D(_MainTex, i.texcoord + offset).rgb * bloomFactor;
                    }
                }
                blurredBloom /= samples;

                // 4. 合并结果
                //fixed3 finalColor = col.rgb + blurredBloom * _Intensity;
                float dynamicIntensity = sin(_Time.y * _Speed) + 1.0; // 从0到2循环变化
                fixed3 finalColor = col.rgb + blurredBloom * dynamicIntensity;
                return fixed4(finalColor, col.a);
            }
            ENDCG
        }
    }
}
