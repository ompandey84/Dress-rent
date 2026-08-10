-- =============================================================================
-- DRESS — single-pass full schema, RLS, triggers, seed
-- Project: https://mvwtswyakcalqworyrqu.supabase.co
-- Idempotent: safe to re-run any number of times.
-- Tables already in your schema are kept; columns are added via ALTER TABLE
--   ADD COLUMN IF NOT EXISTS; new tables are created via CREATE TABLE IF NOT
--   EXISTS. RLS policies are dropped-and-recreated to be safe.
-- =============================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- =============================================================================
-- STEP 1: ENSURE COLUMNS EXIST BEFORE FUNCTIONS REFERENCE THEM
--   The is_admin() helper reads profiles.is_admin, so the column must
--   exist at parse time. We add it here, before any function is created.
-- =============================================================================

-- profiles — minimum columns required by helper functions
alter table public.profiles add column if not exists is_admin boolean not null default false;
alter table public.profiles add column if not exists is_verified boolean not null default false;
alter table public.profiles add column if not exists is_vendor boolean default false;
alter table public.profiles add column if not exists age_verified boolean not null default false;
alter table public.profiles add column if not exists is_onboarded boolean default false;
alter table public.profiles add column if not exists kyc_status text default 'pending';
alter table public.profiles add column if not exists kyc_id_url text;
alter table public.profiles add column if not exists kyc_id_type text;
alter table public.profiles add column if not exists date_of_birth date;
alter table public.profiles add column if not exists gender text;
alter table public.profiles add column if not exists measurements jsonb;
alter table public.profiles add column if not exists address jsonb;
alter table public.profiles add column if not exists reviews_count int default 0;
alter table public.profiles add column if not exists rating numeric(2,1) default 0.0;
alter table public.profiles add column if not exists total_rentals int default 0;
alter table public.profiles add column if not exists total_listings int default 0;
alter table public.profiles add column if not exists total_orders int default 0;
alter table public.profiles add column if not exists response_rate numeric(3,1) default 0.0;
alter table public.profiles add column if not exists referral_code text;
alter table public.profiles add column if not exists referred_by text;
alter table public.profiles add column if not exists push_token text;
-- Standard aliases
alter table public.profiles add column if not exists name text;
alter table public.profiles add column if not exists phone text;

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- Auto-create profile row on signup (matches user's profiles schema)
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, phone_number, phone, role, is_vendor, is_admin, is_verified, age_verified, is_onboarded)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    new.phone,
    new.phone,
    'buyer',
    false,
    false,
    false,
    false,
    false
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
-- STEP 2: REMAINING PROFILE COLUMNS + OTHER TABLES
-- =============================================================================

-- products — extend with rental-flow fields the app needs
alter table public.products add column if not exists video_url text;
alter table public.products add column if not exists color text;
alter table public.products add column if not exists fabric text;
alter table public.products add column if not exists min_days int default 1;
alter table public.products add column if not exists max_days int default 14;
alter table public.products add column if not exists security_deposit numeric(10,2) default 0;
alter table public.products add column if not exists insurance_fee numeric(10,2);
alter table public.products add column if not exists pickup_address jsonb;
alter table public.products add column if not exists pickup_method text default 'both';
alter table public.products add column if not exists rejection_reason text;
alter table public.products add column if not exists reviewed_by uuid references public.profiles(id);
alter table public.products add column if not exists reviewed_at timestamptz;
alter table public.products add column if not exists bookings_count int default 0;

-- Drop the original strict products.status check and allow 'pending' and 'rejected'
-- (the Flutter app uses 'pending' for new listings awaiting admin review).
alter table public.products drop constraint if exists products_status_check;
alter table public.products add constraint products_status_check check (status in (
  'draft','pending','published','rejected','archived','rented','active'
));

-- orders — extend with rental-lifecycle fields
alter table public.orders add column if not exists cashfree_order_id text unique;
alter table public.orders add column if not exists cashfree_payment_id text;
alter table public.orders add column if not exists selected_size text;
alter table public.orders add column if not exists selected_color text;
alter table public.orders add column if not exists rental_days int;
alter table public.orders add column if not exists insurance_fee numeric(10,2) default 0;
alter table public.orders add column if not exists payment_status text default 'pending';
alter table public.orders add column if not exists escrow_status text default 'none';
alter table public.orders add column if not exists damage_claim_id uuid;
alter table public.orders add column if not exists completed_at timestamptz;
alter table public.orders add column if not exists pickup_method text;
alter table public.orders add column if not exists pickup_tracking_id text;
alter table public.orders add column if not exists rider_name text;
alter table public.orders add column if not exists rider_phone text;
alter table public.orders add column if not exists qc_notes text;
alter table public.orders add column if not exists cancelled_by uuid references public.profiles(id);
alter table public.orders add column if not exists order_number text unique;
alter table public.orders add column if not exists accepted_at timestamptz;
alter table public.orders add column if not exists delivered_at timestamptz;
alter table public.orders add column if not exists returned_at timestamptz;

