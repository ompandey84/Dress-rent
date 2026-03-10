CREATE TABLE public.app_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  feedback_text TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.app_feedback ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users create own feedback" ON public.app_feedback FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users view own feedback" ON public.app_feedback FOR SELECT USING (auth.uid() = user_id);
