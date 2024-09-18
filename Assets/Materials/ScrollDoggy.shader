Shader "Custom/ScrollDoggy"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _ScrollLightTex("Scroll Light Texture", 2D) = "black" {}
        _ScrollLightMaskTex("Scroll Light Mask Texture", 2D) = "black" {}
        _ScrollLightMoveSpeed("Scroll Light Move Speed", FLOAT) = 0

        [HDR]_Color("Color", COLOR) = (1, 1, 1, 1)
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
                float4 texcoord : TEXCOORD0;//xy:main, zw:mask
                float4 texcoord1 : TEXCOORD1; // noise
            };

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
                // 1. 获取原始颜色
                fixed4 col = tex2D(_MainTex, i.texcoord.xy);
                float4 scrollCol = tex2D(_ScrollLightTex, i.texcoord.zw + _ScrollLightMoveSpeed * _Time.y);
                float4 scrollColMask = tex2D(_ScrollLightMaskTex, i.texcoord1.xy);

                // 2. 使用 lerp 判断 scrollColMask 是否接近白色
                float whiteThreshold = 0.95; // 白色阈值
                float maskFactor = smoothstep(whiteThreshold, 1.0, dot(scrollColMask.rgb, float3(0.333, 0.333, 0.333))); // 通过点乘近似灰度

                return lerp(col, col + scrollCol * _Color * scrollColMask, maskFactor);
            }

            ENDCG
        }
    }
}
