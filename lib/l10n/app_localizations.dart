import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dengue Lens'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tutorialToggle.
  ///
  /// In en, this message translates to:
  /// **'Show Tutorial'**
  String get tutorialToggle;

  /// No description provided for @languageSwitch.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSwitch;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @replayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial?'**
  String get replayTutorial;

  /// No description provided for @replayTutorialDesc.
  ///
  /// In en, this message translates to:
  /// **'This will show the app tutorial again so you can revisit all features.'**
  String get replayTutorialDesc;

  /// No description provided for @replayTutorialTooltip.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial'**
  String get replayTutorialTooltip;

  /// No description provided for @analysingImage.
  ///
  /// In en, this message translates to:
  /// **'Analysing image…'**
  String get analysingImage;

  /// No description provided for @runningTwoStage.
  ///
  /// In en, this message translates to:
  /// **'Running two-stage detection'**
  String get runningTwoStage;

  /// No description provided for @modelNotReady.
  ///
  /// In en, this message translates to:
  /// **'Model not ready yet. Please wait and try again.'**
  String get modelNotReady;

  /// No description provided for @predictionFailed.
  ///
  /// In en, this message translates to:
  /// **'Prediction failed: {error}'**
  String predictionFailed(String error);

  /// No description provided for @failedPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedPickImage(String error);

  /// No description provided for @failedCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String failedCaptureImage(String error);

  /// No description provided for @unsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Please select JPEG, PNG, GIF or WebP'**
  String get unsupportedFormat;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Dengue Lens'**
  String get appName;

  /// No description provided for @heroTitle1.
  ///
  /// In en, this message translates to:
  /// **'Identify Mosquito &'**
  String get heroTitle1;

  /// No description provided for @heroTitle2.
  ///
  /// In en, this message translates to:
  /// **'Assess Risk'**
  String get heroTitle2;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your family with instant analysis.'**
  String get heroSubtitle;

  /// No description provided for @scanMosquito.
  ///
  /// In en, this message translates to:
  /// **'Scan Mosquito'**
  String get scanMosquito;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get uploadFromGallery;

  /// No description provided for @healthTipsMosquitoBites.
  ///
  /// In en, this message translates to:
  /// **'Health Tips: Mosquito Bites'**
  String get healthTipsMosquitoBites;

  /// No description provided for @treatingABite.
  ///
  /// In en, this message translates to:
  /// **'Treating a Bite'**
  String get treatingABite;

  /// No description provided for @treatingABiteDesc.
  ///
  /// In en, this message translates to:
  /// **'Wash the area with soap and water. Apply a cool compress to reduce swelling and itching.'**
  String get treatingABiteDesc;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @treatingAMosquitoBite.
  ///
  /// In en, this message translates to:
  /// **'Treating a Mosquito Bite'**
  String get treatingAMosquitoBite;

  /// No description provided for @treatmentSteps.
  ///
  /// In en, this message translates to:
  /// **'1. Wash the area with soap and water.\n2. Apply a cool compress to reduce swelling and itching.\n3. Avoid scratching the bite to prevent infection.\n4. Apply an over-the-counter anti-itch or antihistamine cream.\n5. Monitor the bite for signs of infection (increased redness, swelling, or pus).'**
  String get treatmentSteps;

  /// No description provided for @tipOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day: '**
  String get tipOfTheDay;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'Use mosquito repellent containing DEET for long-lasting protection.'**
  String get dailyTip;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @noScanHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet.'**
  String get noScanHistoryYet;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record?'**
  String get deleteRecord;

  /// No description provided for @deleteRecordDesc.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the scan record for \"{name}\" and its saved image.'**
  String deleteRecordDesc(String name);

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteTooltip;

  /// No description provided for @scanRecordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scan record deleted'**
  String get scanRecordDeleted;

  /// No description provided for @mosquitoScans.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Scans'**
  String get mosquitoScans;

  /// No description provided for @resultSavedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Result saved to history'**
  String get resultSavedToHistory;

  /// No description provided for @sightingSharedToMap.
  ///
  /// In en, this message translates to:
  /// **'Sighting shared to the dengue map!'**
  String get sightingSharedToMap;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location. Please enable GPS.'**
  String get unableToGetLocation;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @noInternetDesc.
  ///
  /// In en, this message translates to:
  /// **'Please connect to the internet to share your result to the dengue map. You can still save it locally using \"Record Result\".'**
  String get noInternetDesc;

  /// No description provided for @noMosquitoDetected.
  ///
  /// In en, this message translates to:
  /// **'No Mosquito Detected'**
  String get noMosquitoDetected;

  /// No description provided for @noMosquitoDetectedDesc.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t detect any mosquito in the image. Make sure the mosquito is in focus and well-lit for better accuracy.'**
  String get noMosquitoDetectedDesc;

  /// No description provided for @wereBitten.
  ///
  /// In en, this message translates to:
  /// **'Were you bitten by this mosquito?'**
  String get wereBitten;

  /// No description provided for @bitenDesc.
  ///
  /// In en, this message translates to:
  /// **'{mosquito} is a known dengue vector. If you were bitten, we recommend checking your symptoms.'**
  String bitenDesc(String mosquito);

  /// No description provided for @yesCheckSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Yes, Check Symptoms'**
  String get yesCheckSymptoms;

  /// No description provided for @detectionResult.
  ///
  /// In en, this message translates to:
  /// **'Detection Result'**
  String get detectionResult;

  /// No description provided for @detectionResults.
  ///
  /// In en, this message translates to:
  /// **'Detection Results ({count})'**
  String detectionResults(int count);

  /// No description provided for @detectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Detection Details'**
  String get detectionDetails;

  /// No description provided for @sampleType.
  ///
  /// In en, this message translates to:
  /// **'Sample Type'**
  String get sampleType;

  /// No description provided for @mosquitoType.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Type'**
  String get mosquitoType;

  /// No description provided for @primaryMosquito.
  ///
  /// In en, this message translates to:
  /// **'Primary Mosquito'**
  String get primaryMosquito;

  /// No description provided for @detectionDate.
  ///
  /// In en, this message translates to:
  /// **'Detection Date'**
  String get detectionDate;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @backToHomeBtn.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHomeBtn;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share Result'**
  String get shareResult;

  /// No description provided for @resultShared.
  ///
  /// In en, this message translates to:
  /// **'Result Shared'**
  String get resultShared;

  /// No description provided for @recordResult.
  ///
  /// In en, this message translates to:
  /// **'Record Result'**
  String get recordResult;

  /// No description provided for @resultRecorded.
  ///
  /// In en, this message translates to:
  /// **'Result Recorded'**
  String get resultRecorded;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable, showing default area'**
  String get locationUnavailable;

  /// No description provided for @educationalLibrary.
  ///
  /// In en, this message translates to:
  /// **'Educational Library'**
  String get educationalLibrary;

  /// No description provided for @mosquitoSpecies.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Species'**
  String get mosquitoSpecies;

  /// No description provided for @dengueSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Dengue Symptoms'**
  String get dengueSymptoms;

  /// No description provided for @preventionGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Prevention Guidelines'**
  String get preventionGuidelines;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aedesAegyptiTitle.
  ///
  /// In en, this message translates to:
  /// **'Aedes aegypti'**
  String get aedesAegyptiTitle;

  /// No description provided for @aedesAegyptiDesc.
  ///
  /// In en, this message translates to:
  /// **'The primary vector of dengue. It is a small, dark mosquito with white lyre-shaped markings and banded legs. They typically bite during the day, particularly early morning and late afternoon.'**
  String get aedesAegyptiDesc;

  /// No description provided for @aedesAlbopictusTitle.
  ///
  /// In en, this message translates to:
  /// **'Aedes albopictus'**
  String get aedesAlbopictusTitle;

  /// No description provided for @aedesAlbopictusDesc.
  ///
  /// In en, this message translates to:
  /// **'A secondary vector of dengue, also known as the Asian tiger mosquito. It has a single white stripe down the center of its head and back. It can survive in cooler, temperate regions.'**
  String get aedesAlbopictusDesc;

  /// No description provided for @culexTitle.
  ///
  /// In en, this message translates to:
  /// **'Culex spp.'**
  String get culexTitle;

  /// No description provided for @culexDesc.
  ///
  /// In en, this message translates to:
  /// **'Often found around houses. They usually bite at night. While they can transmit diseases like West Nile virus and Japanese encephalitis, they are not vectors for dengue.'**
  String get culexDesc;

  /// No description provided for @anophelesTitle.
  ///
  /// In en, this message translates to:
  /// **'Anopheles spp.'**
  String get anophelesTitle;

  /// No description provided for @anophelesDesc.
  ///
  /// In en, this message translates to:
  /// **'Primarily known as the vector for malaria. They typically bite between dusk and dawn. Like Culex, they are not a risk for dengue transmission.'**
  String get anophelesDesc;

  /// No description provided for @commonSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common Symptoms'**
  String get commonSymptomsTitle;

  /// No description provided for @commonSymptomsDesc.
  ///
  /// In en, this message translates to:
  /// **'• High fever (40°C/104°F)\n• Severe headache\n• Pain behind the eyes\n• Muscle and joint pains\n• Nausea and vomiting\n• Swollen glands\n• Rash'**
  String get commonSymptomsDesc;

  /// No description provided for @severeDengueTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe Dengue Warning Signs'**
  String get severeDengueTitle;

  /// No description provided for @severeDengueDesc.
  ///
  /// In en, this message translates to:
  /// **'• Severe abdominal pain\n• Persistent vomiting\n• Rapid breathing\n• Bleeding gums or nose\n• Fatigue, restlessness\n• Blood in vomit or stool\n\nSeek immediate medical attention if these occur.'**
  String get severeDengueDesc;

  /// No description provided for @preventBitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent Mosquito Bites'**
  String get preventBitesTitle;

  /// No description provided for @preventBitesDesc.
  ///
  /// In en, this message translates to:
  /// **'• Use mosquito repellents containing DEET, Picaridin, or IR3535.\n• Wear long-sleeved shirts and long pants.\n• Use mosquito nets if sleeping during the day or in unscreened rooms.'**
  String get preventBitesDesc;

  /// No description provided for @eliminateSitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Eliminate Breeding Sites'**
  String get eliminateSitesTitle;

  /// No description provided for @eliminateSitesDesc.
  ///
  /// In en, this message translates to:
  /// **'• Cover, empty, or clean domestic water storage containers on a weekly basis.\n• Dispose of solid waste properly and remove artificial man-made habitats.\n• Apply appropriate insecticides to water storage outdoor containers.'**
  String get eliminateSitesDesc;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Dengue Lens helps identify potential dengue vectors from photos and supports follow-up risk assessment.'**
  String get aboutDesc;

  /// No description provided for @symptomCheck.
  ///
  /// In en, this message translates to:
  /// **'Symptom Check'**
  String get symptomCheck;

  /// No description provided for @earlyAssessmentQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to do an early dengue symptom assessment?'**
  String get earlyAssessmentQuestion;

  /// No description provided for @earlyAssessmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms can be mild or severe, with warning signs of severe cases appearing 24-48 hours after the fever subsides.'**
  String get earlyAssessmentSubtitle;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'Start Assessment'**
  String get startAssessment;

  /// No description provided for @interactiveAssessment.
  ///
  /// In en, this message translates to:
  /// **'Interactive Assessment'**
  String get interactiveAssessment;

  /// No description provided for @selectSymptomsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select all symptoms you have experienced in the last 24-48 hours.'**
  String get selectSymptomsPrompt;

  /// No description provided for @submitAssessment.
  ///
  /// In en, this message translates to:
  /// **'Submit Assessment'**
  String get submitAssessment;

  /// No description provided for @pleaseSelectOneOption.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option'**
  String get pleaseSelectOneOption;

  /// No description provided for @noSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'I don\'t experience any of these symptoms'**
  String get noSymptomsTitle;

  /// No description provided for @noSymptomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No dengue-related symptoms detected'**
  String get noSymptomsSubtitle;

  /// No description provided for @symptomHighFever.
  ///
  /// In en, this message translates to:
  /// **'High fever'**
  String get symptomHighFever;

  /// No description provided for @symptomHighFeverSub.
  ///
  /// In en, this message translates to:
  /// **'Sudden onset above 38.5°C'**
  String get symptomHighFeverSub;

  /// No description provided for @symptomSevereHeadache.
  ///
  /// In en, this message translates to:
  /// **'Severe headache'**
  String get symptomSevereHeadache;

  /// No description provided for @symptomSevereHeadacheSub.
  ///
  /// In en, this message translates to:
  /// **'Intense pain across forehead'**
  String get symptomSevereHeadacheSub;

  /// No description provided for @symptomEyePain.
  ///
  /// In en, this message translates to:
  /// **'Eye pain'**
  String get symptomEyePain;

  /// No description provided for @symptomEyePainSub.
  ///
  /// In en, this message translates to:
  /// **'Pain behind the eyes'**
  String get symptomEyePainSub;

  /// No description provided for @symptomJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint/muscle pain'**
  String get symptomJointPain;

  /// No description provided for @symptomJointPainSub.
  ///
  /// In en, this message translates to:
  /// **'Severe \"bone-breaking\" pain'**
  String get symptomJointPainSub;

  /// No description provided for @symptomSkinRash.
  ///
  /// In en, this message translates to:
  /// **'Skin rash'**
  String get symptomSkinRash;

  /// No description provided for @symptomSkinRashSub.
  ///
  /// In en, this message translates to:
  /// **'Red spots on torso or limbs'**
  String get symptomSkinRashSub;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomNauseaSub.
  ///
  /// In en, this message translates to:
  /// **'Persistent vomiting or queasiness'**
  String get symptomNauseaSub;

  /// No description provided for @symptomSwollenGlands.
  ///
  /// In en, this message translates to:
  /// **'Swollen glands'**
  String get symptomSwollenGlands;

  /// No description provided for @symptomSwollenGlandsSub.
  ///
  /// In en, this message translates to:
  /// **'Enlarged lymph nodes in neck'**
  String get symptomSwollenGlandsSub;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomFatigueSub.
  ///
  /// In en, this message translates to:
  /// **'Extreme weakness or exhaustion'**
  String get symptomFatigueSub;

  /// No description provided for @riskAssessment.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get riskAssessment;

  /// No description provided for @medicalDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This tool is for education and early awareness only. It does not replace professional medical diagnosis. If you feel unwell or your symptoms worsen, contact a healthcare provider.'**
  String get medicalDisclaimerText;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get score;

  /// No description provided for @homeCareProtocol.
  ///
  /// In en, this message translates to:
  /// **'Home Care Protocol'**
  String get homeCareProtocol;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get recommended;

  /// No description provided for @assessmentSummary.
  ///
  /// In en, this message translates to:
  /// **'ASSESSMENT SUMMARY'**
  String get assessmentSummary;

  /// No description provided for @symptomAssessmentLogged.
  ///
  /// In en, this message translates to:
  /// **'Symptom assessment logged'**
  String get symptomAssessmentLogged;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dengue Lens!'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s take a quick tour so you can start identifying mosquitoes and assessing dengue risk right away.'**
  String get tutorialWelcomeDesc;

  /// No description provided for @tutorialScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a Mosquito'**
  String get tutorialScanTitle;

  /// No description provided for @tutorialScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap this button to capture a mosquito photo using your camera for instant AI-powered analysis.'**
  String get tutorialScanDesc;

  /// No description provided for @tutorialUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get tutorialUploadTitle;

  /// No description provided for @tutorialUploadDesc.
  ///
  /// In en, this message translates to:
  /// **'Already have a photo? Upload it from your gallery instead for the same accurate detection.'**
  String get tutorialUploadDesc;

  /// No description provided for @tutorialNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the App'**
  String get tutorialNavTitle;

  /// No description provided for @tutorialNavDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the navigation bar at the bottom to explore all the powerful features — History, Map, Risk Assessment, and Library.'**
  String get tutorialNavDesc;

  /// No description provided for @tutorialHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get tutorialHistoryTitle;

  /// No description provided for @tutorialHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'All your previous mosquito scans are saved here. Tap any record to view the full analysis result, including detection details and confidence scores.'**
  String get tutorialHistoryDesc;

  /// No description provided for @tutorialHistoryTip.
  ///
  /// In en, this message translates to:
  /// **'Swipe a record left to reveal the delete button, or long-press to remove a scan you no longer need.'**
  String get tutorialHistoryTip;

  /// No description provided for @tutorialMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Point Map'**
  String get tutorialMapTitle;

  /// No description provided for @tutorialMapDesc.
  ///
  /// In en, this message translates to:
  /// **'The map shows real-time crowd-sourced mosquito sightings near you. Green dots are Aedes aegypti (high risk) and amber dots are Aedes albopictus. Brighter dots indicate recent sightings (within 12 h).'**
  String get tutorialMapDesc;

  /// No description provided for @tutorialMapTip.
  ///
  /// In en, this message translates to:
  /// **'Tap any map marker to see the species, distance, and exact time it was reported.'**
  String get tutorialMapTip;

  /// No description provided for @tutorialRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get tutorialRiskTitle;

  /// No description provided for @tutorialRiskDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer a short symptom questionnaire to assess your personal dengue risk level. The result guides you on whether to seek medical attention.'**
  String get tutorialRiskDesc;

  /// No description provided for @tutorialRiskTip.
  ///
  /// In en, this message translates to:
  /// **'You can also start a risk assessment directly from a scan result — it considers the specific mosquito species detected.'**
  String get tutorialRiskTip;

  /// No description provided for @tutorialLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Educational Library'**
  String get tutorialLibraryTitle;

  /// No description provided for @tutorialLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn about dengue vectors, symptoms, and how to prevent mosquito breeding in your surroundings. A great reference for keeping your family safe.'**
  String get tutorialLibraryDesc;

  /// No description provided for @tutorialLibraryTip.
  ///
  /// In en, this message translates to:
  /// **'The library covers Aedes aegypti, Aedes albopictus, Culex, and Anopheles mosquito species in detail.'**
  String get tutorialLibraryTip;

  /// No description provided for @tutorialReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay Anytime'**
  String get tutorialReplayTitle;

  /// No description provided for @tutorialReplayDesc.
  ///
  /// In en, this message translates to:
  /// **'You can replay this tutorial anytime by tapping this button. Enjoy using Dengue Lens!'**
  String get tutorialReplayDesc;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @tutorialFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get tutorialFinish;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String tutorialStep(int current, int total);

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK'**
  String get highRisk;

  /// No description provided for @moderateRisk.
  ///
  /// In en, this message translates to:
  /// **'MODERATE RISK'**
  String get moderateRisk;

  /// No description provided for @notAVector.
  ///
  /// In en, this message translates to:
  /// **'NOT A VECTOR'**
  String get notAVector;

  /// No description provided for @dengueVectorHighRisk.
  ///
  /// In en, this message translates to:
  /// **'Dengue Vector — High Risk'**
  String get dengueVectorHighRisk;

  /// No description provided for @dengueVectorModerateRisk.
  ///
  /// In en, this message translates to:
  /// **'Dengue Vector — Moderate Risk'**
  String get dengueVectorModerateRisk;

  /// No description provided for @notADengueVector.
  ///
  /// In en, this message translates to:
  /// **'Not a Dengue Vector'**
  String get notADengueVector;

  /// No description provided for @highRiskBanner.
  ///
  /// In en, this message translates to:
  /// **'HIGH RISK — Dengue Vector Detected'**
  String get highRiskBanner;

  /// No description provided for @moderateRiskBanner.
  ///
  /// In en, this message translates to:
  /// **'MODERATE RISK — Dengue Vector Detected'**
  String get moderateRiskBanner;

  /// No description provided for @mosquitoDetected.
  ///
  /// In en, this message translates to:
  /// **'1 Mosquito Detected'**
  String get mosquitoDetected;

  /// No description provided for @mosquitoesDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} Mosquitoes Detected'**
  String mosquitoesDetected(int count);

  /// No description provided for @mapAcquiringLocation.
  ///
  /// In en, this message translates to:
  /// **'Acquiring Location...'**
  String get mapAcquiringLocation;

  /// No description provided for @mapActiveRecent.
  ///
  /// In en, this message translates to:
  /// **'{active} Active | {recent} Recent'**
  String mapActiveRecent(int active, int recent);

  /// No description provided for @mapMyScan.
  ///
  /// In en, this message translates to:
  /// **'My Scan'**
  String get mapMyScan;

  /// No description provided for @mapOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'The pinpoint map requires an active internet connection to load map tiles and real-time crowd-sourced sightings.'**
  String get mapOfflineDesc;

  /// No description provided for @mapRetryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get mapRetryConnection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
