# P2P Rental Marketplace — Implementation Plan

## 🎯 Vision
Two-sided marketplace: **Renters** discover & rent outfits from **Lenders**, with built-in escrow, QC, damage protection, and dispute resolution. Mobile-first Flutter app + backend + admin.

---

## 🧱 Tech Stack

| Layer | Tech |
|---|---|
| Mobile App | Flutter (existing) |
| Local State | Provider + ChangeNotifier (`AppState`) |
| Backend | Supabase (PostgreSQL + Auth + Realtime + Storage) |
| Payments | **Cashfree** (`cashfree_pg` Flutter package) — supports UPI, cards, wallets, net banking |
| Delivery | Third-party logistics API (Delhivery / Dunzo / custom rider app) |
| Push Notifications | Firebase Cloud Messaging |
| Admin | Supabase Studio + custom dashboard (Flutter Web or React) |
| Image/Video | Supabase Storage + Cloudflare Stream |

---

## 🏗️ Architecture Overview

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Renter App │◀────▶│   Supabase   │◀────▶│  Lender App  │
└──────────────┘      │  (Auth+DB+   │      └──────────────┘
                      │  Realtime+   │
┌──────────────┐      │  Storage)    │      ┌──────────────┐
│  Admin Web   │◀────▶│              │◀────▶│ Stripe/      │
└──────────────┘      └──────────────┘      │ Payments     │
                                            └──────────────┘
```

---

## 📦 Data Models (Core Tables)

```sql
users              (id, name, phone, email, avatar, is_verified, kyc_status, role)
user_measurements  (user_id, bust, waist, hips, height, shoulder, inseam, updated_at)
listings           (id, lender_id, title, description, category, size, color, 
                    rental_price_per_day, deposit, address_id, status, photos[], 
                    video_url, ar_model_url, condition, occasion_tags[], 
                    available_from, available_until)
listing_availability (listing_id, date, is_available)
bookings           (id, listing_id, renter_id, start_date, end_date, 
                    rental_fee, deposit, delivery_fee, insurance_fee, total, 
                    status, escrow_status, payment_intent_id, 
                    pickup_photos[], return_photos[], damage_notes)
delivery           (id, booking_id, rider_id, type, status, 
                    pickup_photos[], delivery_photos[], tracking_url, scheduled_at)
damage_claims      (id, booking_id, type, amount, photos[], 
                    status, resolution_notes, resolved_by, resolved_at)
