CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id),
  brand_id UUID REFERENCES public.brands(id),
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  rental_price_per_day NUMERIC(10,2) NOT NULL,
  original_price NUMERIC(10,2) DEFAULT 0.0,
  security_deposit NUMERIC(10,2) DEFAULT 0.0,
  gender TEXT DEFAULT 'Unisex' CHECK (gender IN ('Male', 'Female', 'Unisex')),
  rating NUMERIC(3,2) DEFAULT 0.0,
  reviews_count INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  available_from DATE,
  available_until DATE,
  ar_model_url TEXT DEFAULT '',
  video_url TEXT DEFAULT '',
  total_rentals INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.product_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.product_sizes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  size TEXT NOT NULL,
  quantity INT DEFAULT 0,
  available_quantity INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_products_category ON public.products(category_id);
CREATE INDEX idx_products_brand ON public.products(brand_id);
CREATE INDEX idx_products_store ON public.products(store_id);
CREATE INDEX idx_products_rating ON public.products(rating DESC);
CREATE INDEX idx_products_price ON public.products(rental_price_per_day);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_sizes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active products" ON public.products FOR SELECT USING (true);
CREATE POLICY "Store owners manage products" ON public.products FOR ALL USING (
  auth.uid() = (SELECT owner_id FROM public.stores WHERE id = store_id)
);

CREATE POLICY "Anyone can view product images" ON public.product_images FOR SELECT USING (true);
CREATE POLICY "Store owners manage images" ON public.product_images FOR ALL USING (
  auth.uid() = (SELECT s.owner_id FROM public.stores s JOIN public.products p ON p.store_id = s.id WHERE p.id = product_id)
);

CREATE POLICY "Anyone can view product sizes" ON public.product_sizes FOR SELECT USING (true);
CREATE POLICY "Store owners manage sizes" ON public.product_sizes FOR ALL USING (
  auth.uid() = (SELECT s.owner_id FROM public.stores s JOIN public.products p ON p.store_id = s.id WHERE p.id = product_id)
);
