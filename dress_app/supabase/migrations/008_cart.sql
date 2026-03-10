CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  selected_size TEXT NOT NULL,
  selected_color TEXT NOT NULL,
  rental_start_date DATE NOT NULL,
  rental_end_date DATE NOT NULL,
  quantity INT DEFAULT 1,
  locked_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own cart" ON public.cart_items FOR ALL USING (auth.uid() = user_id);
