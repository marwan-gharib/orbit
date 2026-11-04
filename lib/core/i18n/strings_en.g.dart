///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$en app = Translations$app$en._(_root);
	late final Translations$home$en home = Translations$home$en._(_root);
	late final Translations$errors$en errors = Translations$errors$en._(_root);
	late final Translations$validators$en validators = Translations$validators$en._(_root);
	late final Translations$splash$en splash = Translations$splash$en._(_root);
	late final Translations$onboarding$en onboarding = Translations$onboarding$en._(_root);
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$crm$en crm = Translations$crm$en._(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Orbit'
	String get title => 'Orbit';

	late final Translations$app$homePlaceholder$en homePlaceholder = Translations$app$homePlaceholder$en._(_root);
	late final Translations$app$a11y$en a11y = Translations$app$a11y$en._(_root);
}

// Path: home
class Translations$home$en {
	Translations$home$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get title => 'Home';
}

// Path: errors
class Translations$errors$en {
	Translations$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You're offline. Check your internet connection and try again.'
	String get offline => 'You\'re offline. Check your internet connection and try again.';

	/// en: 'We couldn't reach the server. Please try again in a moment.'
	String get unreachable => 'We couldn\'t reach the server. Please try again in a moment.';

	/// en: 'The server is taking too long to respond. Please try again.'
	String get timeout => 'The server is taking too long to respond. Please try again.';

	/// en: 'We couldn't make a secure connection. Check your network and your device's date and time, then try again.'
	String get certificate => 'We couldn\'t make a secure connection. Check your network and your device\'s date and time, then try again.';

	/// en: 'The request was cancelled.'
	String get cancelled => 'The request was cancelled.';

	/// en: 'We couldn't verify your identity. Please sign in again.'
	String get unauthorized => 'We couldn\'t verify your identity. Please sign in again.';

	/// en: 'Your session has expired. Please sign in again.'
	String get sessionExpired => 'Your session has expired. Please sign in again.';

	/// en: 'Your email or password is incorrect. Please check them and try again.'
	String get invalidCredentials => 'Your email or password is incorrect. Please check them and try again.';

	/// en: 'You don't have permission to do this.'
	String get forbidden => 'You don\'t have permission to do this.';

	/// en: 'We couldn't find what you were looking for.'
	String get notFound => 'We couldn\'t find what you were looking for.';

	/// en: 'This is no longer available.'
	String get gone => 'This is no longer available.';

	/// en: 'Please check the highlighted fields and try again.'
	String get validation => 'Please check the highlighted fields and try again.';

	/// en: 'Too many attempts. Please wait a moment and try again.'
	String get rateLimit => 'Too many attempts. Please wait a moment and try again.';

	/// en: 'Too many attempts. Please try again in {wait}.'
	String rateLimitWait({required Object wait}) => 'Too many attempts. Please try again in ${wait}.';

	/// en: '(one) {1 second} (other) {{n} seconds}'
	String waitSeconds({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 second',
		other: '${n} seconds',
	);

	/// en: '(one) {1 minute} (other) {{n} minutes}'
	String waitMinutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 minute',
		other: '${n} minutes',
	);

	/// en: 'We couldn't complete your request. Please try again.'
	String get request => 'We couldn\'t complete your request. Please try again.';

	/// en: 'We couldn't process your request. Please check your input and try again.'
	String get request400 => 'We couldn\'t process your request. Please check your input and try again.';

	/// en: 'This action isn't supported right now. Please update the app or contact support.'
	String get request405 => 'This action isn\'t supported right now. Please update the app or contact support.';

	/// en: 'This conflicts with existing data. Refresh and try again.'
	String get request409 => 'This conflicts with existing data. Refresh and try again.';

	/// en: 'The file or data you're sending is too large.'
	String get request413 => 'The file or data you\'re sending is too large.';

	/// en: 'This item is locked right now. Please try again later.'
	String get request423 => 'This item is locked right now. Please try again later.';

	/// en: 'This content isn't available in your region.'
	String get request451 => 'This content isn\'t available in your region.';

	/// en: 'Something went wrong on our side. Please try again later.'
	String get server => 'Something went wrong on our side. Please try again later.';

	/// en: 'Our servers are having trouble responding. Please try again shortly.'
	String get server502 => 'Our servers are having trouble responding. Please try again shortly.';

	/// en: 'The service is temporarily unavailable. Please try again soon.'
	String get server503 => 'The service is temporarily unavailable. Please try again soon.';

	/// en: 'The service is temporarily unavailable. Please try again in {wait}.'
	String server503Wait({required Object wait}) => 'The service is temporarily unavailable. Please try again in ${wait}.';

	/// en: 'We received unexpected data from the server. Please try again.'
	String get parsing => 'We received unexpected data from the server. Please try again.';

	/// en: 'We couldn't read the saved data on your device.'
	String get cache => 'We couldn\'t read the saved data on your device.';

	/// en: 'We couldn't access secure data on your device. Please sign in again.'
	String get storage => 'We couldn\'t access secure data on your device. Please sign in again.';

	/// en: 'Something unexpected happened. Please try again.'
	String get unknown => 'Something unexpected happened. Please try again.';
}

// Path: validators
class Translations$validators$en {
	Translations$validators$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This field is required.'
	String get required => 'This field is required.';

	/// en: 'Enter a valid email address.'
	String get email => 'Enter a valid email address.';

	/// en: 'Password must be at least 8 characters.'
	String get passwordLength => 'Password must be at least 8 characters.';

	/// en: 'Password must contain an uppercase letter.'
	String get passwordUppercase => 'Password must contain an uppercase letter.';

	/// en: 'Password must contain a lowercase letter.'
	String get passwordLowercase => 'Password must contain a lowercase letter.';

	/// en: 'Password must contain a digit.'
	String get passwordDigit => 'Password must contain a digit.';

	/// en: 'Password must contain a special character.'
	String get passwordSpecial => 'Password must contain a special character.';

	/// en: 'Passwords do not match.'
	String get passwordMismatch => 'Passwords do not match.';

	/// en: 'Use letters only. Spaces, numbers, and symbols aren't allowed.'
	String get name => 'Use letters only. Spaces, numbers, and symbols aren\'t allowed.';

	/// en: 'Enter a valid phone number.'
	String get phone => 'Enter a valid phone number.';

	/// en: 'Enter numbers only.'
	String get numeric => 'Enter numbers only.';
}

// Path: splash
class Translations$splash$en {
	Translations$splash$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Every project. Every team. One orbit.'
	String get tagline => 'Every project. Every team. One orbit.';

