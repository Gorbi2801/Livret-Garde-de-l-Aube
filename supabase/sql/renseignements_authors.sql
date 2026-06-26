alter table public.mk_rens_rapports
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists created_by_name text,
  add column if not exists created_by_grade text;

create index if not exists mk_rens_rapports_created_by_idx
on public.mk_rens_rapports(created_by, created_at desc);

grant insert(created_by, created_by_name, created_by_grade) on public.mk_rens_rapports to authenticated;
