class AppStrings {
  static const appName = 'CureMate';
   /// splash view texts
  static const aSmartHealthSolution='A Smart Health Solution';
  static const loading='Loading...';
  static const noInternet='No Internet Connection';
  static const checkingInternet='Checking Your Internet Connection';

                           /// Patients views Strings section ///

  /// on boarding view texts
  static const findTrustedDoctors = 'Find Trusted Doctors';
  static const chooseBestDoctors = 'Choose Best Doctors';
  static const easyAppointment = 'Easy Appointments';

  static const findTrustedDoctorsDesc =
      'We help you connect with trusted doctors\n near you, ensuring expert care for all\n your health needs.';
  static const chooseBestDoctorsDesc =
      'Browse verified reviews to choose the best\n doctors in your area for personalized\n and quality medical care.';
  static const easyAppointmentDesc =
      'Book appointments quickly and easily\n through our app—anytime, anywhere,\n with just a few taps.';

  static const getStartedBtnText='Get Started';
  static const skipBtnText='Skip';

  /// SignIN view texts
  static const welcomeBack='Welcome Back';
  static const subtextOfWelcomeBack='Sign in to manage care, appointments, and\n   connect with professionals or patients.';
  static const email='Email';
  static const enterEmail='enter an email';
  static const password='Password';
  static const enterValidPassword='Enter valid password';
  static const passwordHint='enter password';
  static const passwordLengthMessage='Password must be at least 6 characters';
  static const signIn='Sign in';
  static const forgetPassword='Forget password';
  static const doNotHaveAccount="Don't have an account? Join US";

  /// SignUp view texts
  static const joinUsToDiscoverCareThatCares='Join Us to Discover Care That Cares';
  static const subtextOfJoinUS='You can find doctors who specialize in your\n     needs and receive the care you deserve.';
  static const signUp='Sign Up';
  static const haveAccount="Already have an account? Log in";
  static const List<String> userTypes = ['Patient','Doctor'];
  static const List<String> cities = ['Multan','Bahawalpur','DG Khan','Faisalabad','Lahore', 'Karachi', 'Islamabad'];
  static const List<String> docCategories =  [
    'Allergist/Immunologist',
    'Anesthesiologist',
    'Bariatric Surgeon',
    'Cardiologist',
    'Cardiothoracic Surgeon',
    'Chiropractor',
    'Clinic Doctor',
    'Colorectal Surgeon',
    'Cosmetologist',
    'Dentist',
    'Dermatologist',
    'Diabetologist',
    'Dietitian',
    'Endocrinologist',
    'ENT Specialist',
    'ENT Surgeon',
    'Family Physician',
    'Gastroenterologist',
    'General Practitioner (GP)',
    'General Physician',
    'General Surgeon',
    'Gynecologist',
    'Hematologist',
    'Hepatobiliary Surgeon',
    'Homeopathic Doctor',
    'House Officer',
    'Infectious Disease Specialist',
    'Internal Medicine Specialist',
    'Medical Officer',
    'Nephrologist',
    'Neurosurgeon',
    'Neurologist',
    'Nutritionist',
    'Occupational Therapist',
    'Oncologist',
    'Ophthalmologist',
    'Oral and Maxillofacial Surgeon',
    'Orthopedic Surgeon',
    'Pathologist',
    'Pediatric Surgeon',
    'Pediatrician',
    'Physiotherapist',
    'Plastic Surgeon',
    'Primary Care Doctor',
    'Psychiatrist',
    'Psychologist',
    'Pulmonologist',
    'Radiologist',
    'Rheumatologist',
    'Sexologist',
    'Speech Therapist',
    'Transplant Surgeon',
    'Trauma Surgeon',
    'Urologist',
    'Urologic Surgeon',
    'Vascular Surgeon',
    'Other',
  ];
   final cloudName='dqijptmo0';
  final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dqijptmo0/image/upload';
  final uploadPreset = 'curemate_preset';
  final folderName = 'curemate_profiles';


  /// no internet
  static const noInternetInSnackBar='No internet, Please check your internet connection';
  static const internetHasBeenConnectedInSnackBar='Internet has been restored successfully';

  //patient chat with doctors strings
  static const chatsWithDoctors='Chats With Doctors';
  //doctor chat with patients strings
  static const chatsWithPatients='Chats With Patients';
  /// near by doctor view strings
  static const List<int> doctorSearchingAreaRadius=[10,30,50,70,100,150,200,500];
  static const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static const List<String> appointmentFilterOptions = [
    'All',
    'Pending',
    'Accepted',
    'Completed',
    'Rejected',
  ];
}
