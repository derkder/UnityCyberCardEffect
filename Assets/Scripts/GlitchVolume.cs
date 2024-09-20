using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
[System.Serializable, VolumeComponentMenu("Custom/GlitchVolume")]
public class GlitchVolume : VolumeComponent
{
    public BoolParameter isShow = new BoolParameter(false, true);
    [Tooltip("Strength of the line.")]
    public MinFloatParameter lineStrength = new MinFloatParameter(1, 0, true);
    [Tooltip("The color of the line.")]
    public ColorParameter lineColor = new ColorParameter(Color.black, true);
    [Tooltip("The color of the background.")]
    public ColorParameter baseColor = new ColorParameter(Color.white, true);
}
