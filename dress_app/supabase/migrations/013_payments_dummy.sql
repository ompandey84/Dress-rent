-- DUMMY: No real payment processing. Stores card details for UI display.
CREATE TABLE public.payment_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  cardholder_name TEXT NOT NULL,
  card_last_four TEXT NOT NULL,
  card_brand TEXT DEFAULT 'Visa',
  expiry_month INT NOT NULL,
  expiry_year INT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  amount NUMERIC(10,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('payment', 'refund', 'deposit', 'deposit_return', 'cancellation_fee')),
  status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
  payment_method TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.payment_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own cards" ON public.payment_cards FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users view own transactions" ON public.transactions FOR SELECT USING (auth.uid() = user_id);
