using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PuluseNoiseController : MonoBehaviour
{
	IEnumerator GeneratePuluseNoise()
	{
		for(int i = 0; i <= 180; i += 30)
		{
			GetComponent<Renderer>().material.SetFloat("_Amount", 0.2f * Mathf.Sin(i * Mathf.Deg2Rad));
			yield return null;
		}
	}

	// Update is called once per frame
	void Update()
	{
		if(Mathf.Floor(Time.time % 2) == 0)
		{
			StartCoroutine(GeneratePuluseNoise());
		}
	}
}
