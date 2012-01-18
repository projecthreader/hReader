//
//  HRConfig.h
//  HReader
//
//  Created by Marshall Huss on 11/15/11.
//  Copyright (c) 2011 MITRE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "HRPatient.h"
#import "HRAddress.h"
#import "HREncounter.h"

#import "DDXML.h"

NSString * const HRPatientDidChangeNotification = @"HRPatientDidChangeNotification";
NSString * const HRPatientKey                   = @"HRPatientKey";
NSString * const HRHasLaunched                  = @"has_launched";
NSString * const HRPasscodeEnabled              = @"passcode_enabled";
NSString * const HRPPrivacyWarningConfirmed     = @"privacy_warning_confirmed";

@interface HRConfig ()
+ (void)parseEncounters;
@end


@implementation HRConfig

#pragma mark - App Info

+ (NSString *)appVersion { 
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)formattedVersion {
    return [NSString stringWithFormat:@"%@ (%@)", [self appVersion], [self bundleVersion]];
}

#pragma mark - API Keys

+ (NSString *)testFlightTeamToken {
    return @"e8ef4e7b3c88827400af56886c6fe280_MjYyNTYyMDExLTEwLTE5IDE2OjU3OjQ3LjMyNDk4OQ";
}

#pragma mark - Colors

+ (UIColor *)textureColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"handmadepaper"]];
}

