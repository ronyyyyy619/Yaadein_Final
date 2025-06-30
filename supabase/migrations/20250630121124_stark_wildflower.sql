/*
  # Fix RLS Policies to Avoid Infinite Recursion

  This migration fixes the infinite recursion issues in RLS policies
  by creating simpler policies that don't cause circular references.
*/

-- First check if the family_members table exists
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'family_members') THEN
    -- Drop all problematic policies that cause recursion
    DROP POLICY IF EXISTS "Family members can read families" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can read memberships via families" ON public.family_members;
    DROP POLICY IF EXISTS "Family creators can manage all memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family owners can manage all memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can manage memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family members can read memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can read all memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can manage other memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family owners can manage all memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can manage other user memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Family admins can delete other user memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Users can read own memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Users can join families" ON public.family_members;
    DROP POLICY IF EXISTS "Users can update own memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Users can read own family memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Users can insert own family memberships" ON public.family_members;
    DROP POLICY IF EXISTS "Users can update own family memberships" ON public.family_members;

    -- Create simplified policies that avoid recursion

    -- 1. Users can always read their own family memberships
    CREATE POLICY "Users can read own memberships"
      ON public.family_members
      FOR SELECT
      TO authenticated
      USING (user_id = auth.uid());

    -- 2. Users can insert their own family memberships (for joining families)
    CREATE POLICY "Users can join families"
      ON public.family_members
      FOR INSERT
      TO authenticated
      WITH CHECK (user_id = auth.uid());

    -- 3. Users can update their own family memberships
    CREATE POLICY "Users can update own memberships"
      ON public.family_members
      FOR UPDATE
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;

  -- Check if families table exists before creating policies for it
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'families') THEN
    -- Drop existing policies on families table
    DROP POLICY IF EXISTS "Users can view families they created" ON public.families;
    DROP POLICY IF EXISTS "Users can view families they belong to" ON public.families;
    
    -- Create direct policies for families table
    CREATE POLICY "Users can view families they created"
      ON public.families
      FOR SELECT
      TO authenticated
      USING (created_by = auth.uid());
      
    -- Create a policy for users to view families they're members of, if family_members exists
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'family_members') THEN
      CREATE POLICY "Users can view families they belong to"
        ON public.families
        FOR SELECT
        TO authenticated
        USING (
          id IN (
            SELECT family_id FROM public.family_members WHERE user_id = auth.uid()
          )
        );
    END IF;
  END IF;
  
  -- If family_members exists, create the policy for family creators
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'family_members') 
     AND EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'families') THEN
    
    CREATE POLICY "Family creators can manage memberships"
      ON public.family_members
      FOR ALL
      TO authenticated
      USING (
        EXISTS (
          SELECT 1 FROM public.families WHERE id = family_id AND created_by = auth.uid()
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.families WHERE id = family_id AND created_by = auth.uid()
        )
      );
  END IF;
END $$;