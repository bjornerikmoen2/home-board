// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Emil og Emely\'s oppgaver';

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
  String rejectTaskConfirmation(String task, String name) {
    return 'Avvis \"$task\" av $name?';
  }

  @override
  String get taskRejected => 'Oppgave avvist';
}