+ (UIColor *)redColor {
    return [UIColor colorWithRed:148/255.0 green:17/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)greenColor {
    return [UIColor colorWithRed:79/255.0 green:142/255.0 blue:0/255.0 alpha:1.0];
}

+ (UIColor *)lightRedColor {
    return [UIColor colorWithRed:216/255.0 green:83/255.0 blue:111/255.0 alpha:1.0];
}


+ (UIColor *)redGradientTopColor {
    return [UIColor colorWithRed:230/255.0 green:107/255.0 blue:124/255.0 alpha:1.0];
}

+ (UIColor *)redGradientBottomColor {
    return [UIColor colorWithRed:221/255.0 green:59/255.0 blue:81/255.0 alpha:1.0];
}

#pragma mark - Objects

+ (NSArray *)patients {
    
    static NSArray *array = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self parseEncounters];
        
        HRAddress *address = [[HRAddress alloc] initWithSteet1:@"2275 Rolling Run Dr." street2:nil city:@"Woodlawn" state:@"MD" zip:@"21244"];
        
        HRPatient *johnny = [[[HRPatient alloc] initWithName:@"Johnny Smith" image:[UIImage imageNamed:@"Johnny_Smith"]] autorelease];
        johnny.address = address;
        johnny.gender = HRPatientGenderMale;
        johnny.birthday = [self dateForString:@"20061122"];
        johnny.placeOfBirth = @"Boston, MA USA";
        johnny.race = @"White";
        johnny.ethnicity = @"Germanic";
        johnny.phoneNumber = @"410.555.0350 (home)";
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSArray arrayWithObjects:@"Peanuts (severe)", @"Tree Nuts (severe)", nil] forKey:@"allergies"];
        [info setObject:@"Parents reported child has a cold with coughing, shortness of breath, wheezing, and retraction of the ribs.  Child has been previously diagnosed with  asthma." forKey:@"recent_condition"];
        [info setObject:@"05 May 2011" forKey:@"recent_condition_date"];
        [info setObject:[NSArray arrayWithObjects:@"Asthma", @"Excema", nil] forKey:@"chronic_conditions"];
        [info setObject:@"Herpes B Booster within 3 weeks" forKey:@"upcoming_events"];
        [info setObject:@"None" forKey:@"plan_of_care"];
        [info setObject:@"30 Mar 2012" forKey:@"follow_up_appointment"];
        [info setObject:@"None" forKey:@"medication_refill"];
        [info setObject:@"5 Jan 2012" forKey:@"recent_encounters_date"];
        [info setObject:@"Office Visit" forKey:@"recent_encounters_type"];
        [info setObject:@"5 Yr. Immunizations" forKey:@"recent_encounters_description"];
        [info setObject:@"Yes" forKey:@"immunizations"];
        
        [info setObject:@"Height" forKey:@"height_title_label"];
        [info setObject:@"3'2\"" forKey:@"height"];
        [info setObject:@"5 Jan 2012" forKey:@"height_date"];
        [info setObject:@"3'-3'4\"" forKey:@"height_normal"];
        [info setObject:@"26.5" forKey:@"weight"];
        [info setObject:@"5 Jan 2012" forKey:@"weight_date"];
        [info setObject:@"27-32" forKey:@"weight_normal"];
        [info setObject:@"20" forKey:@"bmi"];
        [info setObject:@"5 Jan 2012" forKey:@"bmi_date"];
        [info setObject:@"18-25" forKey:@"bmi_normal"];
        [info setObject:@"65" forKey:@"pulse"];
        [info setObject:@"5 Jan 2012" forKey:@"pulse_date"];
        [info setObject:@"70-130" forKey:@"pulse_normal"];
        [info setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Xopenex (levalbuterol HCl)", @"0.63mg/3mL", @"Pulmicort (budesonide)", @"0.50mg/2mL", nil] forKey:@"medications"];
        [info setObject:@"Since Age 2" forKey:@"functional_status_date"];
        [info setObject:@"Asthma" forKey:@"functional_status_problem"];
        [info setObject:@"Home/Living Situation" forKey:@"functional_status_type"];
        [info setObject:@"Chronic" forKey:@"functional_status_status"];
        [info setObject:@"Dr Crystal Johansen" forKey:@"functional_status_source"];
        [info setObject:@"20 Jul 2010" forKey:@"procedures_date"];
        [info setObject:@"Asthma Treatment" forKey:@"procedures_type"];
        [info setObject:@"20 Jul 2010" forKey:@"diagnosis_date"];
        [info setObject:@"Peak flow/Yellow Zone" forKey:@"diagnosis_results"];
        
        [info setObject:[UIImage imageNamed:@"Sparklines_normal_levels"] forKey:@"height_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_growing_levels"] forKey:@"weight_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low-to-high_levels"] forKey:@"bmi_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low_levels"] forKey:@"pulse_sparklines"];
        
        johnny.info = info;
        [info release];
        
        
        HRPatient *henry = [[[HRPatient alloc] initWithName:@"Henry Smith" image:[UIImage imageNamed:@"Henry_Smith"]] autorelease];
        henry.address = [[[HRAddress alloc] initWithSteet1:@"323 Summer Hill Ln." street2:nil city:@"Baltimore" state:@"MD" zip:@"21215"] autorelease];
        henry.gender = HRPatientGenderMale;
        henry.birthday = [self dateForString:@"19390308"];
        henry.placeOfBirth = @"Austin, TX USA";
        henry.race = @"White";
        henry.ethnicity = @"Germanic";
        henry.phoneNumber = @"425.555.5492 (cell)";
        
        info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSArray arrayWithObjects:@"NKA", nil] forKey:@"allergies"];
        [info setObject:@"Prostate Cancer" forKey:@"recent_condition"];
        [info setObject:@"07 May 2010" forKey:@"recent_condition_date"];
        [info setObject:[NSArray arrayWithObjects:@"Hypertension", @"Heart Failure", nil] forKey:@"chronic_conditions"];
        [info setObject:@"Follow up on Prostate Treatment" forKey:@"upcoming_events"];
        [info setObject:@"Improve Nutrition" forKey:@"plan_of_care"];
        [info setObject:@"12 May 2012" forKey:@"follow_up_appointment"];
        [info setObject:@"3 Apr 2012 - Beta Blocker Therapy" forKey:@"medication_refill"];
        [info setObject:@"5 Jan 2012" forKey:@"recent_encounters_date"];
        [info setObject:@"Outpatient" forKey:@"recent_encounters_type"];
        [info setObject:@"Check up" forKey:@"recent_encounters_description"];
        [info setObject:@"Yes" forKey:@"immunizations"];
        
        [info setObject:@"Total Cholesterol" forKey:@"height_title_label"];
        [info setObject:@"230" forKey:@"height"];
        [info setObject:@"5 Jan 2012" forKey:@"height_date"];
        [info setObject:@"< 200" forKey:@"height_normal"];
        [info setObject:@"200" forKey:@"weight"];
        [info setObject:@"5 Jan 2012" forKey:@"weight_date"];
        [info setObject:@"154-166" forKey:@"weight_normal"];
        [info setObject:@"20" forKey:@"bmi"];
        [info setObject:@"5 Jan 2012" forKey:@"bmi_date"];
        [info setObject:@"18-25" forKey:@"bmi_normal"];
        [info setObject:@"65" forKey:@"pulse"];
        [info setObject:@"5 Jan 2012" forKey:@"pulse_date"];
        [info setObject:@"60-100" forKey:@"pulse_normal"];
        [info setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"ACE Inhibitor", @"10 mg", @"Beta Blocker", @"100 mg", nil] forKey:@"medications"];
        [info setObject:@"20 Jul 2010" forKey:@"functional_status_date"];
        [info setObject:@"" forKey:@"functional_status_problem"];
        [info setObject:@"Home/Living Situation" forKey:@"functional_status_type"];
        [info setObject:@"Chronic" forKey:@"functional_status_status"];
        [info setObject:@"Joseph Yang, M.D." forKey:@"functional_status_source"];
        [info setObject:@"20 Jul 2010" forKey:@"procedures_date"];
        [info setObject:@"Prostate Cancer Treatment" forKey:@"procedures_type"];
        [info setObject:@"20 Jul 2010" forKey:@"diagnosis_date"];
        [info setObject:@"Prostate Specific Antigen Test" forKey:@"diagnosis_results"];
        
        [info setObject:[UIImage imageNamed:@"Sparklines_normal_levels"] forKey:@"height_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_growing_levels"] forKey:@"weight_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low_levels"] forKey:@"bmi_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low-to-high_levels"] forKey:@"pulse_sparklines"];
        
        henry.info = info;
        [info release];
        
        HRPatient *molly = [[[HRPatient alloc] initWithName:@"Molly Smith" image:[UIImage imageNamed:@"Molly_Smith"]] autorelease];
        molly.address = address;
        molly.gender = HRPatientGenderFemale;
        molly.birthday = [self dateForString:@"19960506"];
        molly.placeOfBirth = @"Manchester, NH USA";
        molly.race = @"White";
        molly.ethnicity = @"Germanic";
        molly.phoneNumber = @"410.555.0350 (home)";
        
        info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSArray arrayWithObjects:@"NKA", nil] forKey:@"allergies"];
        [info setObject:@"Asthma Nighttime Symptoms" forKey:@"recent_condition"];
        [info setObject:@"31 Jul 2010" forKey:@"recent_condition_date"];
        [info setObject:[NSArray arrayWithObjects:@"Asthma", @"Pharyngitis", nil] forKey:@"chronic_conditions"];
        [info setObject:@"Herpes B Booster within 3 weeks" forKey:@"upcoming_events"];
        [info setObject:@"None" forKey:@"plan_of_care"];
        [info setObject:@"30 Nov 2012" forKey:@"follow_up_appointment"];
        [info setObject:@"None" forKey:@"medication_refill"];
        [info setObject:@"5 Jan 2012" forKey:@"recent_encounters_date"];
        [info setObject:@"Office Visit" forKey:@"recent_encounters_type"];
        [info setObject:@"Yearly Check up" forKey:@"recent_encounters_description"];
        [info setObject:@"Yes" forKey:@"immunizations"];
        
        
        [info setObject:@"Total Cholesterol" forKey:@"height_title_label"];
        [info setObject:@"202" forKey:@"height"];
        [info setObject:@"5 Jan 2012" forKey:@"height_date"];
        [info setObject:@"< 200" forKey:@"height_normal"];        
        [info setObject:@"110" forKey:@"weight"];
        [info setObject:@"5 Jan 2012" forKey:@"weight_date"];
        [info setObject:@"100-123" forKey:@"weight_normal"];
        [info setObject:@"20" forKey:@"bmi"];
        [info setObject:@"5 Jan 2012" forKey:@"bmi_date"];
        [info setObject:@"18-25" forKey:@"bmi_normal"];
        [info setObject:@"75" forKey:@"pulse"];
        [info setObject:@"5 Jan 2012" forKey:@"pulse_date"];
        [info setObject:@"60-100" forKey:@"pulse_normal"];
        [info setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Short Acting beta2 agonist", @"2 mg", nil] forKey:@"medications"];
        [info setObject:@"10 Aug 2009" forKey:@"functional_status_date"];
        [info setObject:@"Asthma" forKey:@"functional_status_problem"];
        [info setObject:@"Home/Living Situation" forKey:@"functional_status_type"];
        [info setObject:@"Mild" forKey:@"functional_status_status"];
        [info setObject:@"Dr Crystal Johansen" forKey:@"functional_status_source"];
        [info setObject:@"10 Jul 2009" forKey:@"procedures_date"];
        [info setObject:@"Asthma Treatment" forKey:@"procedures_type"];
        [info setObject:@"30 Jul 2010" forKey:@"diagnosis_date"];
        [info setObject:@"Peak flow/Yellow Zon" forKey:@"diagnosis_results"];
        
        [info setObject:[UIImage imageNamed:@"Sparklines_normal_levels"] forKey:@"height_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_growing_levels"] forKey:@"weight_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low-to-high_levels"] forKey:@"bmi_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low_levels"] forKey:@"pulse_sparklines"];
        
        molly.info = info;
        [info release];

        
        HRPatient *sarah = [[[HRPatient alloc] initWithName:@"Sarah Smith" image:[UIImage imageNamed:@"Sarah_Smith"]] autorelease];
        sarah.address = address;
        sarah.gender = HRPatientGenderFemale;
        sarah.birthday = [self dateForString:@"19720626"];
        sarah.placeOfBirth = @"Boston, MA USA";
        sarah.race = @"White";
        sarah.ethnicity = @"Germanic";
        sarah.phoneNumber = @"410.555.0350 (home)";
        
        info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSArray arrayWithObjects:@"NKA", nil] forKey:@"allergies"];
        [info setObject:@"Asthma Nighttime Symptoms" forKey:@"recent_condition"];
        [info setObject:@"1 Jun 2010" forKey:@"recent_condition_date"];
        [info setObject:[NSArray arrayWithObjects:@"Asthma Daytime Symptoms", @"Asthma Nighttime Symptoms", nil] forKey:@"chronic_conditions"];
        [info setObject:@"Follow up on Asthma Treatment" forKey:@"upcoming_events"];
        [info setObject:@"Tobacco Use Cessation Counseling" forKey:@"plan_of_care"];
        [info setObject:@"5 Apr 2012" forKey:@"follow_up_appointment"];
        [info setObject:@"12 May 2012 - Smoking Cessation Agents" forKey:@"medication_refill"];
        [info setObject:@"5 Jan 2012" forKey:@"recent_encounters_date"];
        [info setObject:@"Office Visit" forKey:@"recent_encounters_type"];
        [info setObject:@"Seasonal Immunizations" forKey:@"recent_encounters_description"];
        [info setObject:@"Yes" forKey:@"immunizations"];
        [info setObject:@"3'2\"" forKey:@"height"];
        [info setObject:@"5 Jan 2012" forKey:@"height_date"];
        [info setObject:@"3'-3'4\"" forKey:@"height_normal"];
        [info setObject:@"139" forKey:@"weight"];
        [info setObject:@"5 Jan 2012" forKey:@"weight_date"];
        [info setObject:@"123-154" forKey:@"weight_normal"];
        [info setObject:@"20" forKey:@"bmi"];
        [info setObject:@"5 Jan 2012" forKey:@"bmi_date"];
        [info setObject:@"18-25" forKey:@"bmi_normal"];
        [info setObject:@"70" forKey:@"pulse"];
        [info setObject:@"5 Jan 2012" forKey:@"pulse_date"];
        [info setObject:@"60-100" forKey:@"pulse_normal"];
        [info setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Smoking Cessation Agents", @"10 mg", @"Long acting inhaled", @"2 mg", nil] forKey:@"medications"];
        [info setObject:@"20 Jul 2010" forKey:@"functional_status_date"];
        [info setObject:@"Asthma" forKey:@"functional_status_problem"];
        [info setObject:@"Home/Living Situation" forKey:@"functional_status_type"];
        [info setObject:@"Chronic" forKey:@"functional_status_status"];
        [info setObject:@"Joseph Yang, M.D." forKey:@"functional_status_source"];
        [info setObject:@"10 Jul 2009" forKey:@"procedures_date"];
        [info setObject:@"Asthma Treatmen" forKey:@"procedures_type"];
        [info setObject:@"15 Nov 2010" forKey:@"diagnosis_date"];
        [info setObject:@"Pap Test/Normal" forKey:@"diagnosis_results"];
        
        [info setObject:[UIImage imageNamed:@"Sparklines_normal_levels"] forKey:@"height_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_growing_levels"] forKey:@"weight_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low_levels"] forKey:@"bmi_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low-to-high_levels"] forKey:@"pulse_sparklines"];
        
        sarah.info = info;
        [info release];
        
        HRPatient *tom = [[[HRPatient alloc] initWithName:@"Tom Smith" image:[UIImage imageNamed:@"Tom_Smith"]] autorelease];
        tom.address = address;
        tom.gender = HRPatientGenderMale;
        tom.birthday = [self dateForString:@"19671229"];
        tom.placeOfBirth = @"Milford, MA USA";
        tom.race = @"White";
        tom.ethnicity = @"Germanic";
        tom.phoneNumber = @"410.555.0350 (home)";
        
        [address release];
        
        info = [[NSMutableDictionary alloc] init];
        [info setObject:[NSArray arrayWithObjects:@"NKA", nil] forKey:@"allergies"];
        [info setObject:@"Diabetes" forKey:@"recent_condition"];
        [info setObject:@"16 Apr 2010" forKey:@"recent_condition_date"];
        [info setObject:[NSArray arrayWithObjects:@"Diabetes", nil] forKey:@"chronic_conditions"];
        [info setObject:@"Foot Exam" forKey:@"upcoming_events"];
        [info setObject:@"Diabetes Management" forKey:@"plan_of_care"];
        [info setObject:@"5 Apr 2012" forKey:@"follow_up_appointment"];
        [info setObject:@"3 Apr 2012 - Insulin" forKey:@"medication_refill"];
        [info setObject:@"5 Jan 2012" forKey:@"recent_encounters_date"];
        [info setObject:@"Office Visit" forKey:@"recent_encounters_type"];
        [info setObject:@"Foot Exam" forKey:@"recent_encounters_description"];
        [info setObject:@"Yes" forKey:@"immunizations"];
        [info setObject:@"3'2\"" forKey:@"height"];
        [info setObject:@"5 Jan 2012" forKey:@"height_date"];
        [info setObject:@"3'-3'4\"" forKey:@"height_normal"];
        [info setObject:@"177" forKey:@"weight"];
        [info setObject:@"5 Jan 2012" forKey:@"weight_date"];
        [info setObject:@"165-178" forKey:@"weight_normal"];
        [info setObject:@"24" forKey:@"bmi"];
        [info setObject:@"5 Jan 2012" forKey:@"bmi_date"];
        [info setObject:@"18-25" forKey:@"bmi_normal"];
        [info setObject:@"70" forKey:@"pulse"];
        [info setObject:@"5 Jan 2012" forKey:@"pulse_date"];
        [info setObject:@"60-100" forKey:@"pulse_normal"];
        [info setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Inslin", @"1 unit", nil] forKey:@"medications"];
        [info setObject:@"20 Jul 2010" forKey:@"functional_status_date"];
        [info setObject:@"Type 1 Diabetes" forKey:@"functional_status_problem"];
        [info setObject:@"Home/Living Situation" forKey:@"functional_status_type"];
        [info setObject:@"Chronic" forKey:@"functional_status_status"];
        [info setObject:@"Joseph Yang, M.D." forKey:@"functional_status_source"];
        [info setObject:@"10 Jul 2009" forKey:@"procedures_date"];
        [info setObject:@"Asthma Treatmen" forKey:@"procedures_type"];
        [info setObject:@"10 Jul 2010" forKey:@"diagnosis_date"];
        [info setObject:@"Diabetes Treatment" forKey:@"diagnosis_results"];
        
        [info setObject:[UIImage imageNamed:@"Sparklines_normal_levels"] forKey:@"height_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_growing_levels"] forKey:@"weight_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low-to-high_levels"] forKey:@"bmi_sparklines"];
        [info setObject:[UIImage imageNamed:@"Sparklines_low_levels"] forKey:@"pulse_sparklines"];
        
        tom.info = info;
        [info release];

        
        
        
        array = [[NSArray alloc] initWithObjects:johnny, henry, molly, sarah, tom, nil];
    });
    
    
    return array;
}

