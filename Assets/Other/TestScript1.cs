using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Threading;

[ExecuteInEditMode]
public class TestScript1 : MonoBehaviour {

	private void Start()
	{
		RequestData(Callback);	
	}

	public void RequestData(Action<Data> action)
	{
		print(action);
	}

	public void Callback(Data data)
	{
		print(data.info + " " + data.id);
	}


	public class Data
	{
		public string info;
		public string id;

		public Data(string info, string id)
		{
			this.info = info;
			this.id = id;
		}
	}
}
