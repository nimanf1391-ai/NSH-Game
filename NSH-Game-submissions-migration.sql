-- NSH.Game: User Game Submissions
-- قبل از اجرا، از دیتابیس بکاپ بگیر.

create table if not exists public.game_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  slug text not null,
  description text,
  developer text,
  category_id bigint references public.categories(id),
  game_type text not null
    check (game_type in ('browser','external','download')),
  game_url text,
  thumbnail_url text,
  status text not null default 'pending'
    check (status in ('pending','approved','rejected')),
  admin_note text,
  created_at timestamptz not null default now()
);

alter table public.game_submissions enable row level security;

create policy "Users can submit their own games"
on public.game_submissions
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can view their own submissions"
on public.game_submissions
for select
to authenticated
using (
  auth.uid() = user_id
  or public.is_nsh_admin()
);

create policy "Admins can update submissions"
on public.game_submissions
for update
to authenticated
using (public.is_nsh_admin())
with check (public.is_nsh_admin());
