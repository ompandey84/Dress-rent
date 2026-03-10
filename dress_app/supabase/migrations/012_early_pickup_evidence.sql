CREATE TABLE public.early_pickup_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pickup_request_id UUID NOT NULL REFERENCES public.early_pickup_requests(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.early_pickup_photos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own photos" ON public.early_pickup_photos FOR ALL USING (
  auth.uid() = (SELECT user_id FROM public.early_pickup_requests WHERE id = pickup_request_id)
);
