-- Supabase Stories Table Setup
-- Run this in your Supabase SQL Editor

-- First, let's ensure the table exists with the correct structure
CREATE TABLE IF NOT EXISTS public.stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    summary TEXT,
    accuracy_assessment TEXT,
    accuracy_score INTEGER,
    propaganda_indicators TEXT,
    propaganda_score INTEGER,
    author_sources TEXT,
    author_source_bias TEXT,
    ai_sources TEXT,
    overall_metrics TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows anyone to read stories
CREATE POLICY "Allow public read access" ON public.stories
    FOR SELECT
    USING (true);

-- Create a policy that allows authenticated users to insert stories
CREATE POLICY "Allow authenticated insert" ON public.stories
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Create a policy that allows authenticated users to update their own stories
CREATE POLICY "Allow authenticated update" ON public.stories
    FOR UPDATE
    USING (auth.role() = 'authenticated');

-- Insert sample stories
INSERT INTO public.stories (summary, accuracy_assessment, accuracy_score, propaganda_indicators, propaganda_score, author_sources, author_source_bias, ai_sources, overall_metrics)
VALUES 
(
    'New Climate Report Shows Record High Global Temperatures',
    'The story accurately reflects recent climate data from multiple reputable sources including NASA and NOAA. Temperature records are properly cited and contextualized.',
    92,
    'Minimal emotional language detected. The story maintains objectivity while reporting facts.',
    15,
    'NASA Global Climate Change, NOAA Climate.gov, IPCC AR6 Report',
    'Scientific consensus sources with minimal political bias',
    'Cross-referenced with WMO climate database and peer-reviewed journals',
    'High accuracy, low propaganda risk. Reliable reporting on climate science.'
),
(
    'Tech Giant Announces Revolutionary AI Breakthrough',
    'Claims are partially verified. While the technology represents advancement, revolutionary claims are overstated compared to existing solutions.',
    68,
    'Significant use of superlatives and marketing language. Limited independent verification of claims.',
    55,
    'Company press release, tech blog coverage',
    'Heavy reliance on corporate sources, limited independent analysis',
    'Patent filings and technical papers suggest incremental rather than revolutionary advancement',
    'Moderate accuracy with elevated propaganda indicators. Exercise caution with extraordinary claims.'
),
(
    'Local Community Rallies to Save Historic Landmark',
    'Story accurately represents local events and community sentiment. Timeline and facts verified through multiple local sources.',
    88,
    'Some emotional appeals present but balanced with factual reporting. Multiple perspectives included.',
    25,
    'City council records, local newspaper archives, community organizer interviews',
    'Slight pro-preservation bias but includes development perspectives',
    'Historical records and property data confirm significance of landmark',
    'Good accuracy with minimal propaganda. Well-balanced local journalism.'
),
(
    'New Study Links Social Media Use to Mental Health Concerns',
    'Research findings are accurately represented. The study methodology is sound and published in a peer-reviewed journal.',
    85,
    'Balanced reporting with appropriate caveats about correlation vs causation.',
    20,
    'Journal of Psychology and Health, American Psychological Association',
    'Academic sources with established scientific credibility',
    'Meta-analysis of 50+ studies confirms consistent patterns',
    'Strong accuracy with minimal bias. Evidence-based health reporting.'
),
(
    'Political Leader Claims Economic Miracle Under Their Leadership',
    'Many claims are exaggerated or cherry-picked. Economic data shows mixed results with some positive trends but also concerning indicators.',
    45,
    'Heavy use of self-promotion and selective statistics. Omits contradictory economic data.',
    78,
    'Campaign speeches, partisan media outlets',
    'Sources show strong political bias favoring the leader',
    'Independent economic analysis reveals more nuanced picture',
    'Low accuracy, high propaganda risk. Politically motivated claims require fact-checking.'
);

-- Verify the data was inserted
SELECT COUNT(*) as total_stories FROM public.stories;
