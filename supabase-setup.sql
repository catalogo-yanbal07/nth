create table if not exists public.catalog_settings (
  id boolean primary key default true check (id),
  owner_id uuid references auth.users (id) on delete set null,
  setup_code_hash text
);

insert into public.catalog_settings (id)
values (true)
on conflict (id) do nothing;

create table if not exists public.yanbal_products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 80),
  price numeric(12, 2) not null check (price >= 0),
  currency text not null default '$' check (char_length(currency) between 1 and 5),
  photo text not null default '',
  created_at timestamptz not null default now()
);

alter table public.catalog_settings enable row level security;
alter table public.yanbal_products enable row level security;

revoke all on public.catalog_settings from anon, authenticated;
grant select on public.catalog_settings to anon, authenticated;

revoke all on public.yanbal_products from anon, authenticated;
grant select on public.yanbal_products to anon, authenticated;
grant insert, update, delete on public.yanbal_products to authenticated;

drop policy if exists "Anyone can view catalog settings" on public.catalog_settings;
create policy "Anyone can view catalog settings"
  on public.catalog_settings for select
  using (true);

drop policy if exists "Anyone can view Yanbal products" on public.yanbal_products;
create policy "Anyone can view Yanbal products"
  on public.yanbal_products for select
  using (true);

drop policy if exists "Catalog owner can add products" on public.yanbal_products;
create policy "Catalog owner can add products"
  on public.yanbal_products for insert to authenticated
  with check (
    auth.uid() = (select owner_id from public.catalog_settings where id = true)
  );

drop policy if exists "Catalog owner can update products" on public.yanbal_products;
create policy "Catalog owner can update products"
  on public.yanbal_products for update to authenticated
  using (
    auth.uid() = (select owner_id from public.catalog_settings where id = true)
  )
  with check (
    auth.uid() = (select owner_id from public.catalog_settings where id = true)
  );

drop policy if exists "Catalog owner can delete products" on public.yanbal_products;
create policy "Catalog owner can delete products"
  on public.yanbal_products for delete to authenticated
  using (
    auth.uid() = (select owner_id from public.catalog_settings where id = true)
  );

create or replace function public.claim_catalog_admin(setup_code text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
begin
  if auth.uid() is null then
    raise exception 'You must sign in before claiming catalog ownership';
  end if;

  update public.catalog_settings
  set owner_id = auth.uid(), setup_code_hash = null
  where id = true
    and owner_id is null
    and setup_code_hash = encode(
      extensions.digest(convert_to($1, 'UTF8'), 'sha256'),
      'hex'
    );

  return found;
end;
$$;

revoke all on function public.claim_catalog_admin(text) from public, anon;
grant execute on function public.claim_catalog_admin(text) to authenticated;
