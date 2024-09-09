Wheel of fortune -like application written in Processing  

Will attempt to make releases.  

Requirements:
If on windows, and using releases after 0.5: Java OpenJDK 17 required (get it here: https://adoptium.net/download/)

Instructions:  
1. Download the latest Release   
2. Create file "config.txt" in same folder
3. the configfile should have four lines (for defaults see config.txt in repo): 
    - absolute path of data
    - name of segments file in data folder
    - name of click file
    - name of centerpiece

The wheel is currently fair to an angle of about 2 degrees i.e. the first segment has a 2/360 higher chance than the others. Clicking multiple times should remove that bias. 

TODO:
- fix sound issue in linux
- make textbox prettier
- Allow for images on segments
- custom colours
- make build easier
- refactor file loading