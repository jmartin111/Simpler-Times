using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Date;
using Toybox.ActivityMonitor as Actv;

class MyGridView extends Ui.WatchFace {

	hidden var settingsChange		= false;
	hidden var btImage 				= null;
	hidden var energyImage 			= null;
	hidden var notificationImage 	= null;	
	hidden var device 				= null;
	hidden var rfont 				= null;
	hidden var btLink 				= false;
	
	//var SEGMENT_LEN = 6; 
	
    function initialize() {
        WatchFace.initialize();        
    }  	

    //! Load your resources here
    function onLayout(dc) {
		var backgroundProperty = getColorProp("BackgroundColor");
		device = Ui.loadResource(Rez.Strings.deviceModel);
		rfont  = Ui.loadResource(Rez.Fonts.ocr_a_extnd);

        // avoid crash caused by Garmin Connect Mobile
        if (backgroundProperty == null) {
            backgroundProperty = 0;
        }

        // avoid crash caused by Garmin Connect Mobile
        if (backgroundProperty instanceof Lang.String) {
            backgroundProperty = backgroundProperty.toNumber();
        }
        
        if (backgroundProperty == Gfx.COLOR_BLACK) {
        	setLayout(Rez.Layouts.MainLayout(dc));
        	btImage = Ui.loadResource(Rez.Drawables.BluetoothIconWhite);
        	energyImage = Ui.loadResource(Rez.Drawables.EnergyIconWhite);
        	notificationImage = Ui.loadResource(Rez.Drawables.NotificationIconWhite);
        
        } else if (backgroundProperty == Gfx.COLOR_WHITE) {
			setLayout(Rez.Layouts.BlackLabelLayout(dc));
			btImage = Ui.loadResource(Rez.Drawables.BluetoothIconBlack);
			energyImage = Ui.loadResource(Rez.Drawables.EnergyIconBlack);
			notificationImage = Ui.loadResource(Rez.Drawables.NotificationIconBlack);
		
		} else if (backgroundProperty == Gfx.COLOR_LT_GRAY) {
			setLayout(Rez.Layouts.BlackLabelLayout(dc));
			btImage = Ui.loadResource(Rez.Drawables.BluetoothIconBlackForGray);
			energyImage = Ui.loadResource(Rez.Drawables.EnergyIconBlackForGray);
			notificationImage = Ui.loadResource(Rez.Drawables.NotificationIconBlackForGray);
		}
		
		settingsChange = false;
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }
	
    //! Update the view
    function onUpdate(dc) {
    	var width 	= dc.getWidth();
    	var height	= dc.getHeight();
    	
    	//swap the layout if the color rules call for it
		if (settingsChange) {
			onLayout(dc);
		}
			
		//get battery info
		var sysStats 		= Sys.getSystemStats();
		var sBatteryLife 	= sysStats.battery.format("%.0f")+"%";
    	
    	//get and format date info    	
    	var now 		= Time.now();
		var info 		= Date.info(now, Time.FORMAT_MEDIUM);		
		var sDayOfWeek 	= info.day_of_week.toString().toUpper();
    	var sDay 		= info.day.toString();
    	var sDate 		= sDayOfWeek + " " + sDay;   	
    	
    	//get and format time info
		var timeFormat 	= "$1$:$2$";
    	var clock 		= Sys.getClockTime();
		var hour		= clock.hour; //define this for use below
    	
    	if (!Sys.getDeviceSettings().is24Hour) {
            if (hour > 12) {
                hour = hour - 12;
            }
            if (hour == 0) {
            	hour = 12;
            }
        } else {
        	timeFormat = "$1$$2$";
            hour = hour.format("%02d");
        }
        
        var sTime = Lang.format(timeFormat, [hour, clock.min.format("%02d")]);
        //Sys.println(Sys.getDeviceSettings().is24Hour); 
           	
    	//get activity monitoring info
		var activMon 		= Actv.getInfo();
		var stepGoal 		= activMon.stepGoal;
		var currentSteps 	= activMon.steps;
		var distanceKm		= activMon.distance.toFloat() / 100000;
		var distanceMi		= distanceKm * 0.6213;
		var calories		= activMon.calories;
		var sSteps			= currentSteps.format("%04d") + " STP"; //+ "/" + stepGoal.format("%02d");
		var sDistance		= distanceKm.format("%.02f") + " Km";
		var sCalories		= "CALS " + calories.format("%04d");
		
		if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) {
			sDistance = distanceMi.format("%.02f") + " Mi";
		}
    	
