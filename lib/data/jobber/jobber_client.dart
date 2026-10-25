import 'dart:async';

import 'queries.dart';

/// Minimal GraphQL transport. A production build wires this to `package:http` with the
/// Jobber OAuth bearer token and `X-JOBBER-GRAPHQL-VERSION` header.
abstract class JobberGraphQLClient {
  Future<Map<String, dynamic>> query(String document, {Map<String, dynamic> variables = const {}});
}

/// In-memory Jobber that answers the portal's documents with fixture data in the real
/// response shape (`data.client.properties.nodes`, `data.jobs.nodes`, ...).
class MockJobberClient implements JobberGraphQLClient {
  MockJobberClient({this.latency = const Duration(milliseconds: 250)});

  final Duration latency;
  final List<Map<String, dynamic>> _requests = [..._fixtureRequests];
  int _seq = 3304;

  @override
  Future<Map<String, dynamic>> query(String document, {Map<String, dynamic> variables = const {}}) async {
    await Future<void>.delayed(latency);
    if (identical(document, clientPortalQuery)) return {'data': _fixtureClient};
    if (identical(document, clientJobsQuery)) {
      return {
        'data': {
          'jobs': {'nodes': _fixtureJobs},
          'requests': {'nodes': _requests},
        }
      };
    }
    if (identical(document, recurringServicesQuery)) {
      final id = variables['propertyId'] as String;
      return {
        'data': {
          'property': {
            'jobs': {'nodes': _fixtureRecurring[id] ?? const []}
          }
        }
      };
    }
    if (identical(document, requestCreateMutation)) {
      final input = variables['input'] as Map<String, dynamic>;
      final node = {
        'id': 'Z2lkOi8vSm9iYmVyL1JlcXVlc3QvMzMwNA==',
        'requestNumber': 'R-${_seq++}',
        'title': input['title'],
        'requestStatus': 'new',
        'createdAt': DateTime(2026, 11, 3, 7, 22).toIso8601String(),
        'property': {'id': input['propertyId']},
      };
      _requests.insert(0, node);
      return {
        'data': {
          'requestCreate': {'request': node, 'userErrors': <Object>[]}
        }
      };
    }
    return {
      'errors': [
        {'message': 'Unknown operation'}
      ]
    };
  }
}

const _fixtureClient = {
  'client': {
    'id': 'Z2lkOi8vSm9iYmVyL0NsaWVudC84ODI0',
    'name': 'Dana Whitfield',
    'companyName': 'Northgate Holdings',
    'emails': [
      {'address': 'dana@northgateoffice.com', 'primary': true}
    ],
    'properties': {
      'nodes': [
        {
          'id': 'prop-northgate',
          'address': {
            'street1': '2400 Northgate Blvd',
            'street2': 'Buildings A and B',
            'city': 'Austin',
            'province': 'TX',
            'postalCode': '78758'
          },
          'customFields': [
            {'label': 'Site name', 'valueText': 'Northgate Office Park'},
            {'label': 'Site tag', 'valueText': 'HQ site'},
            {'label': 'Summary', 'valueText': 'Building A and B campus'},
          ],
        },
        {
          'id': 'prop-riverside',
          'address': {
            'street1': '910 Riverside Dr',
            'street2': 'Suites 100 - 450',
            'city': 'Austin',
            'province': 'TX',
            'postalCode': '78704'
          },
          'customFields': [
            {'label': 'Site name', 'valueText': 'Riverside Medical Plaza'},
            {'label': 'Summary', 'valueText': 'Suites 100 - 450'},
          ],
        },
        {
          'id': 'prop-eastgate',
          'address': {
            'street1': '7700 Eastgate Pkwy',
            'street2': 'Dock doors 1 - 24',
            'city': 'Pflugerville',
            'province': 'TX',
            'postalCode': '78660'
          },
          'customFields': [
            {'label': 'Site name', 'valueText': 'Eastgate Distribution Center'},
            {'label': 'Summary', 'valueText': 'Warehouse and offices'},
          ],
        },
      ]
    }
  }
};

