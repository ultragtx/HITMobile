//
//  CalculateAngleAppDelegate.m
//  CalculateAngle
//
//  Created by Hiro on 11-6-9.
//  Copyright 2011 FoOTOo. All rights reserved.
//

#import "CalculateAngleAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@implementation CalculateAngleAppDelegate

@synthesize window;

- (void)makeNewPlist {
	/*double x1 = 677.0; // data bai
	double y1 = 225.0; // data bai
	double x2 = 568.0; // data me
	double y2 = 188.0; // data me
	double scaleX = x2 / x1;
	double scaleY = y2 / y1;
	double sampleX1 = 2378; // data bai
	double sampleY1 = 3100; // data bai
	double sampleX2 = 2243; // data me
	double sampleY2 = 2530; // data me*/
	
	double x1 = 313.0; // data bai
	double y1 = 290.0; // data bai
	double x2 = 279.0; // data me
	double y2 = 257.0; // data me
	double scaleX = x2 / x1;
	double scaleY = y2 / y1;
	double sampleX1 = 1830.0; // data bai
	double sampleY1 = 1311.0; // data bai
	double sampleX2 = 1676.0; // data me
	double sampleY2 = 1235.0; // data me
	int offsetX = (int)(sampleX1 * scaleX - sampleX2);
	int offsetY = (int)(sampleY1 * scaleY - sampleY2);
	
	// fianl bai * scale - offset
	
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"locate" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSArray *locateX = [dict valueForKey:@"Region2CoordinatesX"];
	NSArray *locateY = [dict valueForKey:@"Region2CoordinatesY"];
	
	NSMutableArray *newLocateX = [[NSMutableArray alloc] init];
	NSMutableArray *newLocateY = [[NSMutableArray alloc] init];
	
	for (int i = 0; i <= 47; i++) {
		int tempX = [[locateX objectAtIndex:i] intValue];
		int tempY = [[locateY objectAtIndex:i] intValue];
		int newX = (int)(tempX * scaleX - offsetX);
		int newY = (int)(tempY * scaleY - offsetY);
		[newLocateX addObject:[NSNumber numberWithInt:newX]];
		[newLocateY addObject:[NSNumber numberWithInt:newY]];
	}
	NSDictionary *newLocateDic = [[NSDictionary alloc] initWithObjectsAndKeys:newLocateX, @"Region2CoordinatesX", newLocateY, @"Region2CoordinatesY", nil];
	NSString *newLocateDicPath = @"/Users/Hiro/Desktop/locate2.plist";
	BOOL success = [newLocateDic writeToFile:newLocateDicPath atomically:YES];
	if (!success) {
		NSLog(@"write error");
	}
}

