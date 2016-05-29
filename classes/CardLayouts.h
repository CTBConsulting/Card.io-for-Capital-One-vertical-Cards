//
//  CardLayout.h
//  icc
//
//  Copyright © 2015 CTB Consulting. All rights reserved.
//

#ifndef CardLayout_h
#define CardLayout_h

#import "CardDefinition.h"


@interface CardLayouts : NSObject

@property (nonatomic, strong) NSMutableArray *CardDefinitions;

-(id)initCardLayouts;
-(NSString *)serializeCardDefinition:(CardDefinition *) cd;
-(void)printCardDefinitions;
-(void)deployCardDefinitions:(BOOL)overwrite;



@end

@implementation CardLayouts

-(id)initCardLayouts  {
  if(self = [super init])  {
    
    
    self.CardDefinitions = [[NSMutableArray alloc] init];
 
    [self deployCardDefinitions:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"CardDefinitions.json"];

    
    NSString * jsonData = [[NSString alloc] initWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:NULL];
    if (!jsonData) {
      NSLog(@"Definitions File could not be read!");
    }
    NSLog(jsonData);
    NSError * error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    for (NSString * key in [json allKeys])  {
      
        NSString * rect0val = [[json valueForKey:key] valueForKey:@"Rect0"];
        CGRect rect0 = CGRectFromString(rect0val);
        NSString * rect1val = [[json valueForKey:key] valueForKey:@"Rect1"];
        CGRect rect1 = CGRectFromString(rect1val);
        NSString * rect2val = [[json valueForKey:key] valueForKey:@"Rect2"];
        CGRect rect2 = CGRectFromString(rect2val);
        NSString * rect3val = [[json valueForKey:key] valueForKey:@"Rect3"];
        CGRect rect3 = CGRectFromString(rect3val);
        CardDefinition * cd = [[CardDefinition alloc] initCardDefinition: key : YES : 16 :
                   rect0:
                   rect1:
                   rect2:
                   rect3:
                   CGRectMake(0, 0, 0, 0):
                   CGRectMake(0, 0, 0, 0)];
      [self.CardDefinitions addObject:cd];
    }
  }
  return self;
}

-(void) deployCardDefinitions: (BOOL) overwrite {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSString *jsonPath = [documentsDirectory stringByAppendingPathComponent:@"CardDefinitions.json"];
  
  if ([fileManager fileExistsAtPath:jsonPath] == overwrite) {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"CardDefinitions" ofType:@"json"];
    [fileManager copyItemAtPath:resourcePath toPath:jsonPath error:&error];
    NSLog(@"Deployed Card Definitions!");
  }
  else {
    NSLog(@"Card Definitions Found!");
  }
}

-(void) printCardDefinitions  {
  NSMutableArray * defs = [NSMutableArray new];
  NSMutableArray * vals = [NSMutableArray new];
  for(CardDefinition * cd in self.CardDefinitions) {
    [defs addObject:cd.Name];
    [vals addObject:[self serializeCardDefinition:cd]];
    
  }
  NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:vals forKeys:defs];
  NSError * writeError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&writeError];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   NSLog(@"JSON Output: %@", jsonString);
}

-(NSString*)serializeCardDefinition: (CardDefinition *) cd {
  
  NSMutableArray * keys = [NSMutableArray new];
  
  NSMutableArray * values = [NSMutableArray new];
  [keys addObject:@"Rect0"];
  [values addObject:NSStringFromCGRect(cd.CCNCoordinatesR0)];
  [keys addObject:@"Rect1"];
  [values addObject:NSStringFromCGRect(cd.CCNCoordinatesR1)];
  [keys addObject:@"Rect2"];
  [values addObject:NSStringFromCGRect(cd.CCNCoordinatesR2)];
  [keys addObject:@"Rect3"];
  [values addObject:NSStringFromCGRect(cd.CCNCoordinatesR3)];

  NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
  NSError * writeError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&writeError];
  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  return jsonString;
}


@end

#endif /* CardLayout_h */
