-- Migration 001: Skema awal tabel kos dan Row Level Security (RLS) KosFinder v1

create table if not exists public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nama_kos text not null,
  alamat_lengkap text not null,
  area text not null,
  jenis text not null,
  harga_bulanan bigint not null,
  jumlah_kamar integer not null,
  fasilitas text[] not null default '{}',
  nomor_kontak text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint kos_nama_kos_not_empty check (char_length(btrim(nama_kos)) > 0),
  constraint kos_alamat_lengkap_not_empty check (char_length(btrim(alamat_lengkap)) > 0),
  constraint kos_area_not_empty check (char_length(btrim(area)) > 0),
  constraint kos_jenis_valid check (jenis in ('putra', 'putri', 'campur')),
  constraint kos_harga_bulanan_positive check (harga_bulanan > 0),
  constraint kos_jumlah_kamar_non_negative check (jumlah_kamar >= 0),
  constraint kos_fasilitas_allowed check (
    fasilitas <@ array['AC', 'WiFi', 'kamar mandi dalam', 'parkir']::text[]
  ),
  constraint kos_nomor_kontak_format check (
    nomor_kontak ~ '^(\+62|08)[0-9]+$'
  )
);

-- Indeks untuk performa pencarian, filter, dan daftar kos milik pemilik
create index if not exists idx_kos_owner_id on public.kos (owner_id);
create index if not exists idx_kos_jenis_harga on public.kos (jenis, harga_bulanan);
create index if not exists idx_kos_fasilitas_gin on public.kos using gin (fasilitas);

-- Perbarui updated_at otomatis saat UPDATE
create or replace function public.set_kos_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_kos_updated_at on public.kos;
create trigger trg_kos_updated_at
before update on public.kos
for each row
execute function public.set_kos_updated_at();

-- Aktifkan Row Level Security (RLS) dan hak akses tabel eksplisit
alter table public.kos enable row level security;

revoke all on table public.kos from public, anon, authenticated;
grant select on table public.kos to anon, authenticated;
grant insert, update, delete on table public.kos to authenticated;

-- Semua pengguna (tanpa login maupun sudah login) boleh membaca data kos publik
drop policy if exists "kos_select_public" on public.kos;
create policy "kos_select_public"
on public.kos
for select
to anon, authenticated
using (true);

-- Hanya pemilik yang terautentikasi boleh menambahkan kos miliknya sendiri
drop policy if exists "kos_insert_own" on public.kos;
create policy "kos_insert_own"
on public.kos
for insert
to authenticated
with check (auth.uid() = owner_id);

-- Hanya pemilik yang terautentikasi boleh mengubah kos miliknya sendiri
drop policy if exists "kos_update_own" on public.kos;
create policy "kos_update_own"
on public.kos
for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- Hanya pemilik yang terautentikasi boleh menghapus kos miliknya sendiri
drop policy if exists "kos_delete_own" on public.kos;
create policy "kos_delete_own"
on public.kos
for delete
to authenticated
using (auth.uid() = owner_id);
