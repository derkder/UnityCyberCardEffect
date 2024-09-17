// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Custom/Parallax"
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
                float4 tangent  : TANGENT;
                float3 normal   : NORMAL;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3x3 tangentToWorld : TEXCOORD2;
            };

            // float3 _WorldSpaceCameraPos;

            // 顶点着色器
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color * _Color;
                o.texcoord = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // 计算世界空间的法线、切线和双切线
                float3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 worldBitangent = cross(worldNormal, worldTangent) * tangentSign;

                // 构建切线到世界空间的矩阵
                o.tangentToWorld = float3x3(worldTangent, worldBitangent, worldNormal);

                return o;
            }

            // 片元着色器
            fixed4 frag (v2f i) : SV_Target
            {
                // 计算世界空间的视线方向
                //float3 viewDirWS = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 viewDirWS = mul((float3x3)unity_CameraToWorld, float3(0,0,1));

                // 将视线方向转换到切线空间
                float3 viewDirTS = mul(viewDirWS, (float3x3)i.tangentToWorld);

                // 在切线空间中定义法线
                float3 normalTS = float3(0, 0, 1);

                // 计算反射向量
                float3 reflectionVec = reflect(-viewDirTS, normalTS);

                // 调整 UV 坐标
                float2 newUV = i.texcoord + reflectionVec.xy;

                // 使用新的 UV 采样纹理
                fixed4 reflectionSample = tex2D(_MainTex, newUV);

                return reflectionSample;
            }
            ENDCG
        }
    }
}
