-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  avatar_url text,
  user_type text check (user_type in ('freelancer', 'client')) default 'freelancer',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create projects table
create table public.projects (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  status text check (status in ('planning', 'in_progress', 'review', 'completed', 'cancelled')) default 'planning',
  freelancer_id uuid references public.profiles(id) on delete cascade not null,
  client_id uuid references public.profiles(id) on delete cascade,
  start_date date,
  end_date date,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create project_files table
create table public.project_files (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references public.projects(id) on delete cascade not null,
  file_name text not null,
  file_url text not null,
  file_size bigint,
  file_type text,
  uploaded_by uuid references public.profiles(id) on delete cascade not null,
  is_deliverable boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create project_comments table
create table public.project_comments (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references public.projects(id) on delete cascade not null,
  author_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create milestones table
create table public.milestones (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references public.projects(id) on delete cascade not null,
  title text not null,
  description text,
  due_date date,
  status text check (status in ('pending', 'completed')) default 'pending',
  order_index integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_files enable row level security;
alter table public.project_comments enable row level security;
alter table public.milestones enable row level security;

-- Create policies
create policy "Users can view own profile" on public.profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = id);

create policy "Users can insert own profile" on public.profiles
  for insert with check (auth.uid() = id);

-- Project policies
create policy "Freelancers can view their projects" on public.projects
  for select using (auth.uid() = freelancer_id);

create policy "Clients can view their projects" on public.projects
  for select using (auth.uid() = client_id);

create policy "Freelancers can create projects" on public.projects
  for insert with check (auth.uid() = freelancer_id);

create policy "Freelancers can update their projects" on public.projects
  for update using (auth.uid() = freelancer_id);

-- File policies
create policy "Project members can view files" on public.project_files
  for select using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and (p.freelancer_id = auth.uid() or p.client_id = auth.uid())
    )
  );

create policy "Project members can upload files" on public.project_files
  for insert with check (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and (p.freelancer_id = auth.uid() or p.client_id = auth.uid())
    )
    and auth.uid() = uploaded_by
  );

-- Comment policies
create policy "Project members can view comments" on public.project_comments
  for select using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and (p.freelancer_id = auth.uid() or p.client_id = auth.uid())
    )
  );

create policy "Project members can create comments" on public.project_comments
  for insert with check (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and (p.freelancer_id = auth.uid() or p.client_id = auth.uid())
    )
    and auth.uid() = author_id
  );

-- Milestone policies
create policy "Project members can view milestones" on public.milestones
  for select using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and (p.freelancer_id = auth.uid() or p.client_id = auth.uid())
    )
  );

create policy "Freelancers can manage milestones" on public.milestones
  for all using (
    exists (
      select 1 from public.projects p
      where p.id = project_id
      and p.freelancer_id = auth.uid()
    )
  );

-- Create function to automatically create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger for new user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();