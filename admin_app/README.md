# Dress Admin Dashboard

Internal admin web app for the Dress rental marketplace.

## Run

```bash
cd admin_app
flutter pub get
cp .env.example .env   # then fill in Supabase credentials
flutter run -d chrome
```

If `.env` is empty, the app runs in **mock mode** (any email/password signs in).

## Screens

- **Dashboard** — KPIs, bookings chart, recent activity
- **Listings** — pending review queue, approve/reject with reason
- **Damage claims** — review renter-vs-lender disputes, partial/full/reject
- **Support tickets** — open / in_progress / resolved, with priority
- **Users** — search, filter by role (renter/lender/both), view profile

## Mock-mode behavior

When `SUPABASE_URL` is empty:
- Login accepts any credentials
- All data is hard-coded mock
- Approve / reject only updates local state
- No real Supabase queries

## Production wiring

Set in `.env`:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

Then ensure the Supabase project has the same schema as `dress_app/supabase/migrations/0001_initial_schema.sql`, with these tables used by the admin:
- `listings` (status: pendingReview → approved/rejected)
- `damage_claims`
- `support_tickets`
- `profiles` (for users view)
- `user_reports` (visible in damage claims context)

## Stack

- Flutter Web
- Supabase (auth + queries)
- fl_chart (dashboard)
- Shared theme tokens with `dress_app`
