//
//  HRAppDelegate.m
//  HReader
//
//  Created by Marshall Huss on 11/14/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <objc/message.h>
#import <sys/stat.h>

#import "CMDEncryptedSQLiteStore.h"

#import "HRAppDelegate.h"
#import "HRAPIClient.h"
#import "HRRHExLoginViewController.h"
#import "HRPeopleSetupViewController.h"
#import "HRCryptoManager.h"
#import "HRSplashScreenViewController.h"
#import "HRHIPPAMessageViewController.h"
#import "HRAppletConfigurationViewController.h"
#import "HRCryptoManager.h"
#import "HRMPatient.h"

#import <SecurityCheck/SecurityCheck.h>
#import <AppPassword/AppPassword.h>
#import <SecureFoundation/SecureFoundation.h>

@interface HRAppDelegate() 

    @property (nonatomic)        PASS_CTL   passControl;
    @property (nonatomic,strong) APPass    *appPass;
    @property (nonatomic,strong) APPass    *appQuestion;
    @property (nonatomic)        NSInteger  numberOfQuestions;

    //-----------------------------------
    // Callback block from SecurityCheck
    //-----------------------------------
    typedef void (^cbBlock) (void);

    - (void) weHaveAProblem;

@end


@implementation HRAppDelegate {
    NSUInteger              passcodeAttempts;
    UINavigationController *securityNavigationController;
    NSPersistentStore      *persistentStore;
}

#pragma mark - class methods

+ (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    static NSPersistentStoreCoordinator *coordinator = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hReader"
                                                  withExtension:@"momd"];
        
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc]
                                       initWithContentsOfURL:modelURL];
        
        coordinator = [[NSPersistentStoreCoordinator alloc]
                       initWithManagedObjectModel:model];
    });
    
    return coordinator;
}
+ (NSManagedObjectContext       *) rootManagedObjectContext   {
    
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        context = [[NSManagedObjectContext alloc]
                   initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [context
         setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    });
    return context;
}
+ (NSManagedObjectContext       *) managedObjectContext       {
    
    static NSManagedObjectContext *context = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        context = [[NSManagedObjectContext alloc]
                   initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [context setParentContext:[self rootManagedObjectContext]];
    });
    return context;
}

#pragma mark - object methods

- (void) addPersistentStoreIfNeeded {
    
    if (persistentStore == nil) {
        
        NSError *error = nil;
        NSPersistentStoreCoordinator *coordinator =
        [HRAppDelegate persistentStoreCoordinator];
        
        // store configuration
        NSFileManager *fileManager   = [NSFileManager defaultManager];
        NSURL *applicationSupportURL =
        [[fileManager URLsForDirectory:NSApplicationSupportDirectory
                             inDomains:NSUserDomainMask] lastObject];
        
        [fileManager createDirectoryAtURL:applicationSupportURL
              withIntermediateDirectories:NO
                               attributes:nil
                                    error:nil];
        
        NSURL *databaseURL =
        [applicationSupportURL
         URLByAppendingPathComponent:@"database.sqlite3.2"];
        
        NSDictionary *options =
        @{
        NSPersistentStoreFileProtectionKey           : NSFileProtectionComplete,
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption       : @YES        
        };
        
        // add store
        persistentStore =
        HRCryptoManagerAddEncryptedStoreToCoordinator( coordinator
                                                      ,nil
                                                      ,databaseURL
                                                      ,options
                                                      ,&error);
        
        NSAssert(persistentStore, @"Unable to add persistent store\n%@", error);
        
    }
}
- (void) performLaunchSteps         {
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    //-----------------------------------
    // call back to weHaveAProblem
    //-----------------------------------
    cbBlock chkCallback  = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
    };
    
    //-----------------------------------
    // jailbreak detection
    //-----------------------------------
    checkFork(chkCallback);
    checkFiles(chkCallback);
    checkLinks(chkCallback);
    
