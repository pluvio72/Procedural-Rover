using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu()]
public class TextureData : UpdatableData {

	public int colorCount;

	public Texture texture;
	[Range(0,1.5f)]
	public float randomness;

	public Color[] baseColors;
	[Range(0,1)]
	public float[] baseStartHeights;
	[Range(0,1)]
	public float[] baseBlends;

	float savedMinHeight;
	float savedMaxHeight;

	public void ApplyToMaterial(Material material)
	{
		material.SetInt("baseColorCount", colorCount);
		material.SetColorArray("baseColors", baseColors);
		material.SetFloatArray("baseStartHeights", baseStartHeights);
		material.SetFloatArray("baseBlends", baseBlends);
		material.SetFloat("randomness", randomness);
		material.SetTexture("tex", texture);

		UpdateMeshHeights(material, savedMinHeight, savedMaxHeight);
	}

	public void UpdateMeshHeights(Material material, float minHeight, float maxHeight)
	{
		savedMinHeight = minHeight;
		savedMaxHeight = maxHeight;

		material.SetFloat("minHeight", minHeight);
		material.SetFloat("maxHeight", maxHeight);
	}

}
