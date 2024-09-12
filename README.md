Wheel of fortune -like application written in Processing  

Will attempt to make releases.  

Requirements:
If on windows, and using releases after 0.5: Java OpenJDK 17 required (get it here: https://adoptium.net/download/)

Instructions:  
1. Download the latest Release   
2. Create file "config.txt" in same folder
3. the configfile should have six lines (for defaults see config.txt in repo): 
    - absolute path of data
    - name of segments file in data folder
    - name of click sound file
    - name of centerpiece
    - name of colours file
    - name of images file

The Colours file needs to have the same number of rows as the segment file, which is the number of segments on the wheel.
Each Row will determine two colours: the font colour and the BG colour. 
The format will be strict Hex colours, i.e. "#ghijkl" where "gh" is the red hex value, "ij" the green and "kl" the blue. A complete line hence looks like this:
`#123456 #abcdef`
where the text colour will be <font color="#123456"> #123456 </font>
and the background will be<font color="#abcdef"> #abcdef </font>
You can omit the second colour in every row to just affect the font colour. You cannot only affect the BG colour without affecting the font colour, however the default font colour is <p style="color:#000000;background-color:#FFFFFF"> black: #000000 </p>
The images file needs to have the same number of rows as the segment file. If a colour file and an ingames file are present, the font is taken from the colours, the background is taken from the images. The render of the image goes as follows: The image will be streched to cover exactly the entire wheel. The segment corresponding to the image will mask out all other parts of the image.

The wheel is currently fair to an angle of about 2 degrees i.e. the first segment has a 2/360 higher chance than the others. Clicking multiple times should remove that bias. 

TODO:
- make textbox prettier
- make build easier
- refactor file loading
- general refactor