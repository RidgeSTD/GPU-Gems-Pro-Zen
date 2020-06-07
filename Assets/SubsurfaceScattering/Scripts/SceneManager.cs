using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneManager : MonoBehaviour
{
    public Camera lightCam;
    public Light mainLight;

    void Start()
    {
        if (mainLight.type == LightType.Directional)
        {
            lightCam.orthographic = true;
        }
        else
        {
            lightCam.orthographic = false;
        }
    }

    void Update()
    {

    }
}