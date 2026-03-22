# Freelancer Project Portal

A streamlined web portal that allows freelancers to share project progress, deliverables, and communicate with clients in one centralized location.

## Features

- **Project Dashboard**: Manage project status and updates
- **File Sharing**: Upload and share deliverables with clients
- **Client Communication**: Built-in commenting and feedback system
- **Timeline Tracking**: Milestone and project timeline management
- **User Management**: Separate freelancer and client accounts

## Tech Stack

- **Framework**: Next.js 15 with App Router
- **Authentication**: Supabase Auth
- **Database**: Supabase (PostgreSQL)
- **Styling**: Tailwind CSS
- **Language**: TypeScript

## Getting Started

### Prerequisites

- Node.js 18+ 
- A Supabase project

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd freelancer-project-portal
```

2. Install dependencies
```bash
npm install
```

3. Set up environment variables
```bash
cp .env.example .env.local
```

Update `.env.local` with your Supabase credentials:
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

4. Run database migrations
```bash
# Install Supabase CLI if you haven't already
npm install -g supabase

# Run migrations
supabase db push
```

5. Start the development server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## Project Structure

```
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── signup/
│   ├── dashboard/
│   ├── layout.tsx
│   └── page.tsx
├── lib/
│   └── supabase/
├── supabase/
│   └── migrations/
└── README.md
```

## Database Schema

The application uses the following main tables:

- `profiles` - User profiles (freelancers and clients)
- `projects` - Project information and status
- `project_files` - File uploads and deliverables
- `project_comments` - Communication and feedback
- `milestones` - Project timeline and milestones

## Features in Development

- Project creation and management interface
- File upload with drag-and-drop
- Real-time comments and notifications
- Advanced milestone tracking
- Client invitation system

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License.