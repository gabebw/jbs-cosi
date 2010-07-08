/***
 * Excerpted from "Hello, Android! 2e",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/eband3 for more book information.
***/
package org.example.mymap;

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

public class MyMap extends MapActivity implements OnClickListener {
   private MapView map;
   private MapController controller;
   private Button go;
   private TextView position;
   private MyLocationOverlay overlay;

   @Override
   public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      setContentView(R.layout.main);
      initMapView();
      initMyLocation();
      
      overlay = new MyLocationOverlay(this, map);
      
      go = (Button) findViewById(R.id.go_button);
      position = (TextView) findViewById(R.id.position);
      
      go.setOnClickListener(this);
   }

   /** Find and initialize the map view. */
   private void initMapView() {
      map = (MapView) findViewById(R.id.map);
      controller = map.getController();
      map.setSatellite(true);
      map.setBuiltInZoomControls(true);
   }

   /** Start tracking the position on the map. */
   private void initMyLocation() {
      //final MyLocationOverlay overlay = new MyLocationOverlay(this, map);
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
    * Update position TextView with user's current location. Called when Button#go is pressed.
    */
   private void updatePosition(){
	   GeoPoint g = overlay.getMyLocation();
	   position.setText("pos: " + g.toString());
   }
   
   public void onClick(View v){
	   switch(v.getId()){
	   case(R.id.go_button):
		   updatePosition();
		   break;
	   default:
		   // Nothing
		   break;
	   }
   }

   @Override
   protected boolean isRouteDisplayed() {
      // Required by MapActivity
      return false;
   }
}
