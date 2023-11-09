/********************************************************************************/
/* Car Application Step One - Select Parameters For Search			       		*/
/********************************************************************************/
/* We exclusively stream HTML via a Data _null_ step to render the page      	*/
/* from which users select their search options. Make _output_type = HTML		*/
/********************************************************************************/

%let font_value = Calibri; /* Set univeral font value */


/********************************************************************************/
/* Create form for parameter selection. Make appropriate changes as noted.      */
/* NOTE: Engine Size and Minimum MPG are for cosmetic purposes only.		    */
/********************************************************************************/

data _null_; 
	format infile $char256.; 
	input;
	infile = resolve(_infile_);
	file _webout;
	put infile;
	cards4;
		<HTML>
		<head>
		<title>What Type Of Car Do You Want?</title>
		</head>
		<BODY> 


		<font face=&font_value color="#5C5C5C" size=5>

		<b>What Type Of Car Do You Want?</b></center></font>
		<br><br>
		<font face=&font_value>
		<div class="center">
		<form action="/SASJobExecution/" target="_tab">
		<input type="hidden" name="_program" value="/Users/sasdemo/My Folder/My Jobs/Web App Examples/6_Car_App_Step2"> /* Change to metadata location of next Job */
		<label for="MaxPrice">Maximum Price</label>

		<input type="number" id="MaxPrice" name="MaxPrice" required /* ID Value will be sent as name/value pair and resolve as macro in next step */
		min="11000" max="200000" size="10" value=20000 step=500>

		<br><br>
		<label for="CarType">Car Type</label>

		<select id="CarType" name="CarType"> /* ID Value will be sent as name/value pair and resolve as macro in next step */
		<option value="Sedan">Sedan</option>
		<option value="SUV">SUV</option>
		<option value="Truck">Truck</option>
		<option value="Sports">Sports</option>
		<option value="Hybrid">Hybrid</option>
		<option value="Wagon">Wagon</option>

		</select>

		<br><br>

		<label for="Cyl">Engine Size </label>             
		<select id="Cly" name="Cyl"> /* ID Value will be sent as name/value pair and resolve as macro in next step */
		<option value="4">4 Cylinder</option>
		<option value="8">8 Cylinder</option>
		<option value="12">Show All Cars</option>
		</sele