const _fixtureRecurring = {
  'prop-northgate': [
    {
      'id': 'svc-ng-janitorial',
      'title': 'Nightly janitorial',
      'jobStatus': 'active',
      'recurrenceSchedule': {'friendly': 'Mon-Fri, 6:00 PM'},
      'instructions': 'Full office sweep, trash removal, restroom sanitation, dusting',
    },
    {
      'id': 'svc-ng-windows',
      'title': 'Window cleaning (exterior)',
      'jobStatus': 'quarterly',
      'recurrenceSchedule': {'friendly': 'Quarterly, next Nov 18'},
      'instructions': 'Exterior glass panels and lobby vestibule, high reach',
    },
    {
      'id': 'svc-ng-carpet',
      'title': 'Carpet extraction',
      'jobStatus': 'every 6 months',
      'recurrenceSchedule': {'friendly': 'Every 6 months, next Jan 12'},
      'instructions': 'Hot-water extraction for all 2nd and 3rd floor corridors',
    },
    {
      'id': 'svc-ng-porter',
      'title': 'Day porter',
      'jobStatus': 'active',
      'recurrenceSchedule': {'friendly': 'Mon-Fri, 8:00 AM - 4:00 PM'},
      'instructions': 'Lobby upkeep, restocking, high-touch sanitizing',
    },
  ],
  'prop-riverside': [
    {
      'id': 'svc-rv-janitorial',
      'title': 'Medical office janitorial',
      'jobStatus': 'active',
      'recurrenceSchedule': {'friendly': 'Mon-Sat, 7:00 PM'},
      'instructions': 'Exam rooms, waiting areas, restrooms, terminal disinfection',
    },
    {
      'id': 'svc-rv-restroom',
      'title': 'Restroom deep clean',
      'jobStatus': 'monthly',
      'recurrenceSchedule': {'friendly': 'Monthly, first Monday'},
      'instructions': 'Grout, fixtures, dispensers, partitions',
    },
    {
      'id': 'svc-rv-carpet',
      'title': 'Carpet extraction',
      'jobStatus': 'quarterly',
      'recurrenceSchedule': {'friendly': 'Quarterly, next Jan 24'},
      'instructions': 'Waiting rooms and corridors',
    },
  ],
  'prop-eastgate': [
    {
      'id': 'svc-eg-office',
      'title': 'Office janitorial',
      'jobStatus': 'active',
      'recurrenceSchedule': {'friendly': 'Mon, Wed, Fri, 5:30 PM'},
      'instructions': 'Front offices, break room, restrooms',
    },
    {
      'id': 'svc-eg-scrub',
      'title': 'Warehouse floor scrubbing',
      'jobStatus': 'monthly',
      'recurrenceSchedule': {'friendly': 'Monthly, last Saturday'},
      'instructions': 'Ride-on scrubber, dock aisles and staging lanes',
    },
  ],
};

