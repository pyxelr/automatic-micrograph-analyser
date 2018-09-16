/* 
 *  Micrograph_Analysis.ijm
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
 *      	h) include holes of particles in analysis (optionally)
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


// SPECIFY INPUT
Dialog.create("Micrograph Analysis");

items = newArray("Single File", "Directory of Images");
Dialog.addRadioButtonGroup("What would you like to analyse?", items, 2, 1, "Single File");
Dialog.show();
input = Dialog.getRadioButton();

if (input=="Single File") {
	runMacro("Micrograph_Analysis/Micrograph_Analysis_Single");
}
else {
	runMacro("Micrograph_Analysis/Micrograph_Analysis_Multiple");
}