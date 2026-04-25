import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Memoro'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Memoro'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your notes and memories in one place.'**
  String get welcomeSubtitle;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startButton;

  /// No description provided for @chooseFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Flow'**
  String get chooseFlowTitle;

  /// No description provided for @chooseFlowPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get chooseFlowPatient;

  /// No description provided for @chooseFlowCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get chooseFlowCaregiver;

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonLabel;

  /// No description provided for @chooseFlowCaregiverComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Link to a patient, review care plans, and stay aligned on medications and activities.'**
  String get chooseFlowCaregiverComingSoon;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerWelcomeTitle;

  /// No description provided for @registerWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up in seconds and let us help you remember what matters most.'**
  String get registerWelcomeSubtitle;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get genderSelectHint;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get genderRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get phoneRequired;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number for the selected country.'**
  String get invalidPhoneNumber;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageHint;

  /// No description provided for @fieldHintAge.
  ///
  /// In en, this message translates to:
  /// **'25'**
  String get fieldHintAge;

  /// No description provided for @ageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age between 1 and 120.'**
  String get ageInvalid;

  /// No description provided for @termsAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get termsAgreementPrefix;

  /// No description provided for @termsAgreementLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAgreementLink;

  /// No description provided for @termsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions.'**
  String get termsRequired;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'This is a summary placeholder. Replace with your real terms, privacy policy, and consent text before production.'**
  String get termsBody;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @imagePickerError.
  ///
  /// In en, this message translates to:
  /// **'Could not open photos. Fully stop the app, run \"flutter clean\", then in the ios folder run \"pod install\", and build again (not hot reload).'**
  String get imagePickerError;

  /// No description provided for @registerHaveAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccountPrefix;

  /// No description provided for @registerSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignInLink;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @passwordVisibilityShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordVisibilityShow;

  /// No description provided for @passwordVisibilityHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordVisibilityHide;

  /// No description provided for @fieldHintEmail.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get fieldHintEmail;

  /// No description provided for @fieldHintPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get fieldHintPassword;

  /// No description provided for @fieldHintName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldHintName;

  /// No description provided for @fieldHintPhone.
  ///
  /// In en, this message translates to:
  /// **'01xxxxxxxxx'**
  String get fieldHintPhone;

  /// No description provided for @fieldHintImageUrl.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/photo.jpg'**
  String get fieldHintImageUrl;

  /// No description provided for @profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoLabel;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeProfilePhoto;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @goToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get goToRegister;

  /// No description provided for @imageButton.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Image'**
  String get imageButton;

  /// No description provided for @imageHint.
  ///
  /// In en, this message translates to:
  /// **'Profile Image URL'**
  String get imageHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get forgotPasswordSendButton;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, you will receive reset instructions shortly.'**
  String get passwordResetEmailSent;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginJourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your journey with us.'**
  String get loginJourneySubtitle;

  /// No description provided for @loginNoAccountPrefix.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccountPrefix;

  /// No description provided for @loginCreateAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccountLink;

  /// No description provided for @testAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Use Test Account'**
  String get testAccountButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @usingTestAccount.
  ///
  /// In en, this message translates to:
  /// **'You are signed in with test account.'**
  String get usingTestAccount;

  /// No description provided for @authErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Check your data and try again.'**
  String get authErrorMessage;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authInvalidCredentials;

  /// No description provided for @authPatientLoginOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'This account belongs to caregiver flow. Please use caregiver login.'**
  String get authPatientLoginOnlyMessage;

  /// No description provided for @authCaregiverLoginOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'This account belongs to patient flow. Please use patient login.'**
  String get authCaregiverLoginOnlyMessage;

  /// No description provided for @firebaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not set up on this device. Run the app with a valid firebase_options configuration.'**
  String get firebaseNotConfigured;

  /// No description provided for @firestorePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile (database permission denied). Ask the developer to update Firestore security rules for the patients or users collection.'**
  String get firestorePermissionDenied;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @registerErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 6 characters.'**
  String get registerErrorWeakPassword;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in instead.'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address does not look valid.'**
  String get registerErrorInvalidEmail;

  /// No description provided for @registerErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-up is disabled in the Firebase project.'**
  String get registerErrorOperationNotAllowed;

  /// No description provided for @registerErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get registerErrorNetwork;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created. Sign in with your email and password.'**
  String get registerSuccess;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @currentUser.
  ///
  /// In en, this message translates to:
  /// **'Current User'**
  String get currentUser;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @nextPageSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build your next page!'**
  String get nextPageSnackBar;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get tabGames;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @tabMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get tabMedicine;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @fabTapped.
  ///
  /// In en, this message translates to:
  /// **'Floating Action Button tapped'**
  String get fabTapped;

  /// No description provided for @chatCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Chat Bot'**
  String get chatCardTitle;

  /// No description provided for @chatCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask questions and get instant help.'**
  String get chatCardSubtitle;

  /// No description provided for @chatBotTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chat Bot'**
  String get chatBotTitle;

  /// No description provided for @chatMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatMessagesTitle;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Find a person...'**
  String get chatSearchHint;

  /// No description provided for @chatAssistantCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant Chat-bot'**
  String get chatAssistantCardTitle;

  /// No description provided for @chatAssistantCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant answers and helpful information anytime with our friendly AI assistant'**
  String get chatAssistantCardSubtitle;

  /// No description provided for @chatCaregiverCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get chatCaregiverCardTitle;

  /// No description provided for @chatCaregiverCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect directly with your dedicated caregiver for personalized support and assistance'**
  String get chatCaregiverCardSubtitle;

  /// No description provided for @chatAssistantTime.
  ///
  /// In en, this message translates to:
  /// **'2:15\nPM'**
  String get chatAssistantTime;

  /// No description provided for @chatCaregiverTime.
  ///
  /// In en, this message translates to:
  /// **'2:15\nAM'**
  String get chatCaregiverTime;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLabel;

  /// No description provided for @chatMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These answers are for awareness only and not a replacement for medical advice.'**
  String get chatMedicalDisclaimer;

  /// No description provided for @chatChooseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Choose any Alzheimer\'s question and I will answer:'**
  String get chatChooseQuestion;

  /// No description provided for @gamesNewChallengeLabel.
  ///
  /// In en, this message translates to:
  /// **'New Challenge'**
  String get gamesNewChallengeLabel;

  /// No description provided for @gamesFeaturedHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Test your memory'**
  String get gamesFeaturedHeroTitle;

  /// No description provided for @gamesFeaturedHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 5-minute daily exercise to track your cognitive health'**
  String get gamesFeaturedHeroSubtitle;

  /// No description provided for @gamesHubStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get gamesHubStartNow;

  /// No description provided for @gamesAdvancedGamesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Games'**
  String get gamesAdvancedGamesSectionTitle;

  /// No description provided for @gamesOnlineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Online games'**
  String get gamesOnlineSectionTitle;

  /// No description provided for @gamesSudokuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku Puzzle'**
  String get gamesSudokuTitle;

  /// No description provided for @gamesSudokuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Word challenge'**
  String get gamesSudokuSubtitle;

  /// No description provided for @gamesSimonSaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Simon Says Games'**
  String get gamesSimonSaysTitle;

  /// No description provided for @gamesSimonSaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Number puzzle'**
  String get gamesSimonSaysSubtitle;

  /// No description provided for @gamesChessTitle.
  ///
  /// In en, this message translates to:
  /// **'Chess'**
  String get gamesChessTitle;

  /// No description provided for @gamesChessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Classic cards'**
  String get gamesChessSubtitle;

  /// No description provided for @gamesPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get gamesPlay;

  /// No description provided for @gamesImageMemoryTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Memory Test'**
  String get gamesImageMemoryTestTitle;

  /// No description provided for @gamesImageMemoryTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test your memory with images'**
  String get gamesImageMemoryTestSubtitle;

  /// No description provided for @gamesDailyRecallTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Recall Test'**
  String get gamesDailyRecallTestTitle;

  /// No description provided for @gamesDailyRecallTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recall your day'**
  String get gamesDailyRecallTestSubtitle;

  /// No description provided for @gameMemoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Card Matching'**
  String get gameMemoryTitle;

  /// No description provided for @gameMemorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match all icon pairs to win.'**
  String get gameMemorySubtitle;

  /// No description provided for @gameSequenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Sequence Memory'**
  String get gameSequenceTitle;

  /// No description provided for @gameSequenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the order, then repeat it.'**
  String get gameSequenceSubtitle;

  /// No description provided for @gameMathTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Math Challenge'**
  String get gameMathTitle;

  /// No description provided for @gameMathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve simple math as fast as you can.'**
  String get gameMathSubtitle;

  /// No description provided for @patientActivitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get patientActivitySectionTitle;

  /// No description provided for @restartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restartTooltip;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @playAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgainLabel;

  /// No description provided for @movesLabel.
  ///
  /// In en, this message translates to:
  /// **'Moves: {count}'**
  String movesLabel(Object count);

  /// No description provided for @youWinTitle.
  ///
  /// In en, this message translates to:
  /// **'You win!'**
  String get youWinTitle;

  /// No description provided for @memoryWinMessage.
  ///
  /// In en, this message translates to:
  /// **'Great memory. You finished in {moves} moves.'**
  String memoryWinMessage(Object moves);

  /// No description provided for @sequenceGameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get sequenceGameOverTitle;

  /// No description provided for @sequenceGameOverMessage.
  ///
  /// In en, this message translates to:
  /// **'You reached level {level}. Try again!'**
  String sequenceGameOverMessage(Object level);

  /// No description provided for @sequenceLevelBest.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}   Best: {best}'**
  String sequenceLevelBest(Object level, Object best);

  /// No description provided for @sequenceWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch the sequence...'**
  String get sequenceWatch;

  /// No description provided for @sequenceRepeat.
  ///
  /// In en, this message translates to:
  /// **'Now repeat the sequence'**
  String get sequenceRepeat;

  /// No description provided for @sequenceReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready...'**
  String get sequenceReady;

  /// No description provided for @mathTimeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Time is up!'**
  String get mathTimeUpTitle;

  /// No description provided for @mathScoreBest.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score}\nBest score: {best}'**
  String mathScoreBest(Object score, Object best);

  /// No description provided for @mathHeader.
  ///
  /// In en, this message translates to:
  /// **'Time: {seconds} s   Score: {score}   Best: {best}'**
  String mathHeader(Object seconds, Object score, Object best);

  /// No description provided for @mathYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get mathYourAnswer;

  /// No description provided for @submitLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changeLanguageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguageTooltip;

  /// No description provided for @homeGreetingGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get homeGreetingGoodMorning;

  /// No description provided for @homeGreetingGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get homeGreetingGoodAfternoon;

  /// No description provided for @homeGreetingGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get homeGreetingGoodEvening;

  /// No description provided for @homeMedicationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get homeMedicationReminderTitle;

  /// No description provided for @homeMedicationReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Next dose at 2:00 PM'**
  String get homeMedicationReminderSubtitle;

  /// No description provided for @homeMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get homeMinutesLabel;

  /// No description provided for @homeTakenButton.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get homeTakenButton;

  /// No description provided for @homeThisWeekProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Progress'**
  String get homeThisWeekProgressTitle;

  /// No description provided for @homeWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get homeWeekdayMon;

  /// No description provided for @homeWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get homeWeekdayTue;

  /// No description provided for @homeWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get homeWeekdayWed;

  /// No description provided for @homeWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get homeWeekdayThu;

  /// No description provided for @homeWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get homeWeekdayFri;

  /// No description provided for @homeWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get homeWeekdaySat;

  /// No description provided for @homeWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get homeWeekdaySun;

  /// No description provided for @homeAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'85% medication adherence this week'**
  String get homeAdherenceMessage;

  /// No description provided for @quickActionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get quickActionViewAll;

  /// No description provided for @quickActionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get quickActionStart;

  /// No description provided for @quickActionActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get quickActionActivity;

  /// No description provided for @quickActionMemoryTest.
  ///
  /// In en, this message translates to:
  /// **'Memory Test'**
  String get quickActionMemoryTest;

  /// No description provided for @quickActionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get quickActionFamily;

  /// No description provided for @profileTitleMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitleMyProfile;

  /// No description provided for @profileYouAreSafe.
  ///
  /// In en, this message translates to:
  /// **'You are safe 💙'**
  String get profileYouAreSafe;

  /// No description provided for @profileCallCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Call Caregiver'**
  String get profileCallCaregiver;

  /// No description provided for @profileMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get profileMessageButton;

  /// No description provided for @profileYourCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Your Caregiver'**
  String get profileYourCaregiver;

  /// No description provided for @profilePlaceholderCaregiverName.
  ///
  /// In en, this message translates to:
  /// **'Sarah Johnson'**
  String get profilePlaceholderCaregiverName;

  /// No description provided for @profileNextMedication.
  ///
  /// In en, this message translates to:
  /// **'Next Medication'**
  String get profileNextMedication;

  /// No description provided for @profilePlaceholderNextMedTime.
  ///
  /// In en, this message translates to:
  /// **'2:00 PM Today'**
  String get profilePlaceholderNextMedTime;

  /// No description provided for @profileTodaysActivity.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get profileTodaysActivity;

  /// No description provided for @profilePlaceholderActivity.
  ///
  /// In en, this message translates to:
  /// **'Garden Walk'**
  String get profilePlaceholderActivity;

  /// No description provided for @profileSosSettings.
  ///
  /// In en, this message translates to:
  /// **'SOS Settings'**
  String get profileSosSettings;

  /// No description provided for @profilePlaceholderUserName.
  ///
  /// In en, this message translates to:
  /// **'Mohamed Ali'**
  String get profilePlaceholderUserName;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminders and alerts'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSoundTitle;

  /// No description provided for @settingsSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable sound effects'**
  String get settingsSoundSubtitle;

  /// No description provided for @settingsNeedHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get settingsNeedHelpTitle;

  /// No description provided for @settingsNeedHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support if you need assistance'**
  String get settingsNeedHelpSubtitle;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @medScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medScreenTitle;

  /// No description provided for @medMedicationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Medications'**
  String medMedicationsCount(Object count);

  /// No description provided for @medDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get medDueToday;

  /// No description provided for @medProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get medProgressLabel;

  /// No description provided for @medProgressFraction.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String medProgressFraction(Object current, Object total);

  /// No description provided for @medSectionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get medSectionMorning;

  /// No description provided for @medSectionAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get medSectionAfternoon;

  /// No description provided for @medSectionEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get medSectionEvening;

  /// No description provided for @medDrugAspirin.
  ///
  /// In en, this message translates to:
  /// **'Aspirin'**
  String get medDrugAspirin;

  /// No description provided for @medDrugMetformin.
  ///
  /// In en, this message translates to:
  /// **'Metformin'**
  String get medDrugMetformin;

  /// No description provided for @medDrugVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get medDrugVitaminD;

  /// No description provided for @medDose100mgTablet.
  ///
  /// In en, this message translates to:
  /// **'100mg tablet'**
  String get medDose100mgTablet;

  /// No description provided for @medDose500mgTablet.
  ///
  /// In en, this message translates to:
  /// **'500mg tablet'**
  String get medDose500mgTablet;

  /// No description provided for @medDose1000IuCapsule.
  ///
  /// In en, this message translates to:
  /// **'1000 IU capsule'**
  String get medDose1000IuCapsule;

  /// No description provided for @medTime800Am.
  ///
  /// In en, this message translates to:
  /// **'8:00 AM'**
  String get medTime800Am;

  /// No description provided for @medTime200Pm.
  ///
  /// In en, this message translates to:
  /// **'2:00 PM'**
  String get medTime200Pm;

  /// No description provided for @medTime700Pm.
  ///
  /// In en, this message translates to:
  /// **'7:00 PM'**
  String get medTime700Pm;

  /// No description provided for @medMarkAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get medMarkAsTaken;

  /// No description provided for @notifScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifScreenTitle;

  /// No description provided for @notifClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notifClearAll;

  /// No description provided for @notifTabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notifTabToday;

  /// No description provided for @notifTabReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifTabReminders;

  /// No description provided for @notifTabEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get notifTabEarlier;

  /// No description provided for @notifTitleMedicationTime.
  ///
  /// In en, this message translates to:
  /// **'Medication Time'**
  String get notifTitleMedicationTime;

  /// No description provided for @notifDoseAt.
  ///
  /// In en, this message translates to:
  /// **'Your dose is at {time}'**
  String notifDoseAt(Object time);

  /// No description provided for @notifTitleMessageFromFamily.
  ///
  /// In en, this message translates to:
  /// **'Message from family'**
  String get notifTitleMessageFromFamily;

  /// No description provided for @notifSubtitleFamilyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sara sent you a new photo!'**
  String get notifSubtitleFamilyPhoto;

  /// No description provided for @motivationGreatTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationGreatTitle;

  /// No description provided for @motivationGreatBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed 4 of your 5 daily\nroutines so keep it up!'**
  String get motivationGreatBody;

  /// No description provided for @familyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Family'**
  String get familyScreenTitle;

  /// No description provided for @familyWhoCalling.
  ///
  /// In en, this message translates to:
  /// **'Who are you calling?'**
  String get familyWhoCalling;

  /// No description provided for @memoriesHeadingPrimary.
  ///
  /// In en, this message translates to:
  /// **'Our'**
  String get memoriesHeadingPrimary;

  /// No description provided for @memoriesHeadingSecondary.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memoriesHeadingSecondary;

  /// No description provided for @memoriesViewPrimary.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get memoriesViewPrimary;

  /// No description provided for @memoriesViewSecondary.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get memoriesViewSecondary;

  /// No description provided for @memoryAlbumCaption.
  ///
  /// In en, this message translates to:
  /// **'Summer Picnic 2023\nGolden Gate Park'**
  String get memoryAlbumCaption;

  /// No description provided for @memoriesAddNewMemory.
  ///
  /// In en, this message translates to:
  /// **'Add New\nMemory'**
  String get memoriesAddNewMemory;

  /// No description provided for @familyMemberDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMemberDetailTitle;

  /// No description provided for @familySendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a Message'**
  String get familySendMessage;

  /// No description provided for @relationDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get relationDaughter;

  /// No description provided for @relationWife.
  ///
  /// In en, this message translates to:
  /// **'Wife'**
  String get relationWife;

  /// No description provided for @relationGrandson.
  ///
  /// In en, this message translates to:
  /// **'Grandson'**
  String get relationGrandson;

  /// No description provided for @callMember.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String callMember(Object name);

  /// No description provided for @familyMemberEncouragement.
  ///
  /// In en, this message translates to:
  /// **'{name} is just a phone call away.\nThey love hearing from you.'**
  String familyMemberEncouragement(Object name);

  /// No description provided for @sosFabLabel.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosFabLabel;

  /// No description provided for @sosNeedHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you need help?'**
  String get sosNeedHelpTitle;

  /// No description provided for @sosConfirmAssistanceBody.
  ///
  /// In en, this message translates to:
  /// **'We will send emergency\nassistance to your location\nimmediately.'**
  String get sosConfirmAssistanceBody;

  /// No description provided for @sosYesSendHelp.
  ///
  /// In en, this message translates to:
  /// **'Yes, send Help'**
  String get sosYesSendHelp;

  /// No description provided for @sosSendingCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending SOS...'**
  String get sosSendingCardTitle;

  /// No description provided for @sosConnectingContactsLine.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Sarah Miller and Dr. Aris'**
  String get sosConnectingContactsLine;

  /// No description provided for @sosViewEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'View Emergency Contacts'**
  String get sosViewEmergencyContacts;

  /// No description provided for @sosAppBarEmergencySos.
  ///
  /// In en, this message translates to:
  /// **'Emergency SOS'**
  String get sosAppBarEmergencySos;

  /// No description provided for @sosHelpRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Help request sent'**
  String get sosHelpRequestSent;

  /// No description provided for @sosContactingFamily.
  ///
  /// In en, this message translates to:
  /// **'Contacting your family...'**
  String get sosContactingFamily;

  /// No description provided for @sosSendingGuidanceBody.
  ///
  /// In en, this message translates to:
  /// **'We are alerting your emergency\ncontacts and providing your\ncurrent location. Please stay\nwhere you are.'**
  String get sosSendingGuidanceBody;

  /// No description provided for @sosLabelCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LOCATION'**
  String get sosLabelCurrentLocation;

  /// No description provided for @sosSampleAddress.
  ///
  /// In en, this message translates to:
  /// **'123 Maple Street, Apt 4B'**
  String get sosSampleAddress;

  /// No description provided for @sosLabelPrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY CONTACT'**
  String get sosLabelPrimaryContact;

  /// No description provided for @sosSamplePrimaryContact.
  ///
  /// In en, this message translates to:
  /// **'Sarah Miller (Daughter)'**
  String get sosSamplePrimaryContact;

  /// No description provided for @sosCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get sosCancelRequest;

  /// No description provided for @sosMistakeHint.
  ///
  /// In en, this message translates to:
  /// **'If this was a mistake, tap above to stop.'**
  String get sosMistakeHint;

  /// No description provided for @sosAppBarSosSent.
  ///
  /// In en, this message translates to:
  /// **'SOS Sent'**
  String get sosAppBarSosSent;

  /// No description provided for @sosSentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your SOS was sent\nsuccessfully!'**
  String get sosSentSuccessTitle;

  /// No description provided for @sosSentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your family and caregivers have\nbeen notified. Stay calm, help is\non the way.'**
  String get sosSentSuccessBody;

  /// No description provided for @sosLocationSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Shared'**
  String get sosLocationSharedTitle;

  /// No description provided for @sosLocationSharedBody.
  ///
  /// In en, this message translates to:
  /// **'Caregivers can see your\ncurrent position.'**
  String get sosLocationSharedBody;

  /// No description provided for @sosBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get sosBackToHome;

  /// No description provided for @sosCallEmergencyNumber.
  ///
  /// In en, this message translates to:
  /// **'Call Emergency Number'**
  String get sosCallEmergencyNumber;

  /// No description provided for @sosHelpEtaNote.
  ///
  /// In en, this message translates to:
  /// **'Help typically arrives in 5-10 minutes'**
  String get sosHelpEtaNote;

  /// No description provided for @sosSimulateSent.
  ///
  /// In en, this message translates to:
  /// **'Simulate Sent'**
  String get sosSimulateSent;

  /// No description provided for @sosSettingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'SOS Settings'**
  String get sosSettingsScreenTitle;

  /// No description provided for @sosEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get sosEmergencyContactTitle;

  /// No description provided for @sosPrimaryCaregiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your primary caregiver'**
  String get sosPrimaryCaregiverSubtitle;

  /// No description provided for @sosCaregiverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Name'**
  String get sosCaregiverNameLabel;

  /// No description provided for @sosPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get sosPhoneNumberLabel;

  /// No description provided for @sosPlaceholderCaregiverName.
  ///
  /// In en, this message translates to:
  /// **'Sarah Johnson'**
  String get sosPlaceholderCaregiverName;

  /// No description provided for @sosPlaceholderPhone.
  ///
  /// In en, this message translates to:
  /// **'01255884562'**
  String get sosPlaceholderPhone;

  /// No description provided for @sosCallEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Call Emergency Contact'**
  String get sosCallEmergencyContact;

  /// No description provided for @sosOptionsHeader.
  ///
  /// In en, this message translates to:
  /// **'SOS Options'**
  String get sosOptionsHeader;

  /// No description provided for @sosShareLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get sosShareLocationTitle;

  /// No description provided for @sosShareLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send your location during SOS'**
  String get sosShareLocationSubtitle;

  /// No description provided for @sosAutoCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Call'**
  String get sosAutoCallTitle;

  /// No description provided for @sosAutoCallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically call emergency contacts'**
  String get sosAutoCallSubtitle;

  /// No description provided for @sosTestSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Test SOS System'**
  String get sosTestSystemTitle;

  /// No description provided for @sosTestSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check if your SOS system is working\nproperly'**
  String get sosTestSystemSubtitle;

  /// No description provided for @sosTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test SOS'**
  String get sosTestButton;

  /// No description provided for @sosHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How SOS Works'**
  String get sosHowItWorksTitle;

  /// No description provided for @sosHowItWorksBullet1.
  ///
  /// In en, this message translates to:
  /// **'• Press and hold the SOS button for 3 seconds'**
  String get sosHowItWorksBullet1;

  /// No description provided for @sosHowItWorksBullet2.
  ///
  /// In en, this message translates to:
  /// **'• Your location will be shared if enabled'**
  String get sosHowItWorksBullet2;

  /// No description provided for @sosHowItWorksBullet3.
  ///
  /// In en, this message translates to:
  /// **'• Emergency contact will be called automatically'**
  String get sosHowItWorksBullet3;

  /// No description provided for @doctorConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Patient'**
  String get doctorConnectTitle;

  /// No description provided for @doctorConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient\'s code to request access'**
  String get doctorConnectSubtitle;

  /// No description provided for @doctorPatientIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get doctorPatientIdLabel;

  /// No description provided for @doctorPatientIdHint.
  ///
  /// In en, this message translates to:
  /// **'D-537254'**
  String get doctorPatientIdHint;

  /// No description provided for @doctorSubmitCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Code'**
  String get doctorSubmitCodeButton;

  /// No description provided for @doctorConnectInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Request the code from the patient. You will proceed to the next page after entering it.'**
  String get doctorConnectInfoBody;

  /// No description provided for @doctorPrivacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'To protect patient privacy, you must be verified by the patient or their primary guardian before accessing health records.'**
  String get doctorPrivacyNoticeBody;

  /// No description provided for @doctorPatientIdDisplay.
  ///
  /// In en, this message translates to:
  /// **'ID: #{id}'**
  String doctorPatientIdDisplay(Object id);

  /// No description provided for @doctorStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get doctorStatusPending;

  /// No description provided for @doctorStatusWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Status Waiting'**
  String get doctorStatusWaitingTitle;

  /// No description provided for @doctorStatusWaitingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System is synchronizing encrypted records for new users.'**
  String get doctorStatusWaitingSubtitle;

  /// No description provided for @doctorCheckAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Check access'**
  String get doctorCheckAccessButton;

  /// No description provided for @doctorEmergencyRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Request'**
  String get doctorEmergencyRequestTitle;

  /// No description provided for @doctorEmergencyRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Margaret Thompson\n2 minutes ago'**
  String get doctorEmergencyRequestSubtitle;

  /// No description provided for @doctorCallButton.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get doctorCallButton;

  /// No description provided for @doctorLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get doctorLocationButton;

  /// No description provided for @doctorMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get doctorMessageButton;

  /// No description provided for @doctorStatusStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get doctorStatusStable;

  /// No description provided for @doctorPatientProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Progress'**
  String get doctorPatientProgressTitle;

  /// No description provided for @doctorWellnessScoreLine.
  ///
  /// In en, this message translates to:
  /// **'This week\'s overall wellness score.'**
  String get doctorWellnessScoreLine;

  /// No description provided for @doctorProgressNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No medicines or activities assigned yet.'**
  String get doctorProgressNoItemsYet;

  /// No description provided for @doctorProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} medicines and activities completed.'**
  String doctorProgressSummary(Object done, Object total);

  /// No description provided for @doctorWellnessPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String doctorWellnessPercent(Object percent);

  /// No description provided for @doctorAlertsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get doctorAlertsSectionTitle;

  /// No description provided for @doctorActiveAlertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String doctorActiveAlertsCount(Object count);

  /// No description provided for @doctorAlertMissedMedication.
  ///
  /// In en, this message translates to:
  /// **'Missed Medication'**
  String get doctorAlertMissedMedication;

  /// No description provided for @doctorAlertActivityReminder.
  ///
  /// In en, this message translates to:
  /// **'Activity Reminder'**
  String get doctorAlertActivityReminder;

  /// No description provided for @doctorNextDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Dose'**
  String get doctorNextDoseLabel;

  /// No description provided for @doctorNextDoseValue.
  ///
  /// In en, this message translates to:
  /// **'Aricept 10mg'**
  String get doctorNextDoseValue;

  /// No description provided for @doctorAddMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get doctorAddMedication;

  /// No description provided for @doctorTodaysProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get doctorTodaysProgressLabel;

  /// No description provided for @doctorTodaysProgressDone.
  ///
  /// In en, this message translates to:
  /// **'Morning routine completed.'**
  String get doctorTodaysProgressDone;

  /// No description provided for @doctorMedViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get doctorMedViewAll;

  /// No description provided for @doctorNextDoseSchedule.
  ///
  /// In en, this message translates to:
  /// **'Aricept 10mg - 8:00 PM'**
  String get doctorNextDoseSchedule;

  /// No description provided for @doctorNextDoseIn.
  ///
  /// In en, this message translates to:
  /// **'In 2h'**
  String get doctorNextDoseIn;

  /// No description provided for @doctorActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get doctorActivitiesTitle;

  /// No description provided for @doctorActivitiesCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Completed'**
  String doctorActivitiesCompletedCount(Object count);

  /// No description provided for @doctorAlertMissedMedDetail.
  ///
  /// In en, this message translates to:
  /// **'Evening dose - Aricept 10mg'**
  String get doctorAlertMissedMedDetail;

  /// No description provided for @doctorAlertMissedMedOverdue.
  ///
  /// In en, this message translates to:
  /// **'2 hours overdue'**
  String get doctorAlertMissedMedOverdue;

  /// No description provided for @doctorAlertActivityDetail.
  ///
  /// In en, this message translates to:
  /// **'Memory exercise pending'**
  String get doctorAlertActivityDetail;

  /// No description provided for @doctorAlertActivityDue.
  ///
  /// In en, this message translates to:
  /// **'Due in 30 minutes'**
  String get doctorAlertActivityDue;

  /// No description provided for @doctorFamilyAccessLine.
  ///
  /// In en, this message translates to:
  /// **'{count} members with access'**
  String doctorFamilyAccessLine(Object count);

  /// No description provided for @doctorAssignActivity.
  ///
  /// In en, this message translates to:
  /// **'Assign Activity'**
  String get doctorAssignActivity;

  /// No description provided for @doctorActivityNoActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities assigned yet.'**
  String get doctorActivityNoActivitiesYet;

  /// No description provided for @doctorActivityTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Activity title is required.'**
  String get doctorActivityTitleRequired;

  /// No description provided for @doctorActivityTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity title'**
  String get doctorActivityTitleLabel;

  /// No description provided for @doctorActivityTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Drink water / Morning walk / Stretching'**
  String get doctorActivityTitleHint;

  /// No description provided for @doctorActivityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get doctorActivityTypeLabel;

  /// No description provided for @doctorActivityTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get doctorActivityTypeWater;

  /// No description provided for @doctorActivityTypeExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get doctorActivityTypeExercise;

  /// No description provided for @doctorActivityTypeBreathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get doctorActivityTypeBreathing;

  /// No description provided for @doctorActivityTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get doctorActivityTypeOther;

  /// No description provided for @doctorActivityTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get doctorActivityTargetLabel;

  /// No description provided for @doctorActivityTargetHint.
  ///
  /// In en, this message translates to:
  /// **'8 glasses / 20 mins / 1 session'**
  String get doctorActivityTargetHint;

  /// No description provided for @doctorActivityTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String doctorActivityTimeLabel(Object time);

  /// No description provided for @doctorActivityInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get doctorActivityInstructionsLabel;

  /// No description provided for @doctorActivityInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Any extra details for the patient...'**
  String get doctorActivityInstructionsHint;

  /// No description provided for @doctorActivityDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doctorActivityDoneButton;

  /// No description provided for @doctorActivityLatestWithTime.
  ///
  /// In en, this message translates to:
  /// **'{title} at {time}'**
  String doctorActivityLatestWithTime(Object title, Object time);

  /// No description provided for @doctorActivityNoMissedNow.
  ///
  /// In en, this message translates to:
  /// **'No missed activities right now.'**
  String get doctorActivityNoMissedNow;

  /// No description provided for @doctorActivityOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {duration}'**
  String doctorActivityOverdueBy(Object duration);

  /// No description provided for @doctorActivityDurationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String doctorActivityDurationHoursMinutes(Object hours, Object minutes);

  /// No description provided for @doctorActivityDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String doctorActivityDurationMinutes(Object minutes);

  /// No description provided for @doctorActivityTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Activities'**
  String get doctorActivityTotal;

  /// No description provided for @doctorActivityTakenToday.
  ///
  /// In en, this message translates to:
  /// **'Taken Today'**
  String get doctorActivityTakenToday;

  /// No description provided for @doctorActivityMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get doctorActivityMissed;

  /// No description provided for @doctorActivityWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get doctorActivityWeeklyProgress;

  /// No description provided for @doctorActivityWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activities completed this week. You\'re on track for the target.'**
  String get doctorActivityWeeklySubtitle;

  /// No description provided for @doctorActivityRecentResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Result'**
  String get doctorActivityRecentResultTitle;

  /// No description provided for @doctorActivityRecentResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'High accuracy achieved today'**
  String get doctorActivityRecentResultSubtitle;

  /// No description provided for @doctorActivityAssignDetails.
  ///
  /// In en, this message translates to:
  /// **'Assign Details'**
  String get doctorActivityAssignDetails;

  /// No description provided for @doctorActivityFinishedOnTime.
  ///
  /// In en, this message translates to:
  /// **'Finished on time'**
  String get doctorActivityFinishedOnTime;

  /// No description provided for @doctorActivityScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get doctorActivityScoreLabel;

  /// No description provided for @doctorActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get doctorActivityLevel;

  /// No description provided for @doctorActivityAssignedDate.
  ///
  /// In en, this message translates to:
  /// **'Assigned Date'**
  String get doctorActivityAssignedDate;

  /// No description provided for @doctorActivityScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get doctorActivityScheduledTime;

  /// No description provided for @doctorActivityDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get doctorActivityDuration;

  /// No description provided for @doctorActivityMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get doctorActivityMinutesUnit;

  /// No description provided for @doctorActivityAssignedBy.
  ///
  /// In en, this message translates to:
  /// **'Assigned By'**
  String get doctorActivityAssignedBy;

  /// No description provided for @doctorActivityPerformanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get doctorActivityPerformanceSummary;

  /// No description provided for @doctorActivityFinalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get doctorActivityFinalScore;

  /// No description provided for @doctorActivityTimeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get doctorActivityTimeTaken;

  /// No description provided for @doctorActivityCorrectMatches.
  ///
  /// In en, this message translates to:
  /// **'Correct Matches'**
  String get doctorActivityCorrectMatches;

  /// No description provided for @doctorActivityTotalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total Attempts'**
  String get doctorActivityTotalAttempts;

  /// No description provided for @doctorActivityVisibleForPatient.
  ///
  /// In en, this message translates to:
  /// **'Visible for patient'**
  String get doctorActivityVisibleForPatient;

  /// No description provided for @doctorActivityEditActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get doctorActivityEditActivity;

  /// No description provided for @doctorActivityCancelActivity.
  ///
  /// In en, this message translates to:
  /// **'Cancel Activity'**
  String get doctorActivityCancelActivity;

  /// No description provided for @doctorActivityStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get doctorActivityStatusCancelled;

  /// No description provided for @doctorActivityAssignedGames.
  ///
  /// In en, this message translates to:
  /// **'Assigned Games'**
  String get doctorActivityAssignedGames;

  /// No description provided for @doctorGamesShowMemory.
  ///
  /// In en, this message translates to:
  /// **'Show memory games'**
  String get doctorGamesShowMemory;

  /// No description provided for @doctorGamesShowOnline.
  ///
  /// In en, this message translates to:
  /// **'Show online games'**
  String get doctorGamesShowOnline;

  /// No description provided for @doctorGamesShowSudoku.
  ///
  /// In en, this message translates to:
  /// **'Show Sudoku'**
  String get doctorGamesShowSudoku;

  /// No description provided for @doctorGamesShowSimon.
  ///
  /// In en, this message translates to:
  /// **'Show Simon Says'**
  String get doctorGamesShowSimon;

  /// No description provided for @doctorGamesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Game title'**
  String get doctorGamesTitleLabel;

  /// No description provided for @doctorGamesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Puzzle 2048'**
  String get doctorGamesTitleHint;

  /// No description provided for @doctorGamesUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Game URL'**
  String get doctorGamesUrlLabel;

  /// No description provided for @doctorGamesUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get doctorGamesUrlHint;

  /// No description provided for @doctorGamesAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add game link'**
  String get doctorGamesAddLink;

  /// No description provided for @doctorGamesRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill game title and URL.'**
  String get doctorGamesRequiredFields;

  /// No description provided for @doctorGamesNoCustomLinks.
  ///
  /// In en, this message translates to:
  /// **'No custom links yet.'**
  String get doctorGamesNoCustomLinks;

  /// No description provided for @doctorGamesLinkAdded.
  ///
  /// In en, this message translates to:
  /// **'Game link added.'**
  String get doctorGamesLinkAdded;

  /// No description provided for @doctorGamesHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get doctorGamesHide;

  /// No description provided for @doctorGamesShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get doctorGamesShow;

  /// No description provided for @doctorFamilyMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get doctorFamilyMembersTitle;

  /// No description provided for @doctorManageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage Family'**
  String get doctorManageFamily;

  /// No description provided for @doctorPatientAgeRoom.
  ///
  /// In en, this message translates to:
  /// **'Age {age} · Room {room}'**
  String doctorPatientAgeRoom(Object age, Object room);

  /// No description provided for @doctorFloatingChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get doctorFloatingChat;

  /// No description provided for @doctorFloatingCall.
  ///
  /// In en, this message translates to:
  /// **'Call patient'**
  String get doctorFloatingCall;

  /// No description provided for @doctorPatientIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the patient\'s ID.'**
  String get doctorPatientIdRequired;

  /// No description provided for @doctorPatientNotFound.
  ///
  /// In en, this message translates to:
  /// **'No patient found with that ID. Check the code and try again.'**
  String get doctorPatientNotFound;

  /// No description provided for @doctorPatientLookupError.
  ///
  /// In en, this message translates to:
  /// **'Could not look up the patient. Check your connection and try again.'**
  String get doctorPatientLookupError;

  /// No description provided for @doctorLinkRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send your request. Check your connection or try again later.'**
  String get doctorLinkRequestFailed;

  /// No description provided for @doctorPendingWaitForPatient.
  ///
  /// In en, this message translates to:
  /// **'This screen will update automatically when the patient accepts your request.'**
  String get doctorPendingWaitForPatient;

  /// No description provided for @doctorProfileQuickInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Info'**
  String get doctorProfileQuickInfoTitle;

  /// No description provided for @doctorProfileLinkedPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked Patient'**
  String get doctorProfileLinkedPatientTitle;

  /// No description provided for @doctorProfileNotLinkedPatient.
  ///
  /// In en, this message translates to:
  /// **'No patient linked yet'**
  String get doctorProfileNotLinkedPatient;

  /// No description provided for @doctorProfileManagedTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Managed Tasks'**
  String get doctorProfileManagedTasksTitle;

  /// No description provided for @doctorProfileManagedTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} active tasks'**
  String doctorProfileManagedTasksSubtitle(Object count);

  /// No description provided for @doctorProfileCaregiverRole.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get doctorProfileCaregiverRole;

  /// No description provided for @doctorProfileSosSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SOS Settings'**
  String get doctorProfileSosSettingsTitle;

  /// No description provided for @doctorProfileEditProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get doctorProfileEditProfileTooltip;

  /// No description provided for @doctorMedConnectFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect a patient first to manage medication.'**
  String get doctorMedConnectFirst;

  /// No description provided for @doctorMedTitleMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get doctorMedTitleMedication;

  /// No description provided for @doctorMedViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get doctorMedViewDetails;

  /// No description provided for @doctorMedAllGoodToday.
  ///
  /// In en, this message translates to:
  /// **'All good today'**
  String get doctorMedAllGoodToday;

  /// No description provided for @doctorMedRequiresAttention.
  ///
  /// In en, this message translates to:
  /// **'Requires attention'**
  String get doctorMedRequiresAttention;

  /// No description provided for @doctorMedDosesMissedToday.
  ///
  /// In en, this message translates to:
  /// **'{count} doses missed today'**
  String doctorMedDosesMissedToday(Object count);

  /// No description provided for @doctorMedTotalMedication.
  ///
  /// In en, this message translates to:
  /// **'Total Medication'**
  String get doctorMedTotalMedication;

  /// No description provided for @doctorMedTakenToday.
  ///
  /// In en, this message translates to:
  /// **'Taken Today'**
  String get doctorMedTakenToday;

  /// No description provided for @doctorMedMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get doctorMedMissed;

  /// No description provided for @doctorMedTodaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get doctorMedTodaySchedule;

  /// No description provided for @doctorMedNoMedicationYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet.'**
  String get doctorMedNoMedicationYet;

  /// No description provided for @doctorMedNoMissedNow.
  ///
  /// In en, this message translates to:
  /// **'No missed medications right now.'**
  String get doctorMedNoMissedNow;

  /// No description provided for @doctorMedLatestWithTime.
  ///
  /// In en, this message translates to:
  /// **'{title} at {time}'**
  String doctorMedLatestWithTime(Object title, Object time);

  /// No description provided for @doctorMedAllMedications.
  ///
  /// In en, this message translates to:
  /// **'All Medications'**
  String get doctorMedAllMedications;

  /// No description provided for @doctorMedAddMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get doctorMedAddMedication;

  /// No description provided for @doctorMedMedicationDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Medications Details'**
  String get doctorMedMedicationDetailsButton;

  /// No description provided for @doctorMedNextAt.
  ///
  /// In en, this message translates to:
  /// **'Next: {time}'**
  String doctorMedNextAt(Object time);

  /// No description provided for @doctorMedStatusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get doctorMedStatusTaken;

  /// No description provided for @doctorMedStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get doctorMedStatusMissed;

  /// No description provided for @doctorMedStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get doctorMedStatusUpcoming;

  /// No description provided for @doctorMedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete medication?'**
  String get doctorMedDeleteTitle;

  /// No description provided for @doctorMedDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get doctorMedDeleteBody;

  /// No description provided for @doctorMedDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get doctorMedDeleteButton;

  /// No description provided for @doctorMedDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete medication.'**
  String get doctorMedDeleteFailed;

  /// No description provided for @doctorMedFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'FREQUENCY'**
  String get doctorMedFrequencyLabel;

  /// No description provided for @doctorMedInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get doctorMedInstructionsTitle;

  /// No description provided for @doctorMedNoInstructions.
  ///
  /// In en, this message translates to:
  /// **'No caregiver instructions.'**
  String get doctorMedNoInstructions;

  /// No description provided for @doctorMedEditMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get doctorMedEditMedication;

  /// No description provided for @doctorMedDeleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get doctorMedDeleteMedication;

  /// No description provided for @doctorMedSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get doctorMedSaveChanges;

  /// No description provided for @doctorMedSaveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save Medication'**
  String get doctorMedSaveMedication;

  /// No description provided for @doctorMedCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save medication right now.'**
  String get doctorMedCouldNotSave;

  /// No description provided for @doctorMedCouldNotSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes right now.'**
  String get doctorMedCouldNotSaveChanges;

  /// No description provided for @doctorMedMedicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medication name is required.'**
  String get doctorMedMedicationNameRequired;

  /// No description provided for @doctorMedMedicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get doctorMedMedicationName;

  /// No description provided for @doctorMedWhatTime.
  ///
  /// In en, this message translates to:
  /// **'What time?'**
  String get doctorMedWhatTime;

  /// No description provided for @doctorMedPrimaryTime.
  ///
  /// In en, this message translates to:
  /// **'Primary time'**
  String get doctorMedPrimaryTime;

  /// No description provided for @doctorMedSecondTime.
  ///
  /// In en, this message translates to:
  /// **'Second time'**
  String get doctorMedSecondTime;

  /// No description provided for @doctorMedThirdTime.
  ///
  /// In en, this message translates to:
  /// **'Third time'**
  String get doctorMedThirdTime;

  /// No description provided for @doctorMedSetTime.
  ///
  /// In en, this message translates to:
  /// **'Set Time'**
  String get doctorMedSetTime;

  /// No description provided for @doctorMedHowOften.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get doctorMedHowOften;

  /// No description provided for @doctorMedOnceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once Daily'**
  String get doctorMedOnceDaily;

  /// No description provided for @doctorMedTwiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice Daily'**
  String get doctorMedTwiceDaily;

  /// No description provided for @doctorMedThreeDaily.
  ///
  /// In en, this message translates to:
  /// **'Three Daily'**
  String get doctorMedThreeDaily;

  /// No description provided for @doctorMedNumberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get doctorMedNumberOfDays;

  /// No description provided for @doctorMedDaysTotal.
  ///
  /// In en, this message translates to:
  /// **'DAYS TOTAL'**
  String get doctorMedDaysTotal;

  /// No description provided for @doctorMedMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get doctorMedMedicineType;

  /// No description provided for @doctorMedTypeTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get doctorMedTypeTablet;

  /// No description provided for @doctorMedTypeSyringe.
  ///
  /// In en, this message translates to:
  /// **'Syringe'**
  String get doctorMedTypeSyringe;

  /// No description provided for @doctorMedTypeDrink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get doctorMedTypeDrink;

  /// No description provided for @doctorMedDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get doctorMedDose;

  /// No description provided for @doctorMedSelectMlAmount.
  ///
  /// In en, this message translates to:
  /// **'Select ml amount'**
  String get doctorMedSelectMlAmount;

  /// No description provided for @doctorMedDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doctorMedDone;

  /// No description provided for @doctorMedCaregiverInstructions.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Instructions'**
  String get doctorMedCaregiverInstructions;

  /// No description provided for @doctorMedInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Administer with a light meal.\nPatient may be resistant if room is too bright.'**
  String get doctorMedInstructionHint;

  /// No description provided for @doctorMedStepOneOfTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get doctorMedStepOneOfTwo;

  /// No description provided for @doctorMedNewPrescription.
  ///
  /// In en, this message translates to:
  /// **'New Prescription'**
  String get doctorMedNewPrescription;

  /// No description provided for @doctorMedDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get doctorMedDuration;

  /// No description provided for @doctorMedMedicationDetailsHeader.
  ///
  /// In en, this message translates to:
  /// **'Medication Details'**
  String get doctorMedMedicationDetailsHeader;

  /// No description provided for @doctorMedUnitTabletSingular.
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get doctorMedUnitTabletSingular;

  /// No description provided for @doctorMedUnitTabletPlural.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get doctorMedUnitTabletPlural;

  /// No description provided for @doctorMedUnitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get doctorMedUnitMl;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
