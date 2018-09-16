/* 
 *  Micrograph_Analysis_Single.ijm
 *  Author: Pawel Cislo <pawel.cisloo@gmail.com> <pawelcislo.com>
 *  Version: 1.0
 *  Start of Development: 01/06/2018
 *  License: https://creativecommons.org/licenses/by-sa/4.0/
 *  
 *	REQUIREMENTS:
 *      1) ImageJ/Fiji distribution
 *			a) Fiji is recommended: https://imagej.net/Fiji/Downloads
 *      2) NND plugin: https://icme.hpc.msstate.edu/mediawiki/index.php/Nearest_Neighbor_Distances_Calculation_with_ImageJ
 *		3) Graph plugin: https://imagej.nih.gov/ij/plugins/graph/index.html
 *      4) Activation of BioVoxxel Toolbox: https://imagej.net/BioVoxxel_Toolbox
 *		5) Activation of BAR Toolbox: http://imagej.net/BAR
 *		6) 3 files in the "macros" folder of ImageJ
 *			a) "Micrograph_Analysis.ijm"
 *			b) "Micrograph_Analysis_Single.ijm"
 *			c) "Micrograph_Analysis_Multiple.ijm"
 *		7) The input files must have one of the extensions specified below. The inclusion of different formats requires code modification
 *			a) TIFF (.tiff, .tif)
 *			b) PNG (.png)
 *			c) JPEG (.jpeg, .jpg)
 *			d) BMP (.bmp)
 *
 *
 *  INSTALLATION:
 *  1) Install ImageJ/Fiji distribution from the official website
 *		a) Fiji is recommended https://imagej.net/Fiji/Downloads
 *	2)	Install all the requirements mentioned in points 2-5 of the "REQUIREMENTS" list. 
 *		The up to date installation instructions are placed on the websites mentioned in the points.
 *	3)	Find Fiji installation directory and place “Micrograph_Analysis” folder in the “Fiji/Macros” folder.
 *	4)	In the Fiji toolbar menu, choose “Plugins > Install…”
 *		a)	From the file selection menu, locate and choose “Micrgraph_Analysis.ijm” file
 *		b)	Locate Fiji installation directory and save the file in “Fiji/plugins/Macros” folder
 *
 *
 *  USING THE SYSTEM:
 *	After successful installation, please find the “Micrograph Analysis” entry in the “Plugins” menu of the ImageJ/Fiji toolbar: 
 *	“Plugins > Macros > Micrograph Analysis”.
 * 	After selecting “Micrograph Analysis” entry, please follow the on-screen instructions.
 *
 *
 *	DESCRIPTION:
 *  This macro will perform the following operations:
 *		1) ask the user for input image or directory of images
 *		2) check if the specified input has a supported format and is not empty
 *		3) request to determine the output directory
 *		4) using a GUI, ask the user for:
 *			a) desired output (specified in point 11)
 *			b) preference of analysing interparticle range
 *				a) minimum and maximum particle size taken into analysis
 *				b) minimum and maximum particle circularity taken into analysis 
 *			c) preview of the particles before analysis
 *			d) analysis preferences (specified in point 9)
 *			e) preference of setting the scale (specified in point 7)
 *			f) preference of removing the label (specified in point 8)
 *		5) ask to specify output images (optionally)
 *		6) ask to specify area distribution plot analysis (optionally)
 *		7) ask to set accurate scale (optionally)
 *			a) manually (by drawing a line over scale)
 *			b) typing in the known distances
 *			c) using predefined scale
 *			a) skipping the part (by default 1 pixel = 1 known distance)
 *      8) crop the image to remove the bottom label (optionally)
 *			a) provide predefined option to remove the label as for micrographs taken at Coventry University
 *			b) provide an option to crop the image manually
 *			c) leave the image without cropping
 *      9) perform segmentation
 *			a) transform input into 8-bit image
 *			b) apply automatic threshold
 *      	c) convert input into binary values
 *      	d) remove small particles from the image (outliers) (oprionally)
 *			e) fill holes in particles on the image (optionally)
 *			f) apply watershed algorithm on the image (optionally)
 *      	g) exclude particles on edges during the analysis (optionally)
 *      	h) include holes of particles in analysis (optionally
 *		10) ask the user if he is satisfied with the particles taken into analysis (optionally)
 *			a) if not, specify particle size and circularity again, till the user is satisfied
 *			b) if yes, continue to run the script
 *		11) ask to specify interparticle range analysis (optionally)
 *      12) analyze particles, close windows, optionally save:
 *			a)	overall results (including nearest neighbor distances from centroids) (saved in “RESULTS…” file)
 *			b)	summary (saved in “SUMMARY…” file)
 *			c)	interparticle distances (saved in the “INTERPARTICLE_DISTANCES” folder)
 *			d)	area distribution plot (saved in the “PLOTS” folder)
 *			e)	cluster indication (saved in the “CLUSTERS” folder)
 *			f)	images 
 *			g)	specifications used in analysis (saved in “ANALYSIS_INFO(…)” file)
 *			h)	time of running manual and automatic operations of the script (saved in “ANALYSIS_INFO…” file)	
 *
 *
 *	HELP:
 *	For more help, please read the attached "User Manual.pdf" file, or if it is missed, contact the developer using the e-mail provided above 
 *
*/

