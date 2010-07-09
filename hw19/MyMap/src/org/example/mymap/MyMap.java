/**
 * Author: Gabe B-W
 * Date: 7/8/2010
 * 
 * MyMap class.
 * Uses MapView etc. to display a zoomable map using Google Map API.
 * When user presses "Menu", a menu pops up allowing the user to select one
 * of 3 views for the map:
 * - Traffic (default)
 * - Satellite
 * - Street View
 * There is also a settings page with checkboxes and a ListPreference, but it doesn't
 * actually do anything.
 */
/***
 * Excerpted from "Hello, Android! 2e",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/eband3 for more book information.
***/
package org.example.mymap;

import android.content.Intent;
import android.os.Bundle;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapActivity;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.MyLocationOverlay;

import android.widget.Button;
import android.widget.TextView;
// onClick stuff
import android.view.View;
import android.view.View.OnClickListener;
// Menu stuff
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;


public class MyMap extends MapActivity implements OnClickListener {
   private MapView map;
   private MapController controller;
   private Button showLatitudeLongitudeButton;
   private TextView position;
   private MyLocationOverlay overlay;
   
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.main);
		initMapView();

		overlay = new MyLocationOverlay(this, map);
		initMyLocation();

		showLatitudeLongitudeButton = (Button) findViewById(R.id.show_latitude_longitude_button);
		position = (TextView) findViewById(R.id.position);

		showLatitudeLongitudeButton.setOnClickListener(this);
	}

   /** Find and initialize the map view. */
   private void initMapView() {
      map = (MapView) findViewById(R.id.map);
      controller = map.getController();
      map.setTraffic(true); // default to Traffic view
      map.setBuiltInZoomControls(true);
   }

   /** Start tracking the position on the map. */
   private void initMyLocation() {
      overlay.enableMyLocation();
      //overlay.enableCompass(); // does not work in emulator
      overlay.runOnFirstFix(new Runnable() {
         public void run() {
            // Zoom in to current location
            controller.setZoom(8);
            controller.animateTo(overlay.getMyLocation());
         }
      });
      map.getOverlays().add(overlay);
   }
   
	/**
	 * Update position TextView with user's current location. Called when
	 * showLatitudeLongitudeButton is pressed.
	 */
   private void updatePosition(){
	   GeoPoint g = overlay.getMyLocation();
	   double longitude = g.getLongitudeE6() / 1E6;
	   double latitude = g.getLatitudeE6() / 1E6 ;
	   position.setText("lat: " + latitude + " / long: " + longitude);
   }
   
   public void onClick(View v){
	   switch(v.getId()){
	   case(R.id.show_latitude_longitude_button):
		   updatePosition();
		   break;
	   default:
		   // Nothing
		   break;
	   }
   }

   /**
    * Required by MapActivity. Just returns false, for now.
    */
   @Override
   protected boolean isRouteDisplayed() {
      return false;
   }
   
   /**
    * Called when user presses Menu button. Inflates menu from res/menu/menu.xml
    */
   @Override
   public boolean onCreateOptionsMenu(Menu menu){
	   super.onCreateOptionsMenu(menu);
	   MenuInflater inflater = getMenuInflater();
	   inflater.inflate(R.menu.menu, menu);
	   return true;
   }
   
	/**
	 * Display map using only traffic view (satellite and street view are turned
	 * off).
	 */
	private void showOnlyTraffic() {
		map.setTraffic(true);
		map.setStreetView(false);
		map.setSatellite(false);
	}

	/**
	 * Display map using only satellite view (traffic and street view are turned
	 * off).
	 */
	private void showOnlySatellite() {
		map.setSatellite(true);
		map.setTraffic(false);
		map.setStreetView(false);
	}

	/**
	 * Display map using only street view (traffic and satellite view are turned
	 * off).
	 */
	private void showOnlyStreetView() {
		map.setStreetView(true);
		map.setSatellite(false);
		map.setTraffic(false);
	}
   
	/**
	 * Called when user selects a menu item. Sets view mode (traffic / street
	 * view / satellite) appropriately depending on which button was clicked.
	 */
   @Override
   public boolean onOptionsItemSelected(MenuItem item){
	   switch(item.getItemId()){
	   case R.id.traffic_button:
		   showOnlyTraffic();
		   return true;
	   case R.id.street_view_button:
		   showOnlyStreetView();
		   return true;
	   case R.id.satellite_button:
		   showOnlySatellite();
		   return true;
	   case R.id.settings:
		   // Go to prefs page
		   Intent prefsIntent = new Intent(this, Prefs.class);
		   startActivity(prefsIntent);
		   return true;
	   }
	   return false;
	}
}