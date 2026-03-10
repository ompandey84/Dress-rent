-- Vendor-side transaction log
CREATE TABLE public.vendor_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_profile_id UUID NOT NULL REFERENCES public.vendor_profiles(id),
  order_id UUID REFERENCES public.orders(id),
  booking_reference TEXT DEFAULT '',
  dress_name TEXT DEFAULT '',
  amount NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'credited', 'failed')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Vendor bookings (maps orders from vendor perspective)
CREATE TABLE public.vendor_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_reference TEXT NOT NULL UNIQUE,
  vendor_profile_id UUID NOT NULL REFERENCES public.vendor_profiles(id),
  order_id UUID NOT NULL REFERENCES public.orders(id),
  product_id UUID NOT NULL REFERENCES public.products(id),
  customer_name TEXT NOT NULL,
  rental_dates TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'ready', 'dispatched', 'returned', 'declined')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Influencer/User Posts ("Post Your Look")
CREATE TABLE public.influencer_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  product_id UUID REFERENCES public.products(id),
  likes_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- FAQ content
CREATE TABLE public.faqs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category TEXT DEFAULT 'general',
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Search history for suggestions
CREATE TABLE public.search_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.vendor_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.influencer_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Vendors view own transactions" ON public.vendor_transactions FOR SELECT USING (
  auth.uid() = (SELECT user_id FROM public.vendor_profiles WHERE id = vendor_profile_id)
);
CREATE POLICY "Vendors manage own bookings" ON public.vendor_bookings FOR ALL USING (
  auth.uid() = (SELECT user_id FROM public.vendor_profiles WHERE id = vendor_profile_id)
);
CREATE POLICY "Anyone can view posts" ON public.influencer_posts FOR SELECT USING (true);
CREATE POLICY "Users create own posts" ON public.influencer_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Anyone can view FAQs" ON public.faqs FOR SELECT USING (is_active = true);
CREATE POLICY "Users manage own search history" ON public.search_history FOR ALL USING (auth.uid() = user_id);

-- Seed FAQ data from help_support_screen.dart
INSERT INTO public.faqs (question, answer, display_order) VALUES
  ('How does dress rental work?', 'Browse our collection, select your dates, and we deliver the dress to your door. Return it when your rental period ends.', 1),
  ('What if a dress doesn''t fit?', 'We offer free exchanges within 24 hours of delivery. Check our size guide for accurate measurements.', 2),
  ('How are dresses cleaned?', 'All dresses are professionally dry-cleaned and inspected between rentals. We guarantee freshness.', 3),
  ('What is the cancellation policy?', 'Cancel up to 48 hours before rental start for a full refund. Within 48 hours, a 20% fee applies.', 4),
  ('Can I extend my rental?', 'Yes! Extend through the app before your rental ends. Additional daily charges apply.', 5);
