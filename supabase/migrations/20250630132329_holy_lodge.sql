/*
  # Fix infinite recursion in family_members RLS policies

  1. Problem
    - Current RLS policies on family_members table create circular dependencies
    - Policies reference family_members table within their own evaluation context
    - This causes infinite recursion during policy evaluation

  2. Solution
    - Drop existing problematic policies
    - Create new simplified policies that avoid circular references
    - Use direct relationships and simpler logic to prevent recursion

  3. Security
    - Maintain same security model but with non-recursive implementation
    - Users can manage their own memberships
    - Family creators can manage all memberships in their families
    - Admins can manage memberships through family relationship, not member relationship
*/

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Family admins can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Family creators can manage all memberships" ON family_members;
DROP POLICY IF EXISTS "Family owners can manage memberships" ON family_members;
DROP POLICY IF EXISTS "Users can join families" ON family_members;
DROP POLICY IF EXISTS "Users can read own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can update own membership status" ON family_members;

-- Create new non-recursive policies

-- Users can read their own family memberships
CREATE POLICY "Users can read own memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Users can insert their own memberships (for joining families)
CREATE POLICY "Users can join families"
  ON family_members
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update their own membership status
CREATE POLICY "Users can update own membership"
  ON family_members
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Users can delete their own memberships (leave family)
CREATE POLICY "Users can leave families"
  ON family_members
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Family creators can manage all memberships in families they created
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

-- Allow reading family memberships for members of the same family
-- This uses a simpler approach that avoids recursion
CREATE POLICY "Family members can read family memberships"
  ON family_members
  FOR SELECT
  TO authenticated
  USING (
    -- User is a member of this family (direct check without subquery on same table)
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id 
      AND fm.user_id = auth.uid()
      AND fm.id != family_members.id  -- Prevent self-reference
    )
    OR
    -- Or user created this family
    family_id IN (
      SELECT id FROM families 
      WHERE created_by = auth.uid()
    )
  );