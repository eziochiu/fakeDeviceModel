#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <AppList/AppList.h>

@interface ECAppListController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    HBPreferences *_preferences;
    NSDictionary *_appList;
    NSArray *_allSections;
    NSMutableArray *_apps;
    NSMutableDictionary *_fs;
}

@property (nonatomic, retain) NSDictionary *modelDict;

-(void)loadIcons;
-(void)reloadApps;

@end