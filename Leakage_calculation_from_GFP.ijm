dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3";

for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
    
    open(dir + name + "_GFP.tif");
    rename("GFP");
    open(dir + name + "_mCerulean.tif");
    rename("mCer");
    open(dir + name + "_YFP.tif");
    rename("YFP");
    
    // Make Prrx1+ mask
    selectImage("GFP");
    
    run("Duplicate...", "duplicate");
    
    rename("Mask_Prrx1");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Mask_Prrx1");
	
	// Measure mean intensities
	run("Intensity Measurements 2D/3D", "input=GFP labels=Mask_Prrx1 mean");
	saveAs("Results", dir + "Analysis/Leakage_estimation/Leakages/" + name + "_GFP-GFP.csv");
	
	run("Intensity Measurements 2D/3D", "input=mCer labels=Mask_Prrx1 mean");
	saveAs("Results", dir + "Analysis/Leakage_estimation/Leakages/" + name + "_GFP-mCer.csv");
	
	run("Intensity Measurements 2D/3D", "input=YFP labels=Mask_Prrx1 mean");
	saveAs("Results", dir + "Analysis/Leakage_estimation/Leakages/" + name + "_GFP-YFP.csv");
	
	close("*");
};
