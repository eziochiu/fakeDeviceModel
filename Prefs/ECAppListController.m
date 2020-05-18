#import "ECAppListController.h"
#import "os/lock.h"

static NSMutableArray *iconsToLoad;
static os_unfair_lock spinLock;
static UIImage *defaultImage;

@implementation ECAppListController

-(id)initForContentSize:(CGSize)size {
    self = [super init];

    if (self) {
        defaultImage = [[ALApplicationList sharedApplicationList] iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:@"com.apple.WebSheet"];
        _preferences = [[HBPreferences alloc] initWithIdentifier:@"ezio.fakedevicemodelprefs"];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
        _appList = [NSDictionary new];
        _apps = [NSMutableArray new];
        _fs = [NSMutableDictionary new];
        id list = [_preferences objectForKey:@"fs"];
        if (list && [list isKindOfClass:[NSDictionary class]]) {
            _fs = [list mutableCopy];
        }
        NSLog(@"____fs%@",_fs);
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setEditing:NO];
        [_tableView setAllowsSelection:YES];
        [_tableView setAllowsMultipleSelection:NO];

        if ([self respondsToSelector:@selector(setView:)])
            [self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];
        [self setTitle:@"应用列表"];
        [self.navigationItem setTitle:@"应用列表"];
    }

    return self;
}

-(void)reloadApps {
    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    NSDictionary *allApps = [appList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"(isSystemApplication = NO) OR (isSystemApplication = YES)"] onlyVisible:YES titleSortedIdentifiers:nil];
    NSArray *systemsortedKeys = [[allApps allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [allApps objectForKey:a];
        NSString *second = [allApps objectForKey:b];
        return [first compare:second];
    }];
    _appList = [allApps copy];
    if ([systemsortedKeys count] > 0) {
        [_apps addObjectsFromArray:systemsortedKeys];
    }

    [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
}

-(void)reloadTable {
    [_tableView reloadData];
}

-(id)view {
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [self performSelectorInBackground:@selector(reloadApps) withObject:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"应用列表";
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [_apps count];
}

-(void)loadIcons {
    os_unfair_lock_lock(&spinLock);
    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    while ([iconsToLoad count]) {
        NSString *userInfo = [iconsToLoad objectAtIndex:0];
        [iconsToLoad removeObjectAtIndex:0];
        os_unfair_lock_unlock(&spinLock);
        CGImageRelease([appList copyIconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:userInfo]);
        os_unfair_lock_lock(&spinLock);
    }
    [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:NO];
    iconsToLoad = nil;
    os_unfair_lock_unlock(&spinLock);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *bundleIdentifier = _apps[indexPath.row];
    NSLog(@"____fs%@",bundleIdentifier);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    NSString *bundleIdentifier = _apps[indexPath.row];
    if (!bundleIdentifier) return nil;

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = _appList[bundleIdentifier];
    cell.indentationWidth = 10.0f;
    cell.indentationLevel = 0;

    BOOL isOn = [_fs objectForKey:bundleIdentifier] ? YES : NO;

    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = isOn;
    sw.tag = indexPath.row;
    [sw addTarget:self action:@selector(on:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;

    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    if ([appList hasCachedIconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bundleIdentifier]) {
        cell.imageView.image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bundleIdentifier];
    } else {
        cell.imageView.image = defaultImage;
        os_unfair_lock_lock(&spinLock);
        if (iconsToLoad)
            [iconsToLoad insertObject:bundleIdentifier atIndex:0];
        else {
            iconsToLoad = [[NSMutableArray alloc] initWithObjects:bundleIdentifier, nil];
            [self performSelectorInBackground:@selector(loadIcons) withObject:nil];
        }
        os_unfair_lock_unlock(&spinLock);
    }
    return cell;
}

- (void)on:(UISwitch *)sender {
    NSString *bundleIdentifier = _apps[sender.tag];
    if (sender.isOn && bundleIdentifier) {
        [_fs setObject:_modelDict forKey:bundleIdentifier];
    } else {
        [_fs removeObjectForKey:bundleIdentifier];
    }
    NSLog(@"____fs%@",_fs);
    [_preferences setObject:_fs forKey:@"fs"];
}

@end