/*- (void)calculate {
	// change g to g_rotate
	double gMapAngle1 = 49.8 / 360.0 * 2 * M_PI;  // 参数: 角度
	double gMapPointX = 1005.9;//5;//12.5;					  // 数据
	double gMapPointY = 301.;//120;//0;						  // 数据
	double tempGAngle = atan(gMapPointY / gMapPointX) - gMapAngle1;
	NSLog(@"gtA[%lf]", tempGAngle / (2*M_PI) * 360);
	double tempGLength = sqrt(pow(gMapPointX, 2.0) + pow(gMapPointY, 2.0));
	NSLog(@"gC[%lf]", tempGLength);
	double gMapPointRotateX = tempGLength * cos(tempGAngle);
	double gMapPointRotateY = tempGLength * sin(tempGAngle);
	NSLog(@"gRX[%lf]", gMapPointRotateX);
	NSLog(@"gRY[%lf]", gMapPointRotateY);
	
	// change g_rotate to h_rotate
	double hRotateXScaleToGRotateX = 1.09; //2.69 / 2.40; // 参数: 比例
	double hRotateYScaleToGRotateY = 1.21; //1.90 / 1.23; // 参数: 比例
	double hMapPointRotateX = gMapPointRotateX * hRotateXScaleToGRotateX; // A
	double hMapPointRotateY = gMapPointRotateY * hRotateYScaleToGRotateY; // B
	NSLog(@"hRX[%lf]", hMapPointRotateX);
	NSLog(@"hRY[%lf]", hMapPointRotateY);
	// TODO:delete the test
	//hMapPointRotateX = 26.9;
	//hMapPointRotateY = 19.0;
	// end test
	
	// change h_rotate to h
	double hMapAngle1 = 31.8 / 360.0 * 2 * M_PI;	// 参数:角度
	double hMapAngle2 = 60.4 / 360.0 * 2 * M_PI;	// 参数:角度

	double hMapAngle0 = M_PI_2 - hMapAngle1 + hMapAngle2;
	BOOL hRotateXYGreaterThanZero = ((hMapPointRotateX * hMapPointRotateY) > 0);
	//int oneOrMinusOne = hRotateXYGreaterThanZero ? -1 : 1;
	double tempHAngleC = hMapAngle0; // angle c
	if (hRotateXYGreaterThanZero) {
		tempHAngleC = M_PI - hMapAngle0;
	}
	NSLog(@"hCA[%lf]", tempHAngleC / (2*M_PI) * 360);
	double tempHLength = sqrt(pow(hMapPointRotateX, 2.0) + pow(hMapPointRotateY, 2.0) - // C
									2 * fabs(hMapPointRotateX) * fabs(hMapPointRotateY) * 
								  cos(tempHAngleC));
	NSLog(@"HC[%lf]", tempHLength);
	double tempHAngleB = acos((pow(hMapPointRotateX, 2.0) + pow(tempHLength, 2.0) - // B
							   pow(hMapPointRotateY, 2.0)) / (2 * fabs(hMapPointRotateX) * fabs(tempHLength)));
	NSLog(@"0hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	if (hMapPointRotateX > 0 && hMapPointRotateY > 0) {
		tempHAngleB = tempHAngleB;
		NSLog(@"1hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX > 0 && hMapPointRotateY <= 0) {
		tempHAngleB = 2 * M_PI - tempHAngleB;
		NSLog(@"2hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else if (hMapPointRotateX <= 0 && hMapPointRotateY > 0) {
		tempHAngleB = M_PI - tempHAngleB;
		NSLog(@"3hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	else {
		tempHAngleB = M_PI + tempHAngleB;
		NSLog(@"4hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
	}
	
	
	double tempHAngle = tempHAngleB + hMapAngle1;
	double hMapPointX = tempHLength * cos(tempHAngle);
	double hMapPointY = tempHLength * sin(tempHAngle);
	NSLog(@"hX[%lf]", hMapPointX);
	NSLog(@"hY[%lf]", hMapPointY);

	
}*/

#define OFFSET_ORIGINALPOINT_X 800
#define OFFSET_ORIGINALPOINT_Y 400

#define OFFSET2_ORIGINALPOINT_X 1180//1980//1210
#define OFFSET2_ORIGINALPOINT_Y 366//383

- (int)calculateAverageOffsetX:(int *)xOnMap Y:(int *)yOnMap {
	int average = 0;
	for	(int i = 0; i < 3; i++) {
		int temp1 = abs(xOnMap[i] - correctPointX[i]);
		int temp2 = abs(yOnMap[i] - correctPointY[i]);
		average = average + temp1 * temp1 + temp2 * temp2;
	}
	NSLog(@"###########AVERAGE[%d]############", average);
	return average;
}

