CREATE TABLE public.stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  banner_url TEXT DEFAULT '',
  logo_url TEXT DEFAULT '',
  location TEXT DEFAULT '',
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_verified BOOLEAN DEFAULT FALSE,
  rating NUMERIC(3,2) DEFAULT 0.0,
  reviews_count INT DEFAULT 0,
  total_products INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view stores" ON public.stores FOR SELECT USING (true);
CREATE POLICY "Owners manage own store" ON public.stores FOR ALL USING (auth.uid() = owner_id);
