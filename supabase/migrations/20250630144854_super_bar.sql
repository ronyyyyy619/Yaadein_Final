-- Drop all problematic policies on family_members table that might cause recursion
DO $$ 
BEGIN
  -- Drop all existing policies on family_members table
  DROP POLICY IF EXISTS "Users can view members in their families" ON family_members;
  DROP POLICY IF EXISTS "Users can view family members in shared families" ON family_members;
  DROP POLICY IF EXISTS "Users can see family members in their families" ON family_members;
  DROP POLICY IF EXISTS "Family members can see other members" ON family_members;
  DROP POLICY IF EXISTS "Members can see other members in same family" ON family_members;
  DROP POLICY IF EXISTS "Family members can read family memberships" ON family_members;
  DROP POLICY IF EXISTS "Family members can read memberships" ON family_members;
  DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
  DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
  DROP POLICY IF EXISTS "Users can join families" ON family_members;
  DROP POLICY IF EXISTS "Users can update own membership" ON family_members;
  DROP POLICY IF EXISTS "Users can leave families" ON family_members;
  DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
  DROP POLICY IF EXISTS "Allow users to read own memberships" ON family_members;
END $$;

-- Create a single, simple policy for reading family_members that won't cause recursion
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND schemaname = 'public' 
    AND policyname = 'Allow users to read own memberships'
  ) THEN
    EXECUTE 'CREATE POLICY "Allow users to read own memberships"
      ON family_members
      FOR SELECT
      TO authenticated
      USING (user_id = auth.uid())';
  END IF;
END $$;

-- Create a separate policy for family creators to manage memberships
-- This policy doesn't reference the family_members table in its condition
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND schemaname = 'public' 
    AND policyname = 'Family creators can manage all memberships'
  ) THEN
    EXECUTE 'CREATE POLICY "Family creators can manage all memberships"
      ON family_members
      FOR ALL
      TO authenticated
      USING (
        family_id IN (
          SELECT id FROM families 
          WHERE created_by = auth.uid()
        )
      )
      WITH CHECK (
        family_id IN (
          SELECT id FROM families 
          WHERE created_by = auth.uid()
        )
      )';
  END IF;
END $$;

-- Ensure other basic policies exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND schemaname = 'public' 
    AND policyname = 'Users can join families'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can join families"
      ON family_members
      FOR INSERT
      TO authenticated
      WITH CHECK (user_id = auth.uid())';
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND schemaname = 'public' 
    AND policyname = 'Users can update own membership'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can update own membership"
      ON family_members
      FOR UPDATE
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid())';
  END IF;
END $$;

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND schemaname = 'public' 
    AND policyname = 'Users can leave families'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can leave families"
      ON family_members
      FOR DELETE
      TO authenticated
      USING (user_id = auth.uid())';
  END IF;
END $$;