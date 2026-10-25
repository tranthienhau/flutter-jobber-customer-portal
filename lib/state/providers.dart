import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/gohighlevel/ghl_client.dart';
import '../data/jobber/jobber_client.dart';
import '../data/models.dart';
import '../data/portal_repository.dart';
import '../data/quickbooks/quickbooks_client.dart';

/// Swap these three for real HTTP clients (OAuth tokens from a small backend) to go live.
final jobberClientProvider = Provider<JobberGraphQLClient>((_) => MockJobberClient());
final quickbooksClientProvider = Provider<QuickBooksClient>((_) => MockQuickBooksClient());
final ghlClientProvider = Provider<GoHighLevelClient>((_) => MockGoHighLevelClient());

final repositoryProvider = Provider<PortalRepository>((ref) => PortalRepository(
      jobber: ref.watch(jobberClientProvider),
      quickbooks: ref.watch(quickbooksClientProvider),
      ghl: ref.watch(ghlClientProvider),
    ));

/// Demo clock pinned to the morning crew 2 is on site, so relative dates stay stable.
final clockProvider = Provider<DateTime>((_) => DateTime(2026, 11, 3, 7, 20));

class Session {
  const Session({this.signedIn = false, this.linked = true});
  final bool signedIn;

  /// False until Midas links the customer's service agreement (drives the empty home).
  final bool linked;
  Session copyWith({bool? signedIn, bool? linked}) =>
      Session(signedIn: signedIn ?? this.signedIn, linked: linked ?? this.linked);
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() => const Session();
  void signIn() => state = state.copyWith(signedIn: true);
  void signOut() => state = const Session();
  void setLinked(bool v) => state = state.copyWith(linked: v);
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

final customerProvider = Provider<Customer>((ref) => ref.watch(repositoryProvider).customer());

final propertiesProvider = FutureProvider<List<Property>>((ref) => ref.watch(repositoryProvider).properties());

final propertyProvider = FutureProvider.family<Property, String>((ref, id) async {
  final all = await ref.watch(propertiesProvider.future);
  return all.firstWhere((p) => p.id == id);
});

class JobsNotifier extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() => ref.watch(repositoryProvider).jobs();

  Future<Job> submit(RequestDraft draft) async {
    final job = await ref.read(repositoryProvider).submitRequest(draft);
    state = AsyncData([job, ...state.value ?? const []]);
    ref.read(noticesProvider.notifier).push(PortalNotice(
          id: 'n-${job.id}',
          kind: NoticeKind.scheduled,
          title: 'Request received',
          body: '${job.title} at ${job.propertyName}',
          at: ref.read(clockProvider),
          unread: true,
          route: '/requests/job/${job.id}',
        ));
    return job;
  }

  void rate(String id, int stars) {
    state = AsyncData([for (final j in state.value ?? const <Job>[]) j.id == id ? j.copyWith(rating: stars) : j]);
  }
}

final jobsProvider = AsyncNotifierProvider<JobsNotifier, List<Job>>(JobsNotifier.new);

final jobProvider = Provider.family<Job?, String>((ref, id) {
  final jobs = ref.watch(jobsProvider).value ?? const <Job>[];
  for (final j in jobs) {
    if (j.id == id) return j;
  }
  return null;
});

class FilterNotifier<T> extends Notifier<T> {
  FilterNotifier(this.initial);
  final T initial;
  @override
  T build() => initial;
  void set(T v) => state = v;
}

/// null = All.
final requestFilterProvider =
    NotifierProvider<FilterNotifier<JobStatus?>, JobStatus?>(() => FilterNotifier<JobStatus?>(null));

/// 'All' | 'Open' | 'Paid'.
final invoiceFilterProvider = NotifierProvider<FilterNotifier<String>, String>(() => FilterNotifier('All'));

final invoicesProvider = FutureProvider<List<Invoice>>((ref) => ref.watch(repositoryProvider).invoices());

final invoiceProvider = FutureProvider.family<Invoice, String>((ref, id) async {
  final all = await ref.watch(invoicesProvider.future);
  return all.firstWhere((i) => i.id == id);
});

final balanceProvider = Provider<double>((ref) =>
    (ref.watch(invoicesProvider).value ?? const <Invoice>[]).fold(0.0, (s, i) => s + i.balance));

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() => ref.watch(repositoryProvider).messages();

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final msg = await ref.read(repositoryProvider).send(text.trim());
    state = AsyncData([...state.value ?? const [], msg]);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    state = AsyncData([
      ...state.value ?? const [],
      ChatMessage(
        sender: Sender.staff,
        text: 'Thanks Dana, I have logged that and will confirm shortly.',
        at: msg.at.add(const Duration(minutes: 1)),
      ),
    ]);
  }
}

final chatProvider = AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

class NoticesNotifier extends Notifier<List<PortalNotice>> {
  @override
  List<PortalNotice> build() => ref.watch(repositoryProvider).notices();
  void markAllRead() => state = [for (final n in state) n.read()];
  void push(PortalNotice n) => state = [n, ...state];
}

final noticesProvider = NotifierProvider<NoticesNotifier, List<PortalNotice>>(NoticesNotifier.new);
final unreadCountProvider = Provider<int>((ref) => ref.watch(noticesProvider).where((n) => n.unread).length);

/// Draft state for the new-request form. Photo capture is simulated: tapping
/// "Add photo" attaches the next sample site photo instead of opening the camera.
class DraftState {
  const DraftState({
    this.propertyId = 'prop-northgate',
    this.serviceType = 'Floor care',
    this.description = 'Coffee stain near elevator bank, 2nd floor carpet, about 3 ft wide.',
    this.photos = const ['stain-closeup.jpg'],
    this.timing = 'This week',
    this.textMe = true,
  });
  final String propertyId;
  final String serviceType;
  final String description;
  final List<String> photos;
  final String timing;
  final bool textMe;

  DraftState copyWith({
    String? propertyId,
    String? serviceType,
    String? description,
    List<String>? photos,
    String? timing,
    bool? textMe,
  }) =>
      DraftState(
        propertyId: propertyId ?? this.propertyId,
        serviceType: serviceType ?? this.serviceType,
        description: description ?? this.description,
        photos: photos ?? this.photos,
        timing: timing ?? this.timing,
        textMe: textMe ?? this.textMe,
      );

  RequestDraft toDraft() => RequestDraft(
      propertyId: propertyId,
      serviceType: serviceType,
      description: description,
      photos: photos,
      timing: timing,
      textMe: textMe);
}

const samplePhotos = ['stain-closeup.jpg', 'stain-overview.jpg', 'lobby-floor.jpg', 'restroom-clean.jpg'];

class DraftNotifier extends Notifier<DraftState> {
  @override
  DraftState build() => const DraftState();
  void update(DraftState Function(DraftState) f) => state = f(state);
  void addPhoto() {
    final next = samplePhotos.firstWhere((p) => !state.photos.contains(p), orElse: () => samplePhotos.last);
    if (state.photos.length < 4) state = state.copyWith(photos: [...state.photos, next]);
  }

  void removePhoto(String p) => state = state.copyWith(photos: [...state.photos]..remove(p));
  void reset() => state = const DraftState();
}

final draftProvider = NotifierProvider<DraftNotifier, DraftState>(DraftNotifier.new);
