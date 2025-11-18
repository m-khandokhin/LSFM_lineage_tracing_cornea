dir = "/path/to/files/";
file_list = newArray("file_name_1", "file_name_2", "file_name_3");

for(i = 0; i < file_list.length; i++) {
	name = file_list[i];
    print(name);
    
    // Process GFP signal
    open(dir + name + "_GFP_channel.tif");
    rename("Prrx1");
    
    run("Subtract Background...", "rolling=30 stack");
    
    setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black create");
    rename("Prrx1");
	
	// Process epithelium
	print("Epithelium");
	
	open(dir + "Segmented_nuclei/" + name + "_epi_nuclei.tiff");
	
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Epithelium");
    
    imageCalculator("Multiply stack", "Epithelium", "Prrx1");
    
    selectImage("Epithelium");
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=1000 max_size=-1 32-bit");
    selectImage("Epithelium");
    close();
    selectImage("Bin");
    close();
    selectImage("Seg");
    close();
    
    // Process stroma
    print("Stroma");
    
    open(dir + "Segmented_nuclei/" + name + "_stroma_nuclei.tiff");
	
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Stroma");
    
    imageCalculator("Multiply stack", "Stroma", "Prrx1");
    
    selectImage("Stroma");
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=0 max_size=-1 32-bit");
    selectImage("Stroma");
    close();
    selectImage("Bin");
    close();
    selectImage("Seg");
    close();
    
    // Process endothelium
    print("Endothelium");
    
    open(dir + "Segmented_nuclei/" + name + "_endo_nuclei.tiff");
	
	run("Gamma...", "value=0.5 stack");
	
	setAutoThreshold("Default dark 16-bit stack");
    setOption("BlackBackground", true);
    run("Convert to Mask", "background=Dark black");
    rename("Endothelium");
    
    imageCalculator("Multiply stack", "Endothelium", "Prrx1");
    
    selectImage("Endothelium");
    run("3D Simple Segmentation", "seeds=None low_threshold=128 min_size=1000 max_size=-1 32-bit");
    selectImage("Endothelium");
    close();
    selectImage("Bin");
    close();
    selectImage("Seg");
    close();
    
    selectImage("Prrx1");
    close();
};
