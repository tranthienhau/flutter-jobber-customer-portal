/// GoHighLevel (LeadConnector API v2) client. The portal uses it for two things:
/// the support conversation thread with the account manager, and pushing every new
/// service request into the CRM pipeline as an opportunity so sales sees upsell work.
abstract class GoHighLevelClient {
  Future<List<Map<String, dynamic>>> conversationMessages(String contactId);
  Future<Map<String, dynamic>> sendMessage(String contactId, String body);
  Future<Map<String, dynamic>> createOpportunity(Map<String, dynamic> body);
}

class MockGoHighLevelClient implements GoHighLevelClient {
  MockGoHighLevelClient({this.latency = const Duration(milliseconds: 250)});
  final Duration latency;
  final List<Map<String, dynamic>> opportunities = [];

  final _messages = <Map<String, dynamic>>[
    {
      'id': 'm1',
      'direction': 'outbound',
      'body': 'Hi Dana, crew 2 is on site at Riverside now for the restroom deep clean.',
      'dateAdded': '2026-11-03T07:06:00',
    },
    {
      'id': 'm2',
      'direction': 'inbound',
      'body': 'Great, can they also check the 1st floor lobby restroom?',
      'dateAdded': '2026-11-03T07:12:00',
    },
    {
      'id': 'm3',
      'direction': 'outbound',
      'body': 'Added to the job. I will send photos when done.',
      'dateAdded': '2026-11-03T07:15:00',
      'meta': {'jobId': 'job-2187'},
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> conversationMessages(String contactId) async {
    await Future<void>.delayed(latency);
    return List.of(_messages);
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String contactId, String body) async {
    await Future<void>.delayed(latency);
    final msg = {
      'id': 'm${_messages.length + 1}',
      'direction': 'inbound',
      'body': body,
      'dateAdded': DateTime(2026, 11, 3, 7, 24).toIso8601String(),
    };
    _messages.add(msg);
    return msg;
  }

  @override
  Future<Map<String, dynamic>> createOpportunity(Map<String, dynamic> body) async {
    await Future<void>.delayed(latency);
    final opp = {'id': 'opp-${opportunities.length + 1}', ...body, 'status': 'open'};
    opportunities.add(opp);
    return opp;
  }
}
