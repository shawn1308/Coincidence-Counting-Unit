# Coincidence-Counting-Unit
## INSTRUMENTATION An2 - Sup Galilée
## BY : DJOMO Elisabeth , DIAS Tony , BASKARAN Amalan , YAHMI Riwane

We are a group of four students from Sup Galilée engineering school, working on a project that involves creating an acquisition system for an avalanche photodiode used in quantum optics experiments. 

The basis of our experiment involves creating a pair of entangled photons using a BBO crystal. These two photons then follow different optical paths using mirrors before arriving at their respective Avalanche photodiodes through polarizers. Our task is to count these photons and calculate the correlation time using our FPGA-based CCU. 
Here is an explanatory diagram : 
![alt text](https://github.com/shawn1308/Coincidence-Counting-Unit/blob/main/Images/exp.png)

To complete this project, we are employing a low-cost AMD Xilinx FPGA, Cmod A7 35T, that can operate at 300MHz (3.33 NS). That's appropriate for a low-cost CCU.
![alt text](https://github.com/shawn1308/Coincidence-Counting-Unit/blob/main/Images/carte_fpga.jpg)

This is the RTL Design of our system: 

![alt text](https://github.com/shawn1308/Coincidence-Counting-Unit/blob/main/Images/full_rtl.png)

Final Product : 

![alt text](https://github.com/shawn1308/Coincidence-Counting-Unit/blob/main/Images/bti.jpg)

Git Structure : 

> Photon_VHDL_CODE : All source code <br />
> GUI : Python interface made with PyQt <br />
> FPGA_V_FINAL_for_CMOD_A7.Zip : Project made for CMOD A7 35t <br />
> V3_PROJET_for_BASYS3.zip : Project Made for BASYS 3 <br />
> FPGA_Final_Gerber_33V.zip : gerber files for PCB making <br />
