/// Portal domain models. These are what the UI renders; the integration clients
/// (Jobber GraphQL, QuickBooks Online, GoHighLevel) return their own API shapes and
/// `PortalRepository` maps them into these.
library;

enum JobStatus { requested, scheduled, inProgress, completed }

extension JobStatusX on JobStatus {
  String get label => switch (this) {
        JobStatus.requested => 'Requested',
        JobStatus.scheduled => 'Scheduled',
        JobStatus.inProgress => 'In progress',
        JobStatus.completed => 'Completed',
      };

  /// Jobber exposes request + job states as separate enums; this maps both onto the
  /// four customer-facing stages.
  static JobStatus fromJobber(String raw) => switch (raw) {
        'new' || 'assessment_scheduled' || 'unscheduled' => JobStatus.requested,
        'upcoming' || 'scheduled' || 'today' => JobStatus.scheduled,
        'active' || 'in_progress' || 'action_required' => JobStatus.inProgress,
        _ => JobStatus.completed,
      };
}

class Property {
  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.subtitle,
    required this.image,
    required this.contact,
    required this.services,
    this.tag,
  });

  final String id;
  final String name;
  final String address;
  final String subtitle;
  final String image;
  final String contact;
  final List<ServiceLine> services;
  final String? tag;
}

class ServiceLine {
  const ServiceLine({
    required this.id,
    required this.title,
    required this.schedule,
    required this.scope,
    required this.cadence,
    this.active = true,
  });

  final String id;
  final String title;
  final String schedule;
  final String scope;
  final String cadence;
  final bool active;
}

class TimelineStep {
  const TimelineStep({required this.status, required this.title, required this.detail, this.at});
  final JobStatus status;
  final String title;
  final String detail;
  final DateTime? at;
}

class Job {
  const Job({
    required this.id,
    required this.number,
    required this.title,
    required this.propertyId,
    required this.propertyName,
    required this.location,
    required this.status,
    required this.date,
    required this.scope,
    required this.timeline,
    this.photos = const [],
    this.beforePhoto,
    this.afterPhoto,
    this.crewLead,
    this.crewAvatar,
    this.crewNotes,
    this.rating = 0,
    this.urgent = false,
  });

  final String id;
  final String number;
  final String title;
  final String propertyId;
  final String propertyName;
  final String location;
  final JobStatus status;
  final DateTime date;
  final String scope;
  final List<TimelineStep> timeline;
  final List<String> photos;
  final String? beforePhoto;
  final String? afterPhoto;
  final String? crewLead;
  final String? crewAvatar;
  final String? crewNotes;
  final int rating;
  final bool urgent;

  Job copyWith({JobStatus? status, List<TimelineStep>? timeline, int? rating}) => Job(
        id: id,
        number: number,
        title: title,
        propertyId: propertyId,
        propertyName: propertyName,
        location: location,
        status: status ?? this.status,
        date: date,
        scope: scope,
        timeline: timeline ?? this.timeline,
        photos: photos,
        beforePhoto: beforePhoto,
        afterPhoto: afterPhoto,
        crewLead: crewLead,
        crewAvatar: crewAvatar,
        crewNotes: crewNotes,
        rating: rating ?? this.rating,
        urgent: urgent,
      );
}

class Visit {
  const Visit({
    required this.title,
    required this.propertyName,
    required this.start,
    required this.crew,
    required this.status,
  });
  final String title;
  final String propertyName;
  final DateTime start;
  final String crew;
  final JobStatus status;
}

class InvoiceLine {
  const InvoiceLine(this.description, this.detail, this.amount);
  final String description;
  final String detail;
  final double amount;
}

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.customer,
    required this.propertyName,
    required this.issued,
    required this.due,
    required this.total,
    required this.balance,
    required this.lines,
    required this.syncedAt,
    this.terms = 'Net 30',
  });

  final String id;
  final String number;
  final String customer;
  final String propertyName;
  final DateTime issued;
  final DateTime due;
  final double total;
  final double balance;
  final List<InvoiceLine> lines;
  final DateTime syncedAt;
  final String terms;

  bool get isPaid => balance == 0;
}

enum Sender { customer, staff }

class ChatMessage {
  const ChatMessage({required this.sender, required this.text, required this.at, this.jobId});
  final Sender sender;
  final String text;
  final DateTime at;
  final String? jobId;
}

enum NoticeKind { onSite, scheduled, completed, invoice, approved }

class PortalNotice {
  const PortalNotice({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.unread = false,
    this.image,
    this.route,
  });
  final String id;
  final NoticeKind kind;
  final String title;
  final String body;
  final DateTime at;
  final bool unread;
  final String? image;
  final String? route;

  PortalNotice read() =>
      PortalNotice(id: id, kind: kind, title: title, body: body, at: at, image: image, route: route);
}

class Customer {
  const Customer({
    required this.name,
    required this.firstName,
    required this.role,
    required this.company,
    required this.email,
    required this.avatar,
  });
  final String name;
  final String firstName;
  final String role;
  final String company;
  final String email;
  final String avatar;
}

/// Draft of a new service request before it is sent to Jobber (requestCreate) and
/// mirrored to GoHighLevel as an opportunity.
class RequestDraft {
  const RequestDraft({
    required this.propertyId,
    required this.serviceType,
    required this.description,
    required this.photos,
    required this.timing,
    required this.textMe,
  });
  final String propertyId;
  final String serviceType;
  final String description;
  final List<String> photos;
  final String timing;
  final bool textMe;
}

class ChangeRequest {
  const ChangeRequest({
    required this.serviceId,
    required this.kind,
    required this.days,
    required this.effective,
    required this.notes,
  });
  final String serviceId;
  final String kind;
  final List<String> days;
  final DateTime effective;
  final String notes;
}
