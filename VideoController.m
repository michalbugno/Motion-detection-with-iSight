//
//  VideoController.m
//  motiondetection
//
//  Created by Michal Bugno on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VideoController.h"


@implementation VideoController
- (IBAction)start:(id)sender {
    if ([mCaptureSession isRunning]) {
        [self stopCapture];
    } else {
        [self startCapture];
    }
}

- (void)startCapture {
    // Create a new Capture Session
    mCaptureSession = [[QTCaptureSession alloc] init]; 
    
    //Connect inputs and outputs to the session
    BOOL success = NO;
    NSError *error;
    
    // Find a video device
    QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if(device) {
        success = [device open:&error];
        if(!success) {
            // Handle Error!
        }
        // Add the video device to the session as device input
        mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
        if(!success) {
            // Handle error
        }
        
        // Associate the capture view in the UI with the session
        [mCaptureView setCaptureSession:mCaptureSession];
        mCaptureOutput = [[QTCaptureVideoPreviewOutput alloc] init];
        [mCaptureOutput setDelegate:self];
        [mCaptureSession addOutput:mCaptureOutput error:&error];
                
        // Start the capture session runing
        [mCaptureSession startRunning];
        
    } // End if device
}

- (void)stopCapture {
    [mCaptureSession stopRunning];
    [mCaptureSession release];
    [mCaptureDeviceInput release];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
    float difference;
    
    bytesPerRow = CVPixelBufferGetBytesPerRow(videoFrame);
    CVPixelBufferLockBaseAddress(videoFrame, 0);
    size = CVImageBufferGetDisplaySize(videoFrame);
    imageData = (uint8_t *)CVPixelBufferGetBaseAddress(videoFrame);
    CVPixelBufferUnlockBaseAddress(videoFrame, 0);
    bytesPerPixel = 4;
    if (previousImageData != nil) {
        difference = [self calculateDifferenceBetween:imageData and:previousImageData];
    }
    free(previousImageData);
    previousImageData = malloc(bytesPerRow * size.height);
    memcpy(previousImageData, imageData, bytesPerRow * size.height);
    
    [level setFloatValue:100 * difference];
}

- (float)calculateDifferenceBetween:(uint8_t *)image1 and:(uint8_t *)image2 {
    int xPoint, yPoint;
    float difference;
    int width, height;
    int index;
    int red1, red2, green1, green2, blue1, blue2;
    
    width = size.width;
    height = size.height;
    difference = 0.0;
    for (xPoint = 0; xPoint < width; xPoint += 5) {
        for (yPoint = 0; yPoint < height; yPoint += 5) {
            index = bytesPerRow * yPoint + bytesPerPixel * xPoint;
            red1 = image1[index];
            green1 = image1[index + 1];
            blue1 = image1[index + 2];
            red2 = image2[index];
            green2 = image2[index + 1];
            blue2 = image2[index + 2];
            difference += abs(red1 - red2) / 255.0;
            difference += abs(green1 - green2) / 255.0;
            difference += abs(blue1 - blue2) / 255.0;
        }
    }
    difference =  25 * difference / size.width / size.height;
    NSLog(@"%f", difference);
    return difference;
}

@end
