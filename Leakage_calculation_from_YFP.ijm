dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
    
    open(dir + name + "_tdimer.tif");
    rename("tdimer");
    open(dir + name + "_YFP.tif");
    rename("YFP");
    
    // Make Prrx1+ mask
    selectImage("YFP");
    
    run("Duplicate...", "duplicate");
    
    rename("Mask_YFP");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Mask_YFP");
	
	selectImage("tdimer");
    
    rename("Mask_tdimer");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Mask_tdirmer");
    
    // Make joint mask
    imageCalculator("Multiply stack", "Mask_tdimer", "Mask_YFP");
    selectImage("Mask_YFP");
    close();
    
    open(dir + name + "_GFP.tif");
    rename("GFP");
    
	// Measure mean intensities
	run("Intensity Measurements 2D/3D", "input=GFP labels=Mask_tdimer mean");
	saveAs("Results", dir + "Analysis/Leakage_estimation/Leakages/" + name + "_YFP-GFP.csv");
	
	run("Intensity Measurements 2D/3D", "input=YFP labels=Mask_tdimer mean");
	saveAs("Results", dir + "Analysis/Leakage_estimation/Leakages/" + name + "_YFP-YFP.csv");
	
	close("*");
};