ratings            (id, booking_id, rater_id, ratee_id, score, review, type)
payments           (id, booking_id, type, amount, status, txn_id, method)
payouts            (id, lender_id, amount, commission, status, scheduled_at)
ugc_posts          (id, user_id, booking_id, media_url, caption, hashtags[], likes)
follows            (follower_id, followee_id)
wishlist           (user_id, listing_id, added_at)
waitlist           (user_id, listing_id, start_date, end_date)
disputes           (id, booking_id, raised_by, reason, status, admin_notes)
support_tickets    (id, user_id, subject, body, status, assigned_to, messages[])
notifications      (id, user_id, type, title, body, data, read_at, created_at)
```

---

## 🚀 Phased Roadmap

### **Phase 0: Foundation** (Week 1-2) — *Re-enable real backend*
- [ ] Re-enable Supabase connection (currently mocked)
- [ ] Add `.env` config for `SUPABASE_URL` / `SUPABASE_ANON_KEY`
- [ ] Set up PostgreSQL schema (all tables above)
- [ ] Add Row-Level Security (RLS) policies:
  - Users can read their own data
  - Lenders can edit only their listings
  - Public read on active listings
- [ ] Auth flow (Phone + OTP via Supabase Auth)
- [ ] KYC upload (ID image → Supabase Storage)

### **Phase 1: Onboarding** (Week 2)
- [ ] `OnboardingScreen` 3-page tutorial (already exists, enhance visuals)
- [ ] Age confirmation gate
- [ ] `SignupScreen` — Phone/Email + OTP
- [ ] `KycScreen` — ID upload, basic profile
- [ ] Terms/Privacy acceptance with timestamp
- [ ] `MeasurementsScreen` — Optional size/measurements
- [ ] `UserProfile` enriched with `kycStatus`, `measurements`, `role`

### **Phase 2: Discovery (Renter Side)** (Week 3-4)
- [ ] **Reels Feed** — vertical video scroll (`ReelsScreen`)
  - Use `video_player` package
  - Pull from `ugc_posts` + listing reels
  - Like/save/share inline
- [ ] **Browse tab** — grid + filters
  - Date picker (range)
  - Location (city/area)
  - Size
  - Occasion tags
  - Price slider
- [ ] **Curated Collections** — themed bundles (Wedding Guest, Cocktail, Festive)
- [ ] **Follow Feed** — posts from followed lenders/influencers
- [ ] **Search** — full-text search on listings
- [ ] **Wishlist** — save items, get notified on price drop
- [ ] `ItemDetailScreen` rewrite:
  - Photo carousel + 360° view
  - Size guide modal (vs saved measurements)
  - Lender profile (rating, reviews, response rate)
  - "Message Lender" CTA
  - "Complete the Look" similar items carousel
  - Availability calendar

### **Phase 3: Booking & Payments** (Week 5)
- [ ] `SelectDatesScreen` — calendar showing blocked dates
- [ ] Waitlist flow for unavailable dates (with notification)
- [ ] `BookingSummaryScreen` — fee breakdown
- [ ] `InsuranceAddonScreen` — damage protection opt-in
- [ ] `PaymentScreen` — UPI/Card/Wallet
  - **Cashfree payment gateway** (via `cashfree_pg` package)
  - Edge Function creates order, returns `payment_session_id`
  - Open Cashfree checkout sheet
  - Verify payment via webhook
- [ ] Escrow logic: funds held until delivery confirmed
- [ ] `BookingConfirmedScreen` + rental agreement PDF
- [ ] Push notification to lender on new booking

### **Phase 4: Lender Fulfillment** (Week 6)
- [ ] `BookingListScreen` for lenders (incoming requests)
- [ ] `AcceptBookingModal` — accept/reject with reason
- [ ] Auto-cancel timer (e.g., 4 hours to accept → full refund)
- [ ] `PackItemScreen` — checklist + photo upload
- [ ] Schedule pickup (self-drop or request rider)

### **Phase 5: Delivery & QC** (Week 7-8)
- [ ] Rider dispatch system (or integration with 3PL API)
- [ ] `DeliveryTrackingScreen` — live status for both parties
- [ ] **Pickup QC** — photos at lender's location (timestamped)
- [ ] **Delivery QC** — photos at renter's location
- [ ] **Rejection at delivery** — instant refund if item doesn't match
- [ ] **Reschedule** — if renter not available
- [ ] In-app chat between renter/lender/rider

### **Phase 6: Return Flow** (Week 9)
- [ ] `ReturnReminderScreen` — push notifications
- [ ] Late fee auto-accrual (cron job)
- [ ] **Return QC** — photos at renter's location
- [ ] **Lost in transit** — courier liability flow
- [ ] **Damage check** — deposit deduction with photos
- [ ] Dispute flow (renter can challenge damage claim)
- [ ] In-transit return tracking

### **Phase 7: Post-Order** (Week 10)
- [ ] **Escrow release** — after lender confirms return condition
- [ ] **Mutual rating** — both parties rate within 7 days
- [ ] **Weekly payout** to lenders (minus 15-20% commission)
- [ ] **UGC prompt** — share outfit photo to Reels for credit
- [ ] **Referral program** — share link, both get credit

### **Phase 8: Lender Listing Flow** (Week 11)
- [ ] `LendTab` from home
- [ ] `UploadItemScreen` — multi-photo + short video
- [ ] `ItemDetailsScreen` — size, category, occasion, condition
- [ ] `SetPriceScreen` — per-day price + availability calendar
- [ ] `SetPickupAddressScreen` — address book
- [ ] **Admin approval** — listings reviewed before going live
- [ ] Listing rejected → reason sent to lender

### **Phase 9: Support & Trust** (Week 12)
- [ ] `HelpCenterScreen` — FAQ categories
- [ ] `SupportTicketScreen` — create ticket with attachments
- [ ] `ReportUserModal` — with reason categories
- [ ] `BlockUserScreen` — manage blocked users
- [ ] In-app chat escalation to support

### **Phase 10: Profile** (Week 13)
- [ ] `MyRentalsScreen` — bookings as renter (with status)
- [ ] `MyListingsScreen` — listings as lender
- [ ] `EarningsScreen` — payout history + pending
- [ ] `WalletScreen` — deposit/refund history
- [ ] `MeasurementsScreen` — edit saved measurements
- [ ] `NotificationSettingsScreen` — granular controls
- [ ] `SavedAddressesScreen` — address book
- [ ] `PaymentMethodsScreen` — saved cards/UPI

### **Phase 11: Admin Dashboard** (Week 14-15)
- [ ] Web app (React or Flutter Web)
- [ ] Approve/reject listings with reason
- [ ] Resolve damage disputes (view photos, side-by-side comparison)
- [ ] Live delivery monitoring map
- [ ] GMV / commission / cohort analytics
- [ ] User management (suspend/ban)
- [ ] Refund/cancellation tools

### **Phase 12: Polish & Growth** (Week 16+)
- [ ] AI outfit recommendations (size match, occasion)
- [ ] AR try-on (using existing `arModelUrl` field)
- [ ] Social features (comments, follows, likes)
- [ ] Influencer program (verified badges, analytics)
- [ ] Loyalty program / credits
- [ ] Multi-region (currency, language, logistics)
- [ ] Native iOS push + Android push polish

---

## 🔐 Key Architectural Decisions

### 1. **Escrow Flow**
```
Renter pays ──▶ Stripe holds ──▶ 24h after delivery confirmed
   │                                       │
   │                                       ▼
   │                              Auto-release to lender
   │                              Refund deposit to renter
   │
   └──▶ If damage claim → hold funds until dispute resolved
