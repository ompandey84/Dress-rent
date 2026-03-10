CREATE TYPE public.order_status AS ENUM (
  'requested', 'preparing', 'out_for_delivery', 'delivered', 'refunded', 'cancelled'
);

CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  store_id UUID NOT NULL REFERENCES public.stores(id),
  shipping_address_id UUID REFERENCES public.addresses(id),
  status public.order_status DEFAULT 'requested',
  subtotal NUMERIC(10,2) NOT NULL,
  delivery_fee NUMERIC(10,2) DEFAULT 0.0,
  security_deposit NUMERIC(10,2) DEFAULT 0.0,
  discount NUMERIC(10,2) DEFAULT 0.0,
  total NUMERIC(10,2) NOT NULL,
  promo_code TEXT DEFAULT '',
  payment_method TEXT DEFAULT '',
  rental_start_date DATE,
  rental_end_date DATE,
  estimated_delivery DATE,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT DEFAULT '',
  cancellation_fee NUMERIC(10,2) DEFAULT 0.0,
  refunded_at TIMESTAMPTZ,
  refund_amount NUMERIC(10,2) DEFAULT 0.0,
  refund_method TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id),
  product_name TEXT NOT NULL,
  product_image_url TEXT DEFAULT '',
  selected_size TEXT NOT NULL,
  selected_color TEXT NOT NULL,
  rental_price NUMERIC(10,2) NOT NULL,
  quantity INT DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_orders_user ON public.orders(user_id);
CREATE INDEX idx_orders_store ON public.orders(store_id);
CREATE INDEX idx_orders_status ON public.orders(status);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Vendors view store orders" ON public.orders FOR SELECT USING (
  auth.uid() = (SELECT owner_id FROM public.stores WHERE id = store_id)
);
CREATE POLICY "Users create orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Vendors update order status" ON public.orders FOR UPDATE USING (
  auth.uid() = (SELECT owner_id FROM public.stores WHERE id = store_id)
);

CREATE POLICY "Users view own order items" ON public.order_items FOR SELECT USING (
  auth.uid() = (SELECT user_id FROM public.orders WHERE id = order_id)
);
CREATE POLICY "Vendors view store order items" ON public.order_items FOR SELECT USING (
  auth.uid() = (SELECT s.owner_id FROM public.stores s JOIN public.orders o ON o.store_id = s.id WHERE o.id = order_id)
);
