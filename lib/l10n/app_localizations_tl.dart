// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'Dengue Lens';

  @override
  String get settings => 'Mga Setting';

  @override
  String get tutorialToggle => 'Ipakita ang Tutorial';

  @override
  String get languageSwitch => 'Wika';

  @override
  String get exitApp => 'Umalis sa App';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get ok => 'Sige';

  @override
  String get close => 'Isara';

  @override
  String get back => 'Bumalik';

  @override
  String get delete => 'Burahin';

  @override
  String get replay => 'Ulitin';

  @override
  String get yes => 'Oo';

  @override
  String get no => 'Hindi';

  @override
  String get continue_btn => 'Magpatuloy';

  @override
  String get backToHome => 'Bumalik sa Home';

  @override
  String get notNow => 'Hindi Ngayon';

  @override
  String get replayTutorial => 'Ulitin ang Tutorial?';

  @override
  String get replayTutorialDesc =>
      'Ipapakita muli ang tutorial ng app upang makita mo ang lahat ng features.';

  @override
  String get replayTutorialTooltip => 'Ulitin ang Tutorial';

  @override
  String get analysingImage => 'Sinusuri ang larawan…';

  @override
  String get runningTwoStage => 'Nagpapatakbo ng two-stage detection';

  @override
  String get modelNotReady =>
      'Hindi pa handa ang modelo. Mangyaring maghintay.';

  @override
  String predictionFailed(String error) {
    return 'Nabigo ang prediksyon: $error';
  }

  @override
  String failedPickImage(String error) {
    return 'Nabigo ang pagpili ng larawan: $error';
  }

  @override
  String failedCaptureImage(String error) {
    return 'Nabigo ang pagkuha ng larawan: $error';
  }

  @override
  String get unsupportedFormat =>
      'Hindi suportadong format. Mangyaring pumili ng JPEG, PNG, GIF o WebP';

  @override
  String get appName => 'Dengue Lens';

  @override
  String get heroTitle1 => 'Kilalanin ang Lamok &';

  @override
  String get heroTitle2 => 'Suriin ang Panganib';

  @override
  String get heroSubtitle =>
      'Protektahan ang inyong pamilya gamit ang agarang pagsusuri.';

  @override
  String get scanMosquito => 'I-scan ang Lamok';

  @override
  String get uploadFromGallery => 'Mag-upload mula sa Gallery';

  @override
  String get healthTipsMosquitoBites => 'Mga Tip sa Kalusugan: Kagat ng Lamok';

  @override
  String get treatingABite => 'Paggamot ng Kagat';

  @override
  String get treatingABiteDesc =>
      'Hugasan ang lugar ng sabon at tubig. Mag-apply ng malamig na compress para mabawasan ang pamamaga at pangangati.';

  @override
  String get readMore => 'Magbasa pa';

  @override
  String get treatingAMosquitoBite => 'Paggamot ng Kagat ng Lamok';

  @override
  String get treatmentSteps =>
      '1. Hugasan ang lugar ng sabon at tubig.\n2. Mag-apply ng malamig na compress para mabawasan ang pamamaga at pangangati.\n3. Iwasang kumamot para maiwasan ang impeksyon.\n4. Mag-apply ng over-the-counter na anti-itch o antihistamine cream.\n5. Bantayan ang kagat para sa palatandaan ng impeksyon (pagpapula, pamamaga, o nana).';

  @override
  String get tipOfTheDay => 'Tip ng Araw: ';

  @override
  String get dailyTip =>
      'Gumamit ng pangontra-lamok na naglalaman ng DEET para sa pangmatagalang proteksyon.';

  @override
  String get scanHistory => 'Kasaysayan ng Pag-scan';

  @override
  String get noScanHistoryYet => 'Wala pang kasaysayan ng pag-scan.';

  @override
  String get deleteRecord => 'Burahin ang Rekord?';

  @override
  String deleteRecordDesc(String name) {
    return 'Permanenteng aalisin ang rekord ng pag-scan para sa \"$name\" at ang nakaimbak na larawan.';
  }

  @override
  String get deleteTooltip => 'Burahin ang rekord';

  @override
  String get scanRecordDeleted => 'Nabura ang rekord ng pag-scan';

  @override
  String get mosquitoScans => 'Mga Pag-scan ng Lamok';

  @override
  String get resultSavedToHistory => 'Naisave ang resulta sa kasaysayan';

  @override
  String get sightingSharedToMap => 'Nai-share ang pagtingin sa dengue map!';

  @override
  String get unableToGetLocation =>
      'Hindi matukoy ang iyong lokasyon. Mangyaring i-enable ang GPS.';

  @override
  String get noInternetConnection => 'Walang Koneksyon sa Internet';

  @override
  String get noInternetDesc =>
      'Mangyaring kumonekta sa internet para ibahagi ang iyong resulta sa dengue map. Maaari mo pa ring i-save ito nang lokal gamit ang \"I-rekord ang Resulta\".';

  @override
  String get noMosquitoDetected => 'Walang Natukoy na Lamok';

  @override
  String get noMosquitoDetectedDesc =>
      'Hindi namin natukoy ang lamok sa larawan. Siguraduhing naka-focus at maliwanag ang lamok para sa mas mataas na katumpakan.';

  @override
  String get wereBitten => 'Nakagat ka ba ng lamok na ito?';

  @override
  String bitenDesc(String mosquito) {
    return 'Ang $mosquito ay kilalang tagadala ng dengue. Kung nakagat ka, inirerekomenda naming suriin ang iyong mga sintomas.';
  }

  @override
  String get yesCheckSymptoms => 'Oo, Suriin ang Sintomas';

  @override
  String get detectionResult => 'Resulta ng Pagtukoy';

  @override
  String detectionResults(int count) {
    return 'Mga Resulta ng Pagtukoy ($count)';
  }

  @override
  String get detectionDetails => 'Mga Detalye ng Pagtukoy';

  @override
  String get sampleType => 'Uri ng Sample';

  @override
  String get mosquitoType => 'Uri ng Lamok';

  @override
  String get primaryMosquito => 'Pangunahing Lamok';

  @override
  String get detectionDate => 'Petsa ng Pagtukoy';

  @override
  String get result => 'Resulta';

  @override
  String get confidence => 'Kumpiyansa';

  @override
  String get recommendation => 'Rekomendasyon';

  @override
  String get backToHomeBtn => 'Bumalik sa Home';

  @override
  String get shareResult => 'Ibahagi ang Resulta';

  @override
  String get resultShared => 'Nai-share na ang Resulta';

  @override
  String get recordResult => 'I-rekord ang Resulta';

  @override
  String get resultRecorded => 'Nai-rekord na ang Resulta';

  @override
  String get locationUnavailable =>
      'Hindi available ang lokasyon, ipinapakita ang default na lugar';

  @override
  String get educationalLibrary => 'Aklatan ng Kaalaman';

  @override
  String get mosquitoSpecies => 'Mga Uri ng Lamok';

  @override
  String get dengueSymptoms => 'Mga Sintomas ng Dengue';

  @override
  String get preventionGuidelines => 'Mga Alituntunin sa Pag-iwas';

  @override
  String get about => 'Tungkol Sa';

  @override
  String get aedesAegyptiTitle => 'Aedes aegypti';

  @override
  String get aedesAegyptiDesc =>
      'Ang pangunahing tagadala ng dengue. Ito ay isang maliit, madilim na lamok na may puting lyre-shaped na marka at banded na mga paa. Karaniwang kumagat sila sa araw, lalo na sa maagang umaga at huling hapon.';

  @override
  String get aedesAlbopictusTitle => 'Aedes albopictus';

  @override
  String get aedesAlbopictusDesc =>
      'Isang pangalawang tagadala ng dengue, kilala rin bilang Asian tiger mosquito. Mayroon itong iisang puting guhit sa gitna ng ulo at likod. Maaari itong mabuhay sa mas malamig na mga rehiyon.';

  @override
  String get culexTitle => 'Culex spp.';

  @override
  String get culexDesc =>
      'Madalas na makita sa paligid ng mga bahay. Karaniwang kumagat sila sa gabi. Bagama\'t maaari silang magpasa ng mga sakit tulad ng West Nile virus at Japanese encephalitis, hindi sila tagadala ng dengue.';

  @override
  String get anophelesTitle => 'Anopheles spp.';

  @override
  String get anophelesDesc =>
      'Pangunahing kilala bilang tagadala ng malaria. Karaniwang kumagat sila sa pagitan ng takipsilim at madaling araw. Tulad ng Culex, hindi sila panganib para sa pagpapalaganap ng dengue.';

  @override
  String get commonSymptomsTitle => 'Mga Karaniwang Sintomas';

  @override
  String get commonSymptomsDesc =>
      '• Mataas na lagnat (40°C/104°F)\n• Matinding sakit ng ulo\n• Sakit sa likod ng mga mata\n• Sakit sa mga kasukasuan at kalamnan\n• Pagduduwal at pagsusuka\n• Namamagang mga glandula\n• Pantal';

  @override
  String get severeDengueTitle => 'Mga Babala ng Matinding Dengue';

  @override
  String get severeDengueDesc =>
      '• Matinding sakit ng tiyan\n• Patuloy na pagsusuka\n• Mabilis na paghinga\n• Pagdurugo ng gilagid o ilong\n• Pagod, paguulit-ulit\n• Dugo sa suka o dumi\n\nHumiling ng agarang medikal na atensyon kung mangyayari ang mga ito.';

  @override
  String get preventBitesTitle => 'Iwasan ang Kagat ng Lamok';

  @override
  String get preventBitesDesc =>
      '• Gumamit ng pangontra-lamok na naglalaman ng DEET, Picaridin, o IR3535.\n• Magbihis ng mahabang manggas na shirts at mahabang pantalon.\n• Gumamit ng mosquito nets kapag natutulog sa araw o sa mga kuwartong walang screen.';

  @override
  String get eliminateSitesTitle => 'Alisin ang mga Lugar ng Pagpapalaki';

  @override
  String get eliminateSitesDesc =>
      '• Takpan, waliin, o linisin ang mga lalagyan ng tubig sa bahay linggu-linggo.\n• Itapon nang maayos ang basura at alisin ang mga artificial na tirahan.\n• Mag-apply ng angkop na insecticides sa mga lalagyan ng tubig sa labas.';

  @override
  String get aboutDesc =>
      'Tinutulungan ng Dengue Lens na matukoy ang mga potensyal na tagadala ng dengue mula sa mga larawan at sumusuporta sa follow-up na pagsusuri ng panganib.';

  @override
  String get symptomCheck => 'Pagsuri ng Sintomas';

  @override
  String get earlyAssessmentQuestion =>
      'Nais mo bang gumawa ng maagang pagsusuri ng sintomas ng dengue?';

  @override
  String get earlyAssessmentSubtitle =>
      'Ang mga sintomas ay maaaring banayad o matindi, na may mga babala ng matinding kaso na lumalabas 24-48 oras pagkatapos mawala ang lagnat.';

  @override
  String get startAssessment => 'Simulan ang Pagsusuri';

  @override
  String get interactiveAssessment => 'Interactive na Pagsusuri';

  @override
  String get selectSymptomsPrompt =>
      'Piliin ang lahat ng sintomas na naranasan mo sa nakaraang 24-48 oras.';

  @override
  String get submitAssessment => 'Isumite ang Pagsusuri';

  @override
  String get pleaseSelectOneOption => 'Mangyaring pumili ng kahit isang opsyon';

  @override
  String get noSymptomsTitle =>
      'Wala akong nararamdaman na alinman sa mga sintomang ito';

  @override
  String get noSymptomsSubtitle =>
      'Walang natukoy na sintomas na may kaugnayan sa dengue';

  @override
  String get symptomHighFever => 'Mataas na lagnat';

  @override
  String get symptomHighFeverSub => 'Biglang nagsimula nang higit sa 38.5°C';

  @override
  String get symptomSevereHeadache => 'Matinding sakit ng ulo';

  @override
  String get symptomSevereHeadacheSub => 'Matinding sakit sa noo';

  @override
  String get symptomEyePain => 'Sakit ng mata';

  @override
  String get symptomEyePainSub => 'Sakit sa likod ng mga mata';

  @override
  String get symptomJointPain => 'Sakit ng kasukasuan/kalamnan';

  @override
  String get symptomJointPainSub =>
      'Matinding sakit na parang \"pagdurog ng buto\"';

  @override
  String get symptomSkinRash => 'Pantal sa balat';

  @override
  String get symptomSkinRashSub => 'Pulang mga batik sa katawan o mga paa';

  @override
  String get symptomNausea => 'Pagduduwal';

  @override
  String get symptomNauseaSub => 'Patuloy na pagsusuka o pagduduwal';

  @override
  String get symptomSwollenGlands => 'Namamagang glandula';

  @override
  String get symptomSwollenGlandsSub => 'Naka-enlarge na lymph nodes sa leeg';

  @override
  String get symptomFatigue => 'Pagod';

  @override
  String get symptomFatigueSub => 'Labis na kahinaan o pagkapagod';

  @override
  String get riskAssessment => 'Pagsusuri ng Panganib';

  @override
  String get medicalDisclaimerText =>
      'Ang tool na ito ay para lamang sa edukasyon at maagang kaalaman. Hindi nito pinapalitan ang propesyonal na medikal na diagnosis. Kung hindi ka komportable o lumala ang iyong mga sintomas, makipag-ugnayan sa isang tagapagbigay ng pangangalagang pangkalusugan.';

  @override
  String get score => 'PUNTOS';

  @override
  String get homeCareProtocol => 'Protokol ng Pag-aalaga sa Bahay';

  @override
  String get recommended => 'INIREREKOMENDA';

  @override
  String get assessmentSummary => 'BUOD NG PAGSUSURI';

  @override
  String get symptomAssessmentLogged => 'Naitala ang pagsusuri ng sintomas';

  @override
  String get tutorialWelcomeTitle => 'Maligayang Pagdating sa Dengue Lens!';

  @override
  String get tutorialWelcomeDesc =>
      'Gumawa tayo ng mabilis na pagtour para makapagsimula ka sa pagkilala ng mga lamok at pagsusuri ng panganib ng dengue.';

  @override
  String get tutorialScanTitle => 'I-scan ang Lamok';

  @override
  String get tutorialScanDesc =>
      'I-tap ang button na ito para kumuha ng larawan ng lamok gamit ang iyong camera para sa agarang AI-powered na pagsusuri.';

  @override
  String get tutorialUploadTitle => 'Mag-upload mula sa Gallery';

  @override
  String get tutorialUploadDesc =>
      'Mayroon ka nang larawan? I-upload ito mula sa iyong gallery para sa parehong tumpak na pagtukoy.';

  @override
  String get tutorialNavTitle => 'I-explore ang App';

  @override
  String get tutorialNavDesc =>
      'Gamitin ang navigation bar sa ibaba para ma-explore ang lahat ng makapangyarihang features — Kasaysayan, Mapa, Pagsusuri ng Panganib, at Aklatan.';

  @override
  String get tutorialHistoryTitle => 'Kasaysayan ng Pag-scan';

  @override
  String get tutorialHistoryDesc =>
      'Lahat ng iyong nakaraang pag-scan ng lamok ay nakatago dito. I-tap ang anumang rekord para makita ang buong resulta ng pagsusuri, kabilang ang mga detalye ng pagtukoy at mga antas ng kumpiyansa.';

  @override
  String get tutorialHistoryTip =>
      'I-swipe ang rekord sa kaliwa para ipakita ang button ng pagtanggal, o pindutin nang matagal para alisin ang pag-scan na hindi mo na kailangan.';

  @override
  String get tutorialMapTitle => 'Point Map';

  @override
  String get tutorialMapDesc =>
      'Ipinapakita ng mapa ang real-time na crowd-sourced na mga pagtingin ng lamok malapit sa iyo. Ang mga berdeng tuldok ay Aedes aegypti (mataas na panganib) at ang mga amber na tuldok ay Aedes albopictus. Mas maliwanag na mga tuldok ang nagpapahiwatig ng mga kamakailang pagtingin (sa loob ng 12 oras).';

  @override
  String get tutorialMapTip =>
      'I-tap ang anumang marka sa mapa para makita ang species, distansya, at eksaktong oras ng pag-uulat.';

  @override
  String get tutorialRiskTitle => 'Pagsusuri ng Panganib';

  @override
  String get tutorialRiskDesc =>
      'Sagutin ang maikling talatanungan ng sintomas para masuri ang iyong personal na antas ng panganib sa dengue. Ginagabayan ka ng resulta kung kailangan mong humingi ng medikal na tulong.';

  @override
  String get tutorialRiskTip =>
      'Maaari ka ring magsimula ng pagsusuri ng panganib nang direkta mula sa resulta ng pag-scan — isinasaalang-alang nito ang tukoy na species ng lamok na natukoy.';

  @override
  String get tutorialLibraryTitle => 'Aklatan ng Kaalaman';

  @override
  String get tutorialLibraryDesc =>
      'Matuto tungkol sa mga tagadala ng dengue, mga sintomas, at kung paano mapigilan ang pagpapalaki ng lamok sa iyong paligid. Isang mahusay na sanggunian para mapanatiling ligtas ang iyong pamilya.';

  @override
  String get tutorialLibraryTip =>
      'Sinasaklaw ng aklatan ang Aedes aegypti, Aedes albopictus, Culex, at Anopheles na mga species ng lamok nang detalyado.';

  @override
  String get tutorialReplayTitle => 'Ulitin Kahit Kailan';

  @override
  String get tutorialReplayDesc =>
      'Maaari mong ulitin ang tutorial na ito anumang oras sa pamamagitan ng pag-tap ng button na ito. I-enjoy ang paggamit ng Dengue Lens!';

  @override
  String get tutorialNext => 'Susunod';

  @override
  String get tutorialFinish => 'Tapusin';

  @override
  String get tutorialSkip => 'Laktawan';

  @override
  String tutorialStep(int current, int total) {
    return 'Hakbang $current ng $total';
  }

  @override
  String get highRisk => 'MATAAS NA PANGANIB';

  @override
  String get moderateRisk => 'KATAMTAMANG PANGANIB';

  @override
  String get notAVector => 'HINDI TAGADALA';

  @override
  String get dengueVectorHighRisk => 'Tagadala ng Dengue — Mataas na Panganib';

  @override
  String get dengueVectorModerateRisk =>
      'Tagadala ng Dengue — Katamtamang Panganib';

  @override
  String get notADengueVector => 'Hindi Tagadala ng Dengue';

  @override
  String get highRiskBanner =>
      'MATAAS NA PANGANIB — Natukoy ang Tagadala ng Dengue';

  @override
  String get moderateRiskBanner =>
      'KATAMTAMANG PANGANIB — Natukoy ang Tagadala ng Dengue';

  @override
  String get mosquitoDetected => '1 Lamok ang Natukoy';

  @override
  String mosquitoesDetected(int count) {
    return '$count Lamok ang Natukoy';
  }

  @override
  String get mapAcquiringLocation => 'Kumukuha ng Lokasyon...';

  @override
  String mapActiveRecent(int active, int recent) {
    return '$active Aktibo | $recent Bago';
  }

  @override
  String get mapMyScan => 'Aking Scan';

  @override
  String get mapOfflineDesc =>
      'Kailangan ng internet connection para ma-load ang map at ang mga nai-report na lamok.';

  @override
  String get mapRetryConnection => 'Subukang Muli';
}