```

### 2. **Cashfree Payment Integration**

**Why Cashfree:** Best for Indian market — UPI, cards, wallets, net banking all supported, low fees, instant settlement.

**Architecture:**
```
Flutter App ──▶ Backend (Supabase Edge Function) ──▶ Cashfree API
   │                    │
   │                    └──▶ Creates order, returns payment_session_id
   │
   └──▶ Opens Cashfree payment sheet with session_id
                    │
                    └──▶ User pays
                              │
                              └──▶ Cashfree webhook ──▶ Backend verifies ──▶ Update booking
```

**Setup steps:**
1. Create Cashfree account at [merchant.cashfree.com](https://merchant.cashfree.com)
2. Get `APP_ID` and `SECRET_KEY` (test mode first)
3. Add to `.env`:
   ```
   CASHFREE_APP_ID=your_app_id
   CASHFREE_SECRET_KEY=your_secret_key
   CASHFREE_ENV=SANDBOX  # or PRODUCTION
   ```
4. Use `cashfree_pg` Flutter package for the payment UI
5. Backend Edge Function handles order creation + verification

**Escrow model:**
- Pay rental fee + deposit + insurance to platform
- Cashfree order created with full amount
- Funds held in platform account
- On delivery confirmation → auto-release rental fee to lender
- On return confirmed + 24h grace → refund deposit to renter
- Damage claim → deposit partially held until dispute resolved

**Package:** `cashfree_pg: ^2.0.0` (latest stable)

### 3. **Realtime Updates**
- Use Supabase Realtime for:
  - Chat messages
  - Booking status changes
  - Delivery tracking
  - Notifications
  - New reels/posts in feed

### 4. **Image/Video Strategy**
- Multiple sizes via Supabase image transforms
- Lazy loading with `cached_network_image`
- Video previews ≤ 15s, 720p
- Cloudflare Stream for video hosting (better than Supabase)

### 4. **Damage Protection**
- Optional insurance addon (5-8% of rental fee)
- Covers damage up to 100% of item value
- Without insurance: max deduction = deposit amount

### 5. **Commission Model**
- Platform takes 15-20% of rental fee (excluding deposit)
- No commission on deposit (always refundable)
- Lender sets deposit amount (or platform suggests based on item value)

---

## 📱 Current App Mapping

| Flowchart | Existing Screen | Status |
|---|---|---|
| Onboarding | `OnboardingScreen` | ✅ Exists, enhance |
| Auth | `LoginScreen`, `SignupScreen` | ✅ Exists, wire to backend |
| KYC | ❌ | ⏳ Need to build |
| Home Feed | `HomeScreen` | ✅ Exists, refactor for new fields |
| Browse | `CategoryListingScreen` | ✅ Exists |
| Search | `SearchResultsScreen` | ✅ Exists |
| Item Detail | `ProductDetailsScreen` | ✅ Exists, expand |
| Wishlist | ❌ | ⏳ Need to build |
| Cart | `CartScreen` | ✅ Exists, redesign as rental cart |
| Booking | `SelectDatesScreen`, `CheckoutScreen` | ✅ Exists, add escrow |
| Payment | `AddCardScreen` | ✅ Exists, add Stripe |
| My Orders | `MyOrdersScreen` | ✅ Exists |
| Order Tracking | `OrderStatus/*` | ✅ Exists |
| Profile | `ProfileScreen` | ✅ Exists, expand |
| Chat | `ChatScreen` | ✅ Exists, wire realtime |
| Notifications | `NotificationsScreen` | ✅ Exists |
| Lend Tab | `Vendor/*` screens | ✅ Exists (vendor flow) |
| Reels | ❌ | ⏳ New feature |
| Collections | ❌ | ⏳ New feature |
| Follow Feed | ❌ | ⏳ New feature |
| Damage Claim | ❌ | ⏳ New feature |
| Support | `HelpSupportScreen` | ✅ Exists, expand |
| Admin | ❌ | ⏳ New web app |

---

## ⚡ Quick-Win Priorities (Do These First)

If you want to ship fast, focus on:
1. **Re-enable real backend** (Supabase) — unblocks all data work
2. **Wishlist + Save** — easy engagement driver
3. **Reels feed** — biggest growth lever
4. **Damage claim flow** — biggest trust builder
5. **Mutual ratings** — improves marketplace quality
6. **Push notifications** — improves retention

---

## 📅 Estimated Timeline

- **Phases 0-3** (Auth + Discovery + Booking): **5 weeks**
- **Phases 4-7** (Fulfillment + Return + Post-order): **5 weeks**
- **Phases 8-10** (Lend + Support + Profile): **3 weeks**
- **Phase 11** (Admin): **2 weeks**
- **Phase 12** (Polish): Ongoing

**Total MVP: ~15 weeks** (assuming 1-2 devs)

---

## 🚦 Next Step

Want me to:
1. Start with **Phase 0** (re-enable Supabase + schema setup)?
2. Build the **Wishlist** feature first (quick win)?
3. Tackle the **Reels feed** (biggest impact)?
4. Or focus on the **Damage Claim flow** (biggest trust)?

Tell me which phase to start, and I'll plan & execute it. 🚀
