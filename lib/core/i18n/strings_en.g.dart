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
}

// Path: app
class Translations$app$en {
	Translations$app$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Orbit'
	String get title => 'Orbit';

	late final Translations$app$loginPlaceholder$en loginPlaceholder = Translations$app$loginPlaceholder$en._(_root);
	late final Translations$app$homePlaceholder$en homePlaceholder = Translations$app$homePlaceholder$en._(_root);
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

	/// en: 'Passwords do not match.'
	String get passwordMismatch => 'Passwords do not match.';

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

// Path: app.loginPlaceholder
class Translations$app$loginPlaceholder$en {
	Translations$app$loginPlaceholder$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login (Placeholder)'
	String get title => 'Login (Placeholder)';

	/// en: 'Login screen not yet implemented'
	String get body => 'Login screen not yet implemented';
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

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'Orbit',
			'app.loginPlaceholder.title' => 'Login (Placeholder)',
			'app.loginPlaceholder.body' => 'Login screen not yet implemented',
			'app.homePlaceholder.title' => 'Home (Placeholder)',
			'app.homePlaceholder.body' => 'Home screen not yet implemented',
			'home.title' => 'Home',
			'errors.offline' => 'You\'re offline. Check your internet connection and try again.',
			'errors.unreachable' => 'We couldn\'t reach the server. Please try again in a moment.',
			'errors.timeout' => 'The server is taking too long to respond. Please try again.',
			'errors.certificate' => 'We couldn\'t make a secure connection. Check your network and your device\'s date and time, then try again.',
			'errors.cancelled' => 'The request was cancelled.',
			'errors.unauthorized' => 'We couldn\'t verify your identity. Please sign in again.',
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
			'validators.passwordMismatch' => 'Passwords do not match.',
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
			_ => null,
		};
	}
}