// ==========START==========


// START TIME TRACKING (FOR THE ENTIRE PROCESS)
start = getTime();

// DEFINE VARIABLES
analysis_options = "";
interp_total_number = 0;
interp_max_distance = 0;
interp_total_distance = 0;
interp_total_variance = 0;
preview_particles_run = 0;

// GET DATE AND TIME
 MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
 DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
 getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
 TimeString ="Date: "+DayNames[dayOfWeek]+" ";
 if (dayOfMonth<10) {TimeString = TimeString+"0";}
 TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
 if (hour<10) {TimeString = TimeString+"0";}
 TimeString = TimeString+hour+":";
 if (minute<10) {TimeString = TimeString+"0";}
 TimeString = TimeString+minute+":";
 if (second<10) {TimeString = TimeString+"0";}
 TimeString = TimeString+second;

// SET BATCH MODE ON (DON'T DISPLAY IMAGES WHILE RUNNING MACRO)
setBatchMode(true);


// ==========GET INPUT FILE==========

input_image = File.openDialog("Select Input Image");

// ==========CHECK IF THE INPUT FILE IS AN IMAGE==========

if  ((indexOf(toLowerCase(input_image), ".tif")>0) || (indexOf(toLowerCase(input_image), ".tiff")>0) || 
   	(indexOf(toLowerCase(input_image), ".png")>0) || (indexOf(toLowerCase(input_image), ".jpg")>0) || 
    (indexOf(toLowerCase(input_image), ".jpeg")>0) || (indexOf(toLowerCase(input_image), ".bmp")>0)) {		    

	open(input_image);
	//FIX THE EXTENSION
	image_title = getTitle();
	dotIndex = indexOf( image_title, "." );
	image_title = substring( image_title, 0, dotIndex );
	rename(image_title+".tif");
	image_title = getTitle();
}

else {
	  Dialog.create("Error!")
      Dialog.addMessage("The input file is not an image:\n");
      Dialog.addMessage(input_image);
      Dialog.addMessage("\nPlease specify a different file.\n");
      
      items = newArray("Yes", "No");
      Dialog.setInsets(0,24,0);
  	  Dialog.addRadioButtonGroup("Would you like to run the script again?", items, 2, 1, "No");

  	  Dialog.show();
  	  input = Dialog.getRadioButton();

  	  if (input=="Yes") {
	  	runMacro("Micrograph_Analysis/Micrograph_Analysis_Single");
  	  }
  	  else { 
  	  	exit();
  	  }
}

// ==========GET OUTPUT DIRECTORY==========

dir2 = getDirectory("Choose Output Directory");

// ==========ASK FOR OUTPUT SETTINGS==========

Dialog.create("Output Settings");

// ASK FOR DESIRED OUTPUT
Dialog.setInsets(0,10,0);
Dialog.addMessage("What would you like to output?");

labels = newArray("Results", "Summary", "Interparticle Distances", "Area Distribution Plot", "Cluster Indication", "Generated Images", "Analysis Specifications");

defaults = newArray(labels.length);
defaults[0] = true;
defaults[1] = true;
defaults[5] = true;
defaults[6] = true;

rows = 7;
columns = 1;

Dialog.setInsets(0,24,0);
Dialog.addCheckboxGroup(rows, columns, labels, defaults);

// ASK FOR PARTICLE SIZE
Dialog.setInsets(10,10,0);
Dialog.addMessage("What is the particle size you want to analyse? (in um^2 | between 0 and Infinity)");
Dialog.addNumber("Minimum Size:", 0.10);
Dialog.setInsets(0,20,0);
Dialog.addString("Maximum Size:", "Infinity");
Dialog.setInsets(10,10,0);
Dialog.addMessage("What is the particle circularity you want to analyse? (in um^2 | between 0 and 1)");
Dialog.setInsets(0,10,0);
Dialog.addNumber("Minimum Circularity:", 0.00);
Dialog.setInsets(0,10,0);
Dialog.addNumber("Maximum Circularity:", 1);

// ASK FOR "PREVIEW" OF THE ANALYSIS (SHOW OUTLINED IMAGE AND ASK IF THE SELECTED PARTICLES ARE CORRECT)
Dialog.addCheckbox("Preview selected particles before the analysis", false);

// ASK FOR ANALYSIS PREFERENCES
Dialog.setInsets(10,10,0);
Dialog.addMessage("What are your analysis preferences?");

labels2 = newArray("Remove small particles (outliers) from the image", "Fill holes of the particles on the image", "Apply Watershed Algorithm on the image", "Exclude edges in analysis", "Include holes in analysis");

defaults2 = newArray(labels2.length);
defaults2[0] = true;
defaults2[1] = true;
defaults2[3] = true;
defaults2[4] = true;

rows = 5;
columns = 1;

Dialog.setInsets(0,24,0);
Dialog.addCheckboxGroup(rows, columns, labels2, defaults2);

// ASK FOR TYPE OF SCALE SETTING
items = newArray("Draw line", "Type in known distance in pixels for the marked scale", "Use predefined scale for CU micrographs (18.375 pixels = 1 um)", "Leave default scale (1 pixel = 1 um)");
Dialog.addRadioButtonGroup("How would you like to set the scale?", items, 4, 1, "Draw line");

