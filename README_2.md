# Card.io-for-Capital-One-vertical-Cards
Code to Enhance Card.io so it can recognize Vertical Credit Card Formats from Capital One

This GitHub repository integrates with the existing Card.io open source to allow it to recognize several of the new vertical credit card
formats from Capital One. [see image file "Supported COF Cards.jpg" ] This code easily integrates with the existing card.io source and
is subject to any issues and limitations of the card.io base functionality.

The architecture for this source is built to intercept card images that are rejected by Card.io and then re-analyzes them with an
additional neural processor. When the card can be recognized by the new code, the captured card information is passed back to the normal
card.io process and then handled in the normal fashion. Similarly, cards that cannot be processed by the new code are handled in the
normal Card.io failed recognition steps. The new neural processor has initially been trained to recognize 4 Capital One vertical credit
cards. Sample images for the 4 supported card formats are shown below. A high level process map is pictured in image file "COF Vertical
Card process map.jpg" with a more detailed map of the neural recognition process described in the image " Detailed Process Map.jpg":

In addition to the enhanced neural processor, the new code includes credit card definitions file that assists the neural processor. 
The definitions file describes the characteristics of each known card and where information can found in its layout. The definitions 
data is used in instances where fonts, colors, and other complicating issues reduce neural processor accuracy. The database allows 
a developer to updated the system with new card formats and higher accuracy rates without requiring a re-compile of the complete code.

The source also includes optional code to allow a developer to store copies of each scanned card image in the IOS device photo library.
These can images can be useful for analysis of failures. 
Instructions for compiling this code with card.io can be found in the file "Environment Configurations.pdf" 

