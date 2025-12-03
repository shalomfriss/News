-- Diagnostic SQL for Supabase Stories Table
-- Run this in your Supabase SQL Editor to diagnose the issue

-- 1. Check if table exists and its structure
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'stories'
ORDER BY ordinal_position;

-- 2. Check RLS status
SELECT 
    schemaname,
    tablename, 
    rowsecurity
FROM pg_tables
WHERE tablename = 'stories';

-- 3. Check existing RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'stories';

-- 4. Count total rows in the table (bypassing RLS for this check)
SELECT COUNT(*) as total_rows FROM public.stories;

-- 5. Show first few rows (if any)
SELECT * FROM public.stories LIMIT 5;

-- 6. If RLS is blocking, you can temporarily check data with elevated privileges
-- This will show you what's actually in the table
SELECT 
    id,
    summary,
    accuracy_score,
    propaganda_score,
    created_at
FROM public.stories 
LIMIT 10;