	List<String> get taglineWords => [
		'Every',
		'project.',
		'Every',
		'team.',
		'One',
		'orbit.',
	];
	late final Translations$splash$modules$en modules = Translations$splash$modules$en._(_root);

	/// en: 'Orbit startup screen. Five modules orbit the logo and converge into one unified system. Every project. Every team. One orbit.'
	String get accessibilityLabel => 'Orbit startup screen. Five modules orbit the logo and converge into one unified system. Every project. Every team. One orbit.';
}

// Path: onboarding
class Translations$onboarding$en {
	Translations$onboarding$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Get started'
	String get getStarted => 'Get started';

	late final Translations$onboarding$illustration$en illustration = Translations$onboarding$illustration$en._(_root);
	late final Translations$onboarding$slide1$en slide1 = Translations$onboarding$slide1$en._(_root);
	late final Translations$onboarding$slide2$en slide2 = Translations$onboarding$slide2$en._(_root);
	late final Translations$onboarding$slide3$en slide3 = Translations$onboarding$slide3$en._(_root);
	late final Translations$onboarding$slide4$en slide4 = Translations$onboarding$slide4$en._(_root);
	late final Translations$onboarding$a11y$en a11y = Translations$onboarding$a11y$en._(_root);
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$auth$login$en login = Translations$auth$login$en._(_root);
	late final Translations$auth$signup$en signup = Translations$auth$signup$en._(_root);
	late final Translations$auth$pending$en pending = Translations$auth$pending$en._(_root);
}

// Path: crm
class Translations$crm$en {
	Translations$crm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'CRM'
	String get title => 'CRM';

	late final Translations$crm$tabs$en tabs = Translations$crm$tabs$en._(_root);
	late final Translations$crm$editor$en editor = Translations$crm$editor$en._(_root);
	late final Translations$crm$common$en common = Translations$crm$common$en._(_root);
	late final Translations$crm$crmOpportunities$en crmOpportunities = Translations$crm$crmOpportunities$en._(_root);
	late final Translations$crm$crmInteractions$en crmInteractions = Translations$crm$crmInteractions$en._(_root);
	late final Translations$crm$crmNotes$en crmNotes = Translations$crm$crmNotes$en._(_root);
}

// Path: app.homePlaceholder
class Translations$app$homePlaceholder$en {
	Translations$app$homePlaceholder$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home (Placeholder)'
	String get title => 'Home (Placeholder)';

	/// en: 'Home screen not yet implemented'
	String get body => 'Home screen not yet implemented';
}

// Path: app.a11y
class Translations$app$a11y$en {
	Translations$app$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show password'
	String get showPassword => 'Show password';

	/// en: 'Hide password'
	String get hidePassword => 'Hide password';
}

// Path: splash.modules
class Translations$splash$modules$en {
	Translations$splash$modules$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Projects'
	String get projects => 'Projects';

	/// en: 'People'
	String get people => 'People';

	/// en: 'Finance'
	String get finance => 'Finance';

	/// en: 'Clients'
	String get clients => 'Clients';

	/// en: 'Insights'
	String get insights => 'Insights';
}

// Path: onboarding.illustration
class Translations$onboarding$illustration$en {
	Translations$onboarding$illustration$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'EGP {amount}'
	String profitNumber({required Object amount}) => 'EGP ${amount}';
}

// Path: onboarding.slide1
class Translations$onboarding$slide1$en {
	Translations$onboarding$slide1$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Every project, always in view'
	String get headline => 'Every project, always in view';

	/// en: 'Track tasks, timelines, and budgets in real time, and catch delays before they grow.'
	String get body => 'Track tasks, timelines, and budgets in real time, and catch delays before they grow.';
}

// Path: onboarding.slide2
class Translations$onboarding$slide2$en {
	Translations$onboarding$slide2$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your team, right in your pocket'
	String get headline => 'Your team, right in your pocket';

	/// en: 'Check in, request leave, and approve requests from anywhere, in seconds.'
	String get body => 'Check in, request leave, and approve requests from anywhere, in seconds.';
}

// Path: onboarding.slide3
class Translations$onboarding$slide3$en {
	Translations$onboarding$slide3$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'From closed deal to real profit'
	String get headline => 'From closed deal to real profit';

	/// en: 'Won deals become projects automatically, and costs follow the hours your team logs.'
	String get body => 'Won deals become projects automatically, and costs follow the hours your team logs.';
}

// Path: onboarding.slide4
class Translations$onboarding$slide4$en {
	Translations$onboarding$slide4$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Decisions backed by live data'
	String get headline => 'Decisions backed by live data';

	/// en: 'Dashboards and early-warning alerts keep you one step ahead of project risk.'
	String get body => 'Dashboards and early-warning alerts keep you one step ahead of project risk.';
}

// Path: onboarding.a11y
class Translations$onboarding$a11y$en {
	Translations$onboarding$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Skip onboarding'
	String get skipButton => 'Skip onboarding';

	/// en: 'Go to next page'
	String get nextButton => 'Go to next page';

	/// en: 'Go to previous page'
	String get backButton => 'Go to previous page';

	/// en: 'Complete onboarding and continue to login'
	String get getStartedButton => 'Complete onboarding and continue to login';

	/// en: 'Page {current} of {total}'
	String pageIndicator({required Object current, required Object total}) => 'Page ${current} of ${total}';
}

// Path: auth.login
class Translations$auth$login$en {
	Translations$auth$login$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back'
	String get title => 'Welcome back';

	/// en: 'Sign in to pick up where your team left off.'
	String get subtitle => 'Sign in to pick up where your team left off.';

	/// en: 'Work email'
	String get emailLabel => 'Work email';

	/// en: 'you@company.com'
	String get emailHint => 'you@company.com';

	/// en: 'Password'
	String get passwordLabel => 'Password';

	/// en: 'Sign in'
	String get submit => 'Sign in';

	/// en: 'New to Orbit?'
	String get noAccount => 'New to Orbit?';

	/// en: 'Create an account'
	String get createAccount => 'Create an account';

	/// en: 'Couldn't sign you in'
	String get errorTitle => 'Couldn\'t sign you in';

	/// en: 'or'
	String get orDivider => 'or';

	/// en: 'Continue with Google'
	String get googleSignIn => 'Continue with Google';

	/// en: 'Signing in…'
	String get googleSignInLoading => 'Signing in…';

	/// en: 'Couldn't sign you in with Google'
	String get googleSignInError => 'Couldn\'t sign you in with Google';

