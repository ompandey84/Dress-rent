CREATE TABLE public.promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  discount_type TEXT DEFAULT 'fixed' CHECK (discount_type IN ('fixed', 'percentage')),
  discount_value NUMERIC(10,2) NOT NULL,
  min_order_amount NUMERIC(10,2) DEFAULT 0.0,
  max_discount NUMERIC(10,2),
  max_uses INT,
  current_uses INT DEFAULT 0,
  valid_from TIMESTAMPTZ DEFAULT now(),
  valid_until TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.promo_code_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  promo_code_id UUID NOT NULL REFERENCES public.promo_codes(id),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  order_id UUID REFERENCES public.orders(id),
  used_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(promo_code_id, user_id)
);

ALTER TABLE public.promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promo_code_usages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active promos" ON public.promo_codes FOR SELECT USING (is_active = true);
CREATE POLICY "Users manage own promo usage" ON public.promo_code_usages FOR ALL USING (auth.uid() = user_id);
