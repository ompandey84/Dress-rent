-- =============================================================================
-- DRESS — P2P Rental Marketplace (Supabase Schema)
-- =============================================================================
-- Run this in the Supabase SQL editor (or via `supabase db push`).
-- Idempotent: re-runnable; uses `drop policy if exists` and `create or replace`.
-- =============================================================================

-- Required extensions -------------------------------------------------------
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- =============================================================================
-- 1. PROFILES — extends auth.users
-- =============================================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text unique,
  name text,
  email text,
  avatar_url text,
  is_vendor boolean not null default false,
  is_verified boolean not null default false,    -- KYC passed
  age_verified boolean not null default false,
  date_of_birth date,
  gender text,
  bio text,

  -- address
  address_line1 text,
  address_line2 text,
  city text,
  state text,
  pincode text,
  landmark text,

  -- measurements (renter side)
  height_cm numeric(5,1),
  weight_kg numeric(5,1),
  bust_cm numeric(5,1),
  waist_cm numeric(5,1),
  hip_cm numeric(5,1),
  shoulder_cm numeric(5,1),

  -- aggregates
  rating numeric(2,1) default 0.0,
  reviews_count int default 0,
  total_rentals int default 0,
  total_listings int default 0,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_phone on public.profiles(phone);
create index if not exists idx_profiles_is_vendor on public.profiles(is_vendor);

