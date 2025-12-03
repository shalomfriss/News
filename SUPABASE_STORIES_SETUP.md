# Supabase Stories Setup Guide

This guide will help you set up the stories table in Supabase so you can see fact-checked stories in the app.

## Quick Setup (5 minutes)

### Step 1: Access Supabase Dashboard

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Log in to your account
3. Select your project: `nxfiplvukpehppydgseh`

### Step 2: Run the Setup SQL

1. In the left sidebar, click on **SQL Editor**
2. Click **New Query**
3. Copy the entire contents of `supabase_stories_setup.sql` file
4. Paste it into the SQL editor
5. Click **Run** (or press Cmd/Ctrl + Enter)

### Step 3: Verify the Setup

After running the SQL, you should see:
- ✅ Table `stories` created
- ✅ Row Level Security policies configured
- ✅ 5 sample stories inserted
- ✅ A message showing "total_stories: 5"

### Step 4: Test in the App

1. Restart your Flutter app
2. Log in
3. You should now see 5 fact-checked stories on the home screen!

## What the Setup Does

The SQL script:

1. **Creates the `stories` table** with these columns:
   - `id` (UUID) - Unique identifier
   - `summary` - Story headline/summary
   - `accuracy_assessment` - Detailed accuracy analysis
   - `accuracy_score` - Score from 0-100
   - `propaganda_indicators` - Analysis of propaganda techniques
   - `propaganda_score` - Score from 0-100 (higher = more propaganda)
   - `author_sources` - Original sources cited
   - `author_source_bias` - Bias assessment of sources
   - `ai_sources` - AI-verified cross-references
   - `overall_metrics` - Summary assessment
   - `created_at` / `updated_at` - Timestamps

2. **Configures Row Level Security (RLS)**:
   - Anyone can read stories (SELECT)
   - Only authenticated users can insert stories (INSERT)
   - Only authenticated users can update stories (UPDATE)

3. **Inserts 5 sample stories** covering:
   - Climate report (high accuracy, low propaganda)
   - Tech announcement (moderate accuracy, moderate propaganda)
   - Community news (good accuracy, low propaganda)
   - Health research (strong accuracy, minimal bias)
   - Political claims (low accuracy, high propaganda)

## Troubleshooting

### "No stories available" message
- Make sure you ran the SQL script successfully
- Check that the RLS policy allows public read access
- Verify in Supabase dashboard that stories exist: Table Editor → stories

### "Failed to load stories" error
- Check your internet connection
- Verify the Supabase URL and API key in `lib/main/main_development.dart`
- Check the Flutter debug console for detailed error messages

### Adding Your Own Stories

You can add more stories directly in Supabase:

1. Go to **Table Editor** in the Supabase dashboard
2. Select the `stories` table
3. Click **Insert row**
4. Fill in the fields (only `id` is required, it will auto-generate)
5. Click **Save**

Or use SQL:

```sql
INSERT INTO public.stories (
  summary, 
  accuracy_score, 
  propaganda_score
) VALUES (
  'Your story headline here',
  75,  -- accuracy score 0-100
  25   -- propaganda score 0-100
);
```

## Next Steps

- Add more stories to your database
- Implement story submission from the app
- Add categories or tags to filter stories
- Create a moderation system for user-submitted stories
