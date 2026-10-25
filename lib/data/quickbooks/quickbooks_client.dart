/// Read-only QuickBooks Online accounting client. The portal never writes to the books:
/// it lists invoices for the customer (`SELECT * FROM Invoice WHERE CustomerRef = ...`)
/// so balances always match what the office sees in QuickBooks.
abstract class QuickBooksClient {
  Future<List<Map<String, dynamic>>> invoicesForCustomer(String customerRef);
}

class MockQuickBooksClient implements QuickBooksClient {
  MockQuickBooksClient({this.latency = const Duration(milliseconds: 250)});
  final Duration latency;

  @override
  Future<List<Map<String, dynamic>>> invoicesForCustomer(String customerRef) async {
    await Future<void>.delayed(latency);
    return _invoices;
  }
}

Map<String, dynamic> _line(String desc, String detail, double amt) => {
      'Description': desc,
      'Amount': amt,
      'DetailType': 'SalesItemLineDetail',
      'SalesItemLineDetail': {'ItemRef': {'name': detail}},
    };

final _invoices = <Map<String, dynamic>>[
  {
    'Id': '10482',
    'DocNumber': 'INV-10482',
    'TxnDate': '2026-10-31',
    'DueDate': '2026-11-30',
    'TotalAmt': 1920.00,
    'Balance': 1920.00,
    'SalesTermRef': {'name': 'Net 30'},
    'CustomerRef': {'value': '88', 'name': 'Northgate Office Park LLC'},
    'CustomField': [
      {'Name': 'Site', 'StringValue': 'Northgate Office Park'}
    ],
    'Line': [
      _line('Nightly janitorial - October', '22 scheduled visits', 1540.00),
      _line('Day porter add-on', 'Oct 20 - 24 coverage', 280.00),
      _line('Supplies restock', 'Restroom and pantry inventory', 100.00),
    ],
    'MetaData': {'LastUpdatedTime': '2026-11-01T06:00:00'},
  },
  {
    'Id': '10471',
    'DocNumber': 'INV-10471',
    'TxnDate': '2026-10-15',
    'DueDate': '2026-11-14',
    'TotalAmt': 2360.00,
    'Balance': 2360.00,
    'SalesTermRef': {'name': 'Net 30'},
    'CustomerRef': {'value': '88', 'name': 'Northgate Holdings'},
    'CustomField': [
      {'Name': 'Site', 'StringValue': 'Riverside Medical Plaza'}
    ],
    'Line': [
      _line('Medical office janitorial - first half Oct', '13 scheduled visits', 1820.00),
      _line('Carpet extraction, 3rd floor', '4,200 sq ft', 540.00),
    ],
    'MetaData': {'LastUpdatedTime': '2026-11-01T06:00:00'},
  },
  {
    'Id': '10455',
    'DocNumber': 'INV-10455',
    'TxnDate': '2026-09-30',
    'DueDate': '2026-10-30',
    'TotalAmt': 2360.00,
    'Balance': 0.0,
    'SalesTermRef': {'name': 'Net 30'},
    'CustomerRef': {'value': '88', 'name': 'Northgate Holdings'},
    'CustomField': [
      {'Name': 'Site', 'StringValue': 'Riverside Medical Plaza'}
    ],
    'Line': [
      _line('Medical office janitorial - September', '26 scheduled visits', 2360.00),
    ],
    'MetaData': {'LastUpdatedTime': '2026-10-21T06:00:00'},
  },
  {
    'Id': '10431',
    'DocNumber': 'INV-10431',
    'TxnDate': '2026-09-15',
    'DueDate': '2026-10-15',
    'TotalAmt': 1880.00,
    'Balance': 0.0,
    'SalesTermRef': {'name': 'Net 30'},
    'CustomerRef': {'value': '88', 'name': 'Northgate Holdings'},
    'CustomField': [
      {'Name': 'Site', 'StringValue': 'Eastgate Distribution Center'}
    ],
    'Line': [
      _line('Office janitorial - August', '13 scheduled visits', 1180.00),
      _line('Warehouse floor scrubbing', 'Dock aisles, 38,000 sq ft', 700.00),
    ],
    'MetaData': {'LastUpdatedTime': '2026-10-10T06:00:00'},
  },
];