-- Drop the original strict status check and replace with a broader one
-- that supports the full rental lifecycle.
alter table public.orders drop constraint if exists orders_status_check;
alter table public.orders add constraint orders_status_check check (status in (
  'pending','confirmed','accepted','rejected_by_lender',
  'lender_preparing','in_transit_to_renter','delivered_to_renter',
  'in_use','return_requested','in_transit_to_lender','delivered_to_lender',
  'in_return_qc','completed','shipped','delivered','returned',
  'cancelled','cancelled_by_renter','cancelled_by_lender'
));

-- payment_status: allow the full set
alter table public.orders drop constraint if exists orders_payment_status_check;
alter table public.orders add constraint orders_payment_status_check check (payment_status in (
  'pending','paid','refunded','partially_refunded','failed'
) or payment_status is null);

-- escrow_status
alter table public.orders drop constraint if exists orders_escrow_status_check;
alter table public.orders add constraint orders_escrow_status_check check (escrow_status in (
  'none','held','released','claimed'
) or escrow_status is null);

-- vendors
alter table public.vendors add column if not exists pickup_address jsonb;
alter table public.vendors add column if not exists rating numeric(2,1) default 0.0;
alter table public.vendors add column if not exists reviews_count int default 0;
alter table public.vendors add column if not exists total_listings int default 0;
alter table public.vendors add column if not exists completed_rentals int default 0;
alter table public.vendors add column if not exists bank_account jsonb;
alter table public.vendors add column if not exists kyc_status text default 'pending';

-- =============================================================================
-- NEW TABLES — wallet, support, ratings (user-to-user), referrals, etc.
-- =============================================================================

-- WINDOW: wallet_transactions
create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in (
    'topup','depositPaid','depositRefund','ugcCredit','referralBonus',
    'cashback','withdraw','damageClaim'
  )),
  amount numeric(10,2) not null check (amount > 0),
  description text,
  order_id uuid references public.orders(id) on delete set null,
  source_txn_id uuid references public.wallet_transactions(id) on delete set null,
  external_ref text,
  balance_after numeric(10,2),
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists idx_wallet_user on public.wallet_transactions(user_id);
create index if not exists idx_wallet_order on public.wallet_transactions(order_id);
create index if not exists idx_wallet_created on public.wallet_transactions(created_at desc);

-- Live view: available + held balance per user
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

-- DAMAGE CLAIMS
create table if not exists public.damage_claims (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  raised_by uuid not null references public.profiles(id),
  against_user uuid not null references public.profiles(id),
  damage_type text not null,
  description text not null,
  evidence_urls text[] not null default '{}',
  amount_claimed numeric(10,2) not null check (amount_claimed > 0),
  amount_approved numeric(10,2) default 0,
  deposit_total numeric(10,2) not null,
  status text not null default 'open' check (status in ('open','in_review','approved','partial','rejected','paid')),
  reviewer_id uuid references public.profiles(id),
  reviewer_notes text,
  created_at timestamptz not null default timezone('utc', now()),
  resolved_at timestamptz
);
create index if not exists idx_claims_order on public.damage_claims(order_id);
create index if not exists idx_claims_status on public.damage_claims(status);

-- RATINGS (user-to-user; reviews table is for product ratings)
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  rater_id uuid not null references public.profiles(id) on delete cascade,
  ratee_id uuid not null references public.profiles(id) on delete cascade,
  type text not null check (type in ('renter_to_lender','lender_to_renter')),
  score int not null check (score between 1 and 5),
  review text,
  communication_score int check (communication_score between 1 and 5),
  accuracy_score int check (accuracy_score between 1 and 5),
  delivery_score int check (delivery_score between 1 and 5),
  created_at timestamptz not null default timezone('utc', now()),
  unique (order_id, rater_id, type)
);
create index if not exists idx_ratings_ratee on public.ratings(ratee_id);
create index if not exists idx_ratings_order on public.ratings(order_id);

