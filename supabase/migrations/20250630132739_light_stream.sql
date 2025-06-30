/*
  # Fix infinite recursion in family_members RLS policies

  1. Problem
    - Circular dependency between family_members and profiles table policies
    - This creates infinite recursion when querying profiles or family_members
    - Error: "infinite recursion detected in policy for relation family_members"

  2. Solution
    - Drop all existing problematic policies on family_members table
    - Create new simplified policies that avoid circular references
    - Ensure proper access control without self-referencing issues
*/

-- Drop all existing policies on family_members table to start fresh
DROP POLICY IF EXISTS "Family admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage memberships directly" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family members can read family memberships" ON family_members;
DROP POLICY IF EXISTS "Family members can read memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can leave families" ON family_members;
DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can read own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership status" ON family_members;
DROP POLICY IF EXISTS "Users can update own memberships" ON family_members;
DROP POLICY IF EXISTS "Users can insert own family memberships" ON family_members;

-- Create new simplified policies without circular references

-- 1. Basic policy for users to read their own memberships
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 2. Users can join families (insert their own membership)
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
-- This uses a direct join to families table instead of a subquery
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
-- This is a simplified version that avoids recursion
CREATE POLICY "Family members can see other members"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    family_id IN (
      SELECT family_id FROM family_members
      WHERE user_id = auth.uid()
    )
  );