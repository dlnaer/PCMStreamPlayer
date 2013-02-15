//
//  KNViewController.m
//  PCMStreamPlayer
//
//  Created by cyh on 13. 2. 13..
//  Copyright (c) 2013년 saeha. All rights reserved.
//

#import "KNViewController.h"
#import "KNAudioManager.h"
#include <sys/stat.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KNViewController () {
    FILE* p;
    int size;
    KNAudioManager* mgr;
}

@end

@implementation KNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    /**
        Linear PCM DATA.
        Use GoldWave MP3 -> PCM.
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)playPCM:(id)sende {
    
    if (mgr) {
        NSLog(@"KNAudioManager Instance aready exist.");
        return;
    } else {
        
        /**
            FILE PATH : Convert MP3 -> RAW(PCM)data  to use GoldWave.
         */
        NSString* pcmPath = [[NSBundle mainBundle] pathForResource:@"ila" ofType:@"snd"];
        p = fopen([pcmPath UTF8String], "rb");
        struct stat st;
        stat([pcmPath UTF8String], &st);
        size = st.st_size;
        
        mgr = [[KNAudioManager alloc] init];
    }
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block int currentAudioFramePos = 0;
        mgr.outputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
            fread(data, 1, mgr.bufferSize, p);
            currentAudioFramePos += mgr.bufferSize;
        
            if (size <= currentAudioFramePos) {
                [self performSelectorOnMainThread:@selector(close:) withObject:nil waitUntilDone:NO];
                fclose(p);
            }
        };
        [mgr play];
    });
    
}

- (IBAction)play:(id)sender {
    [mgr play];
}

- (IBAction)stop:(id)sender {
    [mgr pause];
}

- (IBAction)close:(id)sender {
 
    [mgr deactivateAudioSession];
    [mgr release];
    mgr = nil;
}
@end
