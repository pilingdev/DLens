// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dengue Lens';

  @override
  String get settings => 'Settings';

  @override
  String get tutorialToggle => 'Show Tutorial';

  @override
  String get languageSwitch => 'Language';

  @override
  String get exitApp => 'Exit App';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get delete => 'Delete';

  @override
  String get replay => 'Replay';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get continue_btn => 'Continue';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get notNow => 'Not Now';

  @override
  String get replayTutorial => 'Replay Tutorial?';

  @override
  String get replayTutorialDesc =>
      'This will show the app tutorial again so you can revisit all features.';

  @override
  String get replayTutorialTooltip => 'Replay Tutorial';

  @override
  String get analysingImage => 'Analysing image…';

  @override
  String get runningTwoStage => 'Running two-stage detection';

  @override
  String get modelNotReady => 'Model not ready yet. Please wait and try again.';

  @override
  String predictionFailed(String error) {
    return 'Prediction failed: $error';
  }

  @override
  String failedPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedCaptureImage(String error) {
    return 'Failed to capture image: $error';
  }

  @override
  String get unsupportedFormat =>
      'Unsupported format. Please select JPEG, PNG, GIF or WebP';

  @override
  String get appName => 'Dengue Lens';

  @override
  String get heroTitle1 => 'Identify Mosquito &';

  @override
  String get heroTitle2 => 'Assess Risk';

  @override
  String get heroSubtitle => 'Protect your family with instant analysis.';

  @override
  String get scanMosquito => 'Scan Mosquito';

  @override
  String get uploadFromGallery => 'Upload from Gallery';

  @override
  String get healthTipsMosquitoBites => 'Health Tips: Mosquito Bites';

  @override
  String get treatingABite => 'Treating a Bite';

  @override
  String get treatingABiteDesc =>
      'Wash the area with soap and water. Apply a cool compress to reduce swelling and itching.';

  @override
  String get readMore => 'Read More';

  @override
  String get treatingAMosquitoBite => 'Treating a Mosquito Bite';

  @override
  String get treatmentSteps =>
      '1. Wash the area with soap and water.\n2. Apply a cool compress to reduce swelling and itching.\n3. Avoid scratching the bite to prevent infection.\n4. Apply an over-the-counter anti-itch or antihistamine cream.\n5. Monitor the bite for signs of infection (increased redness, swelling, or pus).';

  @override
  String get tipOfTheDay => 'Tip of the Day: ';

  @override
  String get dailyTip =>
      'Use mosquito repellent containing DEET for long-lasting protection.';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get noScanHistoryYet => 'No scan history yet.';

  @override
  String get deleteRecord => 'Delete Record?';

  @override
  String deleteRecordDesc(String name) {
    return 'This will permanently remove the scan record for \"$name\" and its saved image.';
  }

  @override
  String get deleteTooltip => 'Delete record';

  @override
  String get scanRecordDeleted => 'Scan record deleted';

  @override
  String get mosquitoScans => 'Mosquito Scans';

  @override
  String get resultSavedToHistory => 'Result saved to history';

  @override
  String get sightingSharedToMap => 'Sighting shared to the dengue map!';

  @override
  String get unableToGetLocation =>
      'Unable to get your location. Please enable GPS.';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get noInternetDesc =>
      'Please connect to the internet to share your result to the dengue map. You can still save it locally using \"Record Result\".';

  @override
  String get noMosquitoDetected => 'No Mosquito Detected';

  @override
  String get noMosquitoDetectedDesc =>
      'We couldn\'t detect any mosquito in the image. Make sure the mosquito is in focus and well-lit for better accuracy.';

  @override
  String get wereBitten => 'Were you bitten by this mosquito?';

  @override
  String bitenDesc(String mosquito) {
    return '$mosquito is a known dengue vector. If you were bitten, we recommend checking your symptoms.';
  }

  @override
  String get yesCheckSymptoms => 'Yes, Check Symptoms';

  @override
  String get detectionResult => 'Detection Result';

  @override
  String detectionResults(int count) {
    return 'Detection Results ($count)';
  }

  @override
  String get detectionDetails => 'Detection Details';

  @override
  String get sampleType => 'Sample Type';

  @override
  String get mosquitoType => 'Mosquito Type';

  @override
  String get primaryMosquito => 'Primary Mosquito';

  @override
  String get detectionDate => 'Detection Date';

  @override
  String get result => 'Result';

  @override
  String get confidence => 'Confidence';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get backToHomeBtn => 'Back to Home';

  @override
  String get shareResult => 'Share Result';

  @override
  String get resultShared => 'Result Shared';

  @override
  String get recordResult => 'Record Result';

  @override
  String get resultRecorded => 'Result Recorded';

  @override
  String get locationUnavailable =>
      'Location unavailable, showing default area';

  @override
  String get educationalLibrary => 'Educational Library';

  @override
  String get mosquitoSpecies => 'Mosquito Species';

  @override
  String get dengueSymptoms => 'Dengue Symptoms';

  @override
  String get preventionGuidelines => 'Prevention Guidelines';

  @override
  String get about => 'About';

  @override
  String get aedesAegyptiTitle => 'Aedes aegypti';

  @override
  String get aedesAegyptiDesc =>
      'The primary vector of dengue. It is a small, dark mosquito with white lyre-shaped markings and banded legs. They typically bite during the day, particularly early morning and late afternoon.';

  @override
  String get aedesAlbopictusTitle => 'Aedes albopictus';

  @override
  String get aedesAlbopictusDesc =>
      'A secondary vector of dengue, also known as the Asian tiger mosquito. It has a single white stripe down the center of its head and back. It can survive in cooler, temperate regions.';

  @override
  String get culexTitle => 'Culex spp.';

  @override
  String get culexDesc =>
      'Often found around houses. They usually bite at night. While they can transmit diseases like West Nile virus and Japanese encephalitis, they are not vectors for dengue.';

  @override
  String get anophelesTitle => 'Anopheles spp.';

  @override
  String get anophelesDesc =>
      'Primarily known as the vector for malaria. They typically bite between dusk and dawn. Like Culex, they are not a risk for dengue transmission.';

  @override
  String get commonSymptomsTitle => 'Common Symptoms';

  @override
  String get commonSymptomsDesc =>
      '• High fever (40°C/104°F)\n• Severe headache\n• Pain behind the eyes\n• Muscle and joint pains\n• Nausea and vomiting\n• Swollen glands\n• Rash';

  @override
  String get severeDengueTitle => 'Severe Dengue Warning Signs';

  @override
  String get severeDengueDesc =>
      '• Severe abdominal pain\n• Persistent vomiting\n• Rapid breathing\n• Bleeding gums or nose\n• Fatigue, restlessness\n• Blood in vomit or stool\n\nSeek immediate medical attention if these occur.';

  @override
  String get preventBitesTitle => 'Prevent Mosquito Bites';

  @override
  String get preventBitesDesc =>
      '• Use mosquito repellents containing DEET, Picaridin, or IR3535.\n• Wear long-sleeved shirts and long pants.\n• Use mosquito nets if sleeping during the day or in unscreened rooms.';

  @override
  String get eliminateSitesTitle => 'Eliminate Breeding Sites';

  @override
  String get eliminateSitesDesc =>
      '• Cover, empty, or clean domestic water storage containers on a weekly basis.\n• Dispose of solid waste properly and remove artificial man-made habitats.\n• Apply appropriate insecticides to water storage outdoor containers.';

  @override
  String get aboutDesc =>
      'Dengue Lens helps identify potential dengue vectors from photos and supports follow-up risk assessment.';

  @override
  String get symptomCheck => 'Symptom Check';

  @override
  String get earlyAssessmentQuestion =>
      'Would you like to do an early dengue symptom assessment?';

  @override
  String get earlyAssessmentSubtitle =>
      'Symptoms can be mild or severe, with warning signs of severe cases appearing 24-48 hours after the fever subsides.';

  @override
  String get startAssessment => 'Start Assessment';

  @override
  String get interactiveAssessment => 'Interactive Assessment';

  @override
  String get selectSymptomsPrompt =>
      'Select all symptoms you have experienced in the last 24-48 hours.';

  @override
  String get submitAssessment => 'Submit Assessment';

  @override
  String get pleaseSelectOneOption => 'Please select at least one option';

  @override
  String get noSymptomsTitle => 'I don\'t experience any of these symptoms';

  @override
  String get noSymptomsSubtitle => 'No dengue-related symptoms detected';

  @override
  String get symptomHighFever => 'High fever';

  @override
  String get symptomHighFeverSub => 'Sudden onset above 38.5°C';

  @override
  String get symptomSevereHeadache => 'Severe headache';

  @override
  String get symptomSevereHeadacheSub => 'Intense pain across forehead';

  @override
  String get symptomEyePain => 'Eye pain';

  @override
  String get symptomEyePainSub => 'Pain behind the eyes';

  @override
  String get symptomJointPain => 'Joint/muscle pain';

  @override
  String get symptomJointPainSub => 'Severe \"bone-breaking\" pain';

  @override
  String get symptomSkinRash => 'Skin rash';

  @override
  String get symptomSkinRashSub => 'Red spots on torso or limbs';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomNauseaSub => 'Persistent vomiting or queasiness';

  @override
  String get symptomSwollenGlands => 'Swollen glands';

  @override
  String get symptomSwollenGlandsSub => 'Enlarged lymph nodes in neck';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomFatigueSub => 'Extreme weakness or exhaustion';

  @override
  String get riskAssessment => 'Risk Assessment';

  @override
  String get medicalDisclaimerText =>
      'This tool is for education and early awareness only. It does not replace professional medical diagnosis. If you feel unwell or your symptoms worsen, contact a healthcare provider.';

  @override
  String get score => 'SCORE';

  @override
  String get homeCareProtocol => 'Home Care Protocol';

  @override
  String get recommended => 'RECOMMENDED';

  @override
  String get assessmentSummary => 'ASSESSMENT SUMMARY';

  @override
  String get symptomAssessmentLogged => 'Symptom assessment logged';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Dengue Lens!';

  @override
  String get tutorialWelcomeDesc =>
      'Let\'s take a quick tour so you can start identifying mosquitoes and assessing dengue risk right away.';

  @override
  String get tutorialScanTitle => 'Scan a Mosquito';

  @override
  String get tutorialScanDesc =>
      'Tap this button to capture a mosquito photo using your camera for instant AI-powered analysis.';

  @override
  String get tutorialUploadTitle => 'Upload from Gallery';

  @override
  String get tutorialUploadDesc =>
      'Already have a photo? Upload it from your gallery instead for the same accurate detection.';

  @override
  String get tutorialNavTitle => 'Explore the App';

  @override
  String get tutorialNavDesc =>
      'Use the navigation bar at the bottom to explore all the powerful features — History, Map, Risk Assessment, and Library.';

  @override
  String get tutorialHistoryTitle => 'Scan History';

  @override
  String get tutorialHistoryDesc =>
      'All your previous mosquito scans are saved here. Tap any record to view the full analysis result, including detection details and confidence scores.';

  @override
  String get tutorialHistoryTip =>
      'Swipe a record left to reveal the delete button, or long-press to remove a scan you no longer need.';

  @override
  String get tutorialMapTitle => 'Point Map';

  @override
  String get tutorialMapDesc =>
      'The map shows real-time crowd-sourced mosquito sightings near you. Green dots are Aedes aegypti (high risk) and amber dots are Aedes albopictus. Brighter dots indicate recent sightings (within 12 h).';

  @override
  String get tutorialMapTip =>
      'Tap any map marker to see the species, distance, and exact time it was reported.';

  @override
  String get tutorialRiskTitle => 'Risk Assessment';

  @override
  String get tutorialRiskDesc =>
      'Answer a short symptom questionnaire to assess your personal dengue risk level. The result guides you on whether to seek medical attention.';

  @override
  String get tutorialRiskTip =>
      'You can also start a risk assessment directly from a scan result — it considers the specific mosquito species detected.';

  @override
  String get tutorialLibraryTitle => 'Educational Library';

  @override
  String get tutorialLibraryDesc =>
      'Learn about dengue vectors, symptoms, and how to prevent mosquito breeding in your surroundings. A great reference for keeping your family safe.';

  @override
  String get tutorialLibraryTip =>
      'The library covers Aedes aegypti, Aedes albopictus, Culex, and Anopheles mosquito species in detail.';

  @override
  String get tutorialReplayTitle => 'Replay Anytime';

  @override
  String get tutorialReplayDesc =>
      'You can replay this tutorial anytime by tapping this button. Enjoy using Dengue Lens!';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialFinish => 'Finish';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String tutorialStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get highRisk => 'HIGH RISK';

  @override
  String get moderateRisk => 'MODERATE RISK';

  @override
  String get notAVector => 'NOT A VECTOR';

  @override
  String get dengueVectorHighRisk => 'Dengue Vector — High Risk';

  @override
  String get dengueVectorModerateRisk => 'Dengue Vector — Moderate Risk';

  @override
  String get notADengueVector => 'Not a Dengue Vector';

  @override
  String get highRiskBanner => 'HIGH RISK — Dengue Vector Detected';

  @override
  String get moderateRiskBanner => 'MODERATE RISK — Dengue Vector Detected';

  @override
  String get mosquitoDetected => '1 Mosquito Detected';

  @override
  String mosquitoesDetected(int count) {
    return '$count Mosquitoes Detected';
  }

  @override
  String get mapAcquiringLocation => 'Acquiring Location...';

  @override
  String mapActiveRecent(int active, int recent) {
    return '$active Active | $recent Recent';
  }

  @override
  String get mapMyScan => 'My Scan';

  @override
  String get mapOfflineDesc =>
      'The pinpoint map requires an active internet connection to load map tiles and real-time crowd-sourced sightings.';

  @override
  String get mapRetryConnection => 'Retry Connection';

  @override
  String get cameraTipsTitle => 'Before You Scan';

  @override
  String get cameraTipsSubtitle =>
      'Follow these tips for the most accurate detection.';

  @override
  String get cameraTipDistanceTitle => 'Get Close';

  @override
  String get cameraTipDistanceDesc =>
      'Hold the camera 5–10 cm from the mosquito (or closer) while keeping the full body in frame.';

  @override
  String get cameraTipLightingTitle => 'Use Good Lighting';

  @override
  String get cameraTipLightingDesc =>
      'Turn on your flash if the area is dark to ensure the mosquito\'s color, markings, and wings are clearly visible.';

  @override
  String get cameraTipCountTitle => 'One Mosquito at a Time';

  @override
  String get cameraTipCountDesc =>
      'The app detects 1–3 mosquitoes per photo. For best accuracy, avoid capturing multiple mosquitoes at once.';

  @override
  String get cameraTipsGotIt => 'Got it';

  @override
  String get warningSigns => 'Warning Signs — Seek Emergency Care';

  @override
  String get warningSignsExplainer =>
      'Any of these signs means seek emergency medical care immediately. Do not wait.';

  @override
  String get regularSymptoms => 'Dengue Symptoms';

  @override
  String get riskLevelLow => 'Low';

  @override
  String get riskLevelModerate => 'Moderate';

  @override
  String get riskLevelHigh => 'High';

  @override
  String get riskLevelEmergency => 'Emergency';

  @override
  String get riskSummaryNoSymptoms =>
      'You reported no symptoms. Keep monitoring your health and take precautions to avoid further mosquito bites.';

  @override
  String get riskSummaryLow =>
      'Your assessment indicates a Low Risk level. Continue monitoring your health and take precautions to avoid further mosquito bites.';

  @override
  String get riskSummaryModerate =>
      'Your assessment indicates a Moderate Risk level. Some dengue symptoms detected. Monitor closely, stay hydrated, and schedule a consultation with a healthcare provider if symptoms worsen.';

  @override
  String get riskSummaryHigh =>
      'Your assessment indicates a High Risk level with multiple dengue symptoms. Seek prompt medical evaluation today. Immediate consultation is advised.';

  @override
  String get riskSummaryEmergency =>
      'Your symptoms include WHO dengue warning signs. Seek emergency medical attention immediately. Go to the nearest hospital or call emergency services now.';

  @override
  String get whyResultWarningSigns =>
      'Warning signs detected — these require immediate emergency medical care.';

  @override
  String whyResultContributors(String symptoms) {
    return '$symptoms are strong dengue indicators.';
  }

  @override
  String get andConnector => ' and ';

  @override
  String vectorBonusNote(String species, int bonus) {
    return '$species detected: +$bonus pts added to score.';
  }

  @override
  String get emergencyCare1 =>
      'Go to the nearest Emergency Room or call emergency services immediately.';

  @override
  String get emergencyCare2 =>
      'Do not take aspirin or ibuprofen. Paracetamol only for fever.';
}