- (int)showLocationAtLatitude:(double *)latitude
					 lontitude:(double *)longtitude 
			  originalLatitude:(double)oriLatitude 
			originalLongtitude:(double)oriLongtitude {
	
	int xOnMap[3];
	int yOnMap[3];
	
	for (int i = 0; i < 3; i++) {
		// calculate x y on gMap
		CLLocation *location1 = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:oriLongtitude];
		CLLocation *locationX = [[CLLocation alloc] initWithLatitude:oriLatitude longitude:longtitude[i]];
		CLLocation *locationY = [[CLLocation alloc] initWithLatitude:latitude[i] longitude:oriLongtitude];
		double x = [location1 distanceFromLocation:locationX];
		double y = [location1 distanceFromLocation:locationY];
		NSLog(@"x [%lf] y [%lf]", x, y);
		
		if (x <= 0 || y <= 0) {
			NSLog(@"x y must bigger than 0 so that the location is in the school");
			// TODO: add delegate here to show a dialog that you are not in the school or maybe in ViewController
			return -1;
		}
		
		// change g to g_rotateas
		
		// !!!:double gMapAngle1 = 30.0 / 360.0 * 2 * M_PI;  // 参数: 角度
		double gMapPointX = x;	//120;//5;//12.5;					  // 数据
		double gMapPointY = y;	//5;//120;//0;						  // 数据
		
		double tempGAngle = atan(gMapPointY / gMapPointX) - gMapAngle1;
 NSLog(@"gtA[%lf]", tempGAngle / (2*M_PI) * 360);
		double tempGLength = sqrt(pow(gMapPointX, 2.0) + pow(gMapPointY, 2.0));
 NSLog(@"gC[%lf]", tempGLength);
		double gMapPointRotateX = tempGLength * cos(tempGAngle);
		double gMapPointRotateY = tempGLength * sin(tempGAngle);
 NSLog(@"gRX[%lf]", gMapPointRotateX);
 NSLog(@"gRY[%lf]", gMapPointRotateY);
		
		// change g_rotate to h_rotate
		// !!!:double hRotateXScaleToGRotateX = 878.38 / 550.8;	//1.09; //2.69 / 2.40; // 参数: 比例
		// !!!:double hRotateYScaleToGRotateY = 1090.35 / 675.45;	//1.21; //1.90 / 1.23; // 参数: 比例
		double hMapPointRotateX = gMapPointRotateX * hRotateXScaleToGRotateX; // A
		double hMapPointRotateY = gMapPointRotateY * hRotateYScaleToGRotateY; // B
 NSLog(@"hRX[%lf]", hMapPointRotateX);
 NSLog(@"hRY[%lf]", hMapPointRotateY);
		// TODO:delete the test
		//hMapPointRotateX = 26.9;
		//hMapPointRotateY = 19.0;
		// end test
		
		// change h_rotate to h
		double hMapAngle1 = 31.8 / 360.0 * 2 * M_PI; //31.8 / 360.0 * 2 * M_PI;	// 参数:角度
		double hMapAngle2 = 60.4 / 360.0 * 2 * M_PI;//60.4 / 360.0 * 2 * M_PI;	// 参数:角度
		
		double hMapAngle0 = M_PI_2 - hMapAngle1 + hMapAngle2;
		BOOL hRotateXYGreaterThanZero = ((hMapPointRotateX * hMapPointRotateY) > 0);
		//int oneOrMinusOne = hRotateXYGreaterThanZero ? -1 : 1;
		double tempHAngleC = hMapAngle0; // angle c
		if (hRotateXYGreaterThanZero) {
			tempHAngleC = M_PI - hMapAngle0;
		}
 NSLog(@"hCA[%lf]", tempHAngleC / (2*M_PI) * 360);
		double tempHLength = sqrt(pow(hMapPointRotateX, 2.0) + pow(hMapPointRotateY, 2.0) - // C
								  2 * fabs(hMapPointRotateX) * fabs(hMapPointRotateY) * 
								  cos(tempHAngleC));
 NSLog(@"HC[%lf]", tempHLength);
		double tempHAngleB = acos((pow(hMapPointRotateX, 2.0) + pow(tempHLength, 2.0) - // B
								   pow(hMapPointRotateY, 2.0)) / (2 * fabs(hMapPointRotateX) * fabs(tempHLength)));
 NSLog(@"0hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
		if (hMapPointRotateX > 0 && hMapPointRotateY > 0) {
			tempHAngleB = tempHAngleB;
 NSLog(@"1hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
		}
		else if (hMapPointRotateX > 0 && hMapPointRotateY <= 0) {
			tempHAngleB = 2 * M_PI - tempHAngleB;
 NSLog(@"2hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
		}
		else if (hMapPointRotateX <= 0 && hMapPointRotateY > 0) {
			tempHAngleB = M_PI - tempHAngleB;
 NSLog(@"3hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
		}
		else {
			tempHAngleB = M_PI + tempHAngleB;
 NSLog(@"4hBA[%lf]", tempHAngleB / (2*M_PI) * 360);
		}
		
		
		double tempHAngle = tempHAngleB + hMapAngle1;
		double hMapPointX = tempHLength * cos(tempHAngle);
		double hMapPointY = tempHLength * sin(tempHAngle);
 NSLog(@"hX[%lf]", hMapPointX);
 NSLog(@"hY[%lf]", hMapPointY);
		
		int hMapPointXInt = (int)hMapPointX + OFFSET2_ORIGINALPOINT_X;//OFFSET_ORIGINALPOINT_X;
		int hMapPointYInt = 2411 - ((int)hMapPointY+ OFFSET2_ORIGINALPOINT_Y);//OFFSET_ORIGINALPOINT_Y);
		
		 NSLog(@"hX[%d]", hMapPointXInt);
		 NSLog(@"hY[%d]", hMapPointYInt);
		
		xOnMap[i] = hMapPointXInt;
		yOnMap[i] = hMapPointYInt;
	}
	//[self showPinAtPointX:hMapPointXInt Y:hMapPointYInt PinType:PINTYPE_LOCATE];
	return [self calculateAverageOffsetX:xOnMap Y:yOnMap];
	
}

#define CAMP1_ORIPOINT_LA 45.753767
#define CAMP1_ORIPOINT_LO 126.634812
#define CAMP2_ORIPOINT_LA 45.750360
#define CAMP2_ORIPOINT_LO 126.671439


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	//[self calculate];
	//[self makeNewPlist];
	//return;
	
	// const data
	minAverage = INT_MAX;
//	double latitude[3] = {45.759091, 45.752666, 45.751761};//{45.744715, 45.731899, 45.742139};
//	double longtitude[3] = {126.681106, 126.682691, 126.675807};//{126.630918, 126.628190, 126.625053};
	double latitude[3] = {45.759091, 45.752666, 45.740492}; //45.755616};//45.758209};//{45.744715, 45.731899, 45.742139}; 
	double longtitude[3] = {126.681106, 126.682691, 126.628533}; //126.677576};//126.674200};//{126.630918, 126.628190, 126.625053}; 
	
//	int correctPointX1[3] = {1204, 2345, 1507};//{1536, 2203, 2476};
//	int correctPointY1[3] = {530, 1138, 1610};//{2720, 1160, 2448};
	int correctPointX1[3] = {1204, 2345, 0}; //1249};//443};//{1536, 2203, 2476};
		int correctPointY1[3] = {530, 1138, 0}; //1104};//1002};//{2720, 1160, 2448};
	correctPointX = correctPointX1;
	correctPointY = correctPointY1;
	// const data end
	
	gMapAngle1 = 10.5 / 360.0 * 2 * M_PI;
	hRotateXScaleToGRotateX = 907.4188669 / 545.05;//868.7514029 / 556.35; //1.561519552
	hRotateYScaleToGRotateY = 1292.882439 / 726.32;//1088.715298 / 688.4; //1.58151554
	// get offset 25601 by average
	[self showLocationAtLatitude:latitude lontitude:longtitude originalLatitude:CAMP2_ORIPOINT_LA originalLongtitude:CAMP2_ORIPOINT_LO];
	return;
	//angele from 46 to 53
	// scale from 1.4 to 1.8 
	// over with 608 @ 51.800 1.54 1.58
	
	
	//angele from 50 to 52.5
	// scale from 1.4 to 1.6 
	// over with 606 @ 51.950 1.54 1.59

	//angele from 51 to 52.1
	// scale from 1.5 to 1.61 
	// over with 562 @ 51.680000 1.545000 1.580000
	
	gMapAngle1 = 51.5 / 360.0 * 2 * M_PI;
	while (gMapAngle1 += 0.01 / 360.0 * 2 * M_PI) {
		if (gMapAngle1 >= 52.0 / 360.0 * 2 * M_PI) {
			break;
		}
		hRotateXScaleToGRotateX = 1.535;
		while (hRotateXScaleToGRotateX += 0.001) {
			if (hRotateXScaleToGRotateX >= 1.60) {
				break;
			}
			hRotateYScaleToGRotateY = 1.535;
			while (hRotateYScaleToGRotateY += 0.001) {
				if (hRotateYScaleToGRotateY >= 1.60) {
					break;
				}
				int tempAverage = [self showLocationAtLatitude:latitude lontitude:longtitude originalLatitude:45.753767 originalLongtitude:126.634812];
				if (tempAverage < minAverage) {
					NSLog(@"gMapAngle1 [%lf]", gMapAngle1 / (2*M_PI) * 360 );
					NSLog(@"hRotateXScaleToGRotateX [%lf]", hRotateXScaleToGRotateX);
					NSLog(@"hRotateYScaleToGRotateY [%lf]", hRotateYScaleToGRotateY);
					minAverage = tempAverage;
				}
			}
		}
	}
	
	


	
	
	NSLog(@"end!!!!!!!!!!!!!!!!!!!!!! minAverage[%d]", minAverage);
	
}

@end
