//
//  DecadeSix.m
//  RobotWar
//
//  Coded terribly by Teresa & Eric on 03/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DecadeSix.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

int times = 0;

@implementation DecadeSix {
    RobotState _currentRobotState;
    
    CGPoint _currentPosition;
    CGFloat _currentFloat;
    CGPoint _currentGunPosition;
    CGFloat _currentGunFloat;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGFloat testFloat;
}

- (void)run {
    while (true) {
        if (_currentFloat != -45)
        {
            [self turnRobotRight:75];
            [self moveBack:60];
            [self turnRobotLeft:35];
            _currentPosition = [self headingDirection];
            _currentFloat = [self angleBetweenHeadingDirectionAndWorldPosition:_currentPosition];
            _currentRobotState = RobotStateSearching;
            CCLOG(@"%f", _currentFloat);
        }
        if (_currentRobotState == RobotStateSearching)
        {
            _currentGunPosition = [self gunHeadingDirection];
            _currentGunFloat = [self angleBetweenGunHeadingDirectionAndWorldPosition:_currentGunPosition];
            if (_currentGunFloat < -45)
            {
                [self turnGunLeft:1];
            }
            if (_currentGunFloat > -45)
            {
                [self turnGunRight:1];
            }
            if (_currentGunFloat == -45)
            {
                [self shoot];
            }
        }
        if (_currentRobotState == RobotStateFiring)
        {
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
            
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // not sure if i want to make this change
    //slows my searching state
    //[self shoot];
    //_currentRobotState = RobotStateFiring;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring)
    {
        [self cancelActiveAction];
    }
    
    if (_currentRobotState == RobotStateSearching)
    {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        if (angle >= 0) {
            [self turnRobotLeft:abs(angle)];
        } else {
            [self turnRobotRight:abs(angle)];
            
        }
        
        [self moveAhead:20];
        
        _currentRobotState = previousState;
    }
}

@end
