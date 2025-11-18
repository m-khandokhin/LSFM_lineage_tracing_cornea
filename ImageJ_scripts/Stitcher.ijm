// Input data
dir = "/path/to/files";
name = "name";
overlap = "15";
y_tiles = "8";
z_tiles = "4";
pos_number = 32;
pos_list = newArray("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31");
spim_list = newArray("SPIMA", "SPIMB");
spim_write_list = newArray("0", "90");
channel_list = newArray("channel_1", "channel_2", "channel_3", "channel_4", "channel_5");
channel_write_list = newArray("1", "2", "3", "4", "5");
channel_number = 5;

// Loop to deskew and convert to 8-bit all individual tiles
for(i=0;i<pos_number;i+=1) {
	pos = "Pos" + pos_list[i];
	for(j=0;j<2;j+=1) {
		spim = spim_list[j];
		for(k=0;k<channel_number;k+=1) {
			channel = channel_list[k];
			inner_dir = dir + "/" + pos + "/" + spim + "/" + channel;
			name = "SPIMang" + spim_write_list[j] + "-" + channel_write_list[k] + "-" + pos_list[i];
			
		    run("BigStitcher", "select=define define_dataset=[Automatic Loader (Bioformats based)] project_filename=" + name + 
		        ".xml path=" + inner_dir + " exclude=10 move_tiles_to_grid_(per_angle)?=[Do not move Tiles to Grid (use Metadata if available)]" + 
		        " how_to_store_input_images=[Load raw data directly (no resaving)]" + 
		        " load_raw_data_virtually metadata_save_path=/" + inner_dir + " image_data_save_path=/" + inner_dir);
		    if (spim == "SPIMB") {
		      run("Flip Axes", "select=file:/" + inner_dir + "/" + name + ".xml flip_y");
		      run("(De-)Skew Images", "select=file:/" + inner_dir + "/" + name + ".xml skew_direction=X skew_along_which_axis=Z angle=45");
		      run("Apply Transformations", "select=file:/" + inner_dir + "/" + name + ".xml" + 
                  " apply_to_angle=[All angles] apply_to_channel=[All channels]" + 
                  " apply_to_illumination=[All illuminations] apply_to_tile=[All tiles] apply_to_timepoint=[All Timepoints]" + 
                  " transformation=Rigid apply=[Current view transformations (appends to current transforms)]" + 
                  " define=[Rotation around axis]" + 
                  " axis_timepoint_0_channel_0_illumination_0_angle_0=y-axis rotation_timepoint_0_channel_0_illumination_0_angle_0=-45");
		      
		    } else {
		      run("(De-)Skew Images", "select=file:/" + inner_dir + "/" + name + ".xml skew_direction=X skew_along_which_axis=Z angle=-45");
		      run("Apply Transformations", "select=file:/" + inner_dir + "/" + name + ".xml" + 
                  " apply_to_angle=[All angles] apply_to_channel=[All channels]" + 
                  " apply_to_illumination=[All illuminations] apply_to_tile=[All tiles] apply_to_timepoint=[All Timepoints]" + 
                  " transformation=Rigid apply=[Current view transformations (appends to current transforms)]" + 
                  " define=[Rotation around axis]" + 
                  " axis_timepoint_0_channel_0_illumination_0_angle_0=y-axis rotation_timepoint_0_channel_0_illumination_0_angle_0=45");
		    };
        
            run("Image Fusion", "select=file:/" + inner_dir + "/" + name + ".xml" + 
                " process_angle=[All angles] process_channel=[All channels] process_illumination=[All illuminations]" + 
                " process_tile=[All tiles] process_timepoint=[All Timepoints] bounding_box=[All Views] downsampling=1" + 
                " interpolation=[Linear Interpolation] fusion_type=[Avg, Blending] pixel_type=[16-bit unsigned integer]" + 
                " interest_points_for_non_rigid=[-= Disable Non-Rigid =-] preserve_original produce=[Each timepoint & channel]" + 
                " fused_image=[Display using ImageJ] define_input=[Auto-load from input data (values shown below)]" + 
                " display=[precomputed (fast, complete copy in memory before display)] min_intensity=0 max_intensity=65535");
            setMinAndMax(0, 65535);
            setOption("ScaleConversions", true);
            run("8-bit");
            saveAs("Tiff", dir + "/" + name + ".tif");
            close("*");
		};
	};
};

