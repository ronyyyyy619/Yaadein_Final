-- First, drop all problematic policies that might cause recursion
DROP POLICY IF EXISTS "Family members can read profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read profiles in their families" ON profiles;
DROP POLICY IF EXISTS "Family members can see other members" ON family_members;
DROP POLICY IF EXISTS "Members can see other members in same family" ON family_members;
DROP POLICY IF EXISTS "Users can see family members in their families" ON family_members;
DROP POLICY IF EXISTS "Family owners and admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership" ON family_members;
DROP POLICY IF EXISTS "Users can leave families" ON family_members;

-- Create a completely new set of policies that avoid recursion using DO blocks to check existence first

-- PROFILES TABLE POLICIES
DO $$ 
BEGIN
  -- 1. Users can always read their own profile
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND policyname = 'Users can read own profile'
  ) THEN
    CREATE POLICY "Users can read own profile"
      ON profiles
      FOR SELECT
      TO authenticated
      USING (id = auth.uid());
  END IF;

  -- 2. Users can update their own profile
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND policyname = 'Users can update own profile'
  ) THEN
    CREATE POLICY "Users can update own profile"
      ON profiles
      FOR UPDATE
      TO authenticated
      USING (id = auth.uid())
      WITH CHECK (id = auth.uid());
  END IF;

  -- 3. Users can insert their own profile
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND policyname = 'Users can insert own profile'
  ) THEN
    CREATE POLICY "Users can insert own profile"
      ON profiles
      FOR INSERT
      TO authenticated
      WITH CHECK (id = auth.uid());
  END IF;

  -- 4. Users can read profiles of family members
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND policyname = 'Users can read profiles in their families'
  ) THEN
    CREATE POLICY "Users can read profiles in their families"
      ON profiles
      FOR SELECT
      TO authenticated
      USING (
        (id = auth.uid()) OR 
        (id IN ( SELECT fm.user_id
                FROM family_members fm
                WHERE (fm.family_id IN ( SELECT fm2.family_id
                                        FROM family_members fm2
                                        WHERE (fm2.user_id = auth.uid())))))
      );
  END IF;
END $$;

-- FAMILY_MEMBERS TABLE POLICIES
DO $$ 
BEGIN
  -- 1. Basic policy for users to read their own memberships
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Users can read own memberships'
  ) THEN
    CREATE POLICY "Users can read own memberships"
      ON family_members
      FOR SELECT
      TO authenticated
      USING (user_id = auth.uid());
  END IF;

  -- 2. Users can join families (insert their own membership)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Users can join families'
  ) THEN
    CREATE POLICY "Users can join families"
      ON family_members
      FOR INSERT
      TO authenticated
      WITH CHECK (user_id = auth.uid());
  END IF;

  -- 3. Users can update their own membership
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Users can update own membership'
  ) THEN
    CREATE POLICY "Users can update own membership"
      ON family_members
      FOR UPDATE
      TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;

  -- 4. Users can leave families (delete their own membership)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Users can leave families'
  ) THEN
    CREATE POLICY "Users can leave families"
      ON family_members
      FOR DELETE
      TO authenticated
      USING (user_id = auth.uid());
  END IF;

  -- 5. Family creators can manage all memberships in their families
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Family creators can manage memberships'
  ) THEN
    CREATE POLICY "Family creators can manage memberships"
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
      );
  END IF;

  -- 6. Users can see other members in their families
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'family_members' 
    AND policyname = 'Users can see family members in their families'
  ) THEN
    CREATE POLICY "Users can see family members in their families"
      ON family_members
      FOR SELECT
      TO authenticated
      USING (
        family_id IN (
          SELECT DISTINCT family_id 
          FROM family_members 
          WHERE user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- FAMILIES TABLE POLICIES
DO $$ 
BEGIN
  -- 1. Users can view families they created
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'families' 
    AND policyname = 'Users can view families they created'
  ) THEN
    CREATE POLICY "Users can view families they created"
      ON families
      FOR SELECT
      TO authenticated
      USING (created_by = auth.uid());
  END IF;

  -- 2. Users can view families they belong to
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'families' 
    AND policyname = 'Users can view families they belong to'
  ) THEN
    CREATE POLICY "Users can view families they belong to"
      ON families
      FOR SELECT
      TO authenticated
      USING (
        id IN (
          SELECT DISTINCT family_id 
          FROM family_members 
          WHERE user_id = auth.uid()
        )
      );
  END IF;

  -- 3. Users can create families
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'families' 
    AND policyname = 'Authenticated users can create families'
  ) THEN
    CREATE POLICY "Authenticated users can create families"
      ON families
      FOR INSERT
      TO authenticated
      WITH CHECK (created_by = auth.uid());
  END IF;

  -- 4. Family creators can update their families
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'families' 
    AND policyname = 'Family creators can update families'
  ) THEN
    CREATE POLICY "Family creators can update families"
      ON families
      FOR UPDATE
      TO authenticated
      USING (created_by = auth.uid())
      WITH CHECK (created_by = auth.uid());
  END IF;

  -- 5. Family creators can delete their families
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'families' 
    AND policyname = 'Family creators can delete families'
  ) THEN
    CREATE POLICY "Family creators can delete families"
      ON families
      FOR DELETE
      TO authenticated
      USING (created_by = auth.uid());
  END IF;
END $$;