#endif
    
    // check for hippa message
    if (![HRHIPPAMessageViewController hasAcceptedHIPPAMessage]) {
        
        UIStoryboard *storyboard =
        [UIStoryboard storyboardWithName:@"InitialSetup_iPad" bundle:nil];
        
        HRHIPPAMessageViewController *controller  =
        [storyboard
         instantiateViewControllerWithIdentifier:@"HIPPAViewController"];
        
        controller.navigationItem.hidesBackButton = YES;
        controller.target                         = self;
        controller.action                         = _cmd;
        
        UINavigationController *navigation = (id)self.window.rootViewController;
        
        [navigation popToRootViewControllerAnimated:NO];
        
        [navigation pushViewController:controller
                              animated:YES];
    }
    
    // check for passcode
    else if (!HRCryptoManagerHasPasscode()
         ||  !HRCryptoManagerHasSecurityQuestions()) {
        
        [self presentPass:PASS_CREATE];
        
        [[[UIAlertView alloc]
          initWithTitle:@"Welcome"
          message:@"Before you start using hReader, you must set a passcode and create security questions."
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil]
         show];
    }
    
    // unlocked
    else if (HRCryptoManagerIsUnlocked()) {
        
        NSArray          *hosts      = [HRAPIClient hosts];
        UIViewController *controller = [(id)self.window.rootViewController
                                        topViewController];
        
        // load persistent store
        [self addPersistentStoreIfNeeded];
        
        // check for accounts
        if ([hosts count] == 0) {
            
            HRAPIClient *client = [HRAPIClient clientWithHost:
                                   @"growing-spring-4857.herokuapp.com"];
            
            HRRHExLoginViewController *controller =
            [HRRHExLoginViewController loginViewControllerForClient:client];
            
            controller.navigationItem.hidesBackButton = YES;
            controller.target = self;
            controller.action = @selector(initialLoginDidSucceed:);
            
            [(id)self.window.rootViewController pushViewController:controller
                                                          animated:YES];
            
        } else {    // carry on
            
            // update local data
            NSString *host = [hosts lastObject];
            
            [[HRAPIClient clientWithHost:host] patientFeed:nil];
            
            [HRMPatient performSync];
            
            // push storyboard if we need to
            if ([controller isKindOfClass:[HRSplashScreenViewController class]]
            ||  [controller isKindOfClass:[HRHIPPAMessageViewController class]])
            {
                UIStoryboard *storyboard =
                [UIStoryboard storyboardWithName:@"InitialSetup_iPad"
                                          bundle:nil];
                
                id controller =
                [storyboard instantiateViewControllerWithIdentifier:
                 @"PeopleSetupViewController"];
                
                [[controller navigationItem] setHidesBackButton:YES];
                
                [(id)self.window.rootViewController pushViewController:controller
                                                              animated:YES];
            }
            
        }
        
    } else {  // locked
        
        // VERIFICATION
        [self presentPasscodeVerificationController:YES];
    }
    
}

#pragma mark - notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    
    // get contexts
    NSManagedObjectContext *rootContext   = [HRAppDelegate
                                             rootManagedObjectContext];
    NSManagedObjectContext *mainContext   = [HRAppDelegate
                                             managedObjectContext];
    NSManagedObjectContext *savingContext = [notification object];
    
    // main -> root
    if (savingContext == mainContext) {
        
        [rootContext performBlock:^{
            
            NSError *error = nil;
            
            if (![rootContext save:&error]) {
                HRDebugLog(@"Unable to save root context: %@", error);
            }
        }];
        
    } else if ([savingContext parentContext] == mainContext) { // child -> main
        
        [mainContext performBlock:^{
            
            NSError *error = nil;
            
            if (![mainContext save:&error]) {
                HRDebugLog(@"Unable to save main context: %@", error);
            }
        }];
    }
    
}

#pragma mark - application lifecycle

- (BOOL)           application:(UIApplication *) application
 didFinishLaunchingWithOptions:(NSDictionary  *) launchOptions {
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    //--------------------------------
    // do not allow debuggers
    //--------------------------------
    //    dbgStop;
    
    //--------------------------------------------------------------------------
    // check for the presence of a debugger, call weHaveAProblem if there is one
    //--------------------------------------------------------------------------
    cbBlock dbChkCallback = ^{
        
        __weak id weakSelf = self;
        
        if (weakSelf) [weakSelf weHaveAProblem];
    };
    
    dbgCheck(dbChkCallback);
    
#endif
    //--------------------------------------------------------------------------
    // Setup AppPass API 
    //--------------------------------------------------------------------------
    [self initAppAPI];
    
    // notifications
    [[NSNotificationCenter defaultCenter]
     
     addObserver:self
        selector:@selector(managedObjectContextDidSave:)
            name:NSManagedObjectContextDidSaveNotification
          object:nil];
    
    // launch steps
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self performLaunchSteps];
    });
    
    // return
    return YES;
}

