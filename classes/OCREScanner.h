//
//  OCREScanner.h
//  OCRE
//
//  Copyright © 2015 CTB Consulting. All rights reserved.
//

#ifndef OCREScanner_h
#define OCREScanner_h
#import <Foundation/Foundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import "ScanType.h"


@interface OCREScanner : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL currentOperationsCancelled;
@property (nonatomic, assign) BOOL foundCardInfo;
@property (nonatomic, assign) BOOL alertShowing;
@property (nonatomic, strong) NSMutableString * cardInfoResult;


- (id)initScanner;
- (bool) isNumber:(char)character;
- (bool) hasResult;
- (void) addScanOperation: (UIImage *)image :(CGRect) scanAreaRect : (ScanType) scanType : (NSMutableString *) currentCCN : (NSMutableString *) currentCSC : (NSMutableString *) currentExpiry : (BOOL) isFinalOperation;
- (NSMutableString*) scanInfo:(NSMutableString *)destinationString :(NSString *) sourceString :(int) maxCount :(int) startIndex;
-(void)recognizeImageWithTesseract:(UIImage *)image;
-(void) finishedScanning : (NSMutableString *) currentCCN  : (NSMutableString *) currentCSC  : (NSMutableString *) currentExpiry;
-(BOOL) luhnCheck:(NSMutableString *)ccn;
-(void) setTorchOn: (bool) on;
- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise;
- (NSMutableString *) getResult;


@end

#endif