#pragma mark - System settings

+ (BOOL)hasLaunched {
    BOOL hasLaunched = [[NSUserDefaults standardUserDefaults] boolForKey:HRHasLaunched];
    if (hasLaunched) {
        return YES;
    } else {
        return NO;
    }
}
+ (void)setHasLaunched:(BOOL)hasLaunched {
    [[NSUserDefaults standardUserDefaults] setBool:hasLaunched forKey:HRHasLaunched];
}
+ (BOOL)passcodeEnabled {
    BOOL passcodeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:HRPasscodeEnabled];
    if (passcodeEnabled) {
        return YES;
    } else {
        return NO;
    }    
}
+ (void)setPasscodeEnabled:(BOOL)passcodeEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:passcodeEnabled forKey:HRPasscodeEnabled];
}
+ (BOOL)privacyWarningConfirmed {
    BOOL passcodeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:HRPPrivacyWarningConfirmed];
    if (passcodeEnabled) {
        return YES;
    } else {
        return NO;
    }        
}
+ (void)setPrivacyWarningConfirmed:(BOOL)confirmed {
    [[NSUserDefaults standardUserDefaults] setBool:confirmed forKey:HRPPrivacyWarningConfirmed];
}

#pragma mark - Helper methods

+ (NSDate *)dateForString:(NSString *)str {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSDate *date = [formatter dateFromString:str];
    [formatter release];
    
    return date;
}

