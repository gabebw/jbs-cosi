package edu.brandeis.cs.gbw;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.view.View;
import android.view.View.OnClickListener;

public class FahrenheitToCelsius extends Activity implements OnClickListener {
	Button convertButton;
	EditText fahrenheitText;
	EditText celsiusText;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        convertButton = (Button) findViewById(R.id.convertButton);
        fahrenheitText = (EditText) findViewById(R.id.fahrenheitText);
        celsiusText = (EditText) findViewById(R.id.celsiusText);
        
        convertButton.setOnClickListener(this);
    }
   
    public void onClick(View v){
    	// Convert fahrenheit to celsius
    	String f = fahrenheitText.getText().toString();
    	Double fahrenheit = Double.parseDouble(f);
    	Double celsius = (fahrenheit - 32) * 5 / 9;
    	celsiusText.setText(String.valueOf(celsius));
    }
}