	late final Translations$auth$login$a11y$en a11y = Translations$auth$login$a11y$en._(_root);
}

// Path: auth.signup
class Translations$auth$signup$en {
	Translations$auth$signup$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create your account'
	String get title => 'Create your account';

	/// en: 'Tell us who you are. Your team will take it from there.'
	String get subtitle => 'Tell us who you are. Your team will take it from there.';

	/// en: 'First name'
	String get firstNameLabel => 'First name';

	/// en: 'Last name'
	String get lastNameLabel => 'Last name';

	/// en: 'Work email'
	String get workEmailLabel => 'Work email';

	/// en: 'you@company.com'
	String get workEmailHint => 'you@company.com';

	/// en: 'Password'
	String get passwordLabel => 'Password';

	/// en: 'Confirm password'
	String get confirmPasswordLabel => 'Confirm password';

	/// en: 'Create account'
	String get submit => 'Create account';

	/// en: 'Already have an account?'
	String get haveAccount => 'Already have an account?';

	/// en: 'Sign in'
	String get signIn => 'Sign in';

	/// en: 'Couldn't create your account'
	String get errorTitle => 'Couldn\'t create your account';

	/// en: 'Your password needs'
	String get checklistTitle => 'Your password needs';

	/// en: 'Password strength'
	String get strengthLabel => 'Password strength';

	late final Translations$auth$signup$requirements$en requirements = Translations$auth$signup$requirements$en._(_root);
	late final Translations$auth$signup$strength$en strength = Translations$auth$signup$strength$en._(_root);
	late final Translations$auth$signup$a11y$en a11y = Translations$auth$signup$a11y$en._(_root);
}

// Path: auth.pending
class Translations$auth$pending$en {
	Translations$auth$pending$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your account is on its way'
	String get title => 'Your account is on its way';

	/// en: 'An admin needs to approve your request before you can sign in.'
	String get subtitle => 'An admin needs to approve your request before you can sign in.';

	/// en: 'Work email'
	String get emailLabel => 'Work email';

	/// en: 'Registered with Google'
	String get registeredWithGoogle => 'Registered with Google';

	/// en: 'Approval status'
	String get statusLabel => 'Approval status';

	late final Translations$auth$pending$statuses$en statuses = Translations$auth$pending$statuses$en._(_root);

	/// en: 'Last checked: never'
	String get lastCheckedNever => 'Last checked: never';

	/// en: 'Last checked: {time}'
	String lastCheckedAt({required Object time}) => 'Last checked: ${time}';

	/// en: 'Check status'
	String get checkStatus => 'Check status';

	/// en: 'You can check again in a moment.'
	String get cooldown => 'You can check again in a moment.';

	/// en: 'No change yet. Your request is still under review.'
	String get unchanged => 'No change yet. Your request is still under review.';

	/// en: 'Couldn't check your status'
	String get errorTitle => 'Couldn\'t check your status';

	/// en: 'Hi, {name}'
	String greeting({required Object name}) => 'Hi, ${name}';

	late final Translations$auth$pending$stepper$en stepper = Translations$auth$pending$stepper$en._(_root);
	late final Translations$auth$pending$moments$en moments = Translations$auth$pending$moments$en._(_root);
	late final Translations$auth$pending$a11y$en a11y = Translations$auth$pending$a11y$en._(_root);
}

// Path: crm.tabs
class Translations$crm$tabs$en {
	Translations$crm$tabs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Opportunities'
	String get opportunities => 'Opportunities';

	/// en: 'Interactions'
	String get interactions => 'Interactions';
}

// Path: crm.editor
class Translations$crm$editor$en {
	Translations$crm$editor$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log interaction'
	String get titleAdd => 'Log interaction';

	/// en: 'Edit interaction'
	String get titleEdit => 'Edit interaction';

	/// en: 'Type'
	String get type => 'Type';

	/// en: 'Subject'
	String get subject => 'Subject';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Contact (optional)'
	String get contactOptional => 'Contact (optional)';

	/// en: 'None'
	String get contactNone => 'None';

	/// en: 'Call'
	String get typeCall => 'Call';

	/// en: 'Email'
	String get typeEmail => 'Email';

	/// en: 'Meeting'
	String get typeMeeting => 'Meeting';

	/// en: 'Save'
	String get submit => 'Save';

	/// en: 'Subject is required'
	String get subjectRequired => 'Subject is required';

	/// en: 'Date is required'
	String get dateRequired => 'Date is required';

	/// en: 'Discard changes?'
	String get discardTitle => 'Discard changes?';

	/// en: 'You have unsaved changes. Discard them?'
	String get discardBody => 'You have unsaved changes. Discard them?';
}

// Path: crm.common
class Translations$crm$common$en {
	Translations$crm$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Loading…'
	String get loading => 'Loading…';

	/// en: 'Clear filters'
	String get clearFilters => 'Clear filters';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Yesterday'
	String get yesterday => 'Yesterday';

	/// en: 'End of list'
	String get endOfList => 'End of list';

	/// en: 'Refresh failed — previous data kept'
	String get refreshFailedNotice => 'Refresh failed — previous data kept';

	/// en: 'Dismiss'
	String get dismiss => 'Dismiss';

	/// en: 'Call'
	String get call => 'Call';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'More actions'
	String get moreActions => 'More actions';

	/// en: 'Couldn't launch {app}. Try again later.'
	String launchFailed({required Object app}) => 'Couldn\'t launch ${app}. Try again later.';

	/// en: '{n} active filters'
	String activeFilters({required Object n}) => '${n} active filters';

	/// en: 'Updated'
	String get updated => 'Updated';

	/// en: 'Saved'
	String get saved => 'Saved';

	/// en: 'Deleted'
	String get deleted => 'Deleted';

	/// en: 'Invalid opportunity ID'
	String get invalidId => 'Invalid opportunity ID';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Not found'
	String get notFound => 'Not found';

	late final Translations$crm$common$a11y$en a11y = Translations$crm$common$a11y$en._(_root);
}

// Path: crm.crmOpportunities
class Translations$crm$crmOpportunities$en {
	Translations$crm$crmOpportunities$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search opportunities by title'
	String get searchHint => 'Search opportunities by title';

	/// en: 'Filter by stage'
	String get filterTitle => 'Filter by stage';

	late final Translations$crm$crmOpportunities$status$en status = Translations$crm$crmOpportunities$status$en._(_root);
	late final Translations$crm$crmOpportunities$stage$en stage = Translations$crm$crmOpportunities$stage$en._(_root);
	late final Translations$crm$crmOpportunities$card$en card = Translations$crm$crmOpportunities$card$en._(_root);

