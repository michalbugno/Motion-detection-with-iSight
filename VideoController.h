//
//  VideoController.h
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface VideoController : NSObject {
    QTCaptureSession *mCaptureSession;
    QTCaptureDeviceInput *mCaptureDeviceInput;
    IBOutlet QTCaptureView *mCaptureView;
    QTCaptureVideoPreviewOutput *mCaptureOutput;
    uint8_t *imageData, *previousImageData;
    int bytesPerRow, bytesPerPixel;
    CGSize size;
    IBOutlet NSLevelIndicator *level;
}

- (IBAction)start:(id)sender;
- (void)startCapture;
- (void)stopCapture;
- (float)calculateDifferenceBetween:(uint8_t *)image1 and:(uint8_t *)image2;
@end
