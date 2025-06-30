-- Drop all existing policies on family_members table to start fresh
DROP POLICY IF EXISTS "Users can view members in their families" ON family_members;
DROP POLICY IF EXISTS "Users can view family members in shared families" ON family_members;
DROP POLICY IF EXISTS "Users can see family members in their families" ON family_members;
DROP POLICY IF EXISTS "Family members can see other members" ON family_members;
DROP POLICY IF EXISTS "Members can see other members in same family" ON family_members;
DROP POLICY IF EXISTS "Family members can read family memberships" ON family_members;
DROP POLICY IF EXISTS "Family members can read memberships" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
DROP POLICY IF EXISTS "Allow users to read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership" ON family_members;
DROP POLICY IF EXISTS "Users can leave families" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners and admins can manage memberships" ON family_members;

-- Create a single, simple policy for reading family_members that won't cause recursion
-- This policy ONLY allows users to read their own memberships, with no circular dependency
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Create separate policies for other operations that don't cause recursion

-- Users can join families (insert their own membership)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update their own membership
CREATE POLICY "Users can update own membership"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can leave families (delete their own membership)
CREATE POLICY "Users can leave families"
  ON family_members
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Family creators can manage all memberships in their families
-- This policy doesn't reference the family_members table in its condition
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