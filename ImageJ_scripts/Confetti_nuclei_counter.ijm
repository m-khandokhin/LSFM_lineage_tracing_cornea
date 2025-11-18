dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
	
    // Process stroma
    open(dir + "Segmented_nuclei/" + name + "_stroma_nuclei.tiff");
	
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Stroma");
    
    // Process endothelium
    open(dir + "Segmented_nuclei/" + name + "_endo_nuclei.tiff");
	
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Endothelium");
    
    // Open single markers
    open(dir + "Corrected_Confetti/" + name + "_GFP_corr.tiff");
    run("Subtract...", "value=25 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    
    rename("GFP");
    
    open(dir + "Corrected_Confetti/" + name + "_mCer_corr.tiff");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("mCer");
    
    open(dir + "Corrected_Confetti/" + name + "_YFP_corr.tiff");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("YFP");
    
    open(dir + name + "_tdimer.tif");
    run("Subtract Background...", "rolling=30 stack");
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("tdimer");
     
    // Label Stroma
    selectImage("Stroma");
    run("Connected Components Labeling", "connectivity=26 type=float");
    rename("Labelled_Stroma");
    selectImage("Stroma");
    close();
    
    run("Analyze Regions 3D", "centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_stroma_all.csv");
    
    // Label GFP
    selectImage("GFP");
    run("Duplicate...", "duplicate");
    rename("GFP_Stroma");
    run("32-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "GFP_Stroma", "Labelled_Stroma");
    selectImage("GFP_Stroma");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_stroma_gfp.csv");
    selectImage("GFP_Stroma");
    close();
    
    // Label YFP
    selectImage("YFP");
    run("Duplicate...", "duplicate");
    rename("YFP_Stroma");
    run("32-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "YFP_Stroma", "Labelled_Stroma");
    selectImage("YFP_Stroma");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_stroma_yfp.csv");
    selectImage("YFP_Stroma");
    close();
    
    // Label mCer
    selectImage("mCer");
    run("Duplicate...", "duplicate");
    rename("mCer_Stroma");
    run("32-bit");
    run("Divide...", "value=255 stack");
    
    imageCalculator("Multiply stack", "mCer_Stroma", "Labelled_Stroma");
    selectImage("mCer_Stroma");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_stroma_mcer.csv");
    selectImage("mCer_Stroma");
    close();
    
    // Label tdimer
    selectImage("tdimer");
    run("Duplicate...", "duplicate");
    rename("tdimer_Stroma");
    run("32-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "tdimer_Stroma", "Labelled_Stroma");
    selectImage("tdimer_Stroma");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_stroma_tdimer.csv");
    selectImage("tdimer_Stroma");
    close();
    selectImage("Labelled_Stroma");
    close();
    
    // Label Endothelium
    selectImage("Endothelium");
    run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
    rename("Conn_Endothelium");
    run("Label Size Filtering", "operation=Greater_Than size=1000");
    rename("Labelled_Endothelium");
    selectImage("Endothelium");
    close();
    selectImage("Conn_Endothelium");
    close();
    run("Analyze Regions 3D", "centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_endo_all.csv");
    
    // Label GFP
    selectImage("GFP");
    rename("GFP_Endothelium");
    run("16-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "GFP_Endothelium", "Labelled_Endothelium");
    selectImage("GFP_Endothelium");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_endo_gfp.csv");
    selectImage("GFP_Endothelium");
    close();
    
    // Label YFP
    selectImage("YFP");
    run("Duplicate...", "duplicate");
    rename("YFP_Endothelium");
    run("16-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "YFP_Endothelium", "Labelled_Endothelium");
    selectImage("YFP_Endothelium");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_endo_yfp.csv");
    selectImage("YFP_Endothelium");
    close();
    
    // Label mCer
    selectImage("mCer");
    rename("mCer_Endothelium");
    run("16-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "mCer_Endothelium", "Labelled_Endothelium");
    selectImage("mCer_Endothelium");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_endo_mcer.csv");
    selectImage("mCer_Endothelium");
    close();
    
    // Label tdimer
    selectImage("tdimer");
    rename("tdimer_Endothelium");
    run("16-bit");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply stack", "tdimer_Endothelium", "Labelled_Endothelium");
    selectImage("tdimer_Endothelium");
    run("Analyze Regions 3D", "  surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");
    saveAs("Results", dir + "Analysis/Confetti_calculation/" + name + "_endo_tdimer.csv");
    selectImage("tdimer_Endothelium");
    close();
    selectImage("Labelled_Endothelium");
    close();
    close("*");
};