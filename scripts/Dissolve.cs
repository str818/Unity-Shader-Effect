using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dissolve : MonoBehaviour {

    public Material DissolveMaterial;//消融材质
	void Start () {
        DissolveMaterial.SetFloat("_Threshold", 0f);
	}
	
	void Update () {
      DissolveMaterial.SetFloat("_Threshold", DissolveMaterial.GetFloat("_Threshold")+0.005f);
        if (DissolveMaterial.GetFloat("_Threshold") >= 1.5)
        {
            DissolveMaterial.SetFloat("_Threshold", 0f);
            transform.GetComponent<Animation>().Play();
        }
    }

    private void OnDisable()
    {
        DissolveMaterial.SetFloat("_Threshold", 0f);
    }
}
