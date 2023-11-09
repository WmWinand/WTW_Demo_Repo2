Complete the following steps to load and configure the course data for use on a personal Viya deployment. 
NOTE: If you are an administrator and loading the course files for shared access, save the files in a location accessible by all learners. 

1) Log on to SAS Viya. In the upper left corner, click the Applications menu button and select Develop SAS Code or Develop Code and Flows (depends on your version). SAS Studio opens. 

2) In the Explorer section of the Navigation pane, expand Server. Select a folder where you have write access, then right-click and select New Folder. Name the folder VSTU_data and click OK.
NOTE: The label for the file server in your environment may be different. The server icon is most likely between Folder Shortcuts and SAS Content. 

3) Right-click the VSTU_data folder and select Upload files. Click the Add icon and navigate to the VSTU_data folder that was unzipped on the local machine. Press CTRL+A to select all files and click Open. Click Upload. Expand the Home > Courses > VSTU_data folder and confirm 21 files are added. 

4) Right-click the VSTU_data folder and select Add shortcut. Name the shortcut VSTU_data and click OK. Expand Folder Shortcuts in the Explorer to confirm the VSTU_data shortcut is available. 

5) In the Explorer section of the Navigation pane, expand SAS Content. Identify a folder where you have write access, then right-click and select New Folder. Name the folder VSTU and click OK. 

6) Right-click the VSTU folder and select Upload files. Click the Add icon and navigate to the VSTU_SAS_Content folder that was unzipped on the local machine. Press CTRL+A to select all files and click Open. Click Upload. Expand the VSTU folder under SAS Content and confirm 7 files are added. 

7) Right-click the VSTU folder under SAS Content and select New Folder. Name the folder Solutions and click OK.

8) Right-click the Solutions folder and select Upload files. Click the Add icon and navigate to the VSTU_Solutions folder that was unzipped on the local machine. Press CTRL+A to select all files and click Open. Click Upload. expand the Solutions folder and confirm 20 files are added.

9) Right-click the VSTU folder under SAS Content and select Add shortcut. Name the shortcut VSTU and click OK. Expand Folder Shortcuts in the Explorer to confirm the VSTU shortcut is available. 

10) In the Folder Shortcuts > VSTU folder, double-click vs01d01.flw to open the flow. 

11) Any nodes that reference specific paths will need to be updated to run successfully. Click on the quakes node. In the Options tab, click Open next to the File location field. Select the Folder Shortcuts > VSTU_data folder. Select quakes.csv and click OK. 

12) Select the strong_quakes node. In the Options tab, click Open next to the File location field. Select the Folder Shortcuts > VSTU_data folder. Type strong_quakes in the Name field and select Microsoft Excel (*.xlsx) in the Type field. Click Save. 
NOTE: This provides an example of how to update file locations when necessary in flows. You will need to update file locations in other flows throughout the course. 

13) Click Run and verify that there are green check marks on the nodes in the flow.


 =============================================================================

 Copyright (c) 2022 SAS Institute Inc.                                       
 Cary, N.C. USA 27513-8000                                                    
 all rights reserved                                                          
                                                                              
 THE INFORMATION CONTAINED IN THIS DISTRIBUTION IS PROVIDED BY THE INSTITUTE      
 "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
 BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
 A PARTICULAR PURPOSE.  RECIPIENTS ACKNOWLEDGE AND AGREE THAT THE INSTITUTE   
 SHALL NOT BE LIABLE WHATSOEVER FOR ANY DAMAGES ARISING OUT OF THEIR USE OF   
 THIS INFORMATION.    
