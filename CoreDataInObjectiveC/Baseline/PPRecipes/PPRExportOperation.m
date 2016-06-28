/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRExportOperation.h"

@interface PPRExportOperation()

@property (nonatomic, weak) NSManagedObjectContext *parentContext;
@property (nonatomic, strong) NSManagedObjectID *incomingRecipeID;

@end

@implementation PPRExportOperation

- (id)initWithRecipe:(PPRRecipeMO*)recipe;
{
  if (!(self = [super init])) return nil;
  
  [self setIncomingRecipeID:[recipe objectID]];
  [self setParentContext:[recipe managedObjectContext]];

  return self;
}

- (NSDictionary*)moToDictionary:(NSManagedObject*)mo
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (!mo) return dict;
  NSEntityDescription *entity = [mo entity];
  
  NSArray *attributeKeys = [[entity attributesByName] allKeys];
  NSDictionary *values = [mo dictionaryWithValuesForKeys:attributeKeys];
  [dict addEntriesFromDictionary:values];
  
  NSDictionary *relationships = [entity relationshipsByName];
  NSRelationshipDescription *relDesc = nil;
  for (NSString *key in relationships) {
    relDesc = [relationships objectForKey:key];
    if (![[[relDesc userInfo] valueForKey:ppExportRelationship] boolValue]) {
      DLog(@"Skipping %@", [relDesc name]);
      continue;
    }
    
    if ([relDesc isToMany]) {
      NSMutableArray *array = [NSMutableArray array];
      for (NSManagedObject *childMO in [mo valueForKey:key]) {
        [array addObject:[self moToDictionary:childMO]];
      }
      [dict setValue:array forKey:key];
      continue;
    }
    NSManagedObject *childMO = [mo valueForKey:key];
    [dict addEntriesFromDictionary:[self moToDictionary:childMO]];
  }
  return dict;
}

- (void)main
{
  NSAssert([self exportBlock] != NULL, @"No completion block set");
  NSManagedObjectContext *localMOC = nil;
  NSUInteger type = NSPrivateQueueConcurrencyType;
  localMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
  [localMOC setParentContext:[self parentContext]];
  
  __block NSData *data = nil;
  __block NSError *error = nil;
  [localMOC performBlockAndWait:^{
    NSManagedObject *localRecipe = nil;
    localRecipe = [localMOC objectWithID:[self incomingRecipeID]];

    NSDictionary *objectStructure = [self moToDictionary:localRecipe];
    data = [NSJSONSerialization dataWithJSONObject:objectStructure
                                           options:0
                                             error:&error];
  }];

  [self exportBlock](data, error);
}

@end
