-- Drop existing policies on family_members table
DROP POLICY IF EXISTS "Family admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership" ON family_members;
DROP POLICY IF EXISTS "Family members can read family memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can insert own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own family memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can read memberships via families" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships directly" ON family_members;
DROP POLICY IF EXISTS "Family admins can manage other memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can read all memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can manage other user memberships" ON family_members;
DROP POLICY IF EXISTS "Family admins can delete other user memberships" ON family_members;
DROP POLICY IF EXISTS "Users can leave families" ON family_members;
DROP POLICY IF EXISTS "Members can see other members in same family" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership status" ON family_members;

-- Create minimal set of non-recursive policies

-- 1. Users can read their own memberships (direct user ID check)
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 2. Users can join families (insert with their own user ID)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- 3. Users can update their own membership
CREATE POLICY "Users can update own membership"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 4. Users can leave families (delete their own membership)
CREATE POLICY "Users can leave families"
  ON family_members
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- 5. Family creators can manage all memberships in their families
-- This uses a direct join to families table
CREATE POLICY "Family creators can manage memberships"
  ON family_members
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = family_members.family_id 
      AND families.created_by = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = family_members.family_id 
      AND families.created_by = auth.uid()
    )
  );

-- 6. Allow members to see other members in the same family
-- This uses a direct join to avoid recursion
CREATE POLICY "Members can see other members in same family"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    family_id IN (
      SELECT DISTINCT family_id FROM family_members
      WHERE user_id = auth.uid()
    )
  );

-- Fix policies on families table if needed
DROP POLICY IF EXISTS "Family members can read families" ON families;
DROP POLICY IF EXISTS "Users can view families they created" ON families;
DROP POLICY IF EXISTS "Users can view families they belong to" ON families;

-- Create direct policies for families table
-- Removed the IF NOT EXISTS clause which was causing the syntax error
CREATE POLICY "Users can view families they created"
  ON families
  FOR SELECT
  TO authenticated
  USING (created_by = auth.uid());

CREATE POLICY "Users can view families they belong to"
  ON families
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT DISTINCT family_id FROM family_members
      WHERE user_id = auth.uid()
    )
  );