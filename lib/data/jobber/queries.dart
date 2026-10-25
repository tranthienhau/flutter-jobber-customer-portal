/// GraphQL documents the portal sends to the Jobber API (https://api.getjobber.com/api/graphql).
/// The mock client below answers them with fixture data in the same response shape, so
/// swapping in a real HTTP client is a transport change, not a UI change.
library;

const clientPortalQuery = r'''
query ClientPortal($clientId: EncodedId!) {
  client(id: $clientId) {
    id
    name
    companyName
    emails { address primary }
    properties {
      nodes {
        id
        address { street1 street2 city province postalCode }
        customFields { label valueText }
      }
    }
  }
}''';

const clientJobsQuery = r'''
query ClientJobs($clientId: EncodedId!, $first: Int = 50) {
  jobs(filter: { clientId: $clientId }, first: $first) {
    nodes {
      id
      jobNumber
      title
      jobStatus
      instructions
      property { id }
      createdAt
      visits(first: 5) {
        nodes { id title startAt endAt visitStatus assignedUsers { nodes { name { full } } } }
      }
      noteAttachments { nodes { url fileName } }
    }
  }
  requests(filter: { clientId: $clientId }, first: $first) {
    nodes { id title requestStatus createdAt property { id } }
  }
}''';

const recurringServicesQuery = r'''
query RecurringServices($propertyId: EncodedId!) {
  property(id: $propertyId) {
    jobs(filter: { jobType: RECURRING }) {
      nodes { id title jobStatus recurrenceSchedule { friendly } instructions }
    }
  }
}''';

const requestCreateMutation = r'''
mutation RequestCreate($input: RequestCreateInput!) {
  requestCreate(input: $input) {
    request { id title requestStatus createdAt }
    userErrors { message path }
  }
}''';
