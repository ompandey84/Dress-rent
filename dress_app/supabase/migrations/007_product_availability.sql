-- Track which dates a product is booked
CREATE TABLE public.product_availability (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  booked_date DATE NOT NULL,
  order_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(product_id, booked_date)
);

-- Vendor-set blocked dates
CREATE TABLE public.blackout_dates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  blocked_date DATE NOT NULL,
  reason TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(product_id, blocked_date)
);

CREATE INDEX idx_availability_product_date ON public.product_availability(product_id, booked_date);
CREATE INDEX idx_blackout_product_date ON public.blackout_dates(product_id, blocked_date);

ALTER TABLE public.product_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blackout_dates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view availability" ON public.product_availability FOR SELECT USING (true);
CREATE POLICY "Anyone can view blackouts" ON public.blackout_dates FOR SELECT USING (true);
CREATE POLICY "Store owners manage blackouts" ON public.blackout_dates FOR ALL USING (
  auth.uid() = (SELECT s.owner_id FROM public.stores s JOIN public.products p ON p.store_id = s.id WHERE p.id = product_id)
);
