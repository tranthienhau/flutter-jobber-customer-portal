import 'gohighlevel/ghl_client.dart';
import 'jobber/jobber_client.dart';
import 'jobber/queries.dart';
import 'models.dart';
import 'quickbooks/quickbooks_client.dart';

/// Single seam between the UI and the three systems Midas already runs:
/// Jobber (sites, jobs, visits, requests), QuickBooks Online (invoices, read-only) and
/// GoHighLevel (conversations, lead pipeline). Everything the screens see is mapped
/// into portal models here.
class PortalRepository {
  PortalRepository({required this.jobber, required this.quickbooks, required this.ghl});

  final JobberGraphQLClient jobber;
  final QuickBooksClient quickbooks;
  final GoHighLevelClient ghl;

  static const clientId = 'Z2lkOi8vSm9iYmVyL0NsaWVudC84ODI0';
  static const ghlContactId = 'ghl-contact-dana';

  static const _siteImages = {
    'prop-northgate': 'site-northgate.jpg',
    'prop-riverside': 'site-riverside.jpg',
    'prop-eastgate': 'site-eastgate.jpg',
  };

  final Map<String, String> _siteNames = {};

  Customer customer() => const Customer(
        name: 'Dana Whitfield',
        firstName: 'Dana',
        role: 'Facilities Manager',
        company: 'Northgate Holdings',
        email: 'dana@northgateoffice.com',
        avatar: 'avatar-dana.jpg',
      );

  Future<List<Property>> properties() async {
    final res = await jobber.query(clientPortalQuery, variables: {'clientId': clientId});
    final nodes = (res['data']['client']['properties']['nodes'] as List).cast<Map<String, dynamic>>();
    final out = <Property>[];
    for (final n in nodes) {
      final id = n['id'] as String;
      final fields = {
        for (final f in (n['customFields'] as List).cast<Map<String, dynamic>>())
          f['label'] as String: f['valueText'] as String
      };
      final a = n['address'] as Map<String, dynamic>;
      final svcRes = await jobber.query(recurringServicesQuery, variables: {'propertyId': id});
      final svcNodes = (svcRes['data']['property']['jobs']['nodes'] as List).cast<Map<String, dynamic>>();
      _siteNames[id] = fields['Site name']!;
      out.add(Property(
        id: id,
        name: fields['Site name']!,
        address: '${a['street1']}, ${a['street2']}, ${a['city']}, ${a['province']}',
        subtitle: fields['Summary'] ?? '',
        tag: fields['Site tag'],
        image: _siteImages[id]!,
        contact: 'Dana Whitfield',
        services: [
          for (final s in svcNodes)
            ServiceLine(
              id: s['id'] as String,
              title: s['title'] as String,
              schedule: s['recurrenceSchedule']['friendly'] as String,
              scope: s['instructions'] as String,
              cadence: s['jobStatus'] as String,
              active: s['jobStatus'] == 'active',
            )
        ],
      ));
    }
    return out;
  }

  Future<List<Job>> jobs() async {
    if (_siteNames.isEmpty) await properties();
    final res = await jobber.query(clientJobsQuery, variables: {'clientId': clientId});
    final data = res['data'] as Map<String, dynamic>;
    final jobs = [
      for (final n in (data['jobs']['nodes'] as List).cast<Map<String, dynamic>>()) _mapJob(n),
      for (final r in (data['requests']['nodes'] as List).cast<Map<String, dynamic>>()) _mapRequest(r),
    ];
    jobs.sort((a, b) => b.date.compareTo(a.date));
    return jobs;
  }

  Job _mapJob(Map<String, dynamic> n) {
    final status = JobStatusX.fromJobber(n['jobStatus'] as String);
    final visit = ((n['visits']['nodes'] as List).first as Map<String, dynamic>);
    final crew = (visit['assignedUsers']['nodes'] as List).first['name']['full'] as String;
    final start = DateTime.parse(visit['startAt'] as String);
    final created = DateTime.parse(n['createdAt'] as String);
    final scheduled = DateTime.parse(n['scheduledAt'] as String);
    final completed = n['completedAt'] == null ? null : DateTime.parse(n['completedAt'] as String);
    final photos = [
      for (final p in (n['noteAttachments']['nodes'] as List).cast<Map<String, dynamic>>()) p['url'] as String
    ];
    final ba = n['beforeAfter'] as Map<String, dynamic>?;
    return Job(
      id: n['id'] as String,
      number: '#J-${n['jobNumber']}',
      title: n['title'] as String,
      propertyId: n['property']['id'] as String,
      propertyName: _siteNames[n['property']['id']] ?? '',
      location: n['location'] as String? ?? '',
      status: status,
      date: completed ?? start,
      scope: n['instructions'] as String,
      photos: photos,
      beforePhoto: ba?['before'] as String?,
      afterPhoto: ba?['after'] as String?,
      crewLead: crew,
      crewAvatar: crew == 'Maria Gonzalez' ? 'avatar-maria.jpg' : null,
      crewNotes: n['crewNotes'] as String?,
      timeline: [
        TimelineStep(status: JobStatus.requested, title: 'Requested', detail: 'Submitted via client portal', at: created),
        TimelineStep(
            status: JobStatus.scheduled,
            title: 'Scheduled',
            detail: 'Confirmed for ${_fmtShort(start)}',
            at: scheduled),
        TimelineStep(
            status: JobStatus.inProgress,
            title: 'In progress',
            detail: status.index >= 2 ? '$crew checked in on site' : 'Crew checks in on arrival',
            at: status.index >= 2 ? start : null),
        TimelineStep(
            status: JobStatus.completed,
            title: 'Completed',
            detail: completed != null ? 'Signed off by $crew' : 'Sign-off and photo report',
            at: completed),
      ],
    );
  }