    	//initialize the string views
		var dTime = View.findDrawableById("TimeLabel"); 
		dTime.setFont(rfont);
		dTime.setText(sTime);
		dTime.setColor(App.getApp().getProperty("TimeColor"));
		View.findDrawableById("DateLabel").setText(sDate);
   		View.findDrawableById("BatteryLabel").setText(sBatteryLife); 
    	View.findDrawableById("CurrentStepsLabel").setText(sSteps); 
    	View.findDrawableById("DistanceLabel").setText(sDistance); 
    	View.findDrawableById("CaloriesLabel").setText(sCalories);
    	
    	var sDistDims 	= dc.getTextDimensions(sDistance, Gfx.FONT_TINY);
    	var sDistWidth 	= sDistDims[0];
    	var sDistHeight = sDistDims[1];
    	    	
    	//! update the view
		//! for some reason this is the best place to put it
		View.onUpdate(dc);
 		
 		//check bluetooth link
		if (Sys.getDeviceSettings().phoneConnected) {
			btLink = true;
		} else {
			btLink = false;
		}			
		
		//get and format notifications
		var vNotifications = View.findDrawableById("NotificationCount");
		var notifyCount = Sys.getDeviceSettings().notificationCount;
		var sNotifyCount = notifyCount.format("%d");
		
		//prep color and pen for accent lines
 		dc.setColor(getColorProp("TimeColor"), Gfx.COLOR_TRANSPARENT);
 		dc.setPenWidth(2);
		
		//draw bitmaps and accent lines based on device
		if (device.equals("fr235") || device.equals("fr630")) {
			if (btLink) { dc.drawBitmap(150, 32, btImage); }			
			dc.drawBitmap(164, 32, notificationImage);
			dc.drawBitmap(22, 32, energyImage);
			dc.drawLine(0, (height/2) - 61, (width), (height/2) - 61); // top hline
			dc.drawRoundedRectangle(0, height - 48, width/2 - 5, 22, 5);
			dc.drawRoundedRectangle(width/2 + 5, height - 48, width/2, 22, 5);			
		} else if (device.equals("fenix3") || device.equals("fenix3_hr") || device.equals("d2bravo")) {
			if (btLink) { dc.drawBitmap(152, 49, btImage); }
			dc.drawBitmap(166, 49, notificationImage);
			dc.drawBitmap(25, 49, energyImage);
			dc.drawLine(0, (height/2) - 64, (width), (height/2) - 64); // top hline
			dc.drawRoundedRectangle(0, height - 62, width/2 - 3, 22, 5);
			dc.drawRoundedRectangle(width/2 + 3, height - 62, width/2, 22, 5);
		} else if (device.equals("vivoactive")) {
			if (btLink) { dc.drawBitmap(152, 8, btImage); }
			dc.drawBitmap(166, 8, notificationImage);
			dc.drawBitmap(10, 8, energyImage);
			dc.drawLine(0, (height/2) - 44, (width), (height/2) - 44); // top hline
			dc.drawRoundedRectangle(width/2 - sDistWidth/2 - 5,
									height - 27,
									sDistWidth + 10,
									sDistHeight + 2,
									5);
		}
		
		vNotifications.setText(sNotifyCount);
   	}
   	
   	function getColorProp(key) {   		
   		var keyValue = App.getApp().getProperty(key);
   		
   		if (keyValue != null) {
   			return keyValue;
   		} else {   		
	   		return Gfx.COLOR_GREEN; // a default
	   	}
   	}
   	
   	function onSettingsChanged() {
        settingsChange = true;
        Ui.requestUpdate();
    }
	
    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
}
