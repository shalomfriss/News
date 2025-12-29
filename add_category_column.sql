-- Add category column to stories table
-- Run this in your Supabase SQL Editor

-- Add the category column if it doesn't exist
ALTER TABLE public.stories 
ADD COLUMN IF NOT EXISTS category TEXT;

-- Update existing stories with sample categories
UPDATE public.stories 
SET category = CASE 
    WHEN summary LIKE '%Climate%' OR summary LIKE '%Global Temperatures%' THEN 'science'
    WHEN summary LIKE '%Tech%' OR summary LIKE '%AI%' THEN 'technology'
    WHEN summary LIKE '%Community%' OR summary LIKE '%Local%' OR summary LIKE '%Landmark%' THEN 'entertainment'
    WHEN summary LIKE '%Social Media%' OR summary LIKE '%Mental Health%' THEN 'health'
    WHEN summary LIKE '%Political%' OR summary LIKE '%Economic%' OR summary LIKE '%Leadership%' THEN 'business'
    ELSE NULL
END
WHERE category IS NULL;

-- Verify the update
SELECT category, COUNT(*) as count 
FROM public.stories 
GROUP BY category 
ORDER BY count DESC;
