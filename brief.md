# Midas Client Portal - Source Brief

## Title
Midas Client Portal

## Description
Midas Client Portal is a self-service app for the clients of a commercial facility services
company. A facilities manager signs in and sees every site Midas services, the recurring
services at each one and the next scheduled visit. From there they submit a new service
request with photos, ask to change a recurring service, follow each job from requested to
completed, review before and after photos of finished work, read their invoices and message
their account manager, all without calling the office for updates.

## Store links
Not yet published (portfolio POC).

## Platform
Both - iOS and Android, plus a web build from the same Flutter codebase.

## Category
Business / Productivity (B2B customer portal)

## Features
- Sign in to a portal account linked to the client's service agreement
- Home with the next visit, open requests, visits this month and balance due
- Site list with photos; site detail with recurring services, visits and photo history
- New service request: site, service type, description, photos, preferred timing, SMS opt-in
- Request a change to a recurring service: frequency (day picker), time window, areas, pause, cancel
- Job status timeline: Requested, Scheduled, In progress (live), Completed, with crew lead and scope
- Completed work: draggable before/after comparison, full-screen gallery, crew notes, visit rating
- Invoices: balance due, open and paid filters, line items, read-only, synced from QuickBooks Online
- Support chat with the account manager, quick replies, call and email shortcuts
- Notifications for crew on site, visit scheduled, job completed, invoice issued, change approved
- Account: linked sites, team members, notification preferences, connected systems
- First-run state for accounts whose sites are not linked yet

## Tech stack
- Flutter (Dart) for iOS, Android and web
- Riverpod for state (AsyncNotifier for jobs and chat, Notifier for session, filters, drafts)
- go_router with a stateful shell for the four-tab layout
- Jobber GraphQL client (client, properties, recurring jobs, jobs, visits, requestCreate)
- QuickBooks Online invoice client (read-only)
- GoHighLevel client (conversations, pipeline opportunities)
- google_fonts with bundled Plus Jakarta Sans and Unbounded, lucide icons, intl
- integration_test for end-to-end flow and screenshot capture

## Industry
Commercial cleaning and facility services (janitorial, floor care, windows, day porter)

## Metrics
Unpublished POC, no store ratings or downloads. Scope: 15 core screens covering sign in,
home, sites, requests, job tracking, completed work, invoices, support, notifications and
account.

## Research notes
- Verified: the app builds and runs on the iOS simulator, an Android emulator and the web;
  every screen in the screenshots was captured from the running app.
- Mocked: Jobber, QuickBooks Online and GoHighLevel respond from in-app fixtures shaped like
  their API responses (Jobber GraphQL `data.client.properties.nodes`, QuickBooks `Invoice`
  with `DocNumber`, `Balance`, `Line`; GoHighLevel messages with `direction` and `body`).
- Mocked: photo capture attaches sample site photos instead of opening the camera; sign in
  is local; the demo clock is fixed to the morning a crew is on site.
- Future expansion: live OAuth connections through a small backend that holds the API
  tokens, Jobber webhooks for real-time job status, push notifications, client hub
  single sign-on, and a white-label theme per brand.
