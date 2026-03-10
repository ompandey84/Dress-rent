CREATE TABLE public.product_colors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  color_name TEXT NOT NULL,
  color_hex TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.size_guides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES public.categories(id),
  size_label TEXT NOT NULL,
  bust_cm NUMERIC(5,1),
  waist_cm NUMERIC(5,1),
  hips_cm NUMERIC(5,1),
  length_cm NUMERIC(5,1),
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.product_colors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.size_guides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view colors" ON public.product_colors FOR SELECT USING (true);
CREATE POLICY "Anyone can view size guides" ON public.size_guides FOR SELECT USING (true);
