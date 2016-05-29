//
//  CardDefinition.h
//  OCRE
//
//  Copyright © 2015 CTB Consulting. All rights reserved.
//

#ifndef CardDefinition_h
#define CardDefinition_h


/*
 
    Current Card Types:
 
    vclpH = Venture Card Laser Personalization Horizontal
    vclpV = Venture Card Laser Personalization Vertical
    qufpH = Quicksilver Ultragraphics flat print Horizontal
 
 */


@interface CardDefinition : NSObject

/*
 Name: Aribitrary Unique Identifier.
 Digits: The number of digits in the credit card number.
 Resolution: The original resolution this definition is based on so we can convert.
 CCNCoordinates: The [x, y, width, height] of the scan section for the credit card number
 CSCCoordinates: The row [x, y, width, height] of the scan section for the card security code (R1-3 nil if horizontal)
 ExpiryCoordinates: The [x, y, width, height] of the scan section for the expiriation date
 */

@property (nonatomic, strong) NSString  *Name;
@property (nonatomic, assign) BOOL       IsVertical;
@property (nonatomic, assign) BOOL       RotateLeft;
@property (nonatomic, assign) int        Digits;
@property (nonatomic, assign) CGRect     CSCCoordinates;
@property (nonatomic, assign) CGRect     ExpiryCoordinates;
@property (nonatomic, assign) CGRect     CCNCoordinatesR0;
@property (nonatomic, assign) CGRect     CCNCoordinatesR1;
@property (nonatomic, assign) CGRect     CCNCoordinatesR2;
@property (nonatomic, assign) CGRect     CCNCoordinatesR3;


- (id)initCardDefinition: (NSString*) name : (BOOL) isVertical : (int) digits :(CGRect) ccnCoordinatesR0 :(CGRect) ccnCoordinatesR1 :(CGRect) ccnCoordinatesR2 :(CGRect) ccnCoordinatesR3 :(CGRect) cscCoordinates :(CGRect) expiryCoordinates;
- (void)test;

@end // end interface

@implementation CardDefinition
@synthesize Name;
@synthesize IsVertical;
@synthesize RotateLeft;
@synthesize Digits;
@synthesize CSCCoordinates;
@synthesize CCNCoordinatesR0;
@synthesize CCNCoordinatesR1;
@synthesize CCNCoordinatesR2;
@synthesize CCNCoordinatesR3;
@synthesize ExpiryCoordinates;

-(id)initCardDefinition:(NSString*) name : (BOOL) isVertical : (int) digits :(CGRect) ccnCoordinatesR0 :(CGRect) ccnCoordinatesR1 :(CGRect) ccnCoordinatesR2 :(CGRect) ccnCoordinatesR3 :(CGRect) cscCoordinates :(CGRect) expiryCoordinates;  {
  if(self = [super init])  {
    self.Name = name;
    self.IsVertical = isVertical;
    self.Digits = digits;
    self.CCNCoordinatesR0 = ccnCoordinatesR0;
    self.CCNCoordinatesR1 = ccnCoordinatesR1;
    self.CCNCoordinatesR2 = ccnCoordinatesR2;
    self.CCNCoordinatesR3 = ccnCoordinatesR3;
    self.CSCCoordinates = cscCoordinates;
    self.ExpiryCoordinates = expiryCoordinates;
  }
  return self;
}

@end

#endif /* CardDefinition_h */
