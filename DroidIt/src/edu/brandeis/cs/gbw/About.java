/**
 * Author: Gabe Berke-Williams
 * DroidIt About class file. Deals with About activity ("about this app").
 * For now, just shows an about screen.
 */
package edu.brandeis.cs.gbw;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.view.View;

public class About extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.about);
	}
	public About() {
		// TODO Auto-generated constructor stub
	}

}
