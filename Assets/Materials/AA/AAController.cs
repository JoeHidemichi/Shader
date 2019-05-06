﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AAController : MonoBehaviour
{
	public Material mat;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, mat);
	}
}