// ASK FOR TYPE OF LABEL REMOVAL
items = newArray("Draw rectangle over the area to be measured", "Use predefined method for CU micrographs", "There is no label to remove");
Dialog.addRadioButtonGroup("How would you like to remove the label?", items, 3, 1, "Use predefined method for CU micrographs");

// DISPLAY MENU
Dialog.show()

// GET USER'S PREFERENCES
chosenOption=newArray(labels.length);
for (i=0; i<labels.length; i++) {
	chosenOption[i]=Dialog.getCheckbox(); 
}

preview_particles = Dialog.getCheckbox();

chosenOption2=newArray(labels2.length);
for (i=0; i<labels2.length; i++) {
	chosenOption2[i]=Dialog.getCheckbox(); 
}

min_size = Dialog.getNumber();
max_size = Dialog.getString();
min_circularity = Dialog.getNumber();
max_circularity = Dialog.getNumber();

input_scale = Dialog.getRadioButton();
input_label = Dialog.getRadioButton();

// IF CHOSEN OPTION IS TRUE
if(chosenOption2[3]==1) {
	analysis_options += " exclude";
	edges = "excluded";
}
else {
	edges = "included";
}

if(chosenOption2[4]==1) {
	analysis_options += " include";
	holes = "included";
}
else {
	holes = "excluded";
}

// ASK FOR OUTPUT IMAGES (OPTIONALLY)
if(chosenOption[5]==1) {
	Dialog.create("Output Images");
	Dialog.setInsets(10,10,0);
	Dialog.addMessage("Which images would you like to save?");

	Dialog.addCheckbox("Processed", true);
	Dialog.addCheckbox("Outlined", true);
	if(chosenOption[2]==1) {
		Dialog.addCheckbox("Masks", true);
		Dialog.addCheckbox("Interparticle Adjacencies", true);
	}
	if(chosenOption[3]==1) {
		Dialog.addCheckbox("Slices used in area distribution plot", true);
		Dialog.addCheckbox("Montage of the image slices", true);
	}
	if(chosenOption[4]==1) {
		Dialog.addCheckbox("Clustered", true);
	}
	
	Dialog.show()
	
	image_processed = Dialog.getCheckbox();
	image_outlined = Dialog.getCheckbox();
	if(chosenOption[2]==1) {
		image_masks = Dialog.getCheckbox();
		image_interparticle = Dialog.getCheckbox();
	}
	if(chosenOption[3]==1) {
		image_slices = Dialog.getCheckbox();
		image_montage = Dialog.getCheckbox();
	}
	if(chosenOption[4]==1) {
	image_clustered = Dialog.getCheckbox();
	}
}

// ASK FOR "AREA DISTRIBUTION PLOT" SPECIFICATIONS (OPTIONALLY)
if(chosenOption[3]==1) {
	Dialog.create("Area Distribution Plot");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("Please specify the preferences of your area distribution analysis.");
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Slices per row:", 2);
	Dialog.setInsets(0,0,0);
	Dialog.addNumber("Slices per column:", 1);

	Dialog.show();

	input_images_per_row = Dialog.getNumber();
	input_images_per_column = Dialog.getNumber();
}


// SET BATCH MODE OFF FOR THE 1ST IMAGE(DISPLAY IMAGES WHILE RUNNING MACRO)
setBatchMode(false);

// ==========BEGIN OPERATIONS==========


// ==========CREATE OUTPUT DIRECTORY==========

	    dir3=dir2+image_title+"_RESULTS("+year+"-"+month+"-"+dayOfMonth+" "+hour+";"+minute+";"+second+")"+File.separator;
	    File.makeDirectory(dir3);

// ==========SCALE SETTING==========

// REMOVE PREVIOUS SCALE
run("Set Scale...", "distance=1 known=1");

if(input_scale=="Draw line"){
	// SET THE SCALE (MANUALLY - BY DRAWING A LINE)
	setTool("line"); 
    
    waitForUser("Set the scale for this image","Hold Shift to draw a straight line of a known length, then click 'OK'\n \nHINT 1: Zoom in/out for more precision using:\n---> Control and Mouse Wheel\n---> Control and arrow keys on your keyboard\n \nHINT 2: After the selection, move the line using arrow keys on your keyboard"); 

    run("Measure");
    length_of_line = getResult('Length', 0);
    run("Clear Results");
    run("Close");

    Dialog.create("Known distance"); 
    Dialog.addMessage("You have drew a line distance of "+length_of_line+" pixels");
    Dialog.addNumber("What is the known distance for the drawn line?" , 2); 
    Dialog.addString("What is the unit of length (scale) for this image?" , "um"); 
    Dialog.show(); 
    known_distance = Dialog.getNumber(); 
    unit_of_length = Dialog.getString(); 

    run("Set Scale...", "known="+known_distance+" pixel=1 unit="+unit_of_length+" global"); 
}
else if(input_scale=="Type in known distance in pixels for the marked scale") {
	// SET THE SCALE (MANUALLY - BY TYPING A DISTANCE)
	Dialog.create("Known distance"); 
	Dialog.addNumber("What is the length of line (in pixels) that covers the marked scale on the image?" , 36.75); 
    Dialog.addNumber("What is the known distance for the drawn line?" , 2); 
    Dialog.addString("What is the unit of length (scale) for this image?" , "um"); 
    Dialog.show(); 
    length_of_line = Dialog.getNumber();
    known_distance = Dialog.getNumber(); 
    unit_of_length = Dialog.getString(); 

    run("Set Scale...", "distance="+length_of_line+" known="+known_distance+" pixel=1 unit="+unit_of_length+" global");
}
else if(input_scale=="Use predefined scale for CU micrographs (18.375 pixels = 1 um)") {
	length_of_line = 36.75;
	known_distance = 2;
	unit_of_length = "um";
	run("Set Scale...", "distance="+length_of_line+" known="+known_distance+" pixel=1 unit="+unit_of_length+" global");	
}
else {
	//LEAVE DEFAULT SCALE (1 PIXEL = 1 UM)
	length_of_line = 1;
	known_distance = 1;
	unit_of_length = "um";
	run("Set Scale...", "distance="+length_of_line+" known="+known_distance+" pixel=1 unit="+unit_of_length+" global");	
}

