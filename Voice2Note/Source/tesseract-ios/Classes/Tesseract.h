//
//  Tesseract.h
//  Tesseract
//
//  Created by Loïs Di Qual on 24/09/12.
//  Copyright (c) 2012 Loïs Di Qual.
//  Under MIT License. See 'LICENCE' for more informations.
//

#import <Foundation/Foundation.h>

extern NSString * const OcrEngineModeTesseractOnly;
extern NSString * const OcrEngineModeCubeOnly;
extern NSString * const OcrEngineModeTesseractCubeCombined;
extern NSString * const OcrEngineModeDefault;

@interface Tesseract : NSObject {
    NSString* _dataPath;
    NSString* _language;
    NSMutableDictionary* _variables;
}

+ (NSString *)version;

/**
 * Returns <code>NO</code> or <code>nil</code> on failure. On success, Returns
 * an initialized <code>Tesseract</code> object set up to use the given tessdata
 * path, language, and OCR engine mode, configured with the given variables and
 * configuration filenames.
 *
 * @param dataPath
 *  The name of the parent directory of tessdata. Must end in / . Any name after
 *  the last / will be stripped.
 * @param language
 *  An ISO 639-3 string or nil, which will default to eng.
 *  The language may be a string of the form [~]<lang>[+[~]<lang>]* indicating
 *  that multiple languages are to be loaded. Eg hin+eng will load Hindi and
 *  English. Languages may specify internally that they want to be loaded with
 *  one or more other languages, so the ~ sign is available to override that.
 *  Eg if hin were set to load eng by default, then hin+~eng would force loading
 *  only hin. The number of loaded languages is limited only by memory, with the
 *  caveat that loading additional languages will impact both speed and
 *  accuracy, as there is more work to do to decide on the applicable language,
 *  and there is more chance of hallucinating incorrect words.
 * @param mode
 *  The OcrEngineMode to use or nil, which is equivalent to OcrEngineModeDefault
 * @param configFilenames
 *  The names (including paths) of config files to use. Example config files can
 *  be found at
 *  http://code.google.com/p/tesseract-ocr/source/browse/#svn/trunk/tessdata/configs
 * @param variables
 *  A dictionary of tesseract variables to set. Each key must be an NSString
 *  instance corresponding to a tesseract variable, and each value must be an
 *  NSString instance containing a valid value for that variable.
 *  Eg @{@"tessedit_char_whitelist" : @"0123456789.-"}
 * @param setOnlyNonDebugParams
 *  If true, only params that do not contain "debug" in the name will be set.
 */
- (id)initWithDataPath:(NSString *)dataPath
              language:(NSString *)language
         ocrEngineMode:(NSString *)mode
       configFilenames:(NSArray*)configFilenames
             variables:(NSDictionary*)variables
 setOnlyNonDebugParams:(BOOL)setOnlyNonDebugParams;
- (id)initWithDataPath:(NSString *)dataPath language:(NSString *)language;
- (void)setVariableValue:(NSString *)value forKey:(NSString *)key;
- (void)setImage:(UIImage *)image;
- (BOOL)setLanguage:(NSString *)language;
- (BOOL)recognize;
- (NSString *)recognizedText;
- (void)clear;

@end
