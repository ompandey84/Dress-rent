CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  overall_rating INT NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
  quality_rating INT CHECK (quality_rating BETWEEN 1 AND 5),
  fit_rating INT CHECK (fit_rating BETWEEN 1 AND 5),
  value_rating INT CHECK (value_rating BETWEEN 1 AND 5),
  service_rating INT CHECK (service_rating BETWEEN 1 AND 5),
  comment TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Vendor responses to reviews (from vendor_ratings_screen)
CREATE TABLE public.review_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID NOT NULL REFERENCES public.reviews(id) ON DELETE CASCADE UNIQUE,
  vendor_id UUID NOT NULL REFERENCES public.profiles(id),
  response_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_reviews_product ON public.reviews(product_id);
CREATE INDEX idx_reviews_store ON public.reviews(store_id);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users create own reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own reviews" ON public.reviews FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view responses" ON public.review_responses FOR SELECT USING (true);
CREATE POLICY "Vendors create responses" ON public.review_responses FOR INSERT WITH CHECK (auth.uid() = vendor_id);
