/***
 * Excerpted from "Hello, Android! 2e",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/eband3 for more book information.
 ***/
package org.example.browserview;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnKeyListener;
import android.webkit.WebView;
// widgets
import android.widget.Button;
import android.widget.EditText;

// Menu stuff
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

public class BrowserView extends Activity {
	private EditText urlText;
	private Button goButton;
	private WebView webView;

	// ...

	@Override
	public void onCreate(Bundle savedInstanceState) {
		// ...
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		// Get a handle to all user interface elements
		urlText = (EditText) findViewById(R.id.url_field);
		goButton = (Button) findViewById(R.id.go_button);
		webView = (WebView) findViewById(R.id.web_view);
		// ...

		// Setup event handlers
		goButton.setOnClickListener(new OnClickListener() {
			public void onClick(View view) {
				openBrowser();
			}
		});
		urlText.setOnKeyListener(new OnKeyListener() {
			public boolean onKey(View view, int keyCode, KeyEvent event) {
				if (keyCode == KeyEvent.KEYCODE_ENTER) {
					openBrowser();
					return true;
				}
				return false;
			}
		});
	}

	/** Open a browser on the URL specified in the text box */
	private void openBrowser() {
		webView.getSettings().setJavaScriptEnabled(true);
		webView.loadUrl(urlText.getText().toString());
	}

	/**
	 * Called when user selects any menu item.
	 */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		super.onCreateOptionsMenu(menu);
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.menu, menu);
		return true;
	}

	/**
	 * Called when user selects any menu item.
	 * Detects when user presses appropriate shortcut button and takes browser to that site.
	 * Shortcut keys for menu:
	 * "r": Roommate Helper
	 * "c": Cakewalk
	 * "d": Definitious
	 */
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		webView.getSettings().setJavaScriptEnabled(true);
		switch (item.getItemId()) {
		case R.id.rh_button:
			webView.loadUrl(getString(R.string.rh_url));
			return true;
		case R.id.cakewalk_button:
			webView.loadUrl(getString(R.string.cakewalk_url));
			return true;
		case R.id.definitious_button:
			webView.loadUrl(getString(R.string.definitious_url));
			return true;
		}
		return false;
	}
}