//--------------------------------------------------------------------
// if a debugger is attched to the app then this method will be called
//--------------------------------------------------------------------
- (void) weHaveAProblem {
    
    exit(0);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // remove persistent store
//    NSPersistentStoreCoordinator *coordinator = [HRAppDelegate persistentStoreCoordinator];
//    if ([coordinator removePersistentStore:persistentStore error:nil]) {
//        persistentStore = nil;
//        [[HRAppDelegate managedObjectContext] reset];
//    }
    
    // destroy encryption keys
    HRCryptoManagerPurge();
    
    // reset interface
    if (!HRCryptoManagerHasPasscode()
    ||  !HRCryptoManagerHasSecurityQuestions()) {
        
        [(id)self.window.rootViewController popToRootViewControllerAnimated:NO];
    }
    
    [securityNavigationController dismissViewControllerAnimated:NO
                                                     completion:nil];
    securityNavigationController = nil;
    
    // VERIFICATION
    [self presentPasscodeVerificationController:NO];
}

#pragma mark - security scenario one


//------------------------------------------------------------------------------
// APPass
//------------------------------------------------------------------------------
-(void) initAppAPI {

    self.numberOfQuestions    = 2;
    
    self.appPass              = [APPass
                                  complexPassWithName:@"APComplexPass"
                               fromStoryboardWithName:@"InitialSetup_iPad"];
    
    self.appQuestion          = [APPass
                                         passWithName:@"APQuestionPass"
                               fromStoryboardWithName:@"InitialSetup_iPad"
                                        withQuestions:self.numberOfQuestions];
    self.appPass.delegate     = self;
    self.appQuestion.delegate = self;
    
    self.appPass.syntax       = @"^.*(?=.*[a-zA-Z])(?=.*[0-9])(?=.{8,}).*$";

}

-(void)     presentPass:(PASS_CTL) cntrl {
    
    self.passControl              = cntrl;
    self.appPass.verify           = (cntrl == PASS_VERIFY) ? @"verify" : nil;
    self.appPass.parentController = self.window.rootViewController;

}
-(void) presentQuestion:(PASS_CTL) cntrl {
    
    self.passControl                  = cntrl;
    
    if (cntrl == PASS_VERIFY_Q)
        
    self.appQuestion.verifyQuestions  = IMSCryptoManagerSecurityQuestions();
    
    self.appQuestion.parentController = self.window.rootViewController;

}

//------------------------------------------------------------------------------
// APPassProtocol - required
//------------------------------------------------------------------------------
-(void) APPassComplete:(UIViewController*) viewController
            withPhrase:(NSString*)         phrase {
    
    if ( nil != phrase ) {
        
        switch (self.passControl) {
            
            case PASS_CREATE: [self processCreate:viewController
                                        withPhrase:phrase];
                               break;
                
            case PASS_RESET:  [self  processReset:viewController
                                        withPhrase:phrase];
                               break;
                
            case PASS_VERIFY: [self processVerify:viewController
                                        withPhrase:phrase];
                               break;
            default: break;
        }
    }
}
//------------------------------------------------------------------------------
// APPassProtocol - verify the entered passcode with the stored one
//------------------------------------------------------------------------------
-(BOOL) verifyPhraseWithSecureFoundation:(NSString*) phrase {
    
    BOOL ret = NO;
    
    if (phrase) ret = HRCryptoManagerUnlockWithPasscode(phrase);
    
    return ret;
}

-(void) resetPassAP {
    
    [self presentQuestion:PASS_VERIFY_Q];
}