// Define dataset
run("Define Multi-View Dataset", "define_dataset=[Automatic Loader (Bioformats based)] project_filename=" +
    name + ".xml path=" + dir + " exclude=10 pattern_0=Angles pattern_1=Channels pattern_2=Tiles " + 
    "move_tiles_to_grid_(per_angle)?=[Move Tile to Grid (Macro-scriptable)] grid_type=[Up & Left] " + 
    "tiles_x=" + z_tiles + " tiles_y=" + y_tiles + " tiles_z=1 overlap_x_(%)=" + overlap + " overlap_y_(%)=" + overlap + 
    " overlap_z_(%)=" + overlap + " keep_metadata_rotation grid_type=[Up & Left] tiles_x=" + z_tiles + " tiles_y=" + y_tiles + 
    " tiles_z=1 overlap_x_(%)=" + overlap + " overlap_y_(%)=" + overlap + " overlap_z_(%)=" + overlap + 
    " keep_metadata_rotation how_to_store_input_images=[Re-save as multiresolution OME-ZARR] load_raw_data_virtually" + 
    " metadata_save_path=file:/" + dir + " image_data_save_path=file:/" + dir + " check_stack_sizes" + 
    " compression=Zstandard downsampling_factors=[{ {1,1,1}, {2,2,1}, {4,4,2}, {8,8,4}, {16,16,8}, {32,32,16} }]" + 
    " block_size=[{ {128,128,64}, {128,128,64}, {128,128,64}, {128,128,64}, {128,128,64}, {128,128,64} }]" + 
    " compute_block_size_factor_x=7 compute_block_size_factor_y=7 compute_block_size_factor_z=1 number_of_threads=63");

// Detect interest points
run("Detect Interest Points for Registration", "browse=/" + dir + "/" + name + ".xml select=/" + dir + "/" + name + ".xml" + 
    " process_angle=[All angles] process_channel=[Single channel (Select from List)] process_illumination=[All illuminations]" + 
    " process_tile=[All tiles] process_timepoint=[All Timepoints] channel_1 type_of_interest_point_detection=Difference-of-Gaussian" + 
    " label_interest_points=beads define_anisotropy set_minimal_and_maximal_intensit limit_amount_of_detections subpixel_localization=None" + 
    " interest_point_specification=[Advanced ...] downsample_xy=2x downsample_z=1x minimal_intensity=0 maximal_intensity=255" + 
    " sigma=2.50000 threshold=0.02500 find_maxima image_sigma_x=0.50000 image_sigma_y=0.50000 image_sigma_z=0.50000" + 
    " maximum_number=1000000 type_of_detections_to_use=[Around median (of those above threshold)] compute_on=[CPU (Java)]");

// Register dataset (the first fast iteration)
run("Register Dataset based on Interest Points", "select=/" + dir + "/" + name + ".xml process_angle=[All angles]" + 
    " process_channel=[Single channel (Select from List)] process_illumination=[All illuminations] process_tile=[All tiles]" + 
    " process_timepoint=[All Timepoints] processing_channel=[channel 1] registration_algorithm=[Fast descriptor-based (rotation invariant)]" + 
    " registration_in_between_views=[Compare all views against each other] interest_point_inclusion=[Compare all interest point of overlapping views]" + 
    " interest_points=beads fix_views=[Fix first view] map_back_views=[Do not map back (use this if views are fixed)] transformation=Affine" + 
    " regularize_model model_to_regularize_with=Rigid lambda=0.10 redundancy=0 significance=10 allowed_error_for_ransac=5 inlier_factor=3" + 
    " number_of_ransac_iterations=Normal global_optimization_strategy=[Two-Round: Handle unconnected tiles, remove wrong links STRICT (2.5x / 3.5px)]");

// Reguster dataset (the second precise iteration)
run("Register Dataset based on Interest Points", "select=/" + dir + "/" + name + ".xml" + 
    " process_angle=[All angles] process_channel=[Single channel (Select from List)] process_illumination=[All illuminations]"  + 
    " process_tile=[All tiles] process_timepoint=[All Timepoints] processing_channel=[channel 1]" + 
    " registration_algorithm=[Assign closest-points with ICP (no invariance)]" + 
    " registration_in_between_views=[Only compare overlapping views (according to current transformations)]" + 
    " interest_point_inclusion=[Compare all interest point of overlapping views] interest_points=beads fix_views=[Fix first view]" + 
    " map_back_views=[Do not map back (use this if views are fixed)] transformation=Affine regularize_model model_to_regularize_with=Rigid" + 
    " lambda=0.10 maximal_distance=5 maximal_number=100 use_ransac allowed_error_for_ransac=3 ransac_iterations=200 minimal_number=12" + 
    " global_optimization_strategy=[Two-Round: Handle unconnected tiles, remove wrong links RELAXED (5.0x / 7.0px)]");

// Transfer transformations from the first to other channels
run("Duplicate Transformations", "apply=[One channel to other channels] select=/" + dir + "/" + name + ".xml" + 
    " apply_to_angle=[All angles] apply_to_illumination=[All illuminations] apply_to_tile=[All tiles] apply_to_timepoint=[All Timepoints]" + 
    " source=1 target=[All Channels] duplicate_which_transformations=[Replace all transformations]");

// Fuse and save images
run("Image Fusion", "select=/" + dir + "/" + name + ".xml process_angle=[All angles] process_channel=[All channels]" + 
    " process_illumination=[All illuminations] process_tile=[All tiles] process_timepoint=[All Timepoints]" + 
    " bounding_box=[All Views] downsampling=1 interpolation=[Linear Interpolation] fusion_type=[Avg, Blending]" + 
    " pixel_type=[8-bit unsigned integer] interest_points_for_non_rigid=[-= Disable Non-Rigid =-]" + 
    " produce=[Each timepoint & channel] fused_image=[Save as (compressed) TIFF stacks]" + 
    " define_input=[Auto-load from input data (values shown below)] output_file_directory=/" + dir + " filename_addition=" + name);
