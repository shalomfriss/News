-- Check what columns actually exist in your stories table
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'stories'
ORDER BY ordinal_position;

-- Also count rows
SELECT COUNT(*) as total_rows FROM public.stories;
