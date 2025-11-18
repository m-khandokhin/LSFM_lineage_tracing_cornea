dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
	open(dir + "Segmented_nuclei/" + name + "_epi_nuclei.tiff");
	
	// Threshold
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Epithelium");
    
    // Volume calculation - it measures micrometers, not pixels
    run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
    saveAs("Results", dir + "Analysis/Compartment_segmentation/Epithelium/" + name + "_volume.csv");
    close("*");
};
for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
	open(dir + "Segmented_nuclei/" + name + "_stroma_nuclei.tiff");
	
	// Threshold
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Stroma");
    
    // Nuclei number calculation
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=0 max_size=-1 32-bit");
    close("*");
};
for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
	open(dir + "Segmented_nuclei/" + name + "_endo_nuclei.tiff");
	
	// Threshold
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Endothelium");
    
    // Nuclei number calculation - min_size in pixels
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=1000 max_size=-1 32-bit");
    close("*");
};