// ==========CROP THE IMAGE==========	

if(input_label=="Draw rectangle over the area to be measured"){
	// CROP THE IMAGE (MANUALLY)
    setTool("rectangle");
    waitForUser("Remove the label","Mark the area which should be taken into analysis, then click 'OK'\n \nHINT: Zoom in/out for more precision using:\n---> Control and Mouse Wheel\n---> Control and arrow keys on your keyboard\n \nHINT 2: You can move the selection using arrow keys on your keyboard"); 
    getSelectionBounds(x, y, width, height);
    makeRectangle(x, y, width, height);
    run("Crop");
}	
else if(input_label=="Use predefined method for CU micrographs"){
	// CROP THE IMAGE AUTOMATICALLY (FOR COVENTRY UNI ENGINEERING DEPARTMENT)
	makeRectangle(0, 0, 1024, 691);
	run("Crop");
}
else {
	// There is no label to remove
}    

// SET BATCH MODE ON (DON'T DISPLAY IMAGES WHILE RUNNING MACRO)
setBatchMode(true);

// START TIME TRACKING (FOR AUTOMATIC PROCESSES)
start2 = getTime();


// ==========BEGIN SEGMENTATION==========

// TRANSFORM IMAGE INTO 8-BIT TYPE
run("8-bit");

// APPLY THRESHOLD
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");

// TRANSFORM IMAGE INTO BINARY VALUES, REMOVE OUTLIERS AND FILL HOLES IN PARTICLES
run("Make Binary", "thresholded remaining white");

// REMOVE OUTLIERS (OPTIONALLY)
if(chosenOption2[0]==1) {
	run("Remove Outliers...", "radius=1 threshold=50 which=Bright");
}

// FILL HOLES (OPTIONALLY)
if(chosenOption2[1]==1) {
	run("Fill Holes");
}

// RUN WATERSHED ALGORITHM (OPTIONALLY)
if(chosenOption2[2]==1) {
	run("Watershed");
}    

// ==========RUN ANALYSIS==========

// PREVIEW THE ANALYSED PARTICLES (OPTIONALLY)
if (preview_particles == true) {
	setBatchMode(false);
 	while (preview_particles_run == 0) {
 		selectWindow(image_title);
 		run("Extended Particle Analyzer", "  area="+min_size+"-"+max_size+" circularity="+min_circularity+"-"+max_circularity+" show=Outlines redirect=None keep=None display summarize"+analysis_options+"");
		outlined_image_title = getTitle();
		selectWindow(outlined_image_title);

		// MAKE COMPARISON MONTAGE
		open(input_image);
		input_image_for_preview = getTitle();

		run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use keep");
		stack = getTitle();
		run("Delete Slice");

		run("Make Montage...", "columns=2 rows=1 scale=1 border=3 use");
		preview_montage = getTitle();
		
		selectWindow(stack);
		close();
		selectWindow(input_image_for_preview);
		close();
		selectWindow(preview_montage);
		run("Maximize");

		// CREATE DIALOG
		Dialog.create("Preview particles taken into analysis");

		items = newArray("Yes, continue analysis", "No, specify particle parameters again");
		Dialog.addRadioButtonGroup("Are you satisfied with the particles selected for the analysis?", items, 2, 1, "Yes, continue analysis");
		Dialog.show();
		input = Dialog.getRadioButton();

		if (input=="No, specify particle parameters again") {
			selectWindow(preview_montage);
			close();
			selectWindow(outlined_image_title);
			close();

			selectWindow("Results");
			run("Clear Results");
			run("Close");

			if (isOpen("Summary")) {
				selectWindow("Summary");
				Table.deleteRows(0, Table.size, "Summary");
				run("Close");
			}

			selectWindow(image_title);

			// CREATE DIALOG TO SPECIFY THE PARTICLE SIZE AND CIRCULARITY
			Dialog.create("New Interparticle Specifications");

			// ASK FOR PARTICLE SIZE
			Dialog.setInsets(10,10,0);
			Dialog.addMessage("What is the new particle size you want to analyse? (in um^2 | between 0 and Infinity)");
			Dialog.addNumber("Minimum Size:", 0.10);
			Dialog.setInsets(0,20,0);
			Dialog.addString("Maximum Size:", "Infinity");
			Dialog.setInsets(10,10,0);
			Dialog.addMessage("What is the new particle circularity you want to analyse? (in um^2 | between 0 and 1)");
			Dialog.setInsets(0,10,0);
			Dialog.addNumber("Minimum Circularity:", 0.00);
			Dialog.setInsets(0,10,0);
			Dialog.addNumber("Maximum Circularity:", 1);

			Dialog.show();

			min_size = Dialog.getNumber();
			max_size = Dialog.getString();
			min_circularity = Dialog.getNumber();
			max_circularity = Dialog.getNumber();
		}
		else {
			selectWindow(preview_montage);
			close();
			preview_particles_run = 1;
			selectWindow(image_title);
		}
	}
}
else {
	run("Extended Particle Analyzer", "  area="+min_size+"-"+max_size+" circularity="+min_circularity+"-"+max_circularity+" show=Outlines redirect=None keep=None display summarize"+analysis_options+"");
	outlined_image_title = getTitle();
}

