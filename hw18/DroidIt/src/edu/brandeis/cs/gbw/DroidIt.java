/**
 * Author: Gabe Berke-Williams
 * DroidIt main class file.
 * Adds onClick listeners, pulls in main view elements, etc.
 */
package edu.brandeis.cs.gbw;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
// For menu
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

public class DroidIt extends Activity implements OnClickListener {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

		// Set up click listeners for all the buttons
		Button continueButton = (Button) findViewById(R.id.continue_button);
		continueButton.setOnClickListener(this);
		Button newButton = (Button) findViewById(R.id.new_game_button);
		newButton.setOnClickListener(this);
		Button aboutButton = (Button) findViewById(R.id.about_button);
		aboutButton.setOnClickListener(this);
		Button exitButton = (Button) findViewById(R.id.exit_button);
		exitButton.setOnClickListener(this);
    }
    
    /**
     * onClick listener method for buttons on main/home screen. Currently only responds to About button.
     */
    public void onClick(View v) {
    	switch(v.getId()){
    	case R.id.about_button:
    		// Start anonymous Intent
    		Intent i = new Intent(this, About.class);
    		startActivity(i);
    		break;
    	}
	}

    /**
     * Create options menu for main app. Pops up when settings softbutton is pressed.
     */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		// getMenuInflater returns an instance of MenuInflater
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

	/**
	 * Called when user selects any menu item. Currently only does something when settings button is pressed.
	 */
	/*
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.settings:
			// Prefs class displays preferences and allows user to change them.
			startActivity(new Intent(this, Prefs.class));
			return true;
		}
		return false;
	}
	*/
}