-- SUPPORT TICKETS
create table if not exists public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  category text not null check (category in ('booking','payment','damage','account','safety','other')),
  subject text not null,
  description text not null,
  attachments text[] not null default '{}',
  related_order_id uuid references public.orders(id) on delete set null,
  related_user_id uuid references public.profiles(id) on delete set null,
  priority text not null default 'normal' check (priority in ('low','normal','high')),
  status text not null default 'open' check (status in ('open','in_progress','resolved','closed')),
  assignee uuid references public.profiles(id),
  created_at timestamptz not null default timezone('utc', now()),
  resolved_at timestamptz
);
create index if not exists idx_tickets_user on public.support_tickets(user_id);
create index if not exists idx_tickets_status on public.support_tickets(status);

-- USER REPORTS
create table if not exists public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (reason in ('harassment','fake_listing','inappropriate','no_show','damaged_item','other')),
  notes text,
  related_order_id uuid references public.orders(id) on delete set null,
  status text not null default 'pending' check (status in ('pending','reviewed','actioned','dismissed')),
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists idx_reports_reporter on public.user_reports(reporter_id);
create index if not exists idx_reports_reported on public.user_reports(reported_user_id);

-- BLOCKED USERS
create table if not exists public.blocked_users (
  user_id uuid not null references public.profiles(id) on delete cascade,
  blocked_user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, blocked_user_id)
);

-- REFERRALS
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references public.profiles(id) on delete cascade,
  referee_id uuid not null references public.profiles(id) on delete cascade,
  code text not null,
  status text not null default 'pending' check (status in ('pending','signed_up','converted','paid')),
  reward numeric(10,2) default 250,
  created_at timestamptz not null default timezone('utc', now()),
  converted_at timestamptz,
  unique (referrer_id, referee_id)
);

-- UGC POSTS
create table if not exists public.ugc_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  media_url text not null,
  kind text not null default 'photo' check (kind in ('photo','reel')),
  caption text,
  hashtags text[] default '{}',
  product_id uuid references public.products(id) on delete set null,
  credit_awarded numeric(10,2) default 100,
  status text not null default 'published' check (status in ('draft','published','removed')),
  likes int default 0,
  created_at timestamptz not null default timezone('utc', now())
);
create index if not exists idx_ugc_user on public.ugc_posts(user_id);

-- PROMO CODES — already in your schema; seed the test ones
-- Drop the original strict discount_type check and allow 'percent' (the
-- Flutter app uses both 'percent' and 'percentage') for compatibility.
alter table public.promo_codes drop constraint if exists promo_codes_discount_type_check;
alter table public.promo_codes add constraint promo_codes_discount_type_check check (discount_type in ('percent','percentage','flat'));

insert into public.promo_codes (code, description, discount_type, discount_value, is_active)
values
  ('DRESS20', '20% off any rental', 'percentage', 20, true),
  ('FIRST50', '₹50 off first rental', 'flat', 50, true)
on conflict (code) do nothing;

-- =============================================================================
-- TRIGGERS — touch updated_at, recalc product rating, recalc user aggregates
-- =============================================================================

-- touch_updated_at: profiles
drop trigger if exists trg_profiles_touch on public.profiles;
create trigger trg_profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

-- touch_updated_at: products
drop trigger if exists trg_products_touch on public.products;
create trigger trg_products_touch before update on public.products
  for each row execute function public.touch_updated_at();

-- touch_updated_at: orders
drop trigger if exists trg_orders_touch on public.orders;
create trigger trg_orders_touch before update on public.orders
  for each row execute function public.touch_updated_at();

-- touch_updated_at: vendors
drop trigger if exists trg_vendors_touch on public.vendors;
create trigger trg_vendors_touch before update on public.vendors
  for each row execute function public.touch_updated_at();

-- touch_updated_at: chat
drop trigger if exists trg_chat_rooms_touch on public.chat_rooms;
create trigger trg_chat_rooms_touch before update on public.chat_rooms
  for each row execute function public.touch_updated_at();

-- Recalc products.average_rating and review_count
create or replace function public.recalc_product_rating()
returns trigger language plpgsql as $$
begin
  update public.products set
    average_rating = coalesce((select avg(rating)::numeric(2,1) from public.reviews where product_id = new.product_id), 5.0),
    review_count = (select count(*) from public.reviews where product_id = new.product_id)
  where id = new.product_id;
  return new;
end;
$$;