// CONTINUE ANALYSIS
run("Summarize");
run("Nnd ");

// ==========SAVE RESULTS==========	    
		    
// TRANSFER NND TO THE "RESULTS" TABLE
selectWindow("Nearest Neighbor Distances");
nnd = Table.getColumn("C1");
run("Close");
selectWindow("Results");
Table.setColumn("Nearest_Neighbor_Distance",nnd);

	//REARRANGE THE "RESULTS" TABLE
Table.renameColumn("Perim.", "Perim");
Table.renameColumn("Circ.", "Circ");

code = "Area2=Area; NearestNeighborDistance=Nearest_Neighbor_Distance;"
+"Perimeter=Perim; Circularity=Circ; Roundness=Round;"
+"AR2=AR; Solidity2=Solidity; Feret2=Feret;"
+"FeretAR2=FeretAR; Compactness=Compact; Extent2=Extent;"
+"IntegratedDensity=IntDen; RawIntegratedDensity=RawIntDen; FeretAngle2=FeretAngle;"
+"MinFeret2=MinFeret; FeretX2=FeretX; FeretY2=FeretY;"
+"XM2=XM; YM2=YM; BX2=BX; BY2=BY; Major2=Major; Minor2=Minor;"
+"Angle2=Angle; XStart2=XStart; YStart2=YStart";

Table.applyMacro(code);

Table.deleteColumn("Nearest_Neighbor_Distance");
Table.deleteColumn("Area");
Table.deleteColumn("Mean");
Table.deleteColumn("StdDev");
Table.deleteColumn("Mode");
Table.deleteColumn("Min");
Table.deleteColumn("Max");
Table.deleteColumn("XM");
Table.deleteColumn("YM");
Table.deleteColumn("Perim");
Table.deleteColumn("BX");
Table.deleteColumn("BY");
Table.deleteColumn("Major");
Table.deleteColumn("Minor");
Table.deleteColumn("Angle");
Table.deleteColumn("Slice");
Table.deleteColumn("Circ");
Table.deleteColumn("Feret");
Table.deleteColumn("IntDen");
Table.deleteColumn("Median");
Table.deleteColumn("Skew");
Table.deleteColumn("Kurt");
Table.deleteColumn("%Area");
Table.deleteColumn("RawIntDen");
Table.deleteColumn("FeretX");
Table.deleteColumn("FeretY");
Table.deleteColumn("FeretAngle");
Table.deleteColumn("MinFeret");
Table.deleteColumn("AR");
Table.deleteColumn("Round");
Table.deleteColumn("Solidity");
Table.deleteColumn("XStart");
Table.deleteColumn("YStart");
Table.deleteColumn("FeretAR");
Table.deleteColumn("Compact");
Table.deleteColumn("Extent");

Table.renameColumn("Area2", "Area");
Table.renameColumn("AR2", "AR");
Table.renameColumn("Solidity2", "Solidity");
Table.renameColumn("Feret2", "Feret");
Table.renameColumn("FeretAR2", "FeretAR");
Table.renameColumn("Extent2", "Extent");
Table.renameColumn("FeretAngle2", "FeretAngle");
Table.renameColumn("MinFeret2", "MinFeret");
Table.renameColumn("FeretX2", "FeretX");
Table.renameColumn("FeretY2", "FeretY");
Table.renameColumn("XM2", "XM");
Table.renameColumn("YM2", "YM");
Table.renameColumn("BX2", "BX");
Table.renameColumn("BY2", "BY");
Table.renameColumn("Major2", "Major");
Table.renameColumn("Minor2", "Minor");
Table.renameColumn("Angle2", "Angle");
Table.renameColumn("XStart2", "XStart");
Table.renameColumn("YStart2", "YStart");

Table.update;

// SAVE RESULTS
if(chosenOption[0]==1) {
	saveAs("Results", dir3+"RESULTS_"+image_title+".csv");
}
run("Clear Results");
run("Close");

// SAVE SUMMARY, COUNT AND SAVE "PARTICLE DENSITY", CLEAN THE TABLE
selectWindow("Summary");
	        
// CALCULATE "Particle Density"
particle_count = Table.get("Count", 0);
total_area = Table.get("Total Area", 0);
particle_density = particle_count/total_area;

