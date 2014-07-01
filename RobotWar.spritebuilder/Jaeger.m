//
//  Jaeger.m
//  RobotWar
//
//  Created by New on 6/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Jaeger.h"

//@implementation Jaeger

typedef NS_ENUM(NSInteger, TurretState) {
    kTurretStateScanning,
    kTurretStateFiring
};

// old gun angle tolerance
//static const float GUN_ANGLE_TOLERANCE = 2.0f;
// new, make tolerance greater, for better finding
static const float GUN_ANGLE_TOLERANCE = 6.0f;

@implementation Jaeger {
    TurretState _currentState;
    float _timeSinceLastEnemyHit;
    //added stuff
    CGFloat currentAngle;
    CGPoint currentPoint;
    CGSize currentDimension;
}

- (id)init {
    if (self = [super init]) {
        _currentState = kTurretStateScanning;
    }
    
    return self;
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    
    // Calculate the angle between the turret and the enemy
    float angleBetweenTurretAndEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:position];
    
    //    CCLOG(@"Enemy Position: (%f, %f)", position.x, position.y);
    //    CCLOG(@"Enemy Spotted at Angle: %f", angleBetweenTurretAndEnemy);
    
    if (angleBetweenTurretAndEnemy > GUN_ANGLE_TOLERANCE) {
        [self cancelActiveAction];
        [self turnGunRight:abs(angleBetweenTurretAndEnemy)];
    }
    else if (angleBetweenTurretAndEnemy < -GUN_ANGLE_TOLERANCE) {
        [self cancelActiveAction];
        [self turnGunLeft:abs(angleBetweenTurretAndEnemy)];
    }
    
    _timeSinceLastEnemyHit = self.currentTimestamp;
    _currentState = kTurretStateFiring;
}

- (void)run {
    while (true) {
        switch (_currentState) {
            /* original code
            case kTurretStateScanning:
                [self turnGunRight:90];
                break;
             */
            
            case kTurretStateScanning:
                if (currentAngle != -60)
                {
                [self turnRobotRight:50];
                [self moveBack:30];
                currentPoint = [self headingDirection];
                currentAngle = [self angleBetweenHeadingDirectionAndWorldPosition:currentPoint];
                _currentState = kTurretStateFiring;
                break;
                }
                
            case kTurretStateFiring:
                if (self.currentTimestamp - _timeSinceLastEnemyHit > 10.0f) {
                    [self cancelActiveAction];
                    _currentState = kTurretStateScanning;
                } else {
                    [self shoot];
                }
                break;
        }
    }
}

- (void)_bulletHitEnemy:(Bullet*)bullet {
    _timeSinceLastEnemyHit = self.currentTimestamp;
}

@end


//@end
