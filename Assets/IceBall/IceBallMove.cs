using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IceBallMove : MonoBehaviour
    //private Rigidbody rb;
    
{
    public bool change = false;
    public float thrust = 1.0f; //미는 힘
    public Rigidbody rb; // 해당 리지드바디
    float time = 0.0f;
    public bool I_Change = false;
    // Start is called before the first frame update
    void Start()
    {
        //AddForce(Vector3.up * 12.0f, ForceMode.Acceleration);
        rb = GetComponent<Rigidbody>();
    }

    void OnTriggerStay(Collider col)
    {
        rb.AddForce(Vector3.up * 12.0f, ForceMode.Acceleration);
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.W))
        {
            change = true; 
            rb.AddForce(Vector3.up * 270.0f, ForceMode.Acceleration);
            rb.AddForce(Vector3.right * 200.0f, ForceMode.Acceleration);
            rb.AddForce(Vector3.forward * 30.0f, ForceMode.Acceleration);
        }
        if(change == true)
        {
            //this.transform.localScale += new Vector3(10.0f, 100.0f, 10.0f);
        }

        time += Time.deltaTime;

        if (time >= 9)
        {
            Destroy(gameObject);
            //++GameController.controller.removedGrenades;
            Debug.Log("Destroyed");
            I_Change = true;
        }

    }

}
