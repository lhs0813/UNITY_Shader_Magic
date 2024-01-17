using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HighBall : MonoBehaviour
{
    public bool change = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.W))
        {
            change = true;
        }
        if(change == true)
        {
            this.transform.localScale += new Vector3(0.0005f, 0.0005f, 0.0005f);
        }

    }
}
