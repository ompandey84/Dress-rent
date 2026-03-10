CREATE TABLE public.rental_extensions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  original_end_date DATE NOT NULL,
  new_end_date DATE NOT NULL,
  additional_fee NUMERIC(10,2) DEFAULT 0.0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.return_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  reason TEXT DEFAULT '',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'rejected')),
  initiated_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE public.early_pickup_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  reason TEXT NOT NULL,
  additional_notes TEXT DEFAULT '',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'completed', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.rental_extensions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.return_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.early_pickup_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own extensions" ON public.rental_extensions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own returns" ON public.return_requests FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own pickups" ON public.early_pickup_requests FOR ALL USING (auth.uid() = user_id);
