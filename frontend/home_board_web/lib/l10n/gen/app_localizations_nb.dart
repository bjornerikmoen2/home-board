// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Familieoppgaver';

  @override
  String userTasksTitle(String name) {
    return '${name}s oppgaver';
  }

  @override
  String get login => 'Logg inn';

  @override
  String get logout => 'Logg ut';

  @override
  String get username => 'Brukernavn';

  @override
  String get password => 'Passord';

  @override
  String get loginButton => 'Logg inn';

  @override
  String get usernameRequired => 'Vennligst skriv inn brukernavn';

  @override
  String get passwordRequired => 'Vennligst skriv inn passord';

  @override
  String get loginFailed => 'Pålogging mislyktes. Vennligst sjekk påloggingsinformasjonen din.';

  @override
  String get selectUser => 'Velg bruker';

  @override
  String get or => 'ELLER';

  @override
  String get todayTasks => 'Dagens oppgaver';

  @override
  String get myTasksForToday => 'Mine oppgaver for i dag';

  @override
  String get noTasksToday => 'Ingen oppgaver i dag!';

  @override
  String get enjoyFreeTime => 'Nyt fritiden din! 🎉';

  @override
  String get errorLoadingTasks => 'Feil ved lasting av oppgaver';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get completeTask => 'Fullfør oppgave';

  @override
  String markAsComplete(String title) {
    return 'Marker \"$title\" som fullført?';
  }

  @override
  String get cancel => 'Avbryt';

  @override
  String get confirm => 'Bekreft';

  @override
  String get home => 'Hjem';

  @override
  String get today => 'I dag';

  @override
  String get leaderboard => 'Toppliste';

  @override
  String get admin => 'Administrator';

  @override
  String get tasks => 'Oppgaver';

  @override
  String get points => 'Poeng';

  @override
  String get users => 'Brukere';

  @override
  String get settings => 'Innstillinger';

  @override
  String get save => 'Lagre';

  @override
  String get delete => 'Slett';

  @override
  String get edit => 'Rediger';

  @override
  String get add => 'Legg til';

  @override
  String get loading => 'Laster...';

  @override
  String get error => 'Feil';

  @override
  String get success => 'Suksess';

  @override
  String get taskDefinitions => 'Oppgavedefinisjoner';

  @override
  String get taskAssignments => 'Oppgavetildelinger';

  @override
  String get verificationQueue => 'Verifiseringskø';

  @override
  String get userManagement => 'Brukeradministrasjon';

  @override
  String get payout => 'Utbetaling';

  @override
  String get payoutManagement => 'Utbetalingsadministrasjon';

  @override
  String get lastPayout => 'Siste utbetaling';

  @override
  String get never => 'Aldri';

  @override
  String get netPoints => 'Netto poeng';

  @override
  String get moneyToPay => 'Beløp å betale';

  @override
  String get totalToPay => 'Totalt å betale';

  @override
  String get executePayout => 'Utfør utbetaling';

  @override
  String executePayoutConfirmation(int count, String amount) {
    return 'Er du sikker på at du vil utføre utbetaling for $count bruker(e) på til sammen $amount?';
  }

  @override
  String payoutExecutedSuccessfully(int count, String amount) {
    return 'Utbetaling utført! Behandlet $count bruker(e), utbetalt $amount';
  }

  @override
  String get noUsersForPayout => 'Ingen brukere har poeng å betale ut';

  @override
  String get selectAll => 'Velg alle';

  @override
  String get name => 'Navn';

  @override
  String get description => 'Beskrivelse';

  @override
  String get status => 'Status';

  @override
  String get role => 'Rolle';

  @override
  String get parent => 'Forelder';

  @override
  String get child => 'Barn';

  @override
  String get welcome => 'Velkommen';

  @override
  String get pointsEarned => 'Poeng opptjent';

  @override
  String get taskCount => 'Antall oppgaver';

  @override
  String get language => 'Språk';

  @override
  String welcomeUser(String name) {
    return 'Velkommen, $name!';
  }

  @override
  String get adminPanel => 'Administrasjonspanel';

  @override
  String get adminPanelSubtitle => 'Administrer brukere, oppgaver og verifiser fullføringer';

  @override
  String get todayTasksTitle => 'Dagens oppgaver';

  @override
  String get todayTasksSubtitle => 'Se og fullfør dine oppgaver for i dag';

  @override
  String get leaderboardTitle => 'Toppliste';

  @override
  String get leaderboardSubtitle => 'Se hvem som leder i poeng';

  @override
  String get adminDashboard => 'Administrasjonspanel';

  @override
  String get analytics => 'Analyse';

  @override
  String get refresh => 'Oppdater';

  @override
  String get complete => 'Fullfør';

  @override
  String get completed => 'Fullført';

  @override
  String get taskCompletedVerification => 'Oppgave fullført! Venter på verifisering.';

  @override
  String taskCompletedPoints(int points) {
    return 'Oppgave fullført! +$points poeng';
  }

  @override
  String pointsValue(int points) {
    return '$points poeng';
  }

  @override
  String get needsVerification => 'Trenger verifisering';

  @override
  String errorMessage(String error) {
    return 'Feil: $error';
  }

  @override
  String get addUser => 'Legg til bruker';

  @override
  String get noUsersFound => 'Ingen brukere funnet';

  @override
  String get resetPassword => 'Tilbakestill passord';

  @override
  String get resetPoints => 'Tilbakestill poeng';

  @override
  String resetPointsFor(String name) {
    return 'Tilbakestill poeng for $name';
  }

  @override
  String resetPointsConfirmation(String name) {
    return 'Er du sikker på at du vil tilbakestille alle poeng for \"$name\"? Dette vil sette deres totale poeng til null. Denne handlingen kan ikke angres.';
  }

  @override
  String get pointsResetSuccessfully => 'Poeng tilbakestilt';

  @override
  String get bonusPoints => 'Bonuspoeng';

  @override
  String bonusPointsFor(String name) {
    return 'Gi bonuspoeng til $name';
  }

  @override
  String get bonusPointsAwarded => 'Bonuspoeng gitt';

  @override
  String get pleaseEnterValidPoints => 'Vennligst skriv inn et gyldig antall poeng (større enn 0)';

  @override
  String get award => 'Gi';

  @override
  String get optional => 'valgfritt';

  @override
  String get noPasswordRequired => 'Ikke passord påkrevd';

  @override
  String get noPasswordRequiredDescription => 'Tillat innlogging uten å skrive inn passord (for barn)';

  @override
  String get createNewUser => 'Opprett ny bruker';

  @override
  String get displayName => 'Visningsnavn';

  @override
  String get user => 'Bruker';

  @override
  String get create => 'Opprett';

  @override
  String get userCreatedSuccessfully => 'Bruker opprettet';

  @override
  String get editUser => 'Rediger bruker';

  @override
  String get userUpdatedSuccessfully => 'Bruker oppdatert';

  @override
  String resetPasswordFor(String name) {
    return 'Tilbakestill passord for $name';
  }

  @override
  String get newPassword => 'Nytt passord';

  @override
  String get passwordResetSuccessfully => 'Passord tilbakestilt';

  @override
  String get deleteUser => 'Slett bruker';

  @override
  String deleteUserConfirmation(String name) {
    return 'Er du sikker på at du vil slette \"$name\"?';
  }

  @override
  String get userDeletedSuccessfully => 'Bruker slettet';

  @override
  String get topPerformers => 'Toppytere';

  @override
  String get week => 'Uke';

  @override
  String get thisWeek => 'Denne uken';

  @override
  String get previousWeek => 'Forrige uke';

  @override
  String get month => 'Måned';

  @override
  String get allTime => 'Alltid';

  @override
  String get noEntriesYet => 'Ingen oppføringer ennå';

  @override
  String get completeTasksToAppear => 'Fullfør oppgaver for å vises her!';

  @override
  String get rank => 'Rang';

  @override
  String tasksCompleted(int count) {
    return '$count oppgaver fullført';
  }

  @override
  String get addTask => 'Legg til oppgave';

  @override
  String get noTasksFound => 'Ingen oppgaver funnet';

  @override
  String get noTaskDefinitions => 'Ingen oppgavedefinisjoner';

  @override
  String get createFirstTask => 'Opprett din første oppgavemal!';

  @override
  String get titleRequired => 'Tittel er påkrevd';

  @override
  String get pointsPositiveNumber => 'Poeng må være et positivt tall';

  @override
  String get deleteTaskWarning => 'Dette vil markere den som inaktiv. Eksisterende tildelinger vil forbli.';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get active => 'Aktiv';

  @override
  String get assign => 'Tildel';

  @override
  String get createTaskDefinition => 'Opprett oppgavedefinisjon';

  @override
  String get title => 'Tittel';

  @override
  String get taskCreatedSuccessfully => 'Oppgave opprettet';

  @override
  String get editTaskDefinition => 'Rediger oppgavedefinisjon';

  @override
  String get taskCanBeAssigned => 'Oppgaven kan tildeles brukere';

  @override
  String get taskUpdatedSuccessfully => 'Oppgave oppdatert';

  @override
  String get deleteTaskDefinition => 'Slett oppgavedefinisjon';

  @override
  String deleteTaskConfirmation(String title) {
    return 'Er du sikker på at du vil slette \"$title\"?';
  }

  @override
  String get taskDeletedSuccessfully => 'Oppgave slettet';

  @override
  String get newAssignment => 'Ny tildeling';

  @override
  String get noAssignmentsFound => 'Ingen tildelinger funnet';

  @override
  String get noAssignmentsYet => 'Ingen oppgavetildelinger ennå';

  @override
  String get createAssignmentToStart => 'Opprett en tildeling for å komme i gang';

  @override
  String get scheduleType => 'Planleggingstype';

  @override
  String get daysOfWeek => 'Ukedager';

  @override
  String get startDateOptional => 'Startdato (valgfritt)';

  @override
  String get endDateOptional => 'Sluttdato (valgfritt)';

  @override
  String get dueTimeOptional => 'Frist (valgfritt)';

  @override
  String get update => 'Oppdater';

  @override
  String get sun => 'Søn';

  @override
  String get mon => 'Man';

  @override
  String get tue => 'Tir';

  @override
  String get wed => 'Ons';

  @override
  String get thu => 'Tor';

  @override
  String get fri => 'Fre';

  @override
  String get sat => 'Lør';

  @override
  String get unknown => 'Ukjent';

  @override
  String deleteAssignmentQuestion(String task, String user) {
    return 'Er du sikker på at du vil slette tildelingen \"$task\" for $user?';
  }

  @override
  String assignedTo(String name) {
    return 'Tildelt: $name';
  }

  @override
  String due(String time) {
    return 'Frist: $time';
  }

  @override
  String get noTaskDefinitionsAvailable => 'Ingen oppgavedefinisjoner tilgjengelig. Opprett en først.';

  @override
  String get noUsersAvailable => 'Ingen brukere tilgjengelig. Opprett en bruker først.';

  @override
  String get createTaskAssignment => 'Opprett oppgavetildeling';

  @override
  String get task => 'Oppgave';

  @override
  String get assignTo => 'Tildel til';

  @override
  String get daily => 'Daglig';

  @override
  String get weekly => 'Ukentlig';

  @override
  String get once => 'En gang';

  @override
  String get duringWeek => 'I løpet av uken';

  @override
  String get duringMonth => 'I løpet av måneden';

  @override
  String get selectDays => 'Velg dager';

  @override
  String get monday => 'Mandag';

  @override
  String get tuesday => 'Tirsdag';

  @override
  String get wednesday => 'Onsdag';

  @override
  String get thursday => 'Torsdag';

  @override
  String get friday => 'Fredag';

  @override
  String get saturday => 'Lørdag';

  @override
  String get sunday => 'Søndag';

  @override
  String get dueTime => 'Frist';

  @override
  String get assignmentCreatedSuccessfully => 'Tildeling opprettet';

  @override
  String get editAssignment => 'Rediger tildeling';

  @override
  String get assignmentUpdatedSuccessfully => 'Tildeling oppdatert';

  @override
  String get deleteAssignment => 'Slett tildeling';

  @override
  String get deleteAssignmentConfirmation => 'Er du sikker på at du vil slette denne tildelingen?';

  @override
  String get assignmentDeletedSuccessfully => 'Tildeling slettet';

  @override
  String get pendingVerification => 'Venter på verifisering';

  @override
  String get noItemsInQueue => 'Ingen elementer i køen';

  @override
  String get allCaughtUp => 'Du er ferdig!';

  @override
  String completedBy(String name) {
    return 'Fullført av $name';
  }

  @override
  String completedAt(String time) {
    return 'Fullført: $time';
  }

  @override
  String get failedToLoadImage => 'Kunne ikke laste bilde';

  @override
  String get verifyAndAwardPoints => 'Verifiser og gi poeng';

  @override
  String get reject => 'Avvis';

  @override
  String get verifyTask => 'Verifiser oppgave';

  @override
  String verifyTaskConfirmation(int points, String name) {
    return 'Gi $points poeng til $name?';
  }

  @override
  String get verify => 'Verifiser';

  @override
  String taskVerifiedPoints(int points, String name) {
    return 'Oppgave verifisert! $points poeng gitt til $name';
  }

  @override
  String get rejectTask => 'Avvis oppgave';

  @override
  String rejectTaskConfirmation(String taskTitle, String userName) {
    return 'Avvis \"$taskTitle\" av $userName?';
  }

  @override
  String get taskRejected => 'Oppgave avvist';

  @override
  String get calendar => 'Kalender';

  @override
  String get calendarSubtitle => 'Se kommende oppgaver og tidsplaner';

  @override
  String moreTasksCount(int count) {
    return '+$count flere';
  }

  @override
  String get timezone => 'Tidssone';

  @override
  String get changeTimezone => 'Endre tidssone';

  @override
  String get timezoneHint => 'f.eks., Europe/Oslo, America/New_York';

  @override
  String get timezoneHelper => 'IANA tidssone-identifikator';

  @override
  String get pointToMoneyRate => 'Poeng til pengesats';

  @override
  String get changePointToMoneyRate => 'Endre poeng til pengesats';

  @override
  String get rate => 'Sats';

  @override
  String get rateHint => 'f.eks., 1.0, 0.5, 0.10';

  @override
  String get rateHelper => 'Valutaverdi per poeng';

  @override
  String currencyPerPoint(String amount) {
    return '$amount valuta per poeng';
  }

  @override
  String get weekStartsOn => 'Uken starter på';

  @override
  String get analyticsSubtitle => 'Se fullføringsgrad og poengstatistikk';

  @override
  String get timePeriod => 'Tidsperiode:';

  @override
  String days(int count) {
    return '$count dager';
  }

  @override
  String get pointsSummary => 'Poengoversikt';

  @override
  String get totalEarned => 'Totalt opptjent';

  @override
  String get totalPaidOut => 'Totalt utbetalt';

  @override
  String get currentBalance => 'Nåværende saldo';

  @override
  String get completionRates => 'Fullføringsgrad';

  @override
  String get average => 'Gjennomsnitt';

  @override
  String get pointsEarnedVsMoneyPaidOut => 'Poeng opptjent vs penger utbetalt';

  @override
  String get earned => 'Opptjent';

  @override
  String get paidOut => 'Utbetalt';

  @override
  String get redeemed => 'Innløst';

  @override
  String get noData => 'Ingen data tilgjengelig';

  @override
  String get pendingTaskVerifications => 'Ventende oppgaveverifiseringer';

  @override
  String get noTasksPendingVerification => 'Ingen oppgaver venter på verifisering';

  @override
  String get allTaskCompletionsReviewed => 'Alle fullførte oppgaver er gjennomgått';

  @override
  String completedByUser(String userName) {
    return 'Fullført av: $userName';
  }

  @override
  String get notes => 'Notater:';

  @override
  String awardPointsConfirmation(int points, String userName, String taskTitle) {
    return 'Gi $points poeng til $userName for å fullføre \"$taskTitle\"?';
  }

  @override
  String taskVerifiedPointsAwarded(int points, String userName) {
    return 'Oppgave verifisert! $points poeng gitt til $userName';
  }

  @override
  String get reasonOptional => 'Årsak (valgfritt)';

  @override
  String get whyTaskRejected => 'Hvorfor blir denne oppgaven avvist?';
}
