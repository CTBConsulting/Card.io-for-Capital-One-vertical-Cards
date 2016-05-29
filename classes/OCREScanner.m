//
//  OCREScanner.m
//  OCRE
//
//  Copyright © 2015 CTB Consulting. All rights reserved.
//

#import "OCREScanner.h"
#import "CardLayouts.h"
#import <AVFoundation/AVFoundation.h>



@implementation OCREScanner : NSObject

@synthesize operationQueue;
@synthesize currentOperationsCancelled;
@synthesize foundCardInfo;
@synthesize alertShowing;
@synthesize cardInfoResult;

int currentScanDigits;

-(id)initScanner  {
  self = [super init];
  self.operationQueue = [[NSOperationQueue alloc] init];
  alertShowing = NO;
  return self;
}


-(void)recognizeImageWithTesseract:(UIImage *)image  {
  /*
   * Debug code
   */
  //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
  
  [self setTorchOn:false];
  currentOperationsCancelled = NO;
  foundCardInfo = NO;
  
  CardLayouts *layouts = [[CardLayouts alloc] initCardLayouts];
  for (CardDefinition *cd in layouts.CardDefinitions)  {
    if(foundCardInfo)  {
      break;
    }
    UIImage * imageToScan = image;
    if(cd.RotateLeft)  {
      NSLog(@"Rotating -90d");
      imageToScan = [self rotateUIImage:image clockwise:NO];
      //UIImageWriteToSavedPhotosAlbum(imageToScan, nil, nil, nil);
    }
    
    currentScanDigits = cd.Digits;
    NSLog(@"Scan Started...");
    
    NSMutableString *currentCCN = [NSMutableString new];
    NSMutableString *currentCSC = [NSMutableString new];
    NSMutableString *currentExpiry = [NSMutableString new];
    currentOperationsCancelled = NO;
    [self addScanOperation:imageToScan : cd.CCNCoordinatesR0 : CCN: currentCCN: currentCSC : currentExpiry: NO];
    [self addScanOperation:imageToScan : cd.CCNCoordinatesR1 : CCN: currentCCN: currentCSC : currentExpiry: NO];
    [self addScanOperation:imageToScan : cd.CCNCoordinatesR2 : CCN: currentCCN: currentCSC : currentExpiry: NO];
    [self addScanOperation:imageToScan : cd.CCNCoordinatesR3 : CCN: currentCCN: currentCSC : currentExpiry: YES];
    
  }
}


- (bool) hasResult  {
  return self.foundCardInfo;
}

- (NSMutableString * ) getResult  {
  return self.cardInfoResult;
}

- (void) addScanOperation: (UIImage *)image :(CGRect) scanAreaRect : (ScanType) scanType : (NSMutableString *) currentCCN : (NSMutableString *) currentCSC : (NSMutableString *) currentExpiry :(BOOL) isFinalOperation  {
    if(currentOperationsCancelled)  {
      NSLog(@"Operation Cancelled!");
        return;
    }
  
    if(CGRectIsEmpty(scanAreaRect) || image == nil)  {
      if(isFinalOperation)  {
        [self finishedScanning:currentCCN : currentCSC: currentExpiry];
      }
      return;
    }
  
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleWord;//G8PageSegmentationModeSingleWord;//G8PageSegmentationModeAutoOnly;//G8PageSegmentationModeSingleWord;//
    operation.tesseract.maximumRecognitionTime = 1.0;
    operation.delegate = self;
    operation.tesseract.image = image;
    operation.tesseract.charWhitelist = @"0123456789/";
    operation.tesseract.rect = scanAreaRect;
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract)  {
    NSString *recognizedText = tesseract.recognizedText;
    NSLog(@"%@", recognizedText);
    NSMutableString * creditCardInfo = [NSMutableString new];
    static int i = 0;
    creditCardInfo = [self scanInfo:creditCardInfo : recognizedText : currentScanDigits : i];
    
    //we know if we dont find anything in a scan that we cannot complete the others
    if( creditCardInfo.length < 4 )  {
        currentOperationsCancelled = YES;
        NSLog(@"Operation Cancelled!");
        return;
    }
    
    switch (scanType)  {
      case CCN:  {
        [currentCCN appendFormat:@"%@", creditCardInfo];
      }break;
      case CSC:  {
        [currentCSC appendFormat:@"%@", creditCardInfo];
      }break;
      case Expiry:  {
        [currentExpiry appendFormat:@"%@", creditCardInfo];
      }break;
      default:  {
      }break;
    }
    
    //Debug code:
    //UIImageWriteToSavedPhotosAlbum(operation.tesseract.thresholdedImage, nil, nil, nil);
    
    if(isFinalOperation)  {
      [self finishedScanning:currentCCN : currentCSC: currentExpiry];
    }
  };

  [self.operationQueue addOperation:operation];
}

