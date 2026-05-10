# inertial_nav

This project is attempting to use the x and y accelerometers in a phone to measure the sway of a tall bulding on windy days.
A friend of mine who lives on the 30th floor of a condo building mentioned that how on a windy day he can't keep pictures hanging on walls level due to sway.
This reminded me of when I worked on the 28th floor of a 56 floor skyscraper and standing in front of the elevators how I could hear the building creaking as it swayed back and forth.
It swayed with roughly a 6 to 8 second period, It wasn't enough to physically notice.

So my plan is to use the phone accelerometers like inertial navigation systems to calculate position on the Earth.
Given that integrating acceleration with respect to time yields delat velocity and then integrating velocity with respct to time gives changes in position it is possible to measure the horizontal displacement of the phone and therefore building sway.
Some hurdles facing this application are
1. Accelerometer noise due to electrical and mechanical sources. I'm currently looking into using a Kalman filter to correct for this.
2. The fact that the phone probably isn't perpendicular to gravity causing a partial offset by g based on the sine of the angle from the x and y sensors - the gravity vector.
   To account for this the app takes 50 samples in a calibration phase and takes the average of the samples to calculate a g offset to be applied to run time values.
3. It still might be that the phone sensors aren't accurate enough to get good outputs of horizontal displacement, but time will tell.
