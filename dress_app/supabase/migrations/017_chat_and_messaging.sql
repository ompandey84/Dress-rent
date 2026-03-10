CREATE TABLE public.chat_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_1 UUID NOT NULL REFERENCES public.profiles(id),
  participant_2 UUID NOT NULL REFERENCES public.profiles(id),
  last_message TEXT DEFAULT '',
  last_message_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id),
  text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.chat_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
  file_url TEXT NOT NULL,
  file_type TEXT DEFAULT 'image',
  file_name TEXT DEFAULT '',
  file_size_bytes BIGINT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- AI Stylist Assistant
CREATE TABLE public.ai_chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT DEFAULT 'AI Stylist',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.ai_chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.ai_chat_sessions(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participants view rooms" ON public.chat_rooms FOR SELECT USING (
  auth.uid() = participant_1 OR auth.uid() = participant_2
);
CREATE POLICY "Participants manage messages" ON public.chat_messages FOR ALL USING (
  auth.uid() IN (SELECT participant_1 FROM public.chat_rooms WHERE id = room_id
                 UNION SELECT participant_2 FROM public.chat_rooms WHERE id = room_id)
);
CREATE POLICY "Users manage own AI sessions" ON public.ai_chat_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own AI messages" ON public.ai_chat_messages FOR ALL USING (
  auth.uid() = (SELECT user_id FROM public.ai_chat_sessions WHERE id = session_id)
);
