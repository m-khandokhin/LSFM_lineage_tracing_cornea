dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {

	// Open files
	name = file_list[i];
	open(dir + name + "_GFP.tif");
	rename("GFP");
	open(dir + name + "_mCerulean.tif");
	rename("mCer");
	open(dir + name + "_YFP.tif");
	rename("YFP");
    
    // Correct mCer
    selectImage("GFP");
    run("Duplicate...", "duplicate");
    rename("GFP-mCer");
    run("Multiply...", "value=0.36 stack");
    imageCalculator("Substract stack", "mCer","GFP-mCer");
    selectImage("GFP-mCer");
    close();
    selectImage("mCer");
    saveAs("Tiff", dir + "Corrected_Confetti/" + name + "_mCer_corr.tiff");
    close();
    
    // Correct YFP
    selectImage("GFP");
    run("Duplicate...", "duplicate");
    rename("GFP-YFP");
    run("Multiply...", "value=0.16 stack");
    imageCalculator("Substract stack create", "YFP","GFP-YFP");
    rename("YFP_corr");
    selectImage("GFP-YFP");
    close();
    selectImage("YFP_corr");
    saveAs("Tiff", dir + "Corrected_Confetti/" + name + "_YFP_corr.tiff");
    close();
    
    // Correct GFP
    selectImage("YFP");
    run("Multiply...", "value=0.66 stack");
    imageCalculator("Substract stack", "GFP","YFP");
    selectImage("YFP");
    close();
    selectImage("GFP");
    saveAs("Tiff", dir + "Corrected_Confetti/" + name + "_GFP_corr.tiff");
    close();
};