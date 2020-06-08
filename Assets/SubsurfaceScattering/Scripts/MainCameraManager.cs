using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainCameraManager : MonoBehaviour
{
    public Camera lightCam;
    public Material SSSDepthMapMaterial;

    void OnPreRender()
    {
        SSSDepthMapMaterial.SetMatrix("_WorldToLightMatrix", lightCam.worldToCameraMatrix);
        SSSDepthMapMaterial.SetMatrix("_LightProjectionMatrix", lightCam.projectionMatrix);
    }
}
