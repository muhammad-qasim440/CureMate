class AppStrings {
  static const appName = 'CureMate';
  static const String feedbackEmail = 'ranamqasim440@gmail.com';
  
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
  static const enterValidEmail='enter valid email';
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
  static const List<String> cities = [
    'Abbottabad',
    'Ahmedpur East',
    'Ali Pur',
    'Arifwala',
    'Attock',
    'Bahawalnagar',
    'Bahawalpur',
    'Bannu',
    'Basirpur',
    'Batkhela',
    'Bhalwal',
    'Bhakkar',
    'Bhera',
    'Burewala',
    'Chakwal',
    'Charsadda',
    'Chiniot',
    'Chishtian',
    'Dadu',
    'Daska',
    'Dera Ghazi Khan',
    'Dera Ismail Khan',
    'Faisalabad',
    'Fateh Jang',
    'Gojra',
    'Gujranwala',
    'Gujrat',
    'Gwadar',
    'Hafizabad',
    'Hangu',
    'Haripur',
    'Hyderabad',
    'Islamabad',
    'Jacobabad',
    'Jalalpur Jattan',
    'Jaranwala',
    'Jhang',
    'Jhelum',
    'Kamoke',
    'Karachi',
    'Kasur',
    'Khanewal',
    'Khanpur',
    'Khairpur',
    'Khushab',
    'Kohat',
    'Kot Adu',
    'Lahore',
    'Lalamusa',
    'Larkana',
    'Layyah',
    'Lodhran',
    'Mandi Bahauddin',
    'Mardan',
    'Mian Channu',
    'Mianwali',
    'Multan',
    'Muzaffargarh',
    'Muzaffarabad',
    'Narowal',
    'Nawabshah',
    'Nowshera',
    'Okara',
    'Pakpattan',
    'Peshawar',
    'Quetta',
    'Rahim Yar Khan',
    'Rawalpindi',
    'Sadiqabad',
    'Sahiwal',
    'Sargodha',
    'Shahdadkot',
    'Sheikhupura',
    'Shikarpur',
    'Sialkot',
    'Sibi',
    'Sukkur',
    'Swabi',
    'Swat',
    'Tando Adam',
    'Tando Allahyar',
    'Tank',
    'Taxila',
    'Toba Tek Singh',
    'Vehari',
    'Wah Cantt',
    'Zhob',
    'Ziarat',
    'Other',
  ];
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

  ///patient chat with doctors strings
  static const chatsWithDoctors='Chats With Doctors';
  ///doctor chat with patients strings
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


 static const List<String>  genders=['Male','Female','Other'];
/// Feedback strings for Cure Mate
  static const List<String> feedbackOptions = [
    'Doctor search results are inaccurate',
    'No doctors found in my area',
    'Unable to schedule an appointment',
    'Appointment details not displaying correctly',
    'Profile information not updating',
    'App crashing or freezing',
    'Slow performance when searching for doctors',
    'Location services not working for nearby doctors',
    'Error message displayed when logging in',
    'Difficulty navigating the app interface',
    'Appointment reminders not received',
    'Unable to delete or edit my profile',
    'Issues with marking doctors as favorites',
    'Other (Please Specify)',
  ];
}