final _fixtureJobs = <Map<String, dynamic>>[
  {
    'id': 'job-2187',
    'jobNumber': 2187,
    'title': 'Restroom deep clean',
    'jobStatus': 'active',
    'location': 'Bldg B, Floor 2',
    'instructions':
        'Second floor restrooms - grout and fixture deep clean. Descale 6 porcelain fixtures, steam grout, refill touchless dispensers.',
    'property': {'id': 'prop-riverside'},
    'createdAt': '2026-10-28T09:12:00',
    'scheduledAt': '2026-10-30T14:40:00',
    'visits': {
      'nodes': [
        {
          'id': 'v-1',
          'title': 'Restroom deep clean',
          'startAt': '2026-11-03T07:04:00',
          'endAt': '2026-11-03T10:30:00',
          'visitStatus': 'active',
          'assignedUsers': {
            'nodes': [
              {
                'name': {'full': 'Maria Gonzalez'}
              }
            ]
          }
        }
      ]
    },
    'noteAttachments': {
      'nodes': [
        {'url': 'restroom-1.jpg', 'fileName': 'Restroom B-204'},
        {'url': 'restroom-2.jpg', 'fileName': 'Fixture inspection'},
      ]
    },
  },
  {
    'id': 'job-2193',
    'jobNumber': 2193,
    'title': 'Lobby floor strip and wax',
    'jobStatus': 'upcoming',
    'location': 'Main lobby, Building A',
    'instructions': 'Strip, seal and apply 4 coats of finish to the main lobby VCT, approx. 2,600 sq ft.',
    'property': {'id': 'prop-northgate'},
    'createdAt': '2026-10-29T11:05:00',
    'scheduledAt': '2026-10-30T16:10:00',
    'visits': {
      'nodes': [
        {
          'id': 'v-2',
          'title': 'Lobby floor strip and wax',
          'startAt': '2026-11-09T08:00:00',
          'endAt': '2026-11-09T14:00:00',
          'visitStatus': 'upcoming',
          'assignedUsers': {
            'nodes': [
              {
                'name': {'full': 'Luis M.'}
              }
            ]
          }
        }
      ]
    },
    'noteAttachments': {
      'nodes': [
        {'url': 'lobby-floor.jpg', 'fileName': 'Lobby floor'},
      ]
    },
  },
  {
    'id': 'job-2154',
    'jobNumber': 2154,
    'title': 'Carpet extraction, 3rd floor',
    'jobStatus': 'archived',
    'location': 'Floor 3 corridors and waiting room',
    'instructions': 'Hot-water extraction of 3rd floor corridors and waiting room.',
    'property': {'id': 'prop-riverside'},
    'createdAt': '2026-10-17T10:00:00',
    'scheduledAt': '2026-10-18T09:00:00',
    'completedAt': '2026-10-24T16:15:00',
    'crewNotes': 'Extracted 4,200 sq ft, pre-treated 6 high-traffic spots. Dry in 4 hours.',
    'visits': {
      'nodes': [
        {
          'id': 'v-3',
          'title': 'Carpet extraction',
          'startAt': '2026-10-24T09:30:00',
          'endAt': '2026-10-24T16:15:00',
          'visitStatus': 'completed',
          'assignedUsers': {
            'nodes': [
              {
                'name': {'full': 'Maria Gonzalez'}
              }
            ]
          }
        }
      ]
    },
    'beforeAfter': {'before': 'carpet-before.jpg', 'after': 'carpet-after.jpg'},
    'noteAttachments': {
      'nodes': [
        {'url': 'carpet-after.jpg', 'fileName': 'Elevator landing'},
        {'url': 'gallery-hallway.jpg', 'fileName': 'Corridor 3A'},
        {'url': 'gallery-waiting-room.jpg', 'fileName': 'Waiting room'},
        {'url': 'carpet-clean.jpg', 'fileName': 'Corridor 3B'},
        {'url': 'gallery-conference.jpg', 'fileName': 'Consult room'},
        {'url': 'gallery-floor-detail.jpg', 'fileName': 'Entry mat zone'},
        {'url': 'gallery-restroom.jpg', 'fileName': 'Restroom check'},
        {'url': 'gallery-restroom-fixtures.jpg', 'fileName': 'Fixtures'},
      ]
    },
  },
  {
    'id': 'job-2141',
    'jobNumber': 2141,
    'title': 'Window cleaning',
    'jobStatus': 'archived',
    'location': 'Exterior glass, Buildings A and B',
    'instructions': 'Quarterly exterior glass and lobby vestibule.',
    'property': {'id': 'prop-northgate'},
    'createdAt': '2026-10-06T08:00:00',
    'scheduledAt': '2026-10-07T08:00:00',
    'completedAt': '2026-10-15T15:00:00',
    'crewNotes': 'All exterior panes and vestibule glass cleaned. Two cracked seals reported to building ops.',
    'visits': {
      'nodes': [
        {
          'id': 'v-4',
          'title': 'Window cleaning',
          'startAt': '2026-10-15T07:00:00',
          'endAt': '2026-10-15T15:00:00',
          'visitStatus': 'completed',
          'assignedUsers': {
            'nodes': [
              {
                'name': {'full': 'Luis M.'}
              }
            ]
          }
        }
      ]
    },
    'noteAttachments': {
      'nodes': [
        {'url': 'lobby-hero.jpg', 'fileName': 'Lobby glass'},
        {'url': 'northgate-hero.jpg', 'fileName': 'Exterior'},
      ]
    },
  },
];

final _fixtureRequests = <Map<String, dynamic>>[
  {
    'id': 'req-3291',
    'requestNumber': 'R-3291',
    'title': 'Spill cleanup, loading dock',
    'requestStatus': 'new',
    'urgent': true,
    'details': 'Hydraulic fluid leak near dock door 4, about 6 ft. Needs absorbent and degreaser.',
    'createdAt': '2026-11-02T15:40:00',
    'property': {'id': 'prop-eastgate'},
  },
];
