CREATE TABLE public.vendor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  store_id UUID REFERENCES public.stores(id),
  business_name TEXT NOT NULL,
  vendor_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  shop_address TEXT DEFAULT '',
  city TEXT DEFAULT '',
  state TEXT DEFAULT '',
  pincode TEXT DEFAULT '',
  verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.vendor_bank_details (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_profile_id UUID NOT NULL REFERENCES public.vendor_profiles(id) ON DELETE CASCADE UNIQUE,
  account_holder_name TEXT NOT NULL,
  bank_account_number TEXT NOT NULL,
  ifsc_code TEXT NOT NULL,
  upi_id TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Cached analytics for vendor dashboard
CREATE TABLE public.vendor_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_profile_id UUID NOT NULL REFERENCES public.vendor_profiles(id) ON DELETE CASCADE UNIQUE,
  total_inventory INT DEFAULT 0,
  active_rentals INT DEFAULT 0,
  pending_returns INT DEFAULT 0,
  total_earnings NUMERIC(12,2) DEFAULT 0.0,
  this_month_earnings NUMERIC(12,2) DEFAULT 0.0,
  pending_payments NUMERIC(12,2) DEFAULT 0.0,
  earnings_trend_percent NUMERIC(5,2) DEFAULT 0.0,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.vendor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_bank_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_analytics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own vendor profile" ON public.vendor_profiles FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own bank details" ON public.vendor_bank_details FOR ALL USING (
  auth.uid() = (SELECT user_id FROM public.vendor_profiles WHERE id = vendor_profile_id)
);
CREATE POLICY "Vendors view own analytics" ON public.vendor_analytics FOR SELECT USING (
  auth.uid() = (SELECT user_id FROM public.vendor_profiles WHERE id = vendor_profile_id)
);