-(void) resetQuestionAP {
    
    NSLog(@"resetPassQuestions?");
}
//------------------------------------------------------------------------------
// The passcode has been entered now present the questions
//------------------------------------------------------------------------------
- (void) processCreate:(UIViewController*) viewController
            withPhrase:(NSString*) phrase {
    
    // hold on to the phrase for finialize method 
    HRCryptoManagerStoreTemporaryPasscode(phrase);
    
    // ask to create questions 
    [self presentQuestion:PASS_CREATE_Q];
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
- (void) processVerify:(UIViewController*) viewController
            withPhrase:(NSString*) phrase {
    
    if (HRCryptoManagerUnlockWithPasscode(phrase)) {
        
        [self addPersistentStoreIfNeeded];
        
        [self performLaunchSteps];
    }
}
//------------------------------------------------------------------------------
// Update the stored passcode with a new one
//------------------------------------------------------------------------------
- (void)  processReset:(UIViewController*) viewController
            withPhrase:(NSString*) phrase {
    
    HRCryptoManagerUpdatePasscode(phrase);
    
    [self performLaunchSteps];
}

//------------------------------------------------------------------------------
// APQuestionProtocol - required
//------------------------------------------------------------------------------
-(void) APPassComplete:(UIViewController *) viewController
         withQuestions:(NSArray *)          questions
            andAnswers:(NSArray *)          answers {
    
    if ( nil != questions && nil != answers ) {
        
        switch (self.passControl) {
                
            case PASS_CREATE_Q: [self processCreateQuestion:questions
                                                withAnswers:answers];
                break;
                
            case PASS_RESET_Q:  [self processResetQuestion:questions
                                               withAnswers:answers];
                break;
                
            default: break;
        }
    }
    
    [self performLaunchSteps];
}

-(void) processCreateQuestion:questions withAnswers:answers {
    
    IMSCryptoManagerStoreTemporarySecurityQuestionsAndAnswers(questions
                                                              ,answers);
    IMSCryptoManagerFinalize();
}

-(void)  processResetQuestion:questions withAnswers:answers {
    
    IMSCryptoManagerUpdateSecurityQuestionsAndAnswers(questions, answers);
    
}

-(BOOL) APPassQuestion:(UIViewController *) viewController
         verifyAnswers:(NSArray *)          answers {
    
    return IMSCryptoManagerUnlockWithAnswersForSecurityQuestions(answers);
}

//------------------------------------------------------------------------------
// user forgot the passcode and is answering security questions in order to
// reset it
//------------------------------------------------------------------------------
-(void) APPassQuestionVerified:(UIViewController *) viewController
                   verifyState:(BOOL)               verify {
    
    [self presentPass:PASS_RESET];
}


//------------------------------------------------------------------------------
// Passcode exists and must be entered
//------------------------------------------------------------------------------
- (void)presentPasscodeVerificationController:(BOOL)animated {

    passcodeAttempts = 0;

    [self presentPass:PASS_VERIFY];
}


/*
 
 Methods used when changing the security questions at the request of the user.
 
 */
/*
- (BOOL)verifyPasscodeOnQuestionsChange :(IMSPasswordViewController *)controller :(NSString *)passcode {
    if (HRCryptoManagerUnlockWithPasscode(passcode)) {
        HRSecurityQuestionsViewController *questions = [controller.storyboard instantiateViewControllerWithIdentifier:@"SecurityQuestionsController"];
        questions.navigationItem.hidesBackButton = YES;
        questions.mode = HRSecurityQuestionsViewControllerModeCreate;
        questions.delegate = self;
        questions.title = @"Security Questions";
        questions.action = @selector(updateSecurityQuestions:::);
        [controller.navigationController pushViewController:questions animated:YES];
        return YES;
    }
    return NO;
}

- (void)updateSecurityQuestions :(HRSecurityQuestionsViewController *)controller :(NSArray *)questions :(NSArray *)answers {
    HRCryptoManagerUpdateSecurityQuestionsAndAnswers(questions, answers);
    [controller dismissViewControllerAnimated:YES completion:nil];
}
*/
#pragma mark - security scenario five

- (void)initialLoginDidSucceed :(HRRHExLoginViewController *)login {
    HRPeopleSetupViewController *setup = [login.storyboard instantiateViewControllerWithIdentifier:@"PeopleSetupViewController"];
    setup.navigationItem.hidesBackButton = YES;
    [login.navigationController pushViewController:setup animated:YES];
}

#pragma mark - security questions delegate

- (NSUInteger)numberOfSecurityQuestions {
    return 2;
}

- (NSArray *)securityQuestions {
    return HRCryptoManagerSecurityQuestions();
}

@end
