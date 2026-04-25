// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Memoro';

  @override
  String get welcomeTitle => 'Welcome to Memoro';

  @override
  String get welcomeSubtitle => 'Your notes and memories in one place.';

  @override
  String get startButton => 'Get Started';

  @override
  String get chooseFlowTitle => 'Choose Your Flow';

  @override
  String get chooseFlowPatient => 'Patient';

  @override
  String get chooseFlowCaregiver => 'Caregiver';

  @override
  String get comingSoonLabel => 'Coming soon';

  @override
  String get chooseFlowCaregiverComingSoon => 'Link to a patient, review care plans, and stay aligned on medications and activities.';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerWelcomeTitle => 'Create your account';

  @override
  String get registerWelcomeSubtitle => 'Sign up in seconds and let us help you remember what matters most.';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderSelectHint => 'Select gender';

  @override
  String get genderRequired => 'Please select your gender.';

  @override
  String get phoneRequired => 'Please enter your phone number.';

  @override
  String get invalidPhoneNumber => 'Enter a valid phone number for the selected country.';

  @override
  String get ageHint => 'Age';

  @override
  String get fieldHintAge => '25';

  @override
  String get ageInvalid => 'Enter a valid age between 1 and 120.';

  @override
  String get termsAgreementPrefix => 'I agree to the ';

  @override
  String get termsAgreementLink => 'Terms & Conditions';

  @override
  String get termsRequired => 'Please accept the Terms & Conditions.';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsBody => 'This is a summary placeholder. Replace with your real terms, privacy policy, and consent text before production.';

  @override
  String get dialogClose => 'Close';

  @override
  String get imagePickerError => 'Could not open photos. Fully stop the app, run \"flutter clean\", then in the ios folder run \"pod install\", and build again (not hot reload).';

  @override
  String get registerHaveAccountPrefix => 'Already have an account? ';

  @override
  String get registerSignInLink => 'Sign in';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordVisibilityShow => 'Show password';

  @override
  String get passwordVisibilityHide => 'Hide password';

  @override
  String get fieldHintEmail => 'you@example.com';

  @override
  String get fieldHintPassword => 'Enter your password';

  @override
  String get fieldHintName => 'Full name';

  @override
  String get fieldHintPhone => '01xxxxxxxxx';

  @override
  String get fieldHintImageUrl => 'https://example.com/photo.jpg';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removeProfilePhoto => 'Remove photo';

  @override
  String get nameHint => 'Name';

  @override
  String get phoneHint => 'Phone Number';

  @override
  String get loginButton => 'Sign In';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get goToRegister => 'Don\'t have an account? Register';

  @override
  String get imageButton => 'Add Profile Image';

  @override
  String get imageHint => 'Profile Image URL';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email and we will send you a link to reset your password.';

  @override
  String get forgotPasswordSendButton => 'Send';

  @override
  String get passwordResetEmailSent => 'If an account exists for that email, you will receive reset instructions shortly.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginJourneySubtitle => 'Log in to continue your journey with us.';

  @override
  String get loginNoAccountPrefix => 'Don\'t have an account? ';

  @override
  String get loginCreateAccountLink => 'Create an account';

  @override
  String get testAccountButton => 'Use Test Account';

  @override
  String get logoutButton => 'Logout';

  @override
  String get usingTestAccount => 'You are signed in with test account.';

  @override
  String get authErrorMessage => 'Authentication failed. Check your data and try again.';

  @override
  String get authInvalidCredentials => 'Invalid email or password.';

  @override
  String get authPatientLoginOnlyMessage => 'This account belongs to caregiver flow. Please use caregiver login.';

  @override
  String get authCaregiverLoginOnlyMessage => 'This account belongs to patient flow. Please use patient login.';

  @override
  String get firebaseNotConfigured => 'Firebase is not set up on this device. Run the app with a valid firebase_options configuration.';

  @override
  String get firestorePermissionDenied => 'Could not save your profile (database permission denied). Ask the developer to update Firestore security rules for the patients or users collection.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get registerErrorWeakPassword => 'Password is too weak. Use at least 6 characters.';

  @override
  String get registerErrorEmailInUse => 'This email is already registered. Try signing in instead.';

  @override
  String get registerErrorInvalidEmail => 'That email address does not look valid.';

  @override
  String get registerErrorOperationNotAllowed => 'Email/password sign-up is disabled in the Firebase project.';

  @override
  String get registerErrorNetwork => 'Network error. Check your connection and try again.';

  @override
  String get registerSuccess => 'Account created. Sign in with your email and password.';

  @override
  String get loading => 'Loading...';

  @override
  String get currentUser => 'Current User';

  @override
  String get guestUser => 'Guest';

  @override
  String get nextPageSnackBar => 'Let\'s build your next page!';

  @override
  String get tabHome => 'Home';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabGames => 'Games';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabMedicine => 'Medicine';

  @override
  String get tabProfile => 'Profile';

  @override
  String get fabTapped => 'Floating Action Button tapped';

  @override
  String get chatCardTitle => 'Free Chat Bot';

  @override
  String get chatCardSubtitle => 'Ask questions and get instant help.';

  @override
  String get chatBotTitle => 'AI Chat Bot';

  @override
  String get chatMessagesTitle => 'Messages';

  @override
  String get chatSearchHint => 'Find a person...';

  @override
  String get chatAssistantCardTitle => 'Assistant Chat-bot';

  @override
  String get chatAssistantCardSubtitle => 'Get instant answers and helpful information anytime with our friendly AI assistant';

  @override
  String get chatCaregiverCardTitle => 'Caregiver';

  @override
  String get chatCaregiverCardSubtitle => 'Connect directly with your dedicated caregiver for personalized support and assistance';

  @override
  String get chatAssistantTime => '2:15\nPM';

  @override
  String get chatCaregiverTime => '2:15\nAM';

  @override
  String get languageLabel => 'Language';

  @override
  String get englishLabel => 'English';

  @override
  String get arabicLabel => 'Arabic';

  @override
  String get chatMedicalDisclaimer => 'These answers are for awareness only and not a replacement for medical advice.';

  @override
  String get chatChooseQuestion => 'Choose any Alzheimer\'s question and I will answer:';

  @override
  String get gamesNewChallengeLabel => 'New Challenge';

  @override
  String get gamesFeaturedHeroTitle => 'Test your memory';

  @override
  String get gamesFeaturedHeroSubtitle => 'A 5-minute daily exercise to track your cognitive health';

  @override
  String get gamesHubStartNow => 'Start Now';

  @override
  String get gamesAdvancedGamesSectionTitle => 'Advanced Games';

  @override
  String get gamesOnlineSectionTitle => 'Online games';

  @override
  String get gamesSudokuTitle => 'Sudoku Puzzle';

  @override
  String get gamesSudokuSubtitle => 'Word challenge';

  @override
  String get gamesSimonSaysTitle => 'Simon Says Games';

  @override
  String get gamesSimonSaysSubtitle => 'Number puzzle';

  @override
  String get gamesChessTitle => 'Chess';

  @override
  String get gamesChessSubtitle => 'Classic cards';

  @override
  String get gamesPlay => 'Play';

  @override
  String get gamesImageMemoryTestTitle => 'Image Memory Test';

  @override
  String get gamesImageMemoryTestSubtitle => 'Test your memory with images';

  @override
  String get gamesDailyRecallTestTitle => 'Daily Recall Test';

  @override
  String get gamesDailyRecallTestSubtitle => 'Recall your day';

  @override
  String get gameMemoryTitle => 'Memory Card Matching';

  @override
  String get gameMemorySubtitle => 'Match all icon pairs to win.';

  @override
  String get gameSequenceTitle => 'Sequence Memory';

  @override
  String get gameSequenceSubtitle => 'Watch the order, then repeat it.';

  @override
  String get gameMathTitle => 'Quick Math Challenge';

  @override
  String get gameMathSubtitle => 'Solve simple math as fast as you can.';

  @override
  String get patientActivitySectionTitle => 'Activities';

  @override
  String get restartTooltip => 'Restart';

  @override
  String get closeLabel => 'Close';

  @override
  String get playAgainLabel => 'Play Again';

  @override
  String movesLabel(Object count) {
    return 'Moves: $count';
  }

  @override
  String get youWinTitle => 'You win!';

  @override
  String memoryWinMessage(Object moves) {
    return 'Great memory. You finished in $moves moves.';
  }

  @override
  String get sequenceGameOverTitle => 'Game Over';

  @override
  String sequenceGameOverMessage(Object level) {
    return 'You reached level $level. Try again!';
  }

  @override
  String sequenceLevelBest(Object level, Object best) {
    return 'Level: $level   Best: $best';
  }

  @override
  String get sequenceWatch => 'Watch the sequence...';

  @override
  String get sequenceRepeat => 'Now repeat the sequence';

  @override
  String get sequenceReady => 'Get ready...';

  @override
  String get mathTimeUpTitle => 'Time is up!';

  @override
  String mathScoreBest(Object score, Object best) {
    return 'Your score: $score\nBest score: $best';
  }

  @override
  String mathHeader(Object seconds, Object score, Object best) {
    return 'Time: $seconds s   Score: $score   Best: $best';
  }

  @override
  String get mathYourAnswer => 'Your answer';

  @override
  String get submitLabel => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeLanguageTooltip => 'Change language';

  @override
  String get homeGreetingGoodMorning => 'Good Morning';

  @override
  String get homeGreetingGoodAfternoon => 'Good Afternoon';

  @override
  String get homeGreetingGoodEvening => 'Good Evening';

  @override
  String get homeMedicationReminderTitle => 'Medication Reminder';

  @override
  String get homeMedicationReminderSubtitle => 'Next dose at 2:00 PM';

  @override
  String get homeMinutesLabel => 'Minutes';

  @override
  String get homeTakenButton => 'Taken';

  @override
  String get homeThisWeekProgressTitle => 'This Week\'s Progress';

  @override
  String get homeWeekdayMon => 'Mon';

  @override
  String get homeWeekdayTue => 'Tue';

  @override
  String get homeWeekdayWed => 'Wed';

  @override
  String get homeWeekdayThu => 'Thu';

  @override
  String get homeWeekdayFri => 'Fri';

  @override
  String get homeWeekdaySat => 'Sat';

  @override
  String get homeWeekdaySun => 'Sun';

  @override
  String get homeAdherenceMessage => '85% medication adherence this week';

  @override
  String get quickActionViewAll => 'View All';

  @override
  String get quickActionStart => 'Start';

  @override
  String get quickActionActivity => 'Activity';

  @override
  String get quickActionMemoryTest => 'Memory Test';

  @override
  String get quickActionFamily => 'Family';

  @override
  String get profileTitleMyProfile => 'My Profile';

  @override
  String get profileYouAreSafe => 'You are safe 💙';

  @override
  String get profileCallCaregiver => 'Call Caregiver';

  @override
  String get profileMessageButton => 'Message';

  @override
  String get profileYourCaregiver => 'Your Caregiver';

  @override
  String get profilePlaceholderCaregiverName => 'Sarah Johnson';

  @override
  String get profileNextMedication => 'Next Medication';

  @override
  String get profilePlaceholderNextMedTime => '2:00 PM Today';

  @override
  String get profileTodaysActivity => 'Today\'s Activity';

  @override
  String get profilePlaceholderActivity => 'Garden Walk';

  @override
  String get profileSosSettings => 'SOS Settings';

  @override
  String get profilePlaceholderUserName => 'Mohamed Ali';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsLanguageSubtitle => 'Choose your language';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Get reminders and alerts';

  @override
  String get settingsSoundTitle => 'Sound';

  @override
  String get settingsSoundSubtitle => 'Enable sound effects';

  @override
  String get settingsNeedHelpTitle => 'Need Help?';

  @override
  String get settingsNeedHelpSubtitle => 'Contact support if you need assistance';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get medScreenTitle => 'Medication';

  @override
  String medMedicationsCount(Object count) {
    return '$count Medications';
  }

  @override
  String get medDueToday => 'Due today';

  @override
  String get medProgressLabel => 'Progress';

  @override
  String medProgressFraction(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get medSectionMorning => 'Morning';

  @override
  String get medSectionAfternoon => 'Afternoon';

  @override
  String get medSectionEvening => 'Evening';

  @override
  String get medDrugAspirin => 'Aspirin';

  @override
  String get medDrugMetformin => 'Metformin';

  @override
  String get medDrugVitaminD => 'Vitamin D';

  @override
  String get medDose100mgTablet => '100mg tablet';

  @override
  String get medDose500mgTablet => '500mg tablet';

  @override
  String get medDose1000IuCapsule => '1000 IU capsule';

  @override
  String get medTime800Am => '8:00 AM';

  @override
  String get medTime200Pm => '2:00 PM';

  @override
  String get medTime700Pm => '7:00 PM';

  @override
  String get medMarkAsTaken => 'Mark as Taken';

  @override
  String get notifScreenTitle => 'Notifications';

  @override
  String get notifClearAll => 'Clear All';

  @override
  String get notifTabToday => 'Today';

  @override
  String get notifTabReminders => 'Reminders';

  @override
  String get notifTabEarlier => 'Earlier';

  @override
  String get notifTitleMedicationTime => 'Medication Time';

  @override
  String notifDoseAt(Object time) {
    return 'Your dose is at $time';
  }

  @override
  String get notifTitleMessageFromFamily => 'Message from family';

  @override
  String get notifSubtitleFamilyPhoto => 'Sara sent you a new photo!';

  @override
  String get motivationGreatTitle => 'You\'re doing great!';

  @override
  String get motivationGreatBody => 'You\'ve completed 4 of your 5 daily\nroutines so keep it up!';

  @override
  String get familyScreenTitle => 'My Family';

  @override
  String get familyWhoCalling => 'Who are you calling?';

  @override
  String get memoriesHeadingPrimary => 'Our';

  @override
  String get memoriesHeadingSecondary => 'Memories';

  @override
  String get memoriesViewPrimary => 'View';

  @override
  String get memoriesViewSecondary => 'All';

  @override
  String get memoryAlbumCaption => 'Summer Picnic 2023\nGolden Gate Park';

  @override
  String get memoriesAddNewMemory => 'Add New\nMemory';

  @override
  String get familyMemberDetailTitle => 'Family Member';

  @override
  String get familySendMessage => 'Send a Message';

  @override
  String get relationDaughter => 'Daughter';

  @override
  String get relationWife => 'Wife';

  @override
  String get relationGrandson => 'Grandson';

  @override
  String callMember(Object name) {
    return 'Call $name';
  }

  @override
  String familyMemberEncouragement(Object name) {
    return '$name is just a phone call away.\nThey love hearing from you.';
  }

  @override
  String get sosFabLabel => 'SOS';

  @override
  String get sosNeedHelpTitle => 'Do you need help?';

  @override
  String get sosConfirmAssistanceBody => 'We will send emergency\nassistance to your location\nimmediately.';

  @override
  String get sosYesSendHelp => 'Yes, send Help';

  @override
  String get sosSendingCardTitle => 'Sending SOS...';

  @override
  String get sosConnectingContactsLine => 'Connecting to Sarah Miller and Dr. Aris';

  @override
  String get sosViewEmergencyContacts => 'View Emergency Contacts';

  @override
  String get sosAppBarEmergencySos => 'Emergency SOS';

  @override
  String get sosHelpRequestSent => 'Help request sent';

  @override
  String get sosContactingFamily => 'Contacting your family...';

  @override
  String get sosSendingGuidanceBody => 'We are alerting your emergency\ncontacts and providing your\ncurrent location. Please stay\nwhere you are.';

  @override
  String get sosLabelCurrentLocation => 'CURRENT LOCATION';

  @override
  String get sosSampleAddress => '123 Maple Street, Apt 4B';

  @override
  String get sosLabelPrimaryContact => 'PRIMARY CONTACT';

  @override
  String get sosSamplePrimaryContact => 'Sarah Miller (Daughter)';

  @override
  String get sosCancelRequest => 'Cancel Request';

  @override
  String get sosMistakeHint => 'If this was a mistake, tap above to stop.';

  @override
  String get sosAppBarSosSent => 'SOS Sent';

  @override
  String get sosSentSuccessTitle => 'Your SOS was sent\nsuccessfully!';

  @override
  String get sosSentSuccessBody => 'Your family and caregivers have\nbeen notified. Stay calm, help is\non the way.';

  @override
  String get sosLocationSharedTitle => 'Location Shared';

  @override
  String get sosLocationSharedBody => 'Caregivers can see your\ncurrent position.';

  @override
  String get sosBackToHome => 'Back to Home';

  @override
  String get sosCallEmergencyNumber => 'Call Emergency Number';

  @override
  String get sosHelpEtaNote => 'Help typically arrives in 5-10 minutes';

  @override
  String get sosSimulateSent => 'Simulate Sent';

  @override
  String get sosSettingsScreenTitle => 'SOS Settings';

  @override
  String get sosEmergencyContactTitle => 'Emergency Contact';

  @override
  String get sosPrimaryCaregiverSubtitle => 'Your primary caregiver';

  @override
  String get sosCaregiverNameLabel => 'Caregiver Name';

  @override
  String get sosPhoneNumberLabel => 'Phone Number';

  @override
  String get sosPlaceholderCaregiverName => 'Sarah Johnson';

  @override
  String get sosPlaceholderPhone => '01255884562';

  @override
  String get sosCallEmergencyContact => 'Call Emergency Contact';

  @override
  String get sosOptionsHeader => 'SOS Options';

  @override
  String get sosShareLocationTitle => 'Share Location';

  @override
  String get sosShareLocationSubtitle => 'Send your location during SOS';

  @override
  String get sosAutoCallTitle => 'Auto Call';

  @override
  String get sosAutoCallSubtitle => 'Automatically call emergency contacts';

  @override
  String get sosTestSystemTitle => 'Test SOS System';

  @override
  String get sosTestSystemSubtitle => 'Check if your SOS system is working\nproperly';

  @override
  String get sosTestButton => 'Test SOS';

  @override
  String get sosHowItWorksTitle => 'How SOS Works';

  @override
  String get sosHowItWorksBullet1 => '• Press and hold the SOS button for 3 seconds';

  @override
  String get sosHowItWorksBullet2 => '• Your location will be shared if enabled';

  @override
  String get sosHowItWorksBullet3 => '• Emergency contact will be called automatically';

  @override
  String get doctorConnectTitle => 'Connect with Patient';

  @override
  String get doctorConnectSubtitle => 'Enter the patient\'s code to request access';

  @override
  String get doctorPatientIdLabel => 'Patient ID';

  @override
  String get doctorPatientIdHint => 'D-537254';

  @override
  String get doctorSubmitCodeButton => 'Submit Code';

  @override
  String get doctorConnectInfoBody => 'Request the code from the patient. You will proceed to the next page after entering it.';

  @override
  String get doctorPrivacyNoticeBody => 'To protect patient privacy, you must be verified by the patient or their primary guardian before accessing health records.';

  @override
  String doctorPatientIdDisplay(Object id) {
    return 'ID: #$id';
  }

  @override
  String get doctorStatusPending => 'PENDING';

  @override
  String get doctorStatusWaitingTitle => 'Status Waiting';

  @override
  String get doctorStatusWaitingSubtitle => 'System is synchronizing encrypted records for new users.';

  @override
  String get doctorCheckAccessButton => 'Check access';

  @override
  String get doctorEmergencyRequestTitle => 'Emergency Request';

  @override
  String get doctorEmergencyRequestSubtitle => 'Margaret Thompson\n2 minutes ago';

  @override
  String get doctorCallButton => 'Call';

  @override
  String get doctorLocationButton => 'Location';

  @override
  String get doctorMessageButton => 'Message';

  @override
  String get doctorStatusStable => 'Stable';

  @override
  String get doctorPatientProgressTitle => 'Patient Progress';

  @override
  String get doctorWellnessScoreLine => 'This week\'s overall wellness score.';

  @override
  String get doctorProgressNoItemsYet => 'No medicines or activities assigned yet.';

  @override
  String doctorProgressSummary(Object done, Object total) {
    return '$done of $total medicines and activities completed.';
  }

  @override
  String doctorWellnessPercent(Object percent) {
    return '$percent%';
  }

  @override
  String get doctorAlertsSectionTitle => 'Alerts';

  @override
  String doctorActiveAlertsCount(Object count) {
    return '$count Active';
  }

  @override
  String get doctorAlertMissedMedication => 'Missed Medication';

  @override
  String get doctorAlertActivityReminder => 'Activity Reminder';

  @override
  String get doctorNextDoseLabel => 'Next Dose';

  @override
  String get doctorNextDoseValue => 'Aricept 10mg';

  @override
  String get doctorAddMedication => 'Add Medication';

  @override
  String get doctorTodaysProgressLabel => 'Today\'s Progress';

  @override
  String get doctorTodaysProgressDone => 'Morning routine completed.';

  @override
  String get doctorMedViewAll => 'View All';

  @override
  String get doctorNextDoseSchedule => 'Aricept 10mg - 8:00 PM';

  @override
  String get doctorNextDoseIn => 'In 2h';

  @override
  String get doctorActivitiesTitle => 'Activities';

  @override
  String doctorActivitiesCompletedCount(Object count) {
    return '$count Completed';
  }

  @override
  String get doctorAlertMissedMedDetail => 'Evening dose - Aricept 10mg';

  @override
  String get doctorAlertMissedMedOverdue => '2 hours overdue';

  @override
  String get doctorAlertActivityDetail => 'Memory exercise pending';

  @override
  String get doctorAlertActivityDue => 'Due in 30 minutes';

  @override
  String doctorFamilyAccessLine(Object count) {
    return '$count members with access';
  }

  @override
  String get doctorAssignActivity => 'Assign Activity';

  @override
  String get doctorActivityNoActivitiesYet => 'No activities assigned yet.';

  @override
  String get doctorActivityTitleRequired => 'Activity title is required.';

  @override
  String get doctorActivityTitleLabel => 'Activity title';

  @override
  String get doctorActivityTitleHint => 'Drink water / Morning walk / Stretching';

  @override
  String get doctorActivityTypeLabel => 'Activity type';

  @override
  String get doctorActivityTypeWater => 'Water';

  @override
  String get doctorActivityTypeExercise => 'Exercise';

  @override
  String get doctorActivityTypeBreathing => 'Breathing';

  @override
  String get doctorActivityTypeOther => 'Other';

  @override
  String get doctorActivityTargetLabel => 'Target';

  @override
  String get doctorActivityTargetHint => '8 glasses / 20 mins / 1 session';

  @override
  String doctorActivityTimeLabel(Object time) {
    return 'Time: $time';
  }

  @override
  String get doctorActivityInstructionsLabel => 'Instructions';

  @override
  String get doctorActivityInstructionsHint => 'Any extra details for the patient...';

  @override
  String get doctorActivityDoneButton => 'Done';

  @override
  String doctorActivityLatestWithTime(Object title, Object time) {
    return '$title at $time';
  }

  @override
  String get doctorActivityNoMissedNow => 'No missed activities right now.';

  @override
  String doctorActivityOverdueBy(Object duration) {
    return 'Overdue by $duration';
  }

  @override
  String doctorActivityDurationHoursMinutes(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String doctorActivityDurationMinutes(Object minutes) {
    return '${minutes}m';
  }

  @override
  String get doctorActivityTotal => 'Total Activities';

  @override
  String get doctorActivityTakenToday => 'Taken Today';

  @override
  String get doctorActivityMissed => 'Missed';

  @override
  String get doctorActivityWeeklyProgress => 'Weekly Progress';

  @override
  String get doctorActivityWeeklySubtitle => 'Activities completed this week. You\'re on track for the target.';

  @override
  String get doctorActivityRecentResultTitle => 'Recent Result';

  @override
  String get doctorActivityRecentResultSubtitle => 'High accuracy achieved today';

  @override
  String get doctorActivityAssignDetails => 'Assign Details';

  @override
  String get doctorActivityFinishedOnTime => 'Finished on time';

  @override
  String get doctorActivityScoreLabel => 'Score';

  @override
  String get doctorActivityLevel => 'Level';

  @override
  String get doctorActivityAssignedDate => 'Assigned Date';

  @override
  String get doctorActivityScheduledTime => 'Scheduled Time';

  @override
  String get doctorActivityDuration => 'Duration';

  @override
  String get doctorActivityMinutesUnit => 'minutes';

  @override
  String get doctorActivityAssignedBy => 'Assigned By';

  @override
  String get doctorActivityPerformanceSummary => 'Performance Summary';

  @override
  String get doctorActivityFinalScore => 'Final Score';

  @override
  String get doctorActivityTimeTaken => 'Time Taken';

  @override
  String get doctorActivityCorrectMatches => 'Correct Matches';

  @override
  String get doctorActivityTotalAttempts => 'Total Attempts';

  @override
  String get doctorActivityVisibleForPatient => 'Visible for patient';

  @override
  String get doctorActivityEditActivity => 'Edit Activity';

  @override
  String get doctorActivityCancelActivity => 'Cancel Activity';

  @override
  String get doctorActivityStatusCancelled => 'Cancelled';

  @override
  String get doctorActivityAssignedGames => 'Assigned Games';

  @override
  String get doctorGamesShowMemory => 'Show memory games';

  @override
  String get doctorGamesShowOnline => 'Show online games';

  @override
  String get doctorGamesShowSudoku => 'Show Sudoku';

  @override
  String get doctorGamesShowSimon => 'Show Simon Says';

  @override
  String get doctorGamesTitleLabel => 'Game title';

  @override
  String get doctorGamesTitleHint => 'Puzzle 2048';

  @override
  String get doctorGamesUrlLabel => 'Game URL';

  @override
  String get doctorGamesUrlHint => 'https://...';

  @override
  String get doctorGamesAddLink => 'Add game link';

  @override
  String get doctorGamesRequiredFields => 'Please fill game title and URL.';

  @override
  String get doctorGamesNoCustomLinks => 'No custom links yet.';

  @override
  String get doctorGamesLinkAdded => 'Game link added.';

  @override
  String get doctorGamesHide => 'Hide';

  @override
  String get doctorGamesShow => 'Show';

  @override
  String get doctorFamilyMembersTitle => 'Family Members';

  @override
  String get doctorManageFamily => 'Manage Family';

  @override
  String doctorPatientAgeRoom(Object age, Object room) {
    return 'Age $age · Room $room';
  }

  @override
  String get doctorFloatingChat => 'Chat';

  @override
  String get doctorFloatingCall => 'Call patient';

  @override
  String get doctorPatientIdRequired => 'Please enter the patient\'s ID.';

  @override
  String get doctorPatientNotFound => 'No patient found with that ID. Check the code and try again.';

  @override
  String get doctorPatientLookupError => 'Could not look up the patient. Check your connection and try again.';

  @override
  String get doctorLinkRequestFailed => 'Could not send your request. Check your connection or try again later.';

  @override
  String get doctorPendingWaitForPatient => 'This screen will update automatically when the patient accepts your request.';

  @override
  String get doctorProfileQuickInfoTitle => 'Quick Info';

  @override
  String get doctorProfileLinkedPatientTitle => 'Linked Patient';

  @override
  String get doctorProfileNotLinkedPatient => 'No patient linked yet';

  @override
  String get doctorProfileManagedTasksTitle => 'Managed Tasks';

  @override
  String doctorProfileManagedTasksSubtitle(Object count) {
    return '$count active tasks';
  }

  @override
  String get doctorProfileCaregiverRole => 'Caregiver';

  @override
  String get doctorProfileSosSettingsTitle => 'SOS Settings';

  @override
  String get doctorProfileEditProfileTooltip => 'Edit profile';

  @override
  String get doctorMedConnectFirst => 'Connect a patient first to manage medication.';

  @override
  String get doctorMedTitleMedication => 'Medication';

  @override
  String get doctorMedViewDetails => 'View Details';

  @override
  String get doctorMedAllGoodToday => 'All good today';

  @override
  String get doctorMedRequiresAttention => 'Requires attention';

  @override
  String doctorMedDosesMissedToday(Object count) {
    return '$count doses missed today';
  }

  @override
  String get doctorMedTotalMedication => 'Total Medication';

  @override
  String get doctorMedTakenToday => 'Taken Today';

  @override
  String get doctorMedMissed => 'Missed';

  @override
  String get doctorMedTodaySchedule => 'Today\'s Schedule';

  @override
  String get doctorMedNoMedicationYet => 'No medications yet.';

  @override
  String get doctorMedNoMissedNow => 'No missed medications right now.';

  @override
  String doctorMedLatestWithTime(Object title, Object time) {
    return '$title at $time';
  }

  @override
  String get doctorMedAllMedications => 'All Medications';

  @override
  String get doctorMedAddMedication => 'Add Medication';

  @override
  String get doctorMedMedicationDetailsButton => 'Medications Details';

  @override
  String doctorMedNextAt(Object time) {
    return 'Next: $time';
  }

  @override
  String get doctorMedStatusTaken => 'Taken';

  @override
  String get doctorMedStatusMissed => 'Missed';

  @override
  String get doctorMedStatusUpcoming => 'Upcoming';

  @override
  String get doctorMedDeleteTitle => 'Delete medication?';

  @override
  String get doctorMedDeleteBody => 'This action cannot be undone.';

  @override
  String get doctorMedDeleteButton => 'Delete';

  @override
  String get doctorMedDeleteFailed => 'Could not delete medication.';

  @override
  String get doctorMedFrequencyLabel => 'FREQUENCY';

  @override
  String get doctorMedInstructionsTitle => 'Instructions';

  @override
  String get doctorMedNoInstructions => 'No caregiver instructions.';

  @override
  String get doctorMedEditMedication => 'Edit Medication';

  @override
  String get doctorMedDeleteMedication => 'Delete Medication';

  @override
  String get doctorMedSaveChanges => 'Save Changes';

  @override
  String get doctorMedSaveMedication => 'Save Medication';

  @override
  String get doctorMedCouldNotSave => 'Could not save medication right now.';

  @override
  String get doctorMedCouldNotSaveChanges => 'Could not save changes right now.';

  @override
  String get doctorMedMedicationNameRequired => 'Medication name is required.';

  @override
  String get doctorMedMedicationName => 'Medication Name';

  @override
  String get doctorMedWhatTime => 'What time?';

  @override
  String get doctorMedPrimaryTime => 'Primary time';

  @override
  String get doctorMedSecondTime => 'Second time';

  @override
  String get doctorMedThirdTime => 'Third time';

  @override
  String get doctorMedSetTime => 'Set Time';

  @override
  String get doctorMedHowOften => 'How often?';

  @override
  String get doctorMedOnceDaily => 'Once Daily';

  @override
  String get doctorMedTwiceDaily => 'Twice Daily';

  @override
  String get doctorMedThreeDaily => 'Three Daily';

  @override
  String get doctorMedNumberOfDays => 'Number of days';

  @override
  String get doctorMedDaysTotal => 'DAYS TOTAL';

  @override
  String get doctorMedMedicineType => 'Medicine Type';

  @override
  String get doctorMedTypeTablet => 'Tablet';

  @override
  String get doctorMedTypeSyringe => 'Syringe';

  @override
  String get doctorMedTypeDrink => 'Drink';

  @override
  String get doctorMedDose => 'Dose';

  @override
  String get doctorMedSelectMlAmount => 'Select ml amount';

  @override
  String get doctorMedDone => 'Done';

  @override
  String get doctorMedCaregiverInstructions => 'Caregiver Instructions';

  @override
  String get doctorMedInstructionHint => 'e.g. Administer with a light meal.\nPatient may be resistant if room is too bright.';

  @override
  String get doctorMedStepOneOfTwo => 'Step 1 of 2';

  @override
  String get doctorMedNewPrescription => 'New Prescription';

  @override
  String get doctorMedDuration => 'Duration';

  @override
  String get doctorMedMedicationDetailsHeader => 'Medication Details';

  @override
  String get doctorMedUnitTabletSingular => 'tablet';

  @override
  String get doctorMedUnitTabletPlural => 'tablets';

  @override
  String get doctorMedUnitMl => 'ml';
}