//REARRANGE THE "SUMMARY" TABLE
Table.set("Particle Density", 0, particle_density);
Table.renameColumn("Count", "Particle Count");
Table.renameColumn("%Area", "Area Fraction");
Table.renameColumn("Perim.", "Perim");
Table.renameColumn("Circ.", "Circ");

code = "IntegratedDensity=IntDen; Perimeter=Perim; Circularity=Circ;"
+"Solidity2=Solidity; Major2=Major; Minor2=Minor;"
+"Angle2=Angle; Feret2=Feret; FeretX2=FeretX;"
+"FeretY2=FeretY; FeretAngle2=FeretAngle; MinFeret2=MinFeret";

Table.applyMacro(code);

Table.deleteColumn("Perim");
Table.deleteColumn("Major");
Table.deleteColumn("Minor");
Table.deleteColumn("Angle");
Table.deleteColumn("Circ");
Table.deleteColumn("Solidity");
Table.deleteColumn("Feret");
Table.deleteColumn("FeretX");
Table.deleteColumn("FeretY");
Table.deleteColumn("FeretAngle");
Table.deleteColumn("MinFeret");
Table.deleteColumn("IntDen");
Table.deleteColumn("Mean");
Table.deleteColumn("Mode");
Table.deleteColumn("Median");
Table.deleteColumn("Skew");
Table.deleteColumn("Kurt");

Table.renameColumn("IntegratedDensity", "Integrated Density");
Table.renameColumn("Solidity2", "Solidity");
Table.renameColumn("Major2", "Major");
Table.renameColumn("Minor2", "Minor");
Table.renameColumn("Angle2", "Angle");
Table.renameColumn("Feret2", "Feret");
Table.renameColumn("FeretX2", "FeretX");
Table.renameColumn("FeretY2", "FeretY");
Table.renameColumn("FeretAngle2", "FeretAngle");
Table.renameColumn("MinFeret2", "MinFeret");

Table.update;

if(chosenOption[1]==1) {
	saveAs("Results", dir3+"SUMMARY_"+image_title+".csv");
}
run("Clear Results");
run("Close");

// SAVE PROCESSED IMAGE
selectWindow(image_title);
if(image_processed==true) {
	saveAs("tiff", dir3+"PROCESSED_"+image_title);
}
else {
	rename("PROCESSED_"+image_title);
}

// SAVE OUTLINED IMAGE
selectWindow(outlined_image_title);
if(image_outlined==true) {
	saveAs("tiff", dir3+"OUTLINED_"+image_title);
}
else {
	rename("OUTLINED_"+image_title);
}
close();
	    
// ==========RUN AND SAVE CLUSTER INDICATION (OPTIONALLY)==========
if(chosenOption[4]==1) {
	
	// MAKE DIRECTORY FOR CLUSTER OUTPUTS
	dir_cluster=dir3+"CLUSTERS"+File.separator;
	File.makeDirectory(dir_cluster);

	run("Set Scale...", "distance=1 known=1 pixel=1 unit=um global");
    run("Cluster Indicator", "");		    
    selectWindow("PROCESSED_"+image_title);
    if(image_clustered==true) {
    	saveAs("png", dir_cluster+"CLUSTERED_"+image_title);
	}
	else {
		rename("CLUSTERED_"+image_title);
	}
    clustered_image_title = getTitle();
    if (isOpen("Log")) {
    	selectWindow("Log");
    	saveAs("Text", dir_cluster+"CLUSTERS_"+image_title+".txt");
    	print("\\Clear");
    	run("Close");
    }	    
    run("Set Scale...", "distance="+length_of_line+" known="+known_distance+" pixel=1 unit="+unit_of_length+" global");
}

// ==========RUN AREA DISTRIBUTION (OPTIONALLY)==========

