CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  icon_url TEXT DEFAULT '',
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  logo_url TEXT DEFAULT '',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Anyone can view brands" ON public.brands FOR SELECT USING (true);

-- Seed initial categories from filters_bottom_sheet.dart
INSERT INTO public.categories (name, slug, display_order) VALUES
  ('Casual', 'casual', 1),
  ('Formal', 'formal', 2),
  ('Party', 'party', 3),
  ('Wedding', 'wedding', 4),
  ('Traditional', 'traditional', 5),
  ('Streetwear', 'streetwear', 6);

-- Seed brands from filters_bottom_sheet.dart
INSERT INTO public.brands (name, slug) VALUES
  ('ZARA', 'zara'),
  ('H&M', 'hm'),
  ('Gucci', 'gucci'),
  ('Prada', 'prada'),
  ('Mango', 'mango'),
  ('Givenchy', 'givenchy');
