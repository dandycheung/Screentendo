//
//  GameScene.m
//  TestGame
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "GameScene.h"
#import "ImageStructureAnalyser.h"
#import "AppDelegate.h"

@interface GameScene() <SKPhysicsContactDelegate>
@end

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    BOOL _keyPressed;
    int _direction;
    BOOL _isJumping;
}

-(void)didChangeSize:(CGSize)oldSize {
    NSLog(@"SIZE CHANGED");
    [self clearSpritesFromScene];
    [self makeAppWindowTransparent];
}

- (void)windowDidResize {
    NSLog(@"Window resized");
}

-(void)keyDown:(NSEvent *)event {
    _keyPressed = YES;
    
    switch([event keyCode]) {
        case 126:
            NSLog(@"Key 126 pressed");
            _direction = 1;
            break;
        case 125:
            NSLog(@"Key 125 pressed");
            _direction = 2;
            break;
        case 124:
            NSLog(@"Key 124 pressed");
            _direction = 3;
            break;
        case 123:
            NSLog(@"Key 123 pressed");
            _direction = 4;
            break;
        default:
            break;
    }
}

-(void)keyUp:(NSEvent *)theEvent {
    _keyPressed = NO;
}

-(void)clearSpritesFromScene {
    [self removeAllChildren];
    [_blocks removeAllObjects];
}

-(void)makeAppWindowTransparent {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowTransparent];
}

-(void)makeAppWindowOpaque {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowOpaque];
}

-(void)mouseDown:(NSEvent *)theEvent {
    int blockSize = 8;
    
    [self clearSpritesFromScene];
    
    NSArray *imageArray = [ImageStructureAnalyser topLevelWindowToBinaryArrayWithBlockSize:blockSize];
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    CGPoint location = [theEvent locationInNode:self];
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    _sprite.size = CGSizeMake(blockSize, blockSize * 2);
    _sprite.position = CGPointMake(location.x, location.y + 230);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sprite.size];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    _sprite.physicsBody.contactTestBitMask = 0;
    [self addChild:_sprite];
    
    int blocksWide = (int)imageArray.count;
    int blocksHigh = (int)[(NSArray*)[imageArray objectAtIndex:0] count];
    
    // Draw the blocks to the screen as images
    for (int x = 0; x < blocksWide; x++) {
        for (int y = 0; y < blocksHigh; y++) {
            NSNumber *currentColor = imageArray[x][y];
            
            if ([currentColor isEqualToNumber:[NSNumber numberWithInt:1]]) {
                SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
                block.size = CGSizeMake(blockSize, blockSize);
                block.position = CGPointMake(x*blockSize,(blocksHigh * blockSize) - y*blockSize);
                block.scale = 1;
                block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
                block.physicsBody.dynamic = NO;
                block.physicsBody.allowsRotation = NO;
                block.physicsBody.usesPreciseCollisionDetection = YES;
                block.physicsBody.affectedByGravity = NO;
                block.physicsBody.contactTestBitMask = 1;
                
                [_blocks addObject:block];
                [self addChild:block];
                
            }
        }
    }
    
    [self makeAppWindowOpaque];
    
    // Hardcoded blocks
  /*  for (int i = 0; i < 5; i++) {
        SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
        block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
        block.position = CGPointMake(location.x + (block.size.width * i), location.y);
        block.scale = 1;
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
        block.physicsBody.dynamic = NO;
        block.physicsBody.allowsRotation = NO;
        block.physicsBody.usesPreciseCollisionDetection = YES;
        block.physicsBody.affectedByGravity = NO;
        
        [_blocks addObject:block];
        [self addChild:block];
    }*/
}

-(void)renderPlayerPosition {
    if (_keyPressed) {
        int xDelta = 0;
        int yDelta = 0;
        
        switch (_direction) {
            case 1:
                //NSLog(@"Jump pressed");
                if (!_isJumping) {
                    _isJumping = YES;
                    [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, 1.0f) atPoint:_sprite.position];
                }
                break;
            case 2:
                //NSLog(@"Down pressed");
                yDelta = -2;
                break;
            case 3:
                //NSLog(@"Right pressed");
                xDelta = +2;
                break;
            case 4:
                //NSLog(@"Left pressed");
                xDelta = -2;
                break;
            default:
                break;
        }
        
        CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
        _sprite.position = desiredPosition;
        
       // _sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx + xDelta,_sprite.physicsBody.velocity.dy + yDelta);
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    //NSLog(@"Did begin contact");
    _isJumping = NO;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self renderPlayerPosition];
}

@end
