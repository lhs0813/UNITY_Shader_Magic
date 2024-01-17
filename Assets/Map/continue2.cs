using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class continue2 : MonoBehaviour
{
    float x = 0;
    bool icing = false;

    // Start is called before the first frame update
    void Start()
    {
        //float continue = obj.GetComponent<Renderer>().material.SetFloat("_MixProgress");

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.A))
        {
            icing = true;
        }

        if (icing == true)
        {
            x += 0.01f;

        }
        
        transform.GetComponent<Renderer>().material.SetFloat("_MixProgress", x);

    }
}
