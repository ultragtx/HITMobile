/*
     File: ParseOperation.m 
 Abstract: NSOperation code for parsing the RSS feed.
  
  Version: 1.2 
  
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
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "ParseOperation.h"
#import "NewsCell.h"
#import "NewsViewController.h"

// string contants found in the RSS feed
static NSString *kTitle = @"title";
static NSString *kTime = @"time";
static NSString *kAuthor = @"author";
static NSString *kCellImage = @"cellimage";
static NSString *kImage = @"image";
static NSString *kLargeImage = @"largeimage";
static NSString *kHtmlCode = @"htmlcode";
static NSString *kEntryStr = @"item";

//static NSString *kIDStr     = @"id";
//static NSString *kNameStr   = @"im:name";
//static NSString *kImageStr  = @"im:image";
//static NSString *kArtistStr = @"im:artist";
//static NSString *kEntryStr  = @"entry";


@interface ParseOperation ()
@property (nonatomic, assign) id <ParseOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) NewsCell *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse, storingCharacterData;

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:kTitle, kTime, kAuthor, kCellImage, kImage, kLargeImage, kHtmlCode, nil];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [workingArray release];
    
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
    [parser parse];
	
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    
    [parser release];

	[pool release];
}


#pragma mark -
#pragma mark RSS processing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    // entry: { id (link), im:name (app name), im:image (variable height) }
    //
    if ([elementName isEqualToString:kEntryStr])
	{
        self.workingEntry = [[[NewsCell alloc] init] autorelease];
    }
    storingCharacterData = [elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    storingCharacterData = [elementsToParse containsObject:elementName];
    if (self.workingEntry)
	{
        if (storingCharacterData)
        {
            NSString *trimmedString = [workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [workingPropertyString setString:@""];  // clear the string for next time
            if ([elementName isEqualToString:kTitle])
            {
                self.workingEntry.newsTitle = trimmedString;
            }
            else if ([elementName isEqualToString:kTime])
            {        
                self.workingEntry.newsDate = trimmedString;
            }
            else if ([elementName isEqualToString:kAuthor])
            {
                self.workingEntry.newsAuthor = trimmedString;
            }
            else if ([elementName isEqualToString:kCellImage])
            {
                if ([trimmedString isEqualToString:@""]) {
                    self.workingEntry.newsCellImageURL = trimmedString;
                } else if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                    if ([[UIScreen mainScreen] scale] == 2) {
                        // Use high resolution images
                        self.workingEntry.newsCellImageURL = [NSString stringWithFormat:@"%@2x.png", [trimmedString substringToIndex:([trimmedString length] - 4)]];
                    } else {
                        self.workingEntry.newsCellImageURL = trimmedString;
                    }
                }
            }
            else if ([elementName isEqualToString:kImage])
            {
                if ([trimmedString isEqualToString:@""]) {
                    self.workingEntry.newsImageURL = trimmedString;
                } else if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                    if ([[UIScreen mainScreen] scale] == 2) {
                        // Use high resolution images
                        self.workingEntry.newsImageURL = [NSString stringWithFormat:@"%@2x.png", [trimmedString substringToIndex:([trimmedString length] - 4)]];
                    } else {
                        self.workingEntry.newsImageURL = trimmedString;
                    }
                }

            }
            else if ([elementName isEqualToString:kLargeImage])
            {
                if ([trimmedString isEqualToString:@""]) {
                    self.workingEntry.newsLargeImageURL = trimmedString;
                } else if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                    if ([[UIScreen mainScreen] scale] == 2) {
                        // Use high resolution images
                        self.workingEntry.newsLargeImageURL = [NSString stringWithFormat:@"%@2x.jpg", [trimmedString substringToIndex:([trimmedString length] - 4)]];
                    } else {
                        self.workingEntry.newsLargeImageURL = trimmedString;
                    }
                }

            }
            else if ([elementName isEqualToString:kHtmlCode])
            {
                self.workingEntry.newsDetail = trimmedString;
            }
        }
        else if ([elementName isEqualToString:kEntryStr])
        {
            [self.workingArray insertObject:self.workingEntry atIndex:0];
            self.workingEntry = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingCharacterData)
    {
        [workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end
