#import "ECDeviceListController.h"
#import "ECAppListController.h"

@implementation ECDeviceListController

-(id)initForContentSize:(CGSize)size {
    self = [super init];
    if (self) {
        _preferences = [[HBPreferences alloc] initWithIdentifier:@"ezio.fakedevicemodelprefs"];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStylePlain];
        _allDeviceList = [NSArray arrayWithContentsOfFile:@"/Library/PreferenceBundles/FakeDeviceModelPrefs.bundle/device.plist"];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setEditing:NO];

        if ([self respondsToSelector:@selector(setView:)])
            [self performSelectorOnMainThread:@selector(setView:) withObject:_tableView waitUntilDone:YES];

        [self setTitle:@"设备列表"];
        [self.navigationItem setTitle:@"设备列表"];
    }

    return self;
}

-(void)reloadTable {
    [_tableView reloadData];
}

-(id)view {
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [self performSelectorInBackground:@selector(reloadTable) withObject:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECAppListController *controller = [[ECAppListController alloc] initForContentSize:self.view.bounds.size];
    controller.modelDict = _allDeviceList[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [_allDeviceList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = _allDeviceList[indexPath.row][@"name"];
    cell.indentationWidth = 10.0f;
    cell.indentationLevel = 0;
    return cell;
}

@end