﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthDraw : MonoBehaviour
{
	public Material mat;

    // Start is called before the first frame update
    void Start()
    {
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, mat);
	}
}