-- Auto-create profile row on signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, phone, name, email)
  values (
    new.id,
    new.phone,
    coalesce(new.raw_user_meta_data->>'name', ''),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================================
-- 2. LISTINGS — items a lender can rent out
-- =============================================================================
create table if not exists public.listings (
  id uuid primary key default uuid_generate_v4(),
  lender_id uuid not null references public.profiles(id) on delete cascade,

  -- core
  title text not null,
  description text,
  category text not null,                       -- Casual, Ethnic, Formal, Party, Bridal, Sports
  gender text not null default 'Women',         -- Women, Men, Unisex
  occasion text,                                -- Casual, Wedding, Party, Festive, Cocktail, Bridal
  condition text not null,                      -- New, Like New, Good, Fair
  color text,
  fabric text,

  -- variants
  sizes text[] not null default '{}',           -- ['S','M','L']
  photo_urls text[] not null default '{}',
  video_url text,

  -- pricing
  price_per_day numeric(10,2) not null check (price_per_day > 0),
  security_deposit numeric(10,2) not null default 0 check (security_deposit >= 0),
  insurance_fee numeric(10,2),
  min_days int not null default 1 check (min_days >= 1),
  max_days int not null default 14 check (max_days >= min_days),

  -- pickup
  pickup_address_line1 text not null,
  pickup_address_line2 text,
  pickup_city text not null,
  pickup_state text not null,
  pickup_pincode text not null,
  pickup_landmark text,
  pickup_method text not null default 'both',   -- self, rider, both

  -- moderation
  status text not null default 'pendingReview'  -- draft, pendingReview, approved, rejected, suspended
        check (status in ('draft','pendingReview','approved','rejected','suspended')),
  rejection_reason text,
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,

  -- metrics
  views int default 0,
  bookings_count int default 0,
  rating numeric(2,1) default 0.0,
  reviews_count int default 0,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_listings_lender on public.listings(lender_id);
create index if not exists idx_listings_status on public.listings(status);
create index if not exists idx_listings_category on public.listings(category);
create index if not exists idx_listings_city on public.listings(pickup_city);

-- =============================================================================
-- 3. BOOKINGS — a rental transaction
-- =============================================================================
create table if not exists public.bookings (
  id uuid primary key default uuid_generate_v4(),
  order_number text unique,                     -- human-readable like DR-1001

  listing_id uuid not null references public.listings(id) on delete restrict,
  lender_id uuid not null references public.profiles(id) on delete restrict,
  renter_id uuid not null references public.profiles(id) on delete restrict,

  start_date date not null,
  end_date date not null,
  rental_days int not null check (rental_days > 0),

  -- variants
  selected_size text,
  selected_color text,

  -- pricing breakdown
  rental_fee numeric(10,2) not null,
  security_deposit numeric(10,2) not null default 0,
  delivery_fee numeric(10,2) not null default 0,
  insurance_fee numeric(10,2) not null default 0,
  discount numeric(10,2) not null default 0,
  total numeric(10,2) not null,                 -- final amount renter pays
  has_insurance boolean not null default false,

  -- status
  status text not null default 'pending_payment'
        check (status in (
          'pending_payment','pending_lender_acceptance','lender_preparing',
          'in_transit_to_renter','delivered_to_renter','in_use',
          'return_requested','in_transit_to_lender','delivered_to_lender',
          'in_return_qc','completed','cancelled_by_renter','cancelled_by_lender',
          'rejected_by_lender'
        )),
  payment_status text not null default 'pending'
        check (payment_status in ('pending','paid','refunded','partially_refunded','failed')),
  escrow_status text not null default 'none'
        check (escrow_status in ('none','held','released','claimed')),

  -- cancellation
  cancellation_reason text,
  cancelled_at timestamptz,
  cancelled_by uuid references public.profiles(id),

  -- cashfree
  cashfree_order_id text unique,
  cashfree_payment_id text,

  -- pickup
  pickup_method text,                           -- self, rider
  pickup_tracking_id text,
  rider_name text,
  rider_phone text,

  -- QC + damage
  qc_notes text,
  damage_claim_id uuid,

  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_bookings_renter on public.bookings(renter_id);
create index if not exists idx_bookings_lender on public.bookings(lender_id);
create index if not exists idx_bookings_listing on public.bookings(listing_id);
create index if not exists idx_bookings_status on public.bookings(status);
create index if not exists idx_bookings_dates on public.bookings(start_date, end_date);

-- =============================================================================
-- 4. WALLET TRANSACTIONS
-- =============================================================================
-- A single ledger. Available balance = sum(is_credit=true) - sum(is_credit=false)
-- minus currently held deposit_paid entries (those are escrow, not spendable).
-- =============================================================================
create table if not exists public.wallet_transactions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in (
    'topup','depositPaid','depositRefund','ugcCredit','referralBonus',
    'cashback','withdraw','damageClaim'
  )),
  amount numeric(10,2) not null check (amount > 0),
  description text,
  booking_id uuid references public.bookings(id) on delete set null,
  source_txn_id uuid references public.wallet_transactions(id) on delete set null,
  external_ref text,                            -- cashfree txn id
  balance_after numeric(10,2),                  -- cached for fast list views
  created_at timestamptz not null default now()
);

create index if not exists idx_wallet_user on public.wallet_transactions(user_id);
create index if not exists idx_wallet_booking on public.wallet_transactions(booking_id);
create index if not exists idx_wallet_created on public.wallet_transactions(created_at desc);

-- Helper view: live available balance per user (topups + refunds - non-hold debits)
create or replace view public.wallet_balance as
  select
    user_id,
    coalesce(sum(case when type in ('topup','depositRefund','ugcCredit','referralBonus','cashback')
                      then amount else 0 end), 0)
    - coalesce(sum(case when type in ('withdraw','damageClaim')
                        then amount else 0 end), 0)
    - coalesce(sum(case when type = 'depositPaid' then amount else 0 end), 0)
    as available_balance,
    coalesce(sum(case when type = 'depositPaid' then amount else 0 end), 0)
    as held_balance
  from public.wallet_transactions
  group by user_id;

-- =============================================================================
-- 5. DAMAGE CLAIMS
-- =============================================================================
create table if not exists public.damage_claims (
  id uuid primary key default uuid_generate_v4(),
  booking_id uuid not null references public.bookings(id) on delete cascade,

  raised_by uuid not null references public.profiles(id),   -- the lender
  against_user uuid not null references public.profiles(id), -- the renter

  damage_type text not null,                     -- stain, tear, burn, missing, broken, other
  description text not null,
  evidence_urls text[] not null default '{}',

  amount_claimed numeric(10,2) not null check (amount_claimed > 0),
  amount_approved numeric(10,2) default 0,
  deposit_total numeric(10,2) not null,         -- snapshot of booking.deposit

  status text not null default 'open' check (status in ('open','in_review','approved','partial','rejected','paid')),
  reviewer_id uuid references public.profiles(id),
  reviewer_notes text,

  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists idx_claims_booking on public.damage_claims(booking_id);
create index if not exists idx_claims_status on public.damage_claims(status);

-- =============================================================================
-- 6. RATINGS — mutual renter↔lender
-- =============================================================================
create table if not exists public.ratings (
  id uuid primary key default uuid_generate_v4(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  rater_id uuid not null references public.profiles(id) on delete cascade,
  ratee_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in ('renter_to_lender','lender_to_renter','renter_to_listing')),

  score int not null check (score between 1 and 5),
  review text,

  -- sub-scores (1-5, nullable)
  communication_score int check (communication_score between 1 and 5),
  accuracy_score int check (accuracy_score between 1 and 5),
  delivery_score int check (delivery_score between 1 and 5),

  created_at timestamptz not null default now(),

  -- one rating per (booking, rater, type)
  unique (booking_id, rater_id, type)
);

create index if not exists idx_ratings_ratee on public.ratings(ratee_id);
create index if not exists idx_ratings_booking on public.ratings(booking_id);

-- =============================================================================
-- 7. SUPPORT TICKETS
-- =============================================================================
create table if not exists public.support_tickets (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  category text not null check (category in ('booking','payment','damage','account','safety','other')),
  subject text not null,
  description text not null,
  attachments text[] not null default '{}',
  related_booking_id uuid references public.bookings(id) on delete set null,
  related_user_id uuid references public.profiles(id) on delete set null,
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  status text not null default 'open' check (status in ('open','in_progress','resolved','closed')),
  assignee uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

create index if not exists idx_tickets_user on public.support_tickets(user_id);
create index if not exists idx_tickets_status on public.support_tickets(status);

-- =============================================================================
-- 8. USER REPORTS & BLOCKS
-- =============================================================================
create table if not exists public.user_reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (reason in ('harassment','fake_listing','inappropriate','no_show','damaged_item','other')),
  notes text,
  related_booking_id uuid references public.bookings(id) on delete set null,
  status text not null default 'pending' check (status in ('pending','reviewed','actioned','dismissed')),
  created_at timestamptz not null default now()
);

create index if not exists idx_reports_reporter on public.user_reports(reporter_id);
create index if not exists idx_reports_reported on public.user_reports(reported_user_id);

create table if not exists public.blocked_users (
  user_id uuid not null references public.profiles(id) on delete cascade,
  blocked_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, blocked_user_id)
);

-- =============================================================================
-- 9. PROMO CODES
-- =============================================================================
create table if not exists public.promo_codes (
  id uuid primary key default uuid_generate_v4(),
  code text unique not null,
  kind text not null check (kind in ('percent','flat')),
  value numeric(10,2) not null check (value > 0),     -- % or absolute
  min_order_amount numeric(10,2) default 0,
  max_uses int,                                        -- null = unlimited
  used_count int not null default 0,
  valid_from timestamptz default now(),
  valid_until timestamptz,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Seed the demo codes the app uses
insert into public.promo_codes (code, kind, value) values
  ('DRESS20', 'percent', 20),
  ('FIRST50', 'flat', 50)
on conflict (code) do nothing;

-- =============================================================================
-- 10. NOTIFICATIONS
-- =============================================================================
create table if not exists public.notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null,                          -- booking, payment, system, support
  title text not null,
  body text not null,
  data jsonb default '{}'::jsonb,               -- payload (booking id etc.)
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user on public.notifications(user_id, read_at);

-- =============================================================================
-- 11. REFERRALS
-- =============================================================================
create table if not exists public.referrals (
  id uuid primary key default uuid_generate_v4(),
  referrer_id uuid not null references public.profiles(id) on delete cascade,
  referee_id uuid not null references public.profiles(id) on delete cascade,
  code text not null,
  status text not null default 'pending' check (status in ('pending','signed_up','converted','paid')),
  reward numeric(10,2) default 250,
  created_at timestamptz not null default now(),
  converted_at timestamptz,
  unique (referrer_id, referee_id)
);

-- =============================================================================
-- 12. SAVED ADDRESSES
-- =============================================================================
create table if not exists public.addresses (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text,                                  -- Home, Work, etc.
  line1 text not null,
  line2 text,
  city text not null,
  state text not null,
  pincode text not null,
  landmark text,
  is_default boolean default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_addresses_user on public.addresses(user_id);

-- =============================================================================
-- 13. UGC POSTS
-- =============================================================================
create table if not exists public.ugc_posts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  media_url text not null,
  kind text not null default 'photo' check (kind in ('photo','reel')),
  caption text,
  hashtags text[] default '{}',
  listing_id uuid references public.listings(id) on delete set null,
  credit_awarded numeric(10,2) default 100,
  status text not null default 'published' check (status in ('draft','published','removed')),
  likes int default 0,
  created_at timestamptz not null default now()
);

create index if not exists idx_ugc_user on public.ugc_posts(user_id);

-- =============================================================================
-- 14. CHAT (in-app messaging between renter and lender)
-- =============================================================================
create table if not exists public.chat_rooms (
  id uuid primary key default uuid_generate_v4(),
  booking_id uuid references public.bookings(id) on delete set null,
  renter_id uuid not null references public.profiles(id) on delete cascade,
  lender_id uuid not null references public.profiles(id) on delete cascade,
  last_message_at timestamptz default now(),
  created_at timestamptz not null default now(),
  unique (renter_id, lender_id, booking_id)
);

create table if not exists public.chat_messages (
  id uuid primary key default uuid_generate_v4(),
  room_id uuid not null references public.chat_rooms(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  attachments text[] default '{}',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_chat_msg_room on public.chat_messages(room_id, created_at);

-- =============================================================================
-- TRIGGERS — keep updated_at fresh, recalc aggregates
-- =============================================================================
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_touch on public.profiles;
create trigger trg_profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_listings_touch on public.listings;
create trigger trg_listings_touch before update on public.listings
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_bookings_touch on public.bookings;
create trigger trg_bookings_touch before update on public.bookings
  for each row execute function public.touch_updated_at();

-- Recalculate profile.rating/reviews_count on new rating
create or replace function public.recalc_ratee_aggregate()
returns trigger language plpgsql as $$
begin
  update public.profiles p set
    rating = coalesce((select avg(score)::numeric(2,1) from public.ratings where ratee_id = new.ratee_id), 0),
    reviews_count = (select count(*) from public.ratings where ratee_id = new.ratee_id)
  where p.id = new.ratee_id;
  return new;
end;
$$;

drop trigger if exists trg_rating_recalc on public.ratings;
create trigger trg_rating_recalc after insert on public.ratings
  for each row execute function public.recalc_ratee_aggregate();

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.profiles           enable row level security;
alter table public.listings           enable row level security;
alter table public.bookings           enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.damage_claims      enable row level security;
alter table public.ratings            enable row level security;
alter table public.support_tickets    enable row level security;
alter table public.user_reports       enable row level security;
alter table public.blocked_users      enable row level security;
alter table public.promo_codes        enable row level security;
alter table public.notifications      enable row level security;
alter table public.referrals          enable row level security;
alter table public.addresses          enable row level security;
alter table public.ugc_posts          enable row level security;
alter table public.chat_rooms         enable row level security;
alter table public.chat_messages      enable row level security;

-- Helper: is_admin() — admin role lives in profiles.is_admin (add column if missing)
alter table public.profiles add column if not exists is_admin boolean not null default false;

create or replace function public.is_admin()
returns boolean language sql stable as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

-- PROFILES --------------------------------------------------------------------
drop policy if exists "profiles_select_all" on public.profiles;
create policy "profiles_select_all" on public.profiles
  for select using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self" on public.profiles
  for insert with check (id = auth.uid());

-- LISTINGS --------------------------------------------------------------------
drop policy if exists "listings_select_approved" on public.listings;
create policy "listings_select_approved" on public.listings
  for select using (
    status = 'approved' or lender_id = auth.uid() or public.is_admin()
  );

drop policy if exists "listings_insert_own" on public.listings;
create policy "listings_insert_own" on public.listings
  for insert with check (lender_id = auth.uid());

drop policy if exists "listings_update_own" on public.listings;
create policy "listings_update_own" on public.listings
  for update using (lender_id = auth.uid() or public.is_admin());

drop policy if exists "listings_delete_own" on public.listings;
create policy "listings_delete_own" on public.listings
  for delete using (lender_id = auth.uid() or public.is_admin());

-- BOOKINGS --------------------------------------------------------------------
drop policy if exists "bookings_select_own" on public.bookings;
create policy "bookings_select_own" on public.bookings
  for select using (
    renter_id = auth.uid() or lender_id = auth.uid() or public.is_admin()
  );

drop policy if exists "bookings_insert_renter" on public.bookings;
create policy "bookings_insert_renter" on public.bookings
  for insert with check (renter_id = auth.uid());

drop policy if exists "bookings_update_parties" on public.bookings;
create policy "bookings_update_parties" on public.bookings
  for update using (
    renter_id = auth.uid() or lender_id = auth.uid() or public.is_admin()
  );

-- WALLET ----------------------------------------------------------------------
drop policy if exists "wallet_select_own" on public.wallet_transactions;
create policy "wallet_select_own" on public.wallet_transactions
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "wallet_insert_own" on public.wallet_transactions;
create policy "wallet_insert_own" on public.wallet_transactions
  for insert with check (user_id = auth.uid() or public.is_admin());

-- DAMAGE CLAIMS ---------------------------------------------------------------
drop policy if exists "claims_select_parties" on public.damage_claims;
create policy "claims_select_parties" on public.damage_claims
  for select using (
    raised_by = auth.uid() or against_user = auth.uid() or public.is_admin()
  );

drop policy if exists "claims_insert_lender" on public.damage_claims;
create policy "claims_insert_lender" on public.damage_claims
  for insert with check (raised_by = auth.uid());

drop policy if exists "claims_update_admin" on public.damage_claims;
create policy "claims_update_admin" on public.damage_claims
  for update using (public.is_admin());

-- RATINGS ---------------------------------------------------------------------
drop policy if exists "ratings_select_all" on public.ratings;
create policy "ratings_select_all" on public.ratings
  for select using (true);

drop policy if exists "ratings_insert_own" on public.ratings;
create policy "ratings_insert_own" on public.ratings
  for insert with check (rater_id = auth.uid());

-- SUPPORT TICKETS -------------------------------------------------------------
drop policy if exists "tickets_select_own" on public.support_tickets;
create policy "tickets_select_own" on public.support_tickets
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "tickets_insert_own" on public.support_tickets;
create policy "tickets_insert_own" on public.support_tickets
  for insert with check (user_id = auth.uid());

drop policy if exists "tickets_update_admin" on public.support_tickets;
create policy "tickets_update_admin" on public.support_tickets
  for update using (user_id = auth.uid() or public.is_admin());

-- USER REPORTS & BLOCKS -------------------------------------------------------
drop policy if exists "reports_select_own" on public.user_reports;
create policy "reports_select_own" on public.user_reports
  for select using (reporter_id = auth.uid() or public.is_admin());

drop policy if exists "reports_insert_own" on public.user_reports;
create policy "reports_insert_own" on public.user_reports
  for insert with check (reporter_id = auth.uid());

drop policy if exists "blocks_select_own" on public.blocked_users;
create policy "blocks_select_own" on public.blocked_users
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "blocks_modify_own" on public.blocked_users;
create policy "blocks_modify_own" on public.blocked_users
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- PROMO CODES (everyone reads; only admin writes) ----------------------------
drop policy if exists "promo_select_all" on public.promo_codes;
create policy "promo_select_all" on public.promo_codes
  for select using (is_active = true or public.is_admin());

drop policy if exists "promo_admin_write" on public.promo_codes;
create policy "promo_admin_write" on public.promo_codes
  for all using (public.is_admin()) with check (public.is_admin());

-- NOTIFICATIONS ---------------------------------------------------------------
drop policy if exists "notif_select_own" on public.notifications;
create policy "notif_select_own" on public.notifications
  for select using (user_id = auth.uid());

drop policy if exists "notif_update_own" on public.notifications;
create policy "notif_update_own" on public.notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "notif_insert_admin" on public.notifications;
create policy "notif_insert_admin" on public.notifications
  for insert with check (public.is_admin() or user_id = auth.uid());

-- REFERRALS / ADDRESSES / UGC / CHAT -----------------------------------------
drop policy if exists "referrals_select_own" on public.referrals;
create policy "referrals_select_own" on public.referrals
  for select using (referrer_id = auth.uid() or referee_id = auth.uid());
drop policy if exists "referrals_insert_self" on public.referrals;
create policy "referrals_insert_self" on public.referrals
  for insert with check (referrer_id = auth.uid());

drop policy if exists "addresses_all_own" on public.addresses;
create policy "addresses_all_own" on public.addresses
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "ugc_select_published" on public.ugc_posts;
create policy "ugc_select_published" on public.ugc_posts
  for select using (status = 'published' or user_id = auth.uid());
drop policy if exists "ugc_insert_own" on public.ugc_posts;
create policy "ugc_insert_own" on public.ugc_posts
  for insert with check (user_id = auth.uid());
drop policy if exists "ugc_update_own" on public.ugc_posts;
create policy "ugc_update_own" on public.ugc_posts
  for update using (user_id = auth.uid());

drop policy if exists "rooms_select_parties" on public.chat_rooms;
create policy "rooms_select_parties" on public.chat_rooms
  for select using (renter_id = auth.uid() or lender_id = auth.uid() or public.is_admin());
drop policy if exists "rooms_insert_parties" on public.chat_rooms;
create policy "rooms_insert_parties" on public.chat_rooms
  for insert with check (renter_id = auth.uid() or lender_id = auth.uid());

drop policy if exists "msg_select_parties" on public.chat_messages;
create policy "msg_select_parties" on public.chat_messages
  for select using (
    exists (
      select 1 from public.chat_rooms r
      where r.id = room_id and (r.renter_id = auth.uid() or r.lender_id = auth.uid() or public.is_admin())
    )
  );
drop policy if exists "msg_insert_sender" on public.chat_messages;
create policy "msg_insert_sender" on public.chat_messages
  for insert with check (sender_id = auth.uid());

-- =============================================================================
-- DONE. Verify with:  select * from public.profiles limit 1;
-- =============================================================================