if(chosenOption[3]==1) {
	// SET BATCH MODE OFF (DISPLAY IMAGES WHILE RUNNING MACRO)
	setBatchMode(false);

	// MAKE SLICES OF THE IMAGE
	run("Montage to Stack...", "images_per_row="+input_images_per_row+" images_per_column="+input_images_per_column+" border=0");
	stack = getTitle();
	run("Set Measurements...", "area mean centroid feret's area_fraction stack display redirect=None decimal=3");

	// GET NUMBER OF SLICES AND ASSIGN IT TO THE VARIABLE
	n = nSlices;

	// MAKE DIRECTORY FOR PLOT OUTPUTS
	dir_plot=dir3+"PLOTS"+File.separator;
	File.makeDirectory(dir_plot);

	// MAKE MONTAGE
	if (image_montage==true) {
		selectWindow(stack);
		run("Make Montage...", "columns="+input_images_per_row+" rows="+input_images_per_column+" scale=0.50 font=50 border=3 label");
		selectWindow("Montage");
		saveAs("Tiff", dir_plot+"Montage of "+image_title+".tif");
		close();
	}

	// START OPERATIONS
	for (slice=1; slice<=n; slice++) {
	    showProgress(slice, n);
	    selectWindow(stack);
	    Stack.setSlice(slice);
	    if(image_slices==true) {
	    	saveAs("PNG", dir_plot+"Slice #"+slice+" of "+image_title+".png");
		}
		else {
			rename("Slice #"+slice+" of "+image_title+".png");
		}
	    rename(stack);
	    run("Analyze Particles...", "  size="+min_size+"-"+max_size+" circularity="+min_circularity+"-"+max_circularity+" show=Nothing slice");
	    saveAs("Results", dir_plot+"Overall Analysis Results of slice #"+slice+" of "+image_title+".csv");
	    run("Distribution Plotter", "parameter=Area tabulate=[Number of values] automatic=Freedman-Diaconis bins=24");
	    low_resolution_plot_title = getTitle();
	    Plot.getValues(x, y);
	    // CLEAN "RESULTS" TABLE AND TRANSFER PLOT VALUES TO IT
	    run("Clear Results");
	    Table.setColumn("X",x);
	    Table.setColumn("Y (bin value)",y);
	    Table.update;
	    saveAs("Results", dir_plot+"Distribution Plot (bin) values of slice #"+slice+" of "+image_title+".csv");
	    run("Clear Results");
	    run("Close");
	    // GENERATE HIGH RESOLUTION PLOT
	    Plot.makeHighResolution("Histograms for slice #"+slice+" of "+image_title+"",4.0);
	    // SAVE THE PLOT
	    saveAs("PNG", dir_plot+"Distribution Plot of slice #"+slice+" of "+image_title+".png");
	    high_resolution_plot_title = getTitle();
	    // CLOSE THE WINDOWS
	    selectWindow(low_resolution_plot_title);
	    run("Close");
	    selectWindow(high_resolution_plot_title);
	    run("Close");
	}

	// CLOSE "STACK" WINDOW
	selectWindow(stack);
	run("Close");
}

// ==========RUN INTERPARTICLE DISTANCES (OPTIONALLY)==========

// GET MAXIMUM NEIGHBOR DISTANCE (USING GUI)
if(chosenOption[2]==1) {

	// MAKE DIRECTORY FOR INTERPARTICLE OUTPUTS
	dir_interparticle=dir3+"INTERPARTICLE_DISTANCES"+File.separator;
	File.makeDirectory(dir_interparticle);

	Dialog.create("Maximum Neighbor Distance");
	Dialog.addNumber("Maximum neighbor distance taken to calculations (in um):", 1);
	Dialog.setInsets(20,0,0);
	Dialog.addMessage("IMPORTANT: Unfortunetaly, the next window cannot be automated.");
	Dialog.setInsets(0,0,0);
	Dialog.addMessage("To correctly run the calculations, in the next window:\n---> Specify the same number\n---> Mark all the three checkboxes");
	Dialog.show();
	maximum_neighbor_distance = Dialog.getNumber(); 
	// SET BATCH MODE OFF (DISPLAY IMAGES WHILE RUNNING MACRO)
	setBatchMode(false);	
	// RUN ANALYSIS AND SHOW "MASKS" IMAGE
	run("Extended Particle Analyzer", "  area="+min_size+"-"+max_size+" circularity="+min_circularity+"-"+max_circularity+" show=Masks redirect=None keep=None display summarize"+analysis_options+"");
	// CLOSE "PROCESSED" IMAGE
	if(chosenOption[4]==1) {
		selectWindow(clustered_image_title);
		close();
	}
	else {
		selectWindow("PROCESSED_"+image_title);
		close();
	}
	// INVERT COLORS OF "MASKS" IMAGE
	setOption("BlackBackground", true);
	run("Make Binary");
	// SAVE MASKS WINDOW (OPTIONALLY)
	if(image_masks==true) {
		saveAs("tiff", dir3+"MASKS_"+image_title);
	}
	else {
			rename("MASKS_"+image_title);
	}
	// RUN INTERPARTICLE DISTANCE (WAIT FOR USER INPUT AS THE FUNCTION CANNOT BE AUTOMATED)
	run("Graph ", "");

	// SAVE ADJACENCIES		
	selectWindow("Adjacencies");
	if(image_interparticle==true) {
		saveAs("png", dir_interparticle+"INTERPARTICLE_ADJACENCIES_"+image_title);
	}
	else {
		rename("INTERPARTICLE_ADJACENCIES_"+image_title);
	}
	//SAVE "LOG" WINDOW
	selectWindow("Log");
	saveAs("Text", dir_interparticle+"INTERPARTICLE_CONNECTIONS("+year+"-"+month+"-"+dayOfMonth+" "+hour+";"+minute+";"+second+").txt");

	//TRANSFER "DISTANCE MATRIX" TO "RESULTS" TABLE
	selectWindow("Results");
	run("Clear Results");
	close();

	selectWindow("Distance Matrix");
	Table.rename("Distance Matrix", "Results");
	
	//SAVE "DISTANCE MATRIX"
	selectWindow("Results");
	saveAs("Results", dir_interparticle+"INTERPARTICLE_DISTANCE_MATRIX_"+image_title+".csv");


	// GET COLUMNS OF "RESULTS" TABLE
	headings = split(String.getResultsHeadings);  
	// CALCULATIONS ON INTERPARTICLE DISTANCES
	for (row=0; row<nResults(); row++) {
		for (col=0; col<lengthOf(headings); col++) {
			interp_distance = getResult(headings[col],row);
			if ((interp_distance>0) && (interp_distance<maximum_neighbor_distance)) {
				interp_total_number = interp_total_number+1;
				// MAX DISTANCE
				if (interp_distance>interp_max_distance){
					interp_max_distance=interp_distance;
				}
				// TOTAL DISTANCE
				if (interp_distance < maximum_neighbor_distance){
					interp_total_distance += interp_distance;
				}
			}
		}	
	}

	// AVERAGE DISTANCE
	interp_average_distance=interp_total_distance/interp_total_number;

	// MIN DISTANCE
	interp_min_distance=interp_max_distance;

	for (row=0; row<nResults(); row++) {
		for (col=0; col<lengthOf(headings); col++) {
			interp_distance = getResult(headings[col],row);
			if ((interp_distance>0) && (interp_distance<maximum_neighbor_distance)) {
				// VARIANCE DISTANCE
		   		interp_total_variance=interp_total_variance+(interp_distance-interp_average_distance)*(interp_distance-interp_average_distance);
				interp_variance=interp_total_variance/(interp_total_number-1);
				//SD OF DISTANCE
				interp_sd=sqrt(interp_variance);
			}
			// MIN DISTANCE
			if ((interp_distance>0) && (interp_distance<maximum_neighbor_distance) && (interp_distance<interp_min_distance)) {
				interp_min_distance=interp_distance;
			}
		}
	}				

	// SAVE INTERPARTICLE ANALYSIS
	if(chosenOption[2]==1) {
		print("\\Clear");
			print("========== INTERPARTICLE DISTANCES ==========");
   	  	print("Number of connections below the maximum neighbor distance: "+interp_total_number/2+"");
		print("\nTotal interparticle distance: "+interp_total_distance+"");
		print("\nMinimum interparticle distance: "+interp_min_distance+"");
		print("Maximum interparticle distance: "+interp_max_distance+"");
		print("Average interparticle distance: "+interp_average_distance+"");
		print("\nVariance of interparticle distance: "+interp_variance+"");
		print("SD of interparticle distance: "+interp_sd+"");
		selectWindow("Log");
		saveAs("Text", dir_interparticle+"INTERPARTICLE_DISTANCES("+year+"-"+month+"-"+dayOfMonth+" "+hour+";"+minute+";"+second+").txt");
		run("Close");
   	}
}

