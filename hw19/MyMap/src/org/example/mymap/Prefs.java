package org.example.mymap;

import android.os.Bundle;
import android.preference.PreferenceActivity;

/*
 * Ideally I would be able to change the MapView (e.g. to street view mode) whenever
 * a preference is changed, but there seems to be no easy way to pass data that way.
 * startActivityForResult() is promising, but I'll just leave it as-is for now.
 * It's pretty, if non-functional.
 */
/*
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
*/

public class Prefs extends PreferenceActivity /* implements OnPreferenceChangeListener */ {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.xml.settings);
		
		/*
		Preference pref = findPreference("view_list_preference");
	    pref.setOnPreferenceChangeListener(this);
	    */
	}

	/**
	 * Called when a preference changes its value. Returns true to update the
	 * state of the Preference with the new value.
	 */
	/*
	public boolean onPreferenceChange(Preference preference, Object newValue) {
		String viewString = (String) newValue;
		if( viewString.equals("traffic") ){
			return true;
		} else if( viewString.equals("street_view") ) {
			return true;
		} else if( viewString.equals("satellite") ){
			return true;
		}
		return false;
	}
	*/
}
