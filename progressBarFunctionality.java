// fr235 et. al
//dc.drawRectangle(width/2 - 90, height/2 - 61, 180, 8);
//update activity progress
var colorMask = 0xFFFFFF;
if (currentSteps != null and stepGoal != null) {
	//call only while goal hasn't been met
	dc.setPenWidth(4);
	dc.setColor(colorMask ^ getColorProp("BackgroundColor"),
				Gfx.COLOR_TRANSPARENT);				
	if (currentSteps <= stepGoal) {
		var progressWidth = getStepProgress(currentSteps, stepGoal);
		dc.drawLine(width/2 - 90, (height/2) - 62, progressWidth * 1.8, (height/2) - 62);
		//dc.fillRectangle(width/2 - 39, height/2 - 60, progressWidth*0.80-2, 5);
	} else {
		dc.drawLine(width/2 - 90, (height/2) - 62, 180, (height/2) - 62);
	}
}

// fenix3 et. al
//update activity progress
var colorMask = 0xFFFFFF;
if (currentSteps != null and stepGoal != null) {
	//call only while goal hasn't been met
	dc.setColor(colorMask ^ getColorProp("BackgroundColor"),
				Gfx.COLOR_TRANSPARENT);				
	if (currentSteps <= stepGoal) {
		var progressWidth = getStepProgress(currentSteps, stepGoal);
		dc.fillRectangle(width/2 - 39, height/2 - 63, progressWidth*0.80-2, 5);
	} else {
		dc.fillRectangle(width/2 - 39, height/2 - 63, 77, 5);
	}
}

// support functions
function getStepProgress(currentSteps, stepGoal) {
   		return (currentSteps.toFloat() / stepGoal.toFloat()) * 100;
   	}
   	
   	function getColorProp(key) {
   		
   		var keyValue = App.getApp().getProperty(key);
   		
   		if (keyValue != null) {
   			return keyValue;
   		} else {   		
	   		return Gfx.COLOR_GREEN; // a default
	   	}
   	}