  Job _mapRequest(Map<String, dynamic> r) {
    final created = DateTime.parse(r['createdAt'] as String);
    final photos = (r['photos'] as List?)?.cast<String>() ?? const <String>[];
    return Job(
      id: r['id'] as String,
      number: '#${r['requestNumber']}',
      title: r['title'] as String,
      propertyId: r['property']['id'] as String,
      propertyName: _siteNames[r['property']['id']] ?? '',
      location: '',
      status: JobStatus.requested,
      date: created,
      scope: r['details'] as String? ?? '',
      photos: photos,
      urgent: r['urgent'] == true,
      timeline: [
        TimelineStep(status: JobStatus.requested, title: 'Requested', detail: 'Submitted via client portal', at: created),
        const TimelineStep(status: JobStatus.scheduled, title: 'Scheduled', detail: 'Midas confirms a time'),
        const TimelineStep(status: JobStatus.inProgress, title: 'In progress', detail: 'Crew checks in on arrival'),
        const TimelineStep(status: JobStatus.completed, title: 'Completed', detail: 'Sign-off and photo report'),
      ],
    );
  }

  /// Creates the request in Jobber and mirrors it to GoHighLevel as an opportunity.
  Future<Job> submitRequest(RequestDraft d) async {
    final title = '${d.serviceType}: ${d.description.split('.').first}';
    final res = await jobber.query(requestCreateMutation, variables: {
      'input': {'clientId': clientId, 'propertyId': d.propertyId, 'title': title, 'details': d.description},
    });
    final node = Map<String, dynamic>.from(res['data']['requestCreate']['request'] as Map)
      ..['details'] = d.description
      ..['photos'] = d.photos
      ..['title'] = d.serviceType == 'Floor care' ? 'Carpet stain, 2nd floor' : title;
    await ghl.createOpportunity({
      'pipelineStage': 'Portal request',
      'name': '${_siteNames[d.propertyId]} - ${d.serviceType}',
      'contactId': ghlContactId,
      'source': 'client-portal',
    });
    return _mapRequest(node);
  }

  Future<void> submitChange(ChangeRequest c) async {
    await ghl.createOpportunity({
      'pipelineStage': 'Service change',
      'name': 'Change ${c.serviceId}: ${c.kind}',
      'contactId': ghlContactId,
      'source': 'client-portal',
    });
  }

  Future<List<Invoice>> invoices() async {
    final rows = await quickbooks.invoicesForCustomer('88');
    return [
      for (final r in rows)
        Invoice(
          id: r['Id'] as String,
          number: r['DocNumber'] as String,
          customer: r['CustomerRef']['name'] as String,
          propertyName: (r['CustomField'] as List).first['StringValue'] as String,
          issued: DateTime.parse(r['TxnDate'] as String),
          due: DateTime.parse(r['DueDate'] as String),
          total: (r['TotalAmt'] as num).toDouble(),
          balance: (r['Balance'] as num).toDouble(),
          terms: r['SalesTermRef']['name'] as String,
          syncedAt: DateTime.parse(r['MetaData']['LastUpdatedTime'] as String),
          lines: [
            for (final l in (r['Line'] as List).cast<Map<String, dynamic>>())
              InvoiceLine(l['Description'] as String, l['SalesItemLineDetail']['ItemRef']['name'] as String,
                  (l['Amount'] as num).toDouble()),
          ],
        )
    ];
  }

  Future<List<ChatMessage>> messages() async {
    final rows = await ghl.conversationMessages(ghlContactId);
    return rows.map(_mapMsg).toList();
  }

  Future<ChatMessage> send(String text) async => _mapMsg(await ghl.sendMessage(ghlContactId, text));

  ChatMessage _mapMsg(Map<String, dynamic> m) => ChatMessage(
        sender: m['direction'] == 'inbound' ? Sender.customer : Sender.staff,
        text: m['body'] as String,
        at: DateTime.parse(m['dateAdded'] as String),
        jobId: (m['meta'] as Map?)?['jobId'] as String?,
      );

  List<PortalNotice> notices() => [
        PortalNotice(
            id: 'n1',
            kind: NoticeKind.onSite,
            title: 'Crew on site',
            body: 'Restroom deep clean at Riverside Medical Plaza',
            at: DateTime(2026, 11, 3, 7, 4),
            unread: true,
            route: '/requests/job/job-2187'),
        PortalNotice(
            id: 'n2',
            kind: NoticeKind.scheduled,
            title: 'Visit scheduled',
            body: 'Lobby floor strip and wax, Sun Nov 9, 8:00 AM',
            at: DateTime(2026, 11, 3, 6, 30),
            unread: true,
            route: '/requests/job/job-2193'),
        PortalNotice(
            id: 'n3',
            kind: NoticeKind.completed,
            title: 'Job completed',
            body: 'Carpet extraction 3rd floor, 8 photos added',
            at: DateTime(2026, 10, 24, 16, 15),
            image: 'carpet-clean.jpg',
            route: '/requests/work/job-2154'),
        PortalNotice(
            id: 'n4',
            kind: NoticeKind.invoice,
            title: 'Invoice issued',
            body: 'INV-10482, \$1,920.00, due Nov 30',
            at: DateTime(2026, 10, 31, 9, 0),
            route: '/invoices/10482'),
        PortalNotice(
            id: 'n5',
            kind: NoticeKind.approved,
            title: 'Change request approved',
            body: 'Window cleaning moved to monthly for Northgate Office Park',
            at: DateTime(2026, 10, 28, 14, 10)),
      ];
}

String _fmtShort(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  return '${m[d.month - 1]} ${d.day} at $h:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
}