drop trigger if exists trg_review_recalc on public.reviews;
create trigger trg_review_recalc after insert or update on public.reviews
  for each row execute function public.recalc_product_rating();

-- Recalc profiles.rating / reviews_count on user-to-user rating
create or replace function public.recalc_user_aggregate()
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
  for each row execute function public.recalc_user_aggregate();

-- Order number generator
create or replace function public.set_order_number()
returns trigger language plpgsql as $$
begin
  if new.order_number is null then
    new.order_number = 'DR-' || lpad((extract(epoch from now())::bigint % 1000000)::text, 6, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_order_number on public.orders;
create trigger trg_order_number before insert on public.orders
  for each row execute function public.set_order_number();

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.profiles           enable row level security;
alter table public.vendors            enable row level security;
alter table public.products           enable row level security;
alter table public.orders             enable row level security;
alter table public.reviews            enable row level security;
alter table public.favorites          enable row level security;
alter table public.wishlist           enable row level security;
alter table public.cart_items         enable row level security;
alter table public.banners            enable row level security;
alter table public.newsletter_subscribers enable row level security;
alter table public.user_settings      enable row level security;
alter table public.addresses          enable row level security;
alter table public.search_history     enable row level security;
alter table public.ai_chat_sessions   enable row level security;
alter table public.ai_chat_messages   enable row level security;
alter table public.review_responses   enable row level security;
alter table public.app_feedback       enable row level security;
alter table public.chat_rooms         enable row level security;
alter table public.chat_messages      enable row level security;
alter table public.chat_attachments   enable row level security;
alter table public.notifications      enable row level security;
alter table public.rental_extensions  enable row level security;
alter table public.return_requests    enable row level security;
alter table public.early_pickup_requests enable row level security;
alter table public.early_pickup_photos enable row level security;
alter table public.promo_codes        enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.damage_claims      enable row level security;
alter table public.ratings            enable row level security;
alter table public.support_tickets    enable row level security;
alter table public.user_reports       enable row level security;
alter table public.blocked_users      enable row level security;
alter table public.referrals          enable row level security;
alter table public.ugc_posts          enable row level security;

-- PROFILES ----
drop policy if exists "profiles_select_all" on public.profiles;
create policy "profiles_select_all" on public.profiles
  for select using (true);
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());
drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self" on public.profiles
  for insert with check (id = auth.uid());

-- VENDORS ----
drop policy if exists "vendors_select_all" on public.vendors;
create policy "vendors_select_all" on public.vendors
  for select using (true);
drop policy if exists "vendors_insert_own" on public.vendors;
create policy "vendors_insert_own" on public.vendors
  for insert with check (user_id = auth.uid());
drop policy if exists "vendors_update_own" on public.vendors;
create policy "vendors_update_own" on public.vendors
  for update using (user_id = auth.uid() or public.is_admin());
drop policy if exists "vendors_delete_own" on public.vendors;
create policy "vendors_delete_own" on public.vendors
  for delete using (user_id = auth.uid() or public.is_admin());