	/// en: 'No opportunities'
	String get listEmpty => 'No opportunities';

	/// en: 'No opportunities match your filters'
	String get listNoResults => 'No opportunities match your filters';

	/// en: '1 opportunity'
	String get listOpportunityCountOne => '1 opportunity';

	/// en: '{n} opportunities'
	String listOpportunityCountOther({required Object n}) => '${n} opportunities';

	late final Translations$crm$crmOpportunities$detail$en detail = Translations$crm$crmOpportunities$detail$en._(_root);
}

// Path: crm.crmInteractions
class Translations$crm$crmInteractions$en {
	Translations$crm$crmInteractions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search interactions by subject or description'
	String get searchHint => 'Search interactions by subject or description';

	late final Translations$crm$crmInteractions$type$en type = Translations$crm$crmInteractions$type$en._(_root);
	late final Translations$crm$crmInteractions$item$en item = Translations$crm$crmInteractions$item$en._(_root);

	/// en: 'No interactions'
	String get feedEmpty => 'No interactions';

	/// en: 'Interactions you add will appear here.'
	String get feedEmptyMessage => 'Interactions you add will appear here.';

	/// en: 'No interactions match your filters'
	String get feedNoResults => 'No interactions match your filters';

	/// en: 'Loading interactions…'
	String get loading => 'Loading interactions…';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'No interactions logged'
	String get interactionsEmpty => 'No interactions logged';

	late final Translations$crm$crmInteractions$deleteConfirm$en deleteConfirm = Translations$crm$crmInteractions$deleteConfirm$en._(_root);
}

// Path: crm.crmNotes
class Translations$crm$crmNotes$en {
	Translations$crm$crmNotes$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get threadTitle => 'Notes';

	/// en: '1 note'
	String get countOne => '1 note';

	/// en: '{n} notes'
	String countOther({required Object n}) => '${n} notes';

	/// en: 'Loading notes…'
	String get loading => 'Loading notes…';

	/// en: 'Notes you add for this customer will appear here.'
	String get emptyMessage => 'Notes you add for this customer will appear here.';

	/// en: 'Note'
	String get composerLabel => 'Note';

	/// en: 'Add a note…'
	String get composerHint => 'Add a note…';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Send note'
	String get sendA11y => 'Send note';

	/// en: 'Sending note'
	String get sending => 'Sending note';

	/// en: 'Note sent'
	String get sent => 'Note sent';

	/// en: 'Couldn't send the note. Try again.'
	String get sendFailed => 'Couldn\'t send the note. Try again.';

	/// en: 'Show more'
	String get showMore => 'Show more';

	/// en: 'Show less'
	String get showLess => 'Show less';

	/// en: 'Discard'
	String get discard => 'Discard';

	/// en: 'Note actions'
	String get moreActions => 'Note actions';

	/// en: '{relative}, {date}'
	String timestampA11y({required Object relative, required Object date}) => '${relative}, ${date}';

	/// en: 'Couldn't refresh notes. Showing the last loaded notes.'
	String get refreshFailed => 'Couldn\'t refresh notes. Showing the last loaded notes.';

	/// en: 'No notes yet'
	String get empty => 'No notes yet';

	/// en: 'Edit note'
	String get edit => 'Edit note';

	/// en: 'Delete note'
	String get delete => 'Delete note';

	late final Translations$crm$crmNotes$deleteConfirm$en deleteConfirm = Translations$crm$crmNotes$deleteConfirm$en._(_root);
	late final Translations$crm$crmNotes$relative$en relative = Translations$crm$crmNotes$relative$en._(_root);
}

// Path: auth.login.a11y
class Translations$auth$login$a11y$en {
	Translations$auth$login$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in to your account'
	String get submit => 'Sign in to your account';

	/// en: 'Sign in with your Google account'
	String get googleSignIn => 'Sign in with your Google account';
}

// Path: auth.signup.requirements
class Translations$auth$signup$requirements$en {
	Translations$auth$signup$requirements$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'At least {n} characters'
	String minLength({required Object n}) => 'At least ${n} characters';

	/// en: 'One uppercase letter'
	String get uppercase => 'One uppercase letter';

	/// en: 'One lowercase letter'
	String get lowercase => 'One lowercase letter';

	/// en: 'One number'
	String get digit => 'One number';

	/// en: 'One special character'
	String get special => 'One special character';
}

// Path: auth.signup.strength
class Translations$auth$signup$strength$en {
	Translations$auth$signup$strength$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Weak'
	String get weak => 'Weak';

	/// en: 'Fair'
	String get fair => 'Fair';

	/// en: 'Good'
	String get good => 'Good';

	/// en: 'Strong'
	String get strong => 'Strong';
}

// Path: auth.signup.a11y
class Translations$auth$signup$a11y$en {
	Translations$auth$signup$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create your account'
	String get submit => 'Create your account';

	/// en: 'Met'
	String get ruleMet => 'Met';

	/// en: 'Not met yet'
	String get ruleNotMet => 'Not met yet';
}

// Path: auth.pending.statuses
class Translations$auth$pending$statuses$en {
	Translations$auth$pending$statuses$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pending approval'
	String get pending => 'Pending approval';

	/// en: 'Approved'
	String get approved => 'Approved';

	/// en: 'Not approved'
	String get rejected => 'Not approved';

	/// en: 'Under review'
	String get unknown => 'Under review';
}

// Path: auth.pending.stepper
class Translations$auth$pending$stepper$en {
	Translations$auth$pending$stepper$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Submitted'
	String get submitted => 'Submitted';

	/// en: 'In review'
	String get review => 'In review';

	/// en: 'Decision'
	String get decision => 'Decision';
}

// Path: auth.pending.moments
class Translations$auth$pending$moments$en {
	Translations$auth$pending$moments$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You're approved. Taking you to sign in.'
	String get approved => 'You\'re approved. Taking you to sign in.';

	/// en: 'This request wasn't approved. Taking you back to sign up.'
	String get rejected => 'This request wasn\'t approved. Taking you back to sign up.';
}

// Path: auth.pending.a11y
class Translations$auth$pending$a11y$en {
	Translations$auth$pending$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Orbit approval status'
	String get hero => 'Orbit approval status';

	/// en: 'Approval progress'
	String get stepper => 'Approval progress';

	/// en: 'Check your approval status'
	String get checkStatus => 'Check your approval status';
}

