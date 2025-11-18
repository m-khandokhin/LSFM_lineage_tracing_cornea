dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {
	
	// ___________________________________ //
	//             EPITHELIUM              //
	// ____________________________________//
	
	// Open file 
	name = file_list[i];
	
	open(dir + name + "_nuclei_channel.tif");
	
	x = getWidth();
	y = getHeight();
	z = nSlices;
	
	rename("Epithelium");
    
    // Make primary epithelial binary mask
    selectImage("Epithelium");
    run("Gaussian Blur 3D...", "x=10 y=20 z=20");
    run("Gamma...", "value=1.5 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Epithelium");
    
    // Process binary mask
    run("Erode", "stack");
    run("Erode", "stack");
    run("Duplicate...", "duplicate");
    rename("Translated");
    run("Translate...", "x=-25 y=0 interpolation=None stack");
    imageCalculator("OR stack", "Epithelium","Translated");
    rename("Epithelium");
    selectImage("Translated");
    close();
    
    run("Duplicate...", "duplicate");
    rename("Translated");
    run("Translate...", "x=-35 y=0 interpolation=None stack");
    imageCalculator("OR stack", "Epithelium","Translated");
    rename("Epithelium");
    selectImage("Translated");
    close();
    
    // Process original image
    open(dir + name + "_nuclei_channel.tif");
    
	rename("Orig");
    run("Duplicate...", "duplicate");
    rename("Bg");
    run("Gaussian Blur 3D...", "x=5 y=5 z=5");
    imageCalculator("Substract stack create", "Orig","Bg");
    rename("SB");
    selectImage("Bg");
    close();
    selectImage("Orig");
    close();
    
    // Substract epithelium
    imageCalculator("Substract stack create", "SB", "Epithelium");
    rename("SB_non_epithelial");
    
    selectImage("Epithelium");
    close();
    
    // Select epithelium
    selectImage("Epithelium");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "SB", "Epithelium");
    rename("SB_epithelial");
    selectImage("Epithelium");
    run("Multiply...", "value=255 stack");
    run("Size...", "width=" + x / 10 + " height=" + y / 10 + " depth=" + z / 10 + " constrain average interpolation=Bilinear");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_epi_mask.tiff");
    close();
    
    // Save
    selectImage("SB_epithelial");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_epi_nuclei.tiff");
    close();
    
    // ___________________________________ //
	//               STROMA                //
	// ___________________________________ //
	
    // Make primary non-endothelial binary mask
    selectImage("SB_non_epithelial");
    run("Duplicate...", "duplicate");
    rename("Stroma_Endothelium");
    run("Gaussian Blur 3D...", "x=4 y=4 z=4");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Stroma_Endothelium");
    
    // Select objects less than 1000000 - stroma
    selectImage("Stroma_Endothelium");
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=0 max_size=1000000");
    selectImage("Bin");
    close();
    selectImage("Stroma_Endothelium");
    close();
    
    selectImage("Seg");
    run("Manual Threshold", "min=1 max=65535");
    run("Convert to Mask", "background=Dark black");
    rename("Stroma");
    
    // Substract stroma
    imageCalculator("Substract stack create", "SB_non_epithelial", "Stroma");
    rename("SB_non_epi_stroma");
    
    // Select stroma
    selectImage("Stroma");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "SB_non_epithelial", "Stroma");
    rename("SB_stromal");
    selectImage("Stroma");
    run("Multiply...", "value=255 stack");
    run("Size...", "width=" + x / 10 + " height=" + y / 10 + " depth=" + z / 10 + " constrain average interpolation=Bilinear");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_stroma_mask.tiff");
    close();
    
    // Save
    selectImage("SB_stromal");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_stroma_nuclei.tiff");
    rename("SB_stromal");
    
    // ___________________________________ //
	//            ENDOTHELIUM              //
	// ___________________________________ //
	
	// Fill stroma
	selectImage("SB_stromal");
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
	for(j = 0; j < 30; j++) {
		run("Dilate", "stack");
	};
	run("Gaussian Blur 3D...", "x=25 y=50 z=50");
	setAutoThreshold("Default dark 16-bit stack");
	setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Stroma");
    for(j = 0; j < 10; j++) {
		run("Dilate", "stack");
	};
	
    // Make a mask for endotheium
    run("Duplicate...", "duplicate");
    rename("Stroma-25");
    run("Translate...", "x=-25 y=0 interpolation=None stack");
    imageCalculator("Substract stack", "Stroma", "Stroma-25");
    rename("Endothelium");
    selectImage("Stroma-25");
    close();
    run("Duplicate...", "duplicate");
    rename("Endothelium_plus_20");
    run("Translate...", "x=20 y=0 interpolation=None stack");
    imageCalculator("OR stack", "Endothelium", "Endothelium_plus_20");
    selectImage("Endothelium_plus_20");
    close();
    
    run("Duplicate...", "duplicate");
    rename("Endothelium_plus_40");
    run("Translate...", "x=40 y=0 interpolation=None stack");
    imageCalculator("OR stack", "Endothelium", "Endothelium_plus_40");
    selectImage("Endothelium_plus_40");
    close();
    
    // Select endothelium by mask
    selectImage("Endothelium");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "SB_non_epi_stroma", "Endothelium");
    rename("SB_endothelium");
    selectImage("Endothelium");
    run("Multiply...", "value=255 stack");
    run("Size...", "width=" + x / 10 + " height=" + y / 10 + " depth=" + z / 10 + " constrain average interpolation=Bilinear");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_endo_mask.tiff");
    close();
    
    // Save
    selectImage("SB_endothelium");
    saveAs("Tiff", dir + "Segmented_nuclei/" + name + "_endo_nuclei.tiff");
    close();
};