#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <substrate.h>
#import <Cephei/HBPreferences.h>

HBPreferences *preferences;

BOOL globalEnabled;
bool enabled;
NSDictionary *current;

static int (*old_sysctlbyname)(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
static int (*old_uname)(struct utsname *);

int new_uname(struct utsname *value) {
    if (enabled) {
        int ret = old_uname(value);
        const char* mechine = [current[@"type"] UTF8String];
        const char* nodename = [current[@"name"] UTF8String];
        strcpy(value->machine, mechine);
        strcpy(value->nodename, nodename);
        return ret;
    } else {
        return old_uname(value);
    }
}

int new_sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen){
    if (strcmp(name,"hw.machine") == 0) {
        if (oldp != NULL && enabled) {
            int ret = old_sysctlbyname(name,oldp,oldlenp,newp,newlen);
            const char* mechine = [current[@"type"] UTF8String];
            strcpy(oldp, mechine);
            return ret;
        }else{
            int ret = old_sysctlbyname(name,oldp,oldlenp,newp,newlen);
            return ret;
        }
    } else if (strcmp(name,"hw.model") == 0) {
        if (oldp != NULL && enabled) {
            int ret = old_sysctlbyname(name,oldp,oldlenp,newp,newlen);
            const char* mechine = [current[@"model"] UTF8String];
            strcpy(oldp, mechine);
            return ret;
        }else{
            int ret = old_sysctlbyname(name,oldp,oldlenp,newp,newlen);
            return ret;
        }
    }
    else{
        return old_sysctlbyname(name,oldp,oldlenp,newp,newlen);
    }
}

%group fakedDevice

%hook UIDevice

- (NSString *)name{
    return current[@"name"];
}

- (NSString *)model{
    return current[@"localizedModel"];
}

- (NSString *)localizedModel{
    return current[@"localizedModel"];;
}

- (NSString *)systemName{
    return %orig;
}

- (NSString *)systemVersion{
    return %orig;
}

- (UIUserInterfaceIdiom)userInterfaceIdiom{
    return [current[@"faceIdiom"] integerValue];
}

- (NSUUID *)identifierForVendor{
    return %orig;
}

%end
%end

%ctor {
    BOOL shouldLoad = NO;
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if (!isFileProvider && isApplication && !skip) {
                shouldLoad = YES;
            }
        }
    }
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    enabled = NO;
    preferences = [[HBPreferences alloc] initWithIdentifier:@"ezio.fakedevicemodelprefs"];
    [preferences registerBool:&globalEnabled default:NO forKey:@"GlobalEnabled"];
    [preferences registerPreferenceChangeBlock:^() {
        enabled = NO;
        current = [preferences objectForKey:@"fs"][bundleIdentifier];
        if (globalEnabled && current) {
            enabled = YES;
            %init(fakedDevice);
            MSHookFunction((void *)uname,(void *)new_uname,(void **) &old_uname);
            MSHookFunction((void *)sysctlbyname,(void *)new_sysctlbyname,(void **) &old_sysctlbyname);
        }
    }];
}
