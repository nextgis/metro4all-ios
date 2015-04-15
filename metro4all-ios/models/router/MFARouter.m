//
//  MFARouter.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 15/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "MFARouter.h"
#import <PESGraph/PESGraph.h>
#import <PESGraph/PESGraphNode.h>
#import <PESGraph/PESGraphEdge.h>
#import <PESGraph/PESGraphRoute.h>

#import <NTYCSVTable/NTYCSVTable.h>

@interface MFARouter ()

@property (nonatomic, strong) PESGraph *graph;

@end

@implementation MFARouter

- (instancetype)initWithStations:(NSArray *)stations edges:(NSArray *)edges
{
    self = [super init];
    if (self) {
        
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

- (NSArray *)routeFromStation:(NSNumber *)stationIdFrom toStation:(NSNumber *)stationIdTo
{
    PESGraphNode *nodeFrom = [self.graph nodeInGraphWithIdentifier:stationIdFrom.stringValue];
    PESGraphNode *nodeTo = [self.graph nodeInGraphWithIdentifier:stationIdTo.stringValue];
    
    PESGraphRoute *route = [self.graph shortestRouteFromNode:nodeFrom toNode:nodeTo];
    
    return [NSArray new];
}

@end