// Path: crm.common.a11y
class Translations$crm$common$a11y$en {
	Translations$crm$common$a11y$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Clear search'
	String get clearSearch => 'Clear search';

	/// en: 'Filters'
	String get filterButton => 'Filters';

	/// en: 'Selected'
	String get chipSelected => 'Selected';
}

// Path: crm.crmOpportunities.status
class Translations$crm$crmOpportunities$status$en {
	Translations$crm$crmOpportunities$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Open'
	String get open => 'Open';

	/// en: 'Won'
	String get won => 'Won';

	/// en: 'Lost'
	String get lost => 'Lost';
}

// Path: crm.crmOpportunities.stage
class Translations$crm$crmOpportunities$stage$en {
	Translations$crm$crmOpportunities$stage$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Lead'
	String get lead => 'Lead';

	/// en: 'Qualified'
	String get qualified => 'Qualified';

	/// en: 'Proposal'
	String get proposal => 'Proposal';

	/// en: 'Negotiation'
	String get negotiation => 'Negotiation';

	/// en: 'Closed'
	String get closed => 'Closed';
}

// Path: crm.crmOpportunities.card
class Translations$crm$crmOpportunities$card$en {
	Translations$crm$crmOpportunities$card$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overdue'
	String get overdue => 'Overdue';

	/// en: 'Estimated value'
	String get valueA11y => 'Estimated value';

	/// en: 'Probability'
	String get probabilityA11y => 'Probability';
}

// Path: crm.crmOpportunities.detail
class Translations$crm$crmOpportunities$detail$en {
	Translations$crm$crmOpportunities$detail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$crm$crmOpportunities$detail$tabs$en tabs = Translations$crm$crmOpportunities$detail$tabs$en._(_root);

	/// en: 'Open'
	String get statusOpen => 'Open';

	/// en: 'Won'
	String get statusWon => 'Won';

	/// en: 'Lost'
	String get statusLost => 'Lost';

	/// en: 'No reason recorded'
	String get lostReasonEmpty => 'No reason recorded';

	late final Translations$crm$crmOpportunities$detail$facts$en facts = Translations$crm$crmOpportunities$detail$facts$en._(_root);
	late final Translations$crm$crmOpportunities$detail$contacts$en contacts = Translations$crm$crmOpportunities$detail$contacts$en._(_root);

	/// en: 'No contacts for this customer'
	String get contactsEmpty => 'No contacts for this customer';

	/// en: 'No interactions logged'
	String get interactionsEmpty => 'No interactions logged';

	/// en: 'No notes yet'
	String get notesEmpty => 'No notes yet';

	late final Translations$crm$crmOpportunities$detail$logIt$en logIt = Translations$crm$crmOpportunities$detail$logIt$en._(_root);
}

// Path: crm.crmInteractions.type
class Translations$crm$crmInteractions$type$en {
	Translations$crm$crmInteractions$type$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All'
	String get all => 'All';

	/// en: 'Call'
	String get call => 'Call';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Meeting'
	String get meeting => 'Meeting';
}

// Path: crm.crmInteractions.item
class Translations$crm$crmInteractions$item$en {
	Translations$crm$crmInteractions$item$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No description'
	String get noDescription => 'No description';

	/// en: 'Opportunity'
	String get openOpportunity => 'Opportunity';
}

// Path: crm.crmInteractions.deleteConfirm
class Translations$crm$crmInteractions$deleteConfirm$en {
	Translations$crm$crmInteractions$deleteConfirm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete interaction?'
	String get title => 'Delete interaction?';

	/// en: 'This interaction will be removed permanently.'
	String get body => 'This interaction will be removed permanently.';
}

// Path: crm.crmNotes.deleteConfirm
class Translations$crm$crmNotes$deleteConfirm$en {
	Translations$crm$crmNotes$deleteConfirm$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete note?'
	String get title => 'Delete note?';

	/// en: 'This note will be removed permanently.'
	String get body => 'This note will be removed permanently.';
}

// Path: crm.crmNotes.relative
class Translations$crm$crmNotes$relative$en {
	Translations$crm$crmNotes$relative$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Just now'
	String get now => 'Just now';

	/// en: '1 minute ago'
	String get minuteAgo => '1 minute ago';

	/// en: '{n} minutes ago'
	String minutesAgo({required Object n}) => '${n} minutes ago';

	/// en: '1 hour ago'
	String get hourAgo => '1 hour ago';

	/// en: '{n} hours ago'
	String hoursAgo({required Object n}) => '${n} hours ago';

	/// en: '1 day ago'
	String get dayAgo => '1 day ago';

	/// en: '{n} days ago'
	String daysAgo({required Object n}) => '${n} days ago';
}

// Path: crm.crmOpportunities.detail.tabs
class Translations$crm$crmOpportunities$detail$tabs$en {
	Translations$crm$crmOpportunities$detail$tabs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Contacts'
	String get contacts => 'Contacts';

	/// en: 'Interactions'
	String get interactions => 'Interactions';

	/// en: 'Notes'
	String get notes => 'Notes';
}

// Path: crm.crmOpportunities.detail.facts
class Translations$crm$crmOpportunities$detail$facts$en {
	Translations$crm$crmOpportunities$detail$facts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Created'
	String get created => 'Created';

	/// en: 'Expected close'
	String get expectedClose => 'Expected close';

	/// en: 'Closed'
	String get closedAt => 'Closed';

	/// en: 'Owner'
	String get owner => 'Owner';

	/// en: 'Lead source'
	String get leadSource => 'Lead source';

	/// en: 'Customer code'
	String get customerCode => 'Customer code';

	/// en: 'Company'
	String get company => 'Company';

	/// en: 'Address'
	String get address => 'Address';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Stage'
	String get stage => 'Stage';

	/// en: 'Probability'
	String get probability => 'Probability';
}

// Path: crm.crmOpportunities.detail.contacts
class Translations$crm$crmOpportunities$detail$contacts$en {
	Translations$crm$crmOpportunities$detail$contacts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Primary'
	String get primary => 'Primary';

	/// en: 'No contacts'
	String get empty => 'No contacts';
}

// Path: crm.crmOpportunities.detail.logIt
class Translations$crm$crmOpportunities$detail$logIt$en {
	Translations$crm$crmOpportunities$detail$logIt$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log this call?'
	String get callTitle => 'Log this call?';

	/// en: 'Log this email?'
	String get emailTitle => 'Log this email?';

	/// en: 'Log this interaction under this opportunity?'
	String get body => 'Log this interaction under this opportunity?';

	/// en: 'Log it'
	String get log => 'Log it';

