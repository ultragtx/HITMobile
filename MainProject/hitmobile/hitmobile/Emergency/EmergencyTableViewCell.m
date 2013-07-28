//
//  EmergencyTableViewCell.m
//  iHIT
//
//  Created by Bai Yalong on 11-3-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 File: IndividualSubviewsBasedApplicationCell.m 
 Abstract: The subclass of ApplicationCell that uses individual subviews to display the content. 
 Version: 1.5 
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
 
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
 
 */

#import "EmergencyTableViewCell.h"


@implementation EmergencyTableViewCell

//- (void)setBackgroundColor:(UIColor *)backgroundColor
//{
//    [super setBackgroundColor:backgroundColor];
//	
//    iconView.backgroundColor = backgroundColor;
//    englishDescriptionLabel.backgroundColor = backgroundColor;
//    chineseDescriptionLabel.backgroundColor = backgroundColor;
//    telephoneNumberLabel.backgroundColor = backgroundColor;
//}

- (void)setIcon:(UIImage *)newIcon
{
    [super setIcon:newIcon];
    iconView.image = newIcon;
}

- (void)setEnglishDescription:(NSString *)newEnglishDescription
{
    [super setEnglishDescription:newEnglishDescription];
    englishDescriptionLabel.text = newEnglishDescription;
}

- (void)setChineseDescription:(NSString *)newChineseDescription
{
    [super setChineseDescription:newChineseDescription];
    chineseDescriptionLabel.text = newChineseDescription;
}

- (void)setTelephoneNumber:(NSString *)newTelephoneNumber
{
    [super setTelephoneNumber:newTelephoneNumber];
    telephoneNumberLabel.text = newTelephoneNumber;
}

- (void)dealloc
{
    [iconView release];
    [englishDescriptionLabel release];
    [chineseDescriptionLabel release];
    [telephoneNumberLabel release];
	
    [super dealloc];
}

@end