+ (void)parseEncounters {
    // Ugly XML to get encounter until we move to JSON
    __block NSMutableArray *patientEncounters = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Johnny_Smith_96" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    if (error) NSLog(@"ERROR Reading DOC %@", error);
    NSArray *results = [doc nodesForXPath:@"//*[local-name()=\"section\"]" error:&error];
    [doc release];
    if (error) NSLog(@"ERROR %@", error);
//    NSLog(@"parsed: %i", [results count]);
    for (DDXMLElement *section in results) {
        NSArray *encounters = [section nodesForXPath:@".//*[local-name()=\"title\"]" error:&error];
//        NSLog(@"Encounters count: %i", [encounters count]);
        if (error) NSLog(@"Section Error %@", error);
        DDXMLNode *encounterNode = [encounters objectAtIndex:0];
        if ([[encounterNode stringValue] isEqualToString:@"Encounters"]) {
            NSArray *tbody = [section nodesForXPath:@".//*[local-name()=\"tbody\"]" error:nil];
            DDXMLNode *encNode = [tbody objectAtIndex:0];
            NSArray *enc = [encNode nodesForXPath:@".//*[local-name()=\"tr\"]" error:&error];
//            NSLog(@"Encounters trs: %i", [enc count]);
            for (DDXMLNode *tdNode in enc) {
                NSString *title = [[tdNode childAtIndex:0] stringValue];
//                NSLog(@"Title %@", title);
                NSString *code = [[tdNode childAtIndex:1] stringValue];
//                NSLog(@"Code %@", code);
                __block NSMutableString *date = [[[tdNode childAtIndex:2] stringValue] mutableCopy];
                NSArray *orindals = [NSArray arrayWithObjects:@"st", @"nd", @"rd", @"th", nil];
                [orindals enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                    [date replaceOccurrencesOfString:obj 
                                          withString:@"" 
                                             options:NSCaseInsensitiveSearch 
                                               range:NSMakeRange(0, [date length])];
                }];
//                NSLog(@"Date %@", date);
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [formatter setLocale:enUS];
                [enUS release];
                [formatter setDateFormat:@"MMMM dd, yyyy mm:hh"]; /* Unicode Locale Data Markup Language */
                NSDate *theDate = [formatter dateFromString:date]; /*e.g. @"Thu, 11 Sep 2008 12:34:12 +0200" */
                HREncounter *hrEncounter = [[HREncounter alloc] initWithTitle:title code:code date:theDate];
                [patientEncounters addObject:hrEncounter];
            }
        }
    }
    NSLog(@"Patient Encounters: %@", patientEncounters);
    
    NSString *timelinePath = [[NSBundle mainBundle] pathForResource:@"timeline/hReader/hReader" ofType:@"xml"];
    NSData *timelineData = [NSData dataWithContentsOfFile:timelinePath];
    DDXMLDocument *timelineDoc = [[DDXMLDocument alloc] initWithData:timelineData options:0 error:&error];
//    NSLog(@"---- %@", timelineDoc);
    DDXMLElement *dataElement = [[timelineDoc nodesForXPath:@"/data" error:&error] lastObject];
    
    for (HREncounter *encounter in patientEncounters) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MMM d yyyy 00:00:00"];
        NSString *dateString = [df stringFromDate:encounter.date];
        [df release];
        NSString *xml = [NSString stringWithFormat:@"<event start=\"%@ GMT\" title=\"\" category=\"encounters\">%@ - %@</event>", dateString, encounter.title, encounter.code];
        DDXMLElement *eElement = [[DDXMLElement alloc] initWithXMLString:xml error:&error];
        [dataElement addChild:eElement];
        [eElement release];
    }
    [patientEncounters release];
    
    NSString *p = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [[timelineDoc XMLData] writeToFile:[p stringByAppendingPathComponent:@"hReader.xml"] atomically:YES];
    [timelineDoc release];
}

@end