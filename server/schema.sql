CREATE SCHEMA IF NOT EXISTS app_private;

-- Users table
create table app_private.users (
  id serial primary key,
  username text not null,
  verified boolean not null default false
);
alter table app_private.users enable row level security;
create policy select_all on app_private.users for select using (true);

-- CREATE TYPE timer_kind AS ENUM ('work', 'short_break', 'long_break');

-- See "Smoke and mirrors" in the README
create function app_private.current_user_id() returns int as $$
  -- Replace with: select nullif(current_setting('jwt.claims.user_id', true), '')::int;
  select 1;
$$ language sql stable;
-- This comment stops this function being exported to the GraphQL schema, see:
-- https://www.graphile.org/postgraphile/smart-comments/
-- comment on function current_user_id() is '@omit';


create table app_private.timers (
  id serial primary key,
  created_at timestamptz not null default now(),
  user_id int not null default app_private.current_user_id() references app_private.users,
  kind timer_kind not null
);


create or replace function active_timer()
returns app_private.timers
as $$
  select *
  from app_private.timers
  where app_private.timers.user_id = app_private.current_user_id()
  order by created_at desc
  limit 1;
$$ language sql stable;

comment on function active_timer() is
  'The current user\'s active timer (or null if there is no active timer).';


create or replace function start_timer(kind timer_kind)
returns app_private.timers
as $$
  select pg_notify(
  'postgraphile:timer',
  '{}'
);
  INSERT INTO app_private.timers (kind)
  values (
          kind
         )
         RETURNING app_private.timers
         ;
$$ LANGUAGE sql VOLATILE STRICT SECURITY DEFINER;


comment on function start_timer(kind timer_kind) is
  'Start a new `kind` timer for the current user.';
