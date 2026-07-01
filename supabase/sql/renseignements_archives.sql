-- Archivage des fiches de renseignements.
-- A lancer dans le SQL editor Supabase.

alter table public.mk_rens_fiches
  add column if not exists archived_at timestamptz,
  add column if not exists archived_by uuid references auth.users(id) on delete set null;

create index if not exists mk_rens_fiches_archived_idx
on public.mk_rens_fiches(archived_at desc)
where archived_at is not null;

create or replace function public.archive_rens_fiche(p_fiche_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.can_edit_section('renseignements') then
    raise exception 'Droit edition renseignements requis.'
      using errcode = '42501';
  end if;

  update public.mk_rens_fiches
  set archived_at = coalesce(archived_at, now()),
      archived_by = auth.uid()
  where id = p_fiche_id;

  if not found then
    raise exception 'Fiche introuvable.'
      using errcode = 'P0002';
  end if;
end;
$$;

create or replace function public.unarchive_rens_fiche(p_fiche_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.can_edit_section('renseignements') then
    raise exception 'Droit edition renseignements requis.'
      using errcode = '42501';
  end if;

  update public.mk_rens_fiches
  set archived_at = null,
      archived_by = null
  where id = p_fiche_id;

  if not found then
    raise exception 'Fiche introuvable.'
      using errcode = 'P0002';
  end if;
end;
$$;

revoke all on function public.archive_rens_fiche(uuid) from public;
revoke all on function public.unarchive_rens_fiche(uuid) from public;
grant execute on function public.archive_rens_fiche(uuid) to authenticated;
grant execute on function public.unarchive_rens_fiche(uuid) to authenticated;
