CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  label TEXT NOT NULL DEFAULT 'Home',
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT DEFAULT '',
  zip_code TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own addresses" ON public.addresses FOR ALL USING (auth.uid() = user_id);
