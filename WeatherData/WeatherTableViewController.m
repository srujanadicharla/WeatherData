//
//  WeatherTableViewController.m
//  WeatherData
//
//  Created by Srujan Simha Adicharla on 4/11/16.
//  Copyright © 2016 Srujan Simha Adicharla. All rights reserved.
//

#import "WeatherTableViewController.h"

@interface WeatherTableViewController ()
{
    NSArray* colors;
}
@property (nonatomic, strong) NSMutableArray* weatherData;

@end

@implementation WeatherTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    _weatherData = [[NSMutableArray alloc] init];
    colors = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self readDataFromURL];
    });
    
}

- (void) readDataFromURL {
    NSURL *URL = [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=London&units=metric&cnt=17&appid=c87d3c85497bdd80ce287079cc2b4a1c"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (error == nil) {
                                          NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                          
                                          NSArray* arr = [[NSArray alloc] initWithArray:[result objectForKey:@"list"]];
                                          for (int i = 0; i < [arr count]; i++) {
                                              NSMutableDictionary* dict = [arr objectAtIndex:i];
                                              for (NSString* key in [dict allKeys]) {
                                                  if ([key isEqualToString:@"weather"]) {
                                                      NSArray* tmpArr = [[NSArray alloc] initWithArray:[dict objectForKey:@"weather"]];
                                                      NSMutableDictionary* tmpDict = [tmpArr objectAtIndex:0];
                                                      [_weatherData addObject:[tmpDict valueForKey:@"description"]];
                                                  }
                                              }
                                          }
                                          [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                                                           withObject:nil
                                                                        waitUntilDone:NO];
                                      }
                                  }];
    
    [task resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_weatherData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [_weatherData objectAtIndex:indexPath.row];
    cell.backgroundColor = [colors objectAtIndex:indexPath.row % 3];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
