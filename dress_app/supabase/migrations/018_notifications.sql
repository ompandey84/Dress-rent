CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('order', 'promo', 'general', 'booking', 'payment', 'return', 'review', 'damage', 'listing')),
  is_read BOOLEAN DEFAULT FALSE,
  related_order_id UUID REFERENCES public.orders(id),
  related_product_id UUID REFERENCES public.products(id),
  deep_link TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notifications_user ON public.notifications(user_id, created_at DESC);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);