	/// en: 'Not now'
	String get notNow => 'Not now';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'Orbit',
			'app.homePlaceholder.title' => 'Home (Placeholder)',
			'app.homePlaceholder.body' => 'Home screen not yet implemented',
			'app.a11y.showPassword' => 'Show password',
			'app.a11y.hidePassword' => 'Hide password',
			'home.title' => 'Home',
			'errors.offline' => 'You\'re offline. Check your internet connection and try again.',
			'errors.unreachable' => 'We couldn\'t reach the server. Please try again in a moment.',
			'errors.timeout' => 'The server is taking too long to respond. Please try again.',
			'errors.certificate' => 'We couldn\'t make a secure connection. Check your network and your device\'s date and time, then try again.',
			'errors.cancelled' => 'The request was cancelled.',
			'errors.unauthorized' => 'We couldn\'t verify your identity. Please sign in again.',
			'errors.sessionExpired' => 'Your session has expired. Please sign in again.',
			'errors.invalidCredentials' => 'Your email or password is incorrect. Please check them and try again.',
			'errors.forbidden' => 'You don\'t have permission to do this.',
			'errors.notFound' => 'We couldn\'t find what you were looking for.',
			'errors.gone' => 'This is no longer available.',
			'errors.validation' => 'Please check the highlighted fields and try again.',
			'errors.rateLimit' => 'Too many attempts. Please wait a moment and try again.',
			'errors.rateLimitWait' => ({required Object wait}) => 'Too many attempts. Please try again in ${wait}.',
			'errors.waitSeconds' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 second', other: '${n} seconds', ), 
			'errors.waitMinutes' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 minute', other: '${n} minutes', ), 
			'errors.request' => 'We couldn\'t complete your request. Please try again.',
			'errors.request400' => 'We couldn\'t process your request. Please check your input and try again.',
			'errors.request405' => 'This action isn\'t supported right now. Please update the app or contact support.',
			'errors.request409' => 'This conflicts with existing data. Refresh and try again.',
			'errors.request413' => 'The file or data you\'re sending is too large.',
			'errors.request423' => 'This item is locked right now. Please try again later.',
			'errors.request451' => 'This content isn\'t available in your region.',
			'errors.server' => 'Something went wrong on our side. Please try again later.',
			'errors.server502' => 'Our servers are having trouble responding. Please try again shortly.',
			'errors.server503' => 'The service is temporarily unavailable. Please try again soon.',
			'errors.server503Wait' => ({required Object wait}) => 'The service is temporarily unavailable. Please try again in ${wait}.',
			'errors.parsing' => 'We received unexpected data from the server. Please try again.',
			'errors.cache' => 'We couldn\'t read the saved data on your device.',
			'errors.storage' => 'We couldn\'t access secure data on your device. Please sign in again.',
			'errors.unknown' => 'Something unexpected happened. Please try again.',
			'validators.required' => 'This field is required.',
			'validators.email' => 'Enter a valid email address.',
			'validators.passwordLength' => 'Password must be at least 8 characters.',
			'validators.passwordUppercase' => 'Password must contain an uppercase letter.',
			'validators.passwordLowercase' => 'Password must contain a lowercase letter.',
			'validators.passwordDigit' => 'Password must contain a digit.',
			'validators.passwordSpecial' => 'Password must contain a special character.',
			'validators.passwordMismatch' => 'Passwords do not match.',
			'validators.name' => 'Use letters only. Spaces, numbers, and symbols aren\'t allowed.',
			'validators.phone' => 'Enter a valid phone number.',
			'validators.numeric' => 'Enter numbers only.',
			'splash.tagline' => 'Every project. Every team. One orbit.',
			'splash.taglineWords.0' => 'Every',
			'splash.taglineWords.1' => 'project.',
			'splash.taglineWords.2' => 'Every',
			'splash.taglineWords.3' => 'team.',
			'splash.taglineWords.4' => 'One',
			'splash.taglineWords.5' => 'orbit.',
			'splash.modules.projects' => 'Projects',
			'splash.modules.people' => 'People',
			'splash.modules.finance' => 'Finance',
			'splash.modules.clients' => 'Clients',
			'splash.modules.insights' => 'Insights',
			'splash.accessibilityLabel' => 'Orbit startup screen. Five modules orbit the logo and converge into one unified system. Every project. Every team. One orbit.',
			'onboarding.skip' => 'Skip',
			'onboarding.next' => 'Next',
			'onboarding.back' => 'Back',
			'onboarding.getStarted' => 'Get started',
			'onboarding.illustration.profitNumber' => ({required Object amount}) => 'EGP ${amount}',
			'onboarding.slide1.headline' => 'Every project, always in view',
			'onboarding.slide1.body' => 'Track tasks, timelines, and budgets in real time, and catch delays before they grow.',
			'onboarding.slide2.headline' => 'Your team, right in your pocket',
			'onboarding.slide2.body' => 'Check in, request leave, and approve requests from anywhere, in seconds.',
			'onboarding.slide3.headline' => 'From closed deal to real profit',
			'onboarding.slide3.body' => 'Won deals become projects automatically, and costs follow the hours your team logs.',
			'onboarding.slide4.headline' => 'Decisions backed by live data',
			'onboarding.slide4.body' => 'Dashboards and early-warning alerts keep you one step ahead of project risk.',
			'onboarding.a11y.skipButton' => 'Skip onboarding',
			'onboarding.a11y.nextButton' => 'Go to next page',
			'onboarding.a11y.backButton' => 'Go to previous page',
			'onboarding.a11y.getStartedButton' => 'Complete onboarding and continue to login',
			'onboarding.a11y.pageIndicator' => ({required Object current, required Object total}) => 'Page ${current} of ${total}',
			'auth.login.title' => 'Welcome back',
			'auth.login.subtitle' => 'Sign in to pick up where your team left off.',
			'auth.login.emailLabel' => 'Work email',
			'auth.login.emailHint' => 'you@company.com',
			'auth.login.passwordLabel' => 'Password',
			'auth.login.submit' => 'Sign in',
			'auth.login.noAccount' => 'New to Orbit?',
			'auth.login.createAccount' => 'Create an account',
			'auth.login.errorTitle' => 'Couldn\'t sign you in',
			'auth.login.orDivider' => 'or',
			'auth.login.googleSignIn' => 'Continue with Google',
			'auth.login.googleSignInLoading' => 'Signing in…',
			'auth.login.googleSignInError' => 'Couldn\'t sign you in with Google',
			'auth.login.a11y.submit' => 'Sign in to your account',
			'auth.login.a11y.googleSignIn' => 'Sign in with your Google account',
			'auth.signup.title' => 'Create your account',
			'auth.signup.subtitle' => 'Tell us who you are. Your team will take it from there.',
			'auth.signup.firstNameLabel' => 'First name',
			'auth.signup.lastNameLabel' => 'Last name',
			'auth.signup.workEmailLabel' => 'Work email',
			'auth.signup.workEmailHint' => 'you@company.com',
			'auth.signup.passwordLabel' => 'Password',
			'auth.signup.confirmPasswordLabel' => 'Confirm password',
			'auth.signup.submit' => 'Create account',
			'auth.signup.haveAccount' => 'Already have an account?',
			'auth.signup.signIn' => 'Sign in',
			'auth.signup.errorTitle' => 'Couldn\'t create your account',
			'auth.signup.checklistTitle' => 'Your password needs',
			'auth.signup.strengthLabel' => 'Password strength',
			'auth.signup.requirements.minLength' => ({required Object n}) => 'At least ${n} characters',
			'auth.signup.requirements.uppercase' => 'One uppercase letter',
			'auth.signup.requirements.lowercase' => 'One lowercase letter',
			'auth.signup.requirements.digit' => 'One number',
			'auth.signup.requirements.special' => 'One special character',
			'auth.signup.strength.weak' => 'Weak',
			'auth.signup.strength.fair' => 'Fair',
			'auth.signup.strength.good' => 'Good',
			'auth.signup.strength.strong' => 'Strong',
			'auth.signup.a11y.submit' => 'Create your account',
			'auth.signup.a11y.ruleMet' => 'Met',
			'auth.signup.a11y.ruleNotMet' => 'Not met yet',
			'auth.pending.title' => 'Your account is on its way',
			'auth.pending.subtitle' => 'An admin needs to approve your request before you can sign in.',
			'auth.pending.emailLabel' => 'Work email',
			'auth.pending.registeredWithGoogle' => 'Registered with Google',
			'auth.pending.statusLabel' => 'Approval status',
			'auth.pending.statuses.pending' => 'Pending approval',
			'auth.pending.statuses.approved' => 'Approved',
			'auth.pending.statuses.rejected' => 'Not approved',
			'auth.pending.statuses.unknown' => 'Under review',
			'auth.pending.lastCheckedNever' => 'Last checked: never',
			'auth.pending.lastCheckedAt' => ({required Object time}) => 'Last checked: ${time}',
			'auth.pending.checkStatus' => 'Check status',
			'auth.pending.cooldown' => 'You can check again in a moment.',
			'auth.pending.unchanged' => 'No change yet. Your request is still under review.',
			'auth.pending.errorTitle' => 'Couldn\'t check your status',
			'auth.pending.greeting' => ({required Object name}) => 'Hi, ${name}',
			'auth.pending.stepper.submitted' => 'Submitted',
			'auth.pending.stepper.review' => 'In review',
			'auth.pending.stepper.decision' => 'Decision',
			'auth.pending.moments.approved' => 'You\'re approved. Taking you to sign in.',
			'auth.pending.moments.rejected' => 'This request wasn\'t approved. Taking you back to sign up.',
			'auth.pending.a11y.hero' => 'Orbit approval status',
			'auth.pending.a11y.stepper' => 'Approval progress',
			'auth.pending.a11y.checkStatus' => 'Check your approval status',
			'crm.title' => 'CRM',
			'crm.tabs.opportunities' => 'Opportunities',
			'crm.tabs.interactions' => 'Interactions',
			'crm.editor.titleAdd' => 'Log interaction',
			'crm.editor.titleEdit' => 'Edit interaction',
			'crm.editor.type' => 'Type',
			'crm.editor.subject' => 'Subject',
			'crm.editor.description' => 'Description',
			'crm.editor.date' => 'Date',
			'crm.editor.contactOptional' => 'Contact (optional)',
			'crm.editor.contactNone' => 'None',
			'crm.editor.typeCall' => 'Call',
			'crm.editor.typeEmail' => 'Email',
			'crm.editor.typeMeeting' => 'Meeting',
			'crm.editor.submit' => 'Save',
			'crm.editor.subjectRequired' => 'Subject is required',
			'crm.editor.dateRequired' => 'Date is required',
			'crm.editor.discardTitle' => 'Discard changes?',
			'crm.editor.discardBody' => 'You have unsaved changes. Discard them?',
			'crm.common.retry' => 'Retry',
			'crm.common.loading' => 'Loading…',
			'crm.common.clearFilters' => 'Clear filters',
			'crm.common.cancel' => 'Cancel',
			'crm.common.save' => 'Save',
			'crm.common.delete' => 'Delete',
			'crm.common.edit' => 'Edit',
			'crm.common.today' => 'Today',
			'crm.common.yesterday' => 'Yesterday',
			'crm.common.endOfList' => 'End of list',
			'crm.common.refreshFailedNotice' => 'Refresh failed — previous data kept',
			'crm.common.dismiss' => 'Dismiss',
			'crm.common.call' => 'Call',
			'crm.common.email' => 'Email',
			'crm.common.moreActions' => 'More actions',
			'crm.common.launchFailed' => ({required Object app}) => 'Couldn\'t launch ${app}. Try again later.',
			'crm.common.activeFilters' => ({required Object n}) => '${n} active filters',
			'crm.common.updated' => 'Updated',
			'crm.common.saved' => 'Saved',
			'crm.common.deleted' => 'Deleted',
			'crm.common.invalidId' => 'Invalid opportunity ID',
			'crm.common.back' => 'Back',
			'crm.common.notFound' => 'Not found',
			'crm.common.a11y.search' => 'Search',
			'crm.common.a11y.clearSearch' => 'Clear search',
			'crm.common.a11y.filterButton' => 'Filters',
			'crm.common.a11y.chipSelected' => 'Selected',
			'crm.crmOpportunities.searchHint' => 'Search opportunities by title',
			'crm.crmOpportunities.filterTitle' => 'Filter by stage',
			'crm.crmOpportunities.status.all' => 'All',
			'crm.crmOpportunities.status.open' => 'Open',
			'crm.crmOpportunities.status.won' => 'Won',
			'crm.crmOpportunities.status.lost' => 'Lost',
			'crm.crmOpportunities.stage.all' => 'All',
			'crm.crmOpportunities.stage.lead' => 'Lead',
			'crm.crmOpportunities.stage.qualified' => 'Qualified',
			'crm.crmOpportunities.stage.proposal' => 'Proposal',
			'crm.crmOpportunities.stage.negotiation' => 'Negotiation',
			'crm.crmOpportunities.stage.closed' => 'Closed',
			'crm.crmOpportunities.card.overdue' => 'Overdue',
			'crm.crmOpportunities.card.valueA11y' => 'Estimated value',
			'crm.crmOpportunities.card.probabilityA11y' => 'Probability',
			'crm.crmOpportunities.listEmpty' => 'No opportunities',
			'crm.crmOpportunities.listNoResults' => 'No opportunities match your filters',
			'crm.crmOpportunities.listOpportunityCountOne' => '1 opportunity',
			'crm.crmOpportunities.listOpportunityCountOther' => ({required Object n}) => '${n} opportunities',
			'crm.crmOpportunities.detail.tabs.overview' => 'Overview',
			'crm.crmOpportunities.detail.tabs.contacts' => 'Contacts',
			'crm.crmOpportunities.detail.tabs.interactions' => 'Interactions',
			'crm.crmOpportunities.detail.tabs.notes' => 'Notes',
			'crm.crmOpportunities.detail.statusOpen' => 'Open',
			'crm.crmOpportunities.detail.statusWon' => 'Won',
			'crm.crmOpportunities.detail.statusLost' => 'Lost',
			'crm.crmOpportunities.detail.lostReasonEmpty' => 'No reason recorded',
			'crm.crmOpportunities.detail.facts.created' => 'Created',
			'crm.crmOpportunities.detail.facts.expectedClose' => 'Expected close',
			'crm.crmOpportunities.detail.facts.closedAt' => 'Closed',
			'crm.crmOpportunities.detail.facts.owner' => 'Owner',
			'crm.crmOpportunities.detail.facts.leadSource' => 'Lead source',
			'crm.crmOpportunities.detail.facts.customerCode' => 'Customer code',
			'crm.crmOpportunities.detail.facts.company' => 'Company',
			'crm.crmOpportunities.detail.facts.address' => 'Address',
			'crm.crmOpportunities.detail.facts.phone' => 'Phone',
			'crm.crmOpportunities.detail.facts.email' => 'Email',
			'crm.crmOpportunities.detail.facts.stage' => 'Stage',
			'crm.crmOpportunities.detail.facts.probability' => 'Probability',
			'crm.crmOpportunities.detail.contacts.primary' => 'Primary',
			'crm.crmOpportunities.detail.contacts.empty' => 'No contacts',
			'crm.crmOpportunities.detail.contactsEmpty' => 'No contacts for this customer',
			'crm.crmOpportunities.detail.interactionsEmpty' => 'No interactions logged',
			'crm.crmOpportunities.detail.notesEmpty' => 'No notes yet',
			'crm.crmOpportunities.detail.logIt.callTitle' => 'Log this call?',
			'crm.crmOpportunities.detail.logIt.emailTitle' => 'Log this email?',
			'crm.crmOpportunities.detail.logIt.body' => 'Log this interaction under this opportunity?',
			'crm.crmOpportunities.detail.logIt.log' => 'Log it',
			'crm.crmOpportunities.detail.logIt.notNow' => 'Not now',
			'crm.crmInteractions.searchHint' => 'Search interactions by subject or description',
			'crm.crmInteractions.type.all' => 'All',
			'crm.crmInteractions.type.call' => 'Call',
			'crm.crmInteractions.type.email' => 'Email',
			'crm.crmInteractions.type.meeting' => 'Meeting',
			'crm.crmInteractions.item.noDescription' => 'No description',
			'crm.crmInteractions.item.openOpportunity' => 'Opportunity',
			'crm.crmInteractions.feedEmpty' => 'No interactions',
			'crm.crmInteractions.feedEmptyMessage' => 'Interactions you add will appear here.',
			'crm.crmInteractions.feedNoResults' => 'No interactions match your filters',
			'crm.crmInteractions.loading' => 'Loading interactions…',
			'crm.crmInteractions.edit' => 'Edit',
			'crm.crmInteractions.delete' => 'Delete',
			'crm.crmInteractions.interactionsEmpty' => 'No interactions logged',
			'crm.crmInteractions.deleteConfirm.title' => 'Delete interaction?',
			'crm.crmInteractions.deleteConfirm.body' => 'This interaction will be removed permanently.',
			'crm.crmNotes.threadTitle' => 'Notes',
			'crm.crmNotes.countOne' => '1 note',
			'crm.crmNotes.countOther' => ({required Object n}) => '${n} notes',
			'crm.crmNotes.loading' => 'Loading notes…',
			'crm.crmNotes.emptyMessage' => 'Notes you add for this customer will appear here.',
			'crm.crmNotes.composerLabel' => 'Note',
			'crm.crmNotes.composerHint' => 'Add a note…',
			'crm.crmNotes.send' => 'Send',
			'crm.crmNotes.sendA11y' => 'Send note',
			'crm.crmNotes.sending' => 'Sending note',
			'crm.crmNotes.sent' => 'Note sent',
			'crm.crmNotes.sendFailed' => 'Couldn\'t send the note. Try again.',
			'crm.crmNotes.showMore' => 'Show more',
			'crm.crmNotes.showLess' => 'Show less',
			'crm.crmNotes.discard' => 'Discard',
			'crm.crmNotes.moreActions' => 'Note actions',
			'crm.crmNotes.timestampA11y' => ({required Object relative, required Object date}) => '${relative}, ${date}',
			'crm.crmNotes.refreshFailed' => 'Couldn\'t refresh notes. Showing the last loaded notes.',
			'crm.crmNotes.empty' => 'No notes yet',
			'crm.crmNotes.edit' => 'Edit note',
			'crm.crmNotes.delete' => 'Delete note',
			'crm.crmNotes.deleteConfirm.title' => 'Delete note?',
			'crm.crmNotes.deleteConfirm.body' => 'This note will be removed permanently.',
			'crm.crmNotes.relative.now' => 'Just now',
			'crm.crmNotes.relative.minuteAgo' => '1 minute ago',
			'crm.crmNotes.relative.minutesAgo' => ({required Object n}) => '${n} minutes ago',
			'crm.crmNotes.relative.hourAgo' => '1 hour ago',
			'crm.crmNotes.relative.hoursAgo' => ({required Object n}) => '${n} hours ago',
			'crm.crmNotes.relative.dayAgo' => '1 day ago',
			'crm.crmNotes.relative.daysAgo' => ({required Object n}) => '${n} days ago',
			_ => null,
		};
	}
}