-- PRODUCTS ----
drop policy if exists "products_select_active" on public.products;
create policy "products_select_active" on public.products
  for select using (
    status in ('published','active','rented')
    or exists (select 1 from public.vendors v where v.id = products.vendor_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "products_insert_vendor" on public.products;
create policy "products_insert_vendor" on public.products
  for insert with check (
    exists (select 1 from public.vendors v where v.id = products.vendor_id and v.user_id = auth.uid())
  );
drop policy if exists "products_update_vendor" on public.products;
create policy "products_update_vendor" on public.products
  for update using (
    exists (select 1 from public.vendors v where v.id = products.vendor_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "products_delete_vendor" on public.products;
create policy "products_delete_vendor" on public.products
  for delete using (
    exists (select 1 from public.vendors v where v.id = products.vendor_id and v.user_id = auth.uid())
    or public.is_admin()
  );

-- ORDERS ----
drop policy if exists "orders_select_parties" on public.orders;
create policy "orders_select_parties" on public.orders
  for select using (
    buyer_id = auth.uid()
    or exists (select 1 from public.vendors v where v.id = orders.vendor_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "orders_insert_buyer" on public.orders;
create policy "orders_insert_buyer" on public.orders
  for insert with check (buyer_id = auth.uid());
drop policy if exists "orders_update_parties" on public.orders;
create policy "orders_update_parties" on public.orders
  for update using (
    buyer_id = auth.uid()
    or exists (select 1 from public.vendors v where v.id = orders.vendor_id and v.user_id = auth.uid())
    or public.is_admin()
  );

-- REVIEWS ----
drop policy if exists "reviews_select_all" on public.reviews;
create policy "reviews_select_all" on public.reviews
  for select using (true);
drop policy if exists "reviews_insert_buyer" on public.reviews;
create policy "reviews_insert_buyer" on public.reviews
  for insert with check (user_id = auth.uid());

-- FAVORITES, WISHLIST, CART ----
drop policy if exists "favorites_own" on public.favorites;
create policy "favorites_own" on public.favorites
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "wishlist_own" on public.wishlist;
create policy "wishlist_own" on public.wishlist
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "cart_own" on public.cart_items;
create policy "cart_own" on public.cart_items
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- USER-LEVEL TABLES ----
drop policy if exists "user_settings_own" on public.user_settings;
create policy "user_settings_own" on public.user_settings
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "addresses_own" on public.addresses;
create policy "addresses_own" on public.addresses
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "search_history_own" on public.search_history;
create policy "search_history_own" on public.search_history
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- AI CHAT ----
drop policy if exists "ai_chat_sessions_own" on public.ai_chat_sessions;
create policy "ai_chat_sessions_own" on public.ai_chat_sessions
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "ai_chat_messages_own" on public.ai_chat_messages;
create policy "ai_chat_messages_own" on public.ai_chat_messages
  for all using (
    exists (select 1 from public.ai_chat_sessions s where s.id = session_id and s.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.ai_chat_sessions s where s.id = session_id and s.user_id = auth.uid())
  );

-- REVIEWS / FEEDBACK / RESPONSES ----
drop policy if exists "review_responses_select_all" on public.review_responses;
create policy "review_responses_select_all" on public.review_responses
  for select using (true);
drop policy if exists "review_responses_insert_vendor" on public.review_responses;
create policy "review_responses_insert_vendor" on public.review_responses
  for insert with check (
    exists (select 1 from public.vendors v where v.id = review_responses.vendor_id and v.user_id = auth.uid())
  );
drop policy if exists "app_feedback_own" on public.app_feedback;
create policy "app_feedback_own" on public.app_feedback
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- CHAT ----
drop policy if exists "chat_rooms_parties" on public.chat_rooms;
create policy "chat_rooms_parties" on public.chat_rooms
  for all using (participant_1 = auth.uid() or participant_2 = auth.uid() or public.is_admin())
  with check (participant_1 = auth.uid() or participant_2 = auth.uid());
drop policy if exists "chat_messages_parties" on public.chat_messages;
create policy "chat_messages_parties" on public.chat_messages
  for all using (
    sender_id = auth.uid()
    or exists (select 1 from public.chat_rooms r where r.id = room_id
               and (r.participant_1 = auth.uid() or r.participant_2 = auth.uid()))
    or public.is_admin()
  ) with check (sender_id = auth.uid());
drop policy if exists "chat_attachments_parties" on public.chat_attachments;
create policy "chat_attachments_parties" on public.chat_attachments
  for all using (
    exists (select 1 from public.chat_messages m where m.id = message_id
               and (m.sender_id = auth.uid()
                    or exists (select 1 from public.chat_rooms r where r.id = m.room_id
                               and (r.participant_1 = auth.uid() or r.participant_2 = auth.uid()))))
  ) with check (
    exists (select 1 from public.chat_messages m where m.id = message_id and m.sender_id = auth.uid())
  );

-- NOTIFICATIONS ----
drop policy if exists "notifications_own" on public.notifications;
create policy "notifications_own" on public.notifications
  for select using (user_id = auth.uid());
drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own" on public.notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "notifications_insert_admin" on public.notifications;
create policy "notifications_insert_admin" on public.notifications
  for insert with check (public.is_admin() or user_id = auth.uid());

-- RENTAL OPS (extensions, returns, early pickup) ----
drop policy if exists "rental_extensions_parties" on public.rental_extensions;
create policy "rental_extensions_parties" on public.rental_extensions
  for all using (
    user_id = auth.uid()
    or exists (select 1 from public.orders o
               join public.vendors v on v.id = o.vendor_id
               where o.id = rental_extensions.order_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "return_requests_parties" on public.return_requests;
create policy "return_requests_parties" on public.return_requests
  for all using (
    user_id = auth.uid()
    or exists (select 1 from public.orders o
               join public.vendors v on v.id = o.vendor_id
               where o.id = return_requests.order_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "early_pickup_parties" on public.early_pickup_requests;
create policy "early_pickup_parties" on public.early_pickup_requests
  for all using (
    user_id = auth.uid()
    or exists (select 1 from public.orders o
               join public.vendors v on v.id = o.vendor_id
               where o.id = early_pickup_requests.order_id and v.user_id = auth.uid())
    or public.is_admin()
  );
drop policy if exists "early_pickup_photos_parties" on public.early_pickup_photos;
create policy "early_pickup_photos_parties" on public.early_pickup_photos
  for all using (
    exists (select 1 from public.early_pickup_requests r
            where r.id = pickup_request_id
            and (r.user_id = auth.uid()
                 or exists (select 1 from public.orders o
                            join public.vendors v on v.id = o.vendor_id
                            where o.id = r.order_id and v.user_id = auth.uid())
                 or public.is_admin()))
  );

-- PROMO CODES (public read; admin write) ----
drop policy if exists "promo_select_active" on public.promo_codes;
create policy "promo_select_active" on public.promo_codes
  for select using (is_active = true or public.is_admin());
drop policy if exists "promo_admin_write" on public.promo_codes;
create policy "promo_admin_write" on public.promo_codes
  for all using (public.is_admin()) with check (public.is_admin());

-- WALLET ----
drop policy if exists "wallet_select_own" on public.wallet_transactions;
create policy "wallet_select_own" on public.wallet_transactions
  for select using (user_id = auth.uid() or public.is_admin());
drop policy if exists "wallet_insert_own" on public.wallet_transactions;
create policy "wallet_insert_own" on public.wallet_transactions
  for insert with check (user_id = auth.uid() or public.is_admin());

-- DAMAGE CLAIMS ----
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

-- RATINGS (user-to-user) ----
drop policy if exists "ratings_select_all" on public.ratings;
create policy "ratings_select_all" on public.ratings
  for select using (true);
drop policy if exists "ratings_insert_own" on public.ratings;
create policy "ratings_insert_own" on public.ratings
  for insert with check (rater_id = auth.uid());

-- SUPPORT TICKETS ----
drop policy if exists "tickets_select_own" on public.support_tickets;
create policy "tickets_select_own" on public.support_tickets
  for select using (user_id = auth.uid() or public.is_admin());
drop policy if exists "tickets_insert_own" on public.support_tickets;
create policy "tickets_insert_own" on public.support_tickets
  for insert with check (user_id = auth.uid());
drop policy if exists "tickets_update_admin" on public.support_tickets;
create policy "tickets_update_admin" on public.support_tickets
  for update using (user_id = auth.uid() or public.is_admin());

-- REPORTS & BLOCKS ----
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

-- REFERRALS, UGC ----
drop policy if exists "referrals_select_own" on public.referrals;
create policy "referrals_select_own" on public.referrals
  for select using (referrer_id = auth.uid() or referee_id = auth.uid());
drop policy if exists "referrals_insert_self" on public.referrals;
create policy "referrals_insert_self" on public.referrals
  for insert with check (referrer_id = auth.uid());

drop policy if exists "ugc_select_published" on public.ugc_posts;
create policy "ugc_select_published" on public.ugc_posts
  for select using (status = 'published' or user_id = auth.uid());
drop policy if exists "ugc_insert_own" on public.ugc_posts;
create policy "ugc_insert_own" on public.ugc_posts
  for insert with check (user_id = auth.uid());
drop policy if exists "ugc_update_own" on public.ugc_posts;
create policy "ugc_update_own" on public.ugc_posts
  for update using (user_id = auth.uid());

-- BANNERS (public read) ----
drop policy if exists "banners_select_active" on public.banners;
create policy "banners_select_active" on public.banners
  for select using (is_active = true or public.is_admin());
drop policy if exists "banners_admin_write" on public.banners;
create policy "banners_admin_write" on public.banners
  for all using (public.is_admin()) with check (public.is_admin());

-- NEWSLETTER (insert by anyone) ----
drop policy if exists "newsletter_insert_any" on public.newsletter_subscribers;
create policy "newsletter_insert_any" on public.newsletter_subscribers
  for insert with check (true);
drop policy if exists "newsletter_select_admin" on public.newsletter_subscribers;
create policy "newsletter_select_admin" on public.newsletter_subscribers
  for select using (public.is_admin());

-- =============================================================================
-- DONE. To verify:  select * from public.profiles limit 1;
--                  select * from public.wallet_balance limit 1;
-- =============================================================================
