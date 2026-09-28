-- Hoşboy secure backend schema (Supabase/PostgreSQL)
-- Admin security model: exactly TWO active admin accounts maximum.
-- Admin access is server-side via RLS; never trust a client-side "isAdmin" flag.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text unique,
  city text check (city in ('Änew','Aşgabat')),
  created_at timestamptz not null default now()
);

create table if not exists public.admins (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  label text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create or replace function public.enforce_two_admins()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.active then
    if (select count(*) from public.admins where active and user_id <> new.user_id) >= 2 then
      raise exception 'Hoşboy admin panelinde en fazla 2 aktif admin olabilir';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_two_admins on public.admins;
create trigger trg_two_admins
before insert or update on public.admins
for each row execute function public.enforce_two_admins();

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null check (category in ('Kadın','Erkek','Unisex')),
  price numeric(12,2) not null check (price >= 0),
  description text not null default '',
  image_url text,
  stock integer not null default 0 check (stock >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  customer_name text not null,
  phone text not null,
  home_address text not null,
  city text not null check (city in ('Änew','Aşgabat')),
  extra_info varchar(100),
  status text not null default 'new'
    check (status in ('new','confirmed','preparing','shipped','delivered','cancelled')),
  total numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  order_id uuid not null references public.orders(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  body text not null,
  created_at timestamptz not null default now(),
  unique(product_id, user_id, order_id)
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete set null,
  user_id uuid references public.profiles(id) on delete set null,
  order_id uuid references public.orders(id) on delete set null,
  question text not null,
  answer text,
  answered_by uuid references public.admins(user_id),
  created_at timestamptz not null default now(),
  answered_at timestamptz
);

-- A review is insertable only when the user owns a delivered order containing the product.
create or replace function public.can_review(p_product uuid, p_order uuid, p_user uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.orders o
    join public.order_items oi on oi.order_id = o.id
    where o.id = p_order
      and o.user_id = p_user
      and o.status = 'delivered'
      and oi.product_id = p_product
  );
$$;

-- Helper for RLS.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins a
    where a.user_id = auth.uid() and a.active = true
  );
$$;

alter table public.profiles enable row level security;
alter table public.admins enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;
alter table public.questions enable row level security;

-- Customers can see/update their own profile; admins can view all users.
create policy "profile self select" on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "profile self insert" on public.profiles for insert with check (id = auth.uid());
create policy "profile self update" on public.profiles for update using (id = auth.uid()) or public.is_admin();

-- Products are public to signed-in app users; only admins modify them.
create policy "products read" on public.products for select using (true);
create policy "products admin write" on public.products for all using (public.is_admin()) with check (public.is_admin());

-- Orders: customers see their own; admins see all.
create policy "orders read" on public.orders for select using (user_id = auth.uid() or public.is_admin());
create policy "orders customer insert" on public.orders for insert with check (user_id = auth.uid() or user_id is null);
create policy "orders admin update" on public.orders for update using (public.is_admin()) with check (public.is_admin());

create policy "order_items read" on public.order_items for select
using (exists(select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
create policy "order_items admin write" on public.order_items for all
using (public.is_admin()) with check (public.is_admin());

-- Reviews: everyone reads; insert only for verified purchasers; admins can moderate.
create policy "reviews read" on public.reviews for select using (true);
create policy "reviews verified insert" on public.reviews for insert
with check (user_id = auth.uid() and public.can_review(product_id, order_id, auth.uid()));
create policy "reviews admin manage" on public.reviews for all using (public.is_admin()) with check (public.is_admin());

-- Questions: customer can create/read own; admins read/update all.
create policy "questions read" on public.questions for select
using (user_id = auth.uid() or public.is_admin());
create policy "questions customer insert" on public.questions for insert
with check (user_id = auth.uid());
create policy "questions admin update" on public.questions for update
using (public.is_admin()) with check (public.is_admin());

-- IMPORTANT:
-- To select the two admins, insert only two rows into public.admins from a trusted
-- SQL/admin environment. Do NOT put their phone numbers in the Flutter source.