//CLOSE AND CLEAR OPENED WINDOWS (IF THEY EXIST)
if (isOpen("Log")) {
	selectWindow("Log");
	print("\\Clear");
	run("Close");		
}
if (isOpen("Results")) {
	selectWindow("Results");
	run("Clear Results");
	run("Close");		
}
if (isOpen("Summary")) {
	selectWindow("Summary");
	Table.deleteRows(0, Table.size, "Summary");
	run("Close");		
}
close("*");

// SET BATCH MODE OFF (DISPLAY IMAGES WHILE RUNNING MACRO)
setBatchMode(false);

// ==========INFORM THE USER ABOUT SUCCESSFUL OPERATION==========


// SAVE ANALYSIS SPECIFICATIONS (OPTIONALLY)
if(chosenOption[6]==1) {		
	print("========== ANALYSIS SPECIFICATIONS ==========\n");
	print("\n=== DAY AND TIME OF ANALYSIS ===");
	print(""+TimeString+"");
	print("\n=== INPUT/OUTPUT FILES ===");
	print("Output folder: "+dir3+"");
	print("Directory of input file: "+input_image+"");
	print("Image title: "+image_title+"");  	 
	print("Number of images: 1");
	print("\n=== PREFERENCES OF ANALYSIS ===");
	print("Scale used: "+length_of_line+" pixels = "+known_distance+" "+unit_of_length+"");
	print("Minimum size of particles: "+min_size+" ("+unit_of_length+"^2)");
	print("Maximum size of particles: "+max_size+" ("+unit_of_length+"^2)");
	print("Particles on the edges: "+edges+"");
	print("Holes of the particles: "+holes+"");
	print("\n=== RUNNING TIME ===");
	print("Overall time taken for analysis: "+(getTime()-start)/1000+" seconds");
	print("Time taken for automatic processes: "+((getTime()-start2)/1000)+" seconds");
	saveAs("Text", dir3+"ANALYSIS_INFO("+year+"-"+month+"-"+dayOfMonth+" "+hour+";"+minute+";"+second+").txt");
	run("Close");
}
// DISPLAY SUCCESS WINDOW
Dialog.create("Success!")
Dialog.addMessage("Success!\nIt took "+(getTime()-start)/1000+" seconds to run all the actions and "+((getTime()-start2)/1000)+" seconds to run automatic scripts on one image.");
Dialog.addMessage("\nThe results were saved in:\n");
Dialog.addMessage("      "+dir3); 

items = newArray("Yes - analyse single file", "Yes - analyse directory of images", "No");
Dialog.setInsets(0,24,0);
Dialog.addRadioButtonGroup("Would you like to run the script again?", items, 3, 1, "No");
Dialog.show();
input = Dialog.getRadioButton();

if (input=="Yes - analyse single file") {
	runMacro("Micrograph_Analysis/Micrograph_Analysis_Single");
}
else if (input=="Yes - analyse directory of images") { 
	runMacro("Micrograph_Analysis/Micrograph_Analysis_Multiple");
}
else {
	exit();
}