-(void) finishedScanning : (NSMutableString *) currentCCN  : (NSMutableString *) currentCSC  : (NSMutableString *) currentExpiry  {
  NSLog(@"Scan Finished.");
  NSRange range = [currentCCN rangeOfString:@"/"];
  // we don't do partial data
  if(currentCCN.length != currentScanDigits|| range.location != NSNotFound)  {
    return;
  }
  range = [currentExpiry rangeOfString:@"/"];
  if(range.location == NSNotFound)  {
    currentExpiry = [NSMutableString new];
  }
  if(currentCSC.length != 3)  {
    currentCSC = [NSMutableString new];;
  }
  
  /*
  //Debug Code
  NSMutableString *debugString = [NSMutableString new];
  [debugString appendFormat:@"%@", @"CCN: "];
  //[debugString appendFormat:@"%@", @"\n CSC: "];
  //[debugString appendFormat:@"%@", currentCSC];
  //[debugString appendFormat:@"%@", @"\n Expiry: "];
  //[debugString appendFormat:@"%@", currentExpiry];
  
  for(int i =0; i< currentCCN.length; i++)
  {
    if(i % 4 == 0)
    {
      [debugString appendFormat:@"%@", @" "];
    }
    [debugString appendFormat:@"%c", [currentCCN characterAtIndex:i]];
    
  } */
  
  if(![self luhnCheck: currentCCN])  {
    NSLog(@"CCN Failed Luhn: REJECTED");
    return;
  }
  
  foundCardInfo = YES;
  NSLog(@"Found Card Info!");
  self.cardInfoResult = currentCCN;
  
  //Debug Code
  /*
  //check to make sure it doesn't show muiltiple times..
  if(!self.alertShowing)
  {
    alertShowing = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCRE Version 1.6.3"
                                                  message:debugString
                                                 delegate:self
                                        cancelButtonTitle:@"Dismiss"
                                        otherButtonTitles:nil];
    [alert show];
  }
  */
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  {
  alertShowing = NO;
}

- (BOOL) luhnCheck:(NSMutableString *)ccn  {
  BOOL isOdd = YES;
  int oddSum = 0;
  int evenSum = 0;
  
  for (int i = ccn.length-1; i >= 0; i--)  {
    int digit = [ccn characterAtIndex:i] - '0';
    if (isOdd)  {
      oddSum += digit;
    }
    else  {
      evenSum += digit / 5 + (2 * digit) % 10;
    }
    isOdd = !isOdd;
  }
  //zero if valid
  return ((oddSum + evenSum) % 10 == 0);
}

- (NSMutableString*) scanInfo:(NSMutableString *)destinationString :(NSString *) sourceString :(int) maxCount :(int) startIndex  {
  int count = 0;
  for (int i = startIndex; i<sourceString.length; i++)  {
    char character = [sourceString characterAtIndex:(i)];
    if([self isNumber:(character)]|| character == '/')  {
      [destinationString appendFormat:@"%c", character];
      count++;
    }
    if(count >= maxCount)  {
      NSLog(@"Scan Segment Overflow");
      break;
    }
  }
  return destinationString;
}

- (bool) isNumber:(char)character  {
  if((int)character >= (int)'0' && (int)character <= (int)'9')  {
    return YES;
  }
  return NO;
}

- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise  {
  CGSize size = sourceImage.size;
  UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
  [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
  UIImage* rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return rotatedImage;
}

//Hack to turn off torch because card.io keeps turning it on...
-(void) setTorchOn: (bool) on  {
  Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
  if (captureDeviceClass != nil)  {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])  {
      
      [device lockForConfiguration:nil];
      if (on)  {
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
      }
      else  {
        [device setTorchMode:AVCaptureTorchModeOff];
        [device setFlashMode:AVCaptureFlashModeOff];
      }
      [device unlockForConfiguration];
    }
  }
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
  NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
  return NO;  // return YES, if you need to cancel recognition prematurely
}

@end