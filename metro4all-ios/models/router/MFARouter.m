//
//  MFARouter.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 15/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouter.h"

#import "MFAInterchange.h"
#import "MFACity.h"
#import "MFAStation.h"

#import <PESGraph/PESGraph.h>
#import <PESGraph/PESGraphNode.h>
#import <PESGraph/PESGraphEdge.h>
#import <PESGraph/PESGraphRoute.h>
#import <PESGraph/PESGraphRouteStep.h>

#import <NTYCSVTable/NTYCSVTable.h>

#define STEP_WEIGHT_CHANGEOVER @5

@interface MFARouter ()

@property (nonatomic, strong) PESGraph *graph;
@property (nonatomic, strong) MFACity *city;

@end

@implementation MFARouter

- (instancetype)initWithCity:(MFACity *)city stations:(NSArray *)stations edges:(NSArray *)edges
{
    self = [super init];
    if (self) {
        self.city = city;
        
        // parse stations and create graph nodes
        NSMutableDictionary *nodes = [[NSMutableDictionary alloc] initWithCapacity:stations.count];
        
        for (NSDictionary *row in stations) {
            PESGraphNode *node = [PESGraphNode nodeWithIdentifier:[row[@"id_station"] description]];
            nodes[row[@"id_station"]] = node;
        }
        
        // parse graph data and create edges
        PESGraph *graph = [[PESGraph alloc] init];
        
        for (NSDictionary *row in edges) {
            [graph addBiDirectionalEdge:[PESGraphEdge edgeWithName:[NSString stringWithFormat:@"%@ - %@", row[@"name_from"], row[@"name_to"]]
                                                         andWeight:row[@"cost"]]
                                fromNode:nodes[row[@"id_from"]]
                                  toNode:nodes[row[@"id_to"]]];
        }
        
        self.graph = graph;
    }
    
    return self;
}

- (NSArray *)routeFromStation:(NSNumber *)stationIdFrom toStation:(NSNumber *)stationIdTo withCost:(NSNumber **)cost
{
    PESGraphNode *nodeFrom = [self.graph nodeInGraphWithIdentifier:stationIdFrom.stringValue];
    PESGraphNode *nodeTo = [self.graph nodeInGraphWithIdentifier:stationIdTo.stringValue];
    
    PESGraphRoute *route = [self.graph shortestRouteFromNode:nodeFrom toNode:nodeTo];
    
    NSMutableArray *steps = [NSMutableArray new];
    
    NSNumberFormatter *f = [NSNumberFormatter new];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    for (NSUInteger i = 0; i < route.steps.count; i++) {
        PESGraphRouteStep *step = route.steps[i];
        
        if (!step.isEndingStep) {
            PESGraphRouteStep *nextStep = route.steps[i+1];
            
            MFAInterchange *interchange = [self.city interchangeFromStationId:[f numberFromString:step.node.identifier]
                                                                  toStationId:[f numberFromString:nextStep.node.identifier]];
            if (interchange) {
                [steps addObject:interchange];
                i++; // skip next step as we've already added it as part of interchange
                continue;
            }
        }
        
        MFAStation *station = [self.city stationWithId:[f numberFromString:step.node.identifier]];
        [steps addObject:station];
    }
    
    *cost = @(route.length);
    
    return